import 'package:flutter/material.dart';

import '../widgets/task_form.dart';
import '../../modal/task_model.dart';

class AddTaskScreen extends StatelessWidget {
  final void Function(Task) onTaskAdded;

  const AddTaskScreen({super.key, required this.onTaskAdded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: const Text('Add Task'),
      ),
      body: SafeArea(child: TaskForm(isEditing: false, onSave: onTaskAdded)),
    );
  }
}
