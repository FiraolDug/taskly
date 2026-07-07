import 'package:flutter/material.dart';
import '../../modal/task_model.dart';
import '../constants/enums/task_priority.dart';
import '../utils/formatter/date_formatter.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.done;

    final priorityColor = switch (task.priority) {
      TaskPriority.high => colorScheme.error,
      TaskPriority.medium => colorScheme.tertiary,
      TaskPriority.low => colorScheme.primary,
    };

    final priorityLabel = switch (task.priority) {
      TaskPriority.high => 'High',
      TaskPriority.medium => 'Medium',
      TaskPriority.low => 'Low',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? colorScheme.error.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Checkbox(
          value: task.done,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          task.taskName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              textTheme.bodyMedium?.copyWith(
                decoration: task.done ? TextDecoration.lineThrough : null,
                color: task.done
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
                fontWeight: task.done ? FontWeight.normal : FontWeight.w500,
              ) ??
              TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null,
                color: task.done
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
                fontWeight: task.done ? FontWeight.normal : FontWeight.w500,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: isOverdue
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(task.dueDate!),
                    style:
                        textTheme.bodySmall?.copyWith(
                          color: isOverdue
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ) ??
                        TextStyle(
                          color: isOverdue
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
            if (task.priority != TaskPriority.medium) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    task.priority == TaskPriority.high
                        ? Icons.priority_high
                        : Icons.low_priority,
                    size: 14,
                    color: priorityColor,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      priorityLabel,
                      style:
                          textTheme.labelSmall?.copyWith(
                            color: priorityColor,
                            fontWeight: FontWeight.w600,
                          ) ??
                          TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              color: colorScheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
