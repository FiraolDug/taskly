import 'package:flutter/material.dart';
import './empty_state.dart';
import './task_card.dart';
import '../../modal/task_model.dart';

class TaskList extends StatelessWidget {
  final List<Task> filteredTasks;
  final bool hasTasks;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onEdit;

  const TaskList({
    super.key,
    required this.filteredTasks,
    required this.hasTasks,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredTasks.isEmpty) {
      return TaskEmptyState(hasTasks: hasTasks);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return TaskCard(
          task: task,
          onToggle: () => onToggle(index),
          onDelete: () => onDelete(index),
          onEdit: () => onEdit(index),
        );
      },
    );
  }
}
