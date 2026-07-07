import 'package:flutter/material.dart';

import '../constants/enums/task_priority.dart';
import '../utils/extension/task_priority.dart';
import '../../modal/task_model.dart';

class TaskForm extends StatefulWidget {
  final bool isEditing;
  final Function(Task) onSave;
  final Task? task;

  const TaskForm({
    super.key,
    required this.isEditing,
    required this.onSave,
    this.task,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.taskName ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isEditing ? 'Edit Task' : 'Add Task',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task title',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            maxLines: 1,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Task description',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Priority',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TaskPriority.values.map((priority) {
              return ChoiceChip(
                label: Text(priority.displayName),
                selected: _priority == priority,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _priority = priority);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Due Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _dueDate = date);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_dueDate == null ? 'Set due date' : 'Change date'),
              ),
            ],
          ),
          if (_dueDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Due: ${_formatDate(_dueDate!)}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dueDate = null),
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    final description = _descriptionController.text.trim();
                    if (title.isEmpty) {
                      return;
                    }

                    final savedTask = widget.isEditing && widget.task != null
                        ? Task(
                            id: widget.task!.id,
                            taskName: title,
                            description: description,
                            done: widget.task!.done,
                            createdAt: widget.task!.createdAt,
                            completedAt: widget.task!.completedAt,
                            priority: _priority,
                            dueDate: _dueDate,
                          )
                        : Task(
                            taskName: title,
                            description: description,
                            done: false,
                            createdAt: DateTime.now(),
                            priority: _priority,
                            dueDate: _dueDate,
                          );

                    widget.onSave(savedTask);
                    Navigator.of(context).pop();
                  },
                  child: Text(widget.isEditing ? 'Save' : 'Add Task'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
