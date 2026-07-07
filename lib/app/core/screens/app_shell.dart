import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/enums/task_filter.dart';
import '../../modal/task_model.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/taskly_bottom_navigation_bar.dart';
import '../widgets/todo_home_page.dart';
import 'add_task_screen.dart';
import 'my_tasks_screen.dart';
import 'performance_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  SharedPreferences? _prefs;
  Task? _recentlyDeletedTask;
  int? _recentlyDeletedTaskIndex;

  int get _totalTasks => _tasks.length;
  int get _completedTasks => _tasks.where((task) => task.done).length;
  int get _activeTasks => _totalTasks - _completedTasks;
  double get _completionRate =>
      _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    _prefs = await SharedPreferences.getInstance();
    final String? tasksString = _prefs?.getString('tasks');
    if (tasksString != null) {
      final List decoded = jsonDecode(tasksString);
      setState(() {
        _tasks = decoded.map((e) => Task.fromJson(e)).toList();
        _applyFilters();
      });
    }
  }

  Future<void> _saveTasks() async {
    final String encoded = jsonEncode(_tasks.map((e) => e.toJson()).toList());
    await _prefs?.setString('tasks', encoded);
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        if (_searchQuery.isNotEmpty) {
          if (!task.taskName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          )) {
            return false;
          }
        }

        switch (_currentFilter) {
          case TaskFilter.all:
            return true;
          case TaskFilter.active:
            return !task.done;
          case TaskFilter.completed:
            return task.done;
        }
      }).toList();
    });
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.insert(0, task);
      _applyFilters();
      _currentIndex = 0;
    });
    _saveTasks();
    _showSnackBar('Task added successfully!');
  }

  void _toggleDone(int index) {
    final taskIndex = _tasks.indexWhere(
      (t) => t.id == _filteredTasks[index].id,
    );
    if (taskIndex != -1) {
      setState(() {
        _tasks[taskIndex].done = !_tasks[taskIndex].done;
        _tasks[taskIndex].completedAt = _tasks[taskIndex].done
            ? DateTime.now()
            : null;
        _applyFilters();
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index) {
    final taskIndex = _tasks.indexWhere(
      (t) => t.id == _filteredTasks[index].id,
    );
    if (taskIndex != -1) {
      setState(() {
        _recentlyDeletedTask = _tasks.removeAt(taskIndex);
        _recentlyDeletedTaskIndex = taskIndex;
        _applyFilters();
      });
      _saveTasks();
      _showSnackBar(
        'Deleted "${_recentlyDeletedTask!.taskName}"',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (_recentlyDeletedTask != null &&
                _recentlyDeletedTaskIndex != null) {
              setState(() {
                _tasks.insert(
                  _recentlyDeletedTaskIndex!,
                  _recentlyDeletedTask!,
                );
                _applyFilters();
              });
              _saveTasks();
            }
          },
        ),
      );
    }
  }

  void _editTask(int index) {
    _showTaskSheet(task: _filteredTasks[index]);
  }

  void _deleteAllCompleted() {
    if (_completedTasks == 0) {
      _showSnackBar('No completed tasks to delete!');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Completed Tasks'),
        content: Text(
          'Are you sure you want to delete $_completedTasks completed task${_completedTasks == 1 ? '' : 's'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tasks.removeWhere((task) => task.done);
                _applyFilters();
              });
              _saveTasks();
              Navigator.of(context).pop();
              _showSnackBar('Completed tasks deleted!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markAllAsDone() {
    if (_activeTasks == 0) {
      _showSnackBar('No active tasks to mark as done!');
      return;
    }

    setState(() {
      for (var task in _tasks) {
        if (!task.done) {
          task.done = true;
          task.completedAt = DateTime.now();
        }
      }
      _applyFilters();
    });
    _saveTasks();
    _showSnackBar('All tasks marked as completed!');
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showTaskSheet({Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditSheet(
        task: task,
        isEditing: task != null,
        onSave: (savedTask) {
          if (task == null) {
            _addTask(savedTask);
          } else {
            final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
            if (taskIndex != -1) {
              setState(() {
                _tasks[taskIndex] = savedTask;
                _applyFilters();
              });
              _saveTasks();
              _showSnackBar('Task updated successfully!');
            }
          }
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onClearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _applyFilters();
    });
  }

  void _onFilterSelected(TaskFilter filter) {
    setState(() {
      _currentFilter = filter;
      _applyFilters();
    });
  }

  void _onNavigationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TodoHomePage(
            tasks: _tasks,
            filteredTasks: _filteredTasks,
            totalTasks: _totalTasks,
            activeTasks: _activeTasks,
            completedTasks: _completedTasks,
            completionRate: _completionRate,
            currentFilter: _currentFilter,
            searchQuery: _searchQuery,
            searchController: _searchController,
            showMenu: _tasks.isNotEmpty,
            onAdd: () => _showTaskSheet(),
            onSelected: (value) {
              switch (value) {
                case 'delete_completed':
                  _deleteAllCompleted();
                  break;
                case 'mark_all_done':
                  _markAllAsDone();
                  break;
              }
            },
            onSearchChanged: _onSearchChanged,
            onClearSearch: _onClearSearch,
            onFilterSelected: _onFilterSelected,
            onToggle: _toggleDone,
            onDelete: _deleteTask,
            onEdit: _editTask,
          ),
          MyTasksScreen(
            tasks: _tasks,
            onToggle: _toggleDone,
            onDelete: _deleteTask,
            onEdit: _editTask,
          ),
          AddTaskScreen(onTaskAdded: _addTask),
          const PerformanceScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: TasklyBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationSelected,
      ),
    );
  }
}
