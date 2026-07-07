import 'package:flutter/material.dart';

import '../widgets/task_list.dart';
import '../../modal/task_model.dart';

class MyTasksScreen extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onEdit;

  const MyTasksScreen({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: const Text('My Tasks'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'All tasks in one place',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: TaskList(
              filteredTasks: tasks,
              hasTasks: tasks.isNotEmpty,
              onToggle: onToggle,
              onDelete: onDelete,
              onEdit: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}
