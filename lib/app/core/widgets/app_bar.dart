import 'package:flutter/material.dart';

class TasklyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenu;
  final void Function(String) onSelected;

  const TasklyAppBar({
    super.key,
    required this.showMenu,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: const Text(
        'Taskly',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      actions: [
        if (showMenu)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: onSelected,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
