import 'package:flutter/material.dart';
import 'item_stat.dart';

class TaskStatsCard extends StatelessWidget {
  final int totalTasks;
  final int activeTasks;
  final int completedTasks;
  final double completionRate;

  const TaskStatsCard({
    super.key,
    required this.totalTasks,
    required this.activeTasks,
    required this.completedTasks,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
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
                  value: totalTasks.toString(),
                  icon: Icons.list_alt,
                  color: colorScheme.primary,
                ),
              ),
              Expanded(
                child: StatItem(
                  label: 'Active',
                  value: activeTasks.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: StatItem(
                  label: 'Done',
                  value: completedTasks.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
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
                    '${(completionRate * 100).toInt()}%',
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
                value: completionRate,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
