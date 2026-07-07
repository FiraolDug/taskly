import 'package:flutter/material.dart';
import '../constants/enums/task_filter.dart';
import './app_bar.dart';
import './filter_chips.dart';
import './search_bar.dart';
import './task_list.dart';
import './task_stats_card.dart';
import '../../modal/task_model.dart';

class TodoHomePage extends StatelessWidget {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final int totalTasks;
  final int activeTasks;
  final int completedTasks;
  final double completionRate;
  final TaskFilter currentFilter;
  final String searchQuery;
  final TextEditingController searchController;
  final bool showMenu;
  final VoidCallback onAdd;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<TaskFilter> onFilterSelected;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onEdit;

  const TodoHomePage({
    super.key,
    required this.tasks,
    required this.filteredTasks,
    required this.totalTasks,
    required this.activeTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.currentFilter,
    required this.searchQuery,
    required this.searchController,
    required this.showMenu,
    required this.onAdd,
    required this.onSelected,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterSelected,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: TasklyAppBar(
        showMenu: showMenu,
        onAdd: onAdd,
        onSelected: onSelected,
      ),
      body: Column(
        children: [
          if (tasks.isNotEmpty)
            TaskStatsCard(
              totalTasks: totalTasks,
              activeTasks: activeTasks,
              completedTasks: completedTasks,
              completionRate: completionRate,
            ),
          if (tasks.isNotEmpty)
            TaskSearchBar(
              controller: searchController,
              searchQuery: searchQuery,
              onChanged: onSearchChanged,
              onClear: onClearSearch,
            ),
          if (tasks.isNotEmpty)
            TaskFilterChips(
              currentFilter: currentFilter,
              onFilterSelected: onFilterSelected,
            ),
          const SizedBox(height: 16),
          Expanded(
            child: TaskList(
              filteredTasks: filteredTasks,
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
