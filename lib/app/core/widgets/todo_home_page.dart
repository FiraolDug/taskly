import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/app/core/constants/enums/task_filter.dart';
import 'package:myapp/app/core/constants/enums/task_priority.dart';
import 'package:myapp/app/core/widgets/app_bar.dart';
import 'package:myapp/app/core/widgets/filter_chips.dart';
import 'package:myapp/app/core/widgets/search_bar.dart';
import 'package:myapp/app/core/widgets/task_input_row.dart';
import 'package:myapp/app/core/widgets/task_list.dart';
import 'package:myapp/app/core/widgets/task_stats_card.dart';
import 'package:myapp/app/core/widgets/task_edit_sheet.dart';
import 'package:myapp/app/modal/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage>
    with TickerProviderStateMixin {
  final _taskController = TextEditingController();
  final _searchController = TextEditingController();
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  SharedPreferences? _prefs;
  Task? _recentlyDeletedTask;
  int? _recentlyDeletedTaskIndex;

  // Filter states
  TaskFilter _currentFilter = TaskFilter.all;
  String _searchQuery = '';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Task statistics
  int get _totalTasks => _tasks.length;
  int get _completedTasks => _tasks.where((t) => t.done).length;
  int get _activeTasks => _totalTasks - _completedTasks;
  double get _completionRate =>
      _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          if (!task.text.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }

        // Apply status filter
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

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Task cannot be empty!', isError: true);
      return;
    }

    setState(() {
      _tasks.insert(
        0,
        Task(
          text: text,
          done: false,
          createdAt: DateTime.now(),
          priority: TaskPriority.medium,
        ),
      );
      _taskController.clear();
      _applyFilters();
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
        'Deleted "${_recentlyDeletedTask!.text}"',
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
    final task = _filteredTasks[index];
    _taskController.text = task.text;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditSheet(
        task: task,
        onSave: (updatedTask) {
          final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
          if (taskIndex != -1) {
            setState(() {
              _tasks[taskIndex] = updatedTask;
              _applyFilters();
            });
            _saveTasks();
            _showSnackBar('Task updated successfully!');
          }
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: TasklyAppBar(
        showMenu: _tasks.isNotEmpty,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_taskController.text.trim().isEmpty) {
            _showSnackBar('Task cannot be empty!', isError: true);
            return;
          }
          _addTask();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_tasks.isNotEmpty)
            TaskStatsCard(
              totalTasks: _totalTasks,
              activeTasks: _activeTasks,
              completedTasks: _completedTasks,
              completionRate: _completionRate,
            ),
          if (_tasks.isNotEmpty)
            TaskSearchBar(
              controller: _searchController,
              searchQuery: _searchQuery,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
              onClear: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _applyFilters();
                });
              },
            ),
          if (_tasks.isNotEmpty)
            TaskFilterChips(
              currentFilter: _currentFilter,
              onFilterSelected: (filter) {
                setState(() {
                  _currentFilter = filter;
                  _applyFilters();
                });
              },
            ),
          const SizedBox(height: 16),
          TaskInputRow(
            controller: _taskController,
            onAdd: _addTask,
            onSubmitted: (_) => _addTask(),
          ),

          const SizedBox(height: 16),

          // Task List
          Expanded(
            child: TaskList(
              filteredTasks: _filteredTasks,
              hasTasks: _tasks.isNotEmpty,
              onToggle: _toggleDone,
              onDelete: _deleteTask,
              onEdit: _editTask,
            ),
          ),
        ],
      ),
    );
  }
}
