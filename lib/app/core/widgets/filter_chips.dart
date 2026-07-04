import 'package:flutter/material.dart';
import 'package:myapp/app/core/constants/enums/task_filter.dart';
import '../utils/extension/task_filter.dart';

class TaskFilterChips extends StatelessWidget {
  final TaskFilter currentFilter;
  final ValueChanged<TaskFilter> onFilterSelected;

  const TaskFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TaskFilter.values.map((filter) {
            final isSelected = currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.displayName),
                selected: isSelected,
                onSelected: (_) => onFilterSelected(filter),
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
