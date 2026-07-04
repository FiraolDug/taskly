import 'package:flutter/material.dart';

class TasklyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenu;
  final void Function(String) onSelected;
  final VoidCallback? onAdd;

  const TasklyAppBar({
    super.key,
    required this.showMenu,
    required this.onSelected,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      titleSpacing: 20,
      toolbarHeight: 72,
      title: Text(
        'Taskly',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      foregroundColor: colorScheme.onSurface,
      shape: Border(
        bottom: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.45),
          width: 1,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            tooltip: 'Add task',
            icon: const Icon(Icons.add_rounded),
            onPressed: onAdd,
          ),
        ),
        if (showMenu)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              tooltip: 'More options',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: onSelected,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_done',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded),
                      SizedBox(width: 8),
                      Text('Mark all as done'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete_completed',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_rounded),
                      SizedBox(width: 8),
                      Text('Delete completed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
