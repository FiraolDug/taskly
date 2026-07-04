import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/app.dart';
import 'package:myapp/app/core/constants/enums/task_filter.dart';
import 'package:myapp/app/core/constants/enums/task_priority.dart';
import 'package:myapp/app/core/widgets/task_edit_sheet.dart';
import 'package:myapp/app/modal/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './item_stat.dart';
import './task_card.dart';

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
  double get _completionRate => _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;

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
      _tasks.insert(0, Task(
        text: text,
        done: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
      ));
      _taskController.clear();
      _applyFilters();
    });
    _saveTasks();
    _showSnackBar('Task added successfully!');
  }

  void _toggleDone(int index) {
    final taskIndex = _tasks.indexWhere((t) => t.id == _filteredTasks[index].id);
    if (taskIndex != -1) {
      setState(() {
        _tasks[taskIndex].done = !_tasks[taskIndex].done;
        _tasks[taskIndex].completedAt = _tasks[taskIndex].done ? DateTime.now() : null;
        _applyFilters();
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index) {
    final taskIndex = _tasks.indexWhere((t) => t.id == _filteredTasks[index].id);
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
            if (_recentlyDeletedTask != null && _recentlyDeletedTaskIndex != null) {
              setState(() {
                _tasks.insert(_recentlyDeletedTaskIndex!, _recentlyDeletedTask!);
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
        content: Text('Are you sure you want to delete $_completedTasks completed task${_completedTasks == 1 ? '' : 's'}?'),
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

  void _showSnackBar(String message, {bool isError = false, SnackBarAction? action}) {
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
      appBar: AppBar(
        title: const Text(
          'Smart ToDo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          if (_tasks.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
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
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_done',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text('Mark all as done'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete_completed',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep),
                      SizedBox(width: 8),
                      Text('Delete completed'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          if (_tasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StatItem(
                      label: 'Total',
                      value: _totalTasks.toString(),
                      icon: Icons.list_alt,
                      color: colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: StatItem(
                      label: 'Active',
                      value: _activeTasks.toString(),
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: StatItem(
                      label: 'Done',
                      value: _completedTasks.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          
          // Progress Bar
          if (_tasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(_completionRate * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _completionRate,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          
          // Search Bar
          if (_tasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _applyFilters();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _applyFilters();
                  });
                },
              ),
            ),
          
          // Filter Chips
          if (_tasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskFilter.values.map((filter) {
                    final isSelected = _currentFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _currentFilter = filter;
                            _applyFilters();
                          });
                        },
                        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Task Input
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Add a new task...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _addTask,
                  mini: true,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Task List
          Expanded(
            child: _filteredTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onToggle: () => _toggleDone(index),
                        onDelete: () => _deleteTask(index),
                        onEdit: () => _editTask(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first task to get started',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
  }
}
