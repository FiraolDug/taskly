import 'package:flutter/material.dart';

class TaskEmptyState extends StatelessWidget {
  final bool hasTasks;

  const TaskEmptyState({super.key, required this.hasTasks});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = hasTasks ? Icons.search_off : Icons.task_alt;
    final title = hasTasks ? 'No tasks found' : 'No tasks yet!';
    final message = hasTasks
        ? 'Try adjusting your search or filters'
        : 'Add your first task to get started';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
