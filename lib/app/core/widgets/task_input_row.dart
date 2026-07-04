import 'package:flutter/material.dart';

class TaskInputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onSubmitted;

  const TaskInputRow({
    super.key,
    required this.controller,
    required this.onAdd,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
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
              onSubmitted: onSubmitted,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: onAdd,
            mini: true,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
