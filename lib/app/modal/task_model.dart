import '../core/constants/enums/task_priority.dart';

class Task {
  final String id;
  String taskName;
  String description;
  bool done;
  final DateTime createdAt;
  DateTime? completedAt;
  TaskPriority priority;
  DateTime? dueDate;

  Task({
    String? id,
    required this.taskName,
    required this.description,
    required this.done,
    DateTime? createdAt,
    this.completedAt,
    this.priority = TaskPriority.medium,
    this.dueDate,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskName': taskName,
    'description': description,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'priority': priority.index,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    taskName: json['taskName'],
    description: json['description'],
    done: json['done'],
    createdAt: DateTime.parse(json['createdAt']),
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'])
        : null,
    priority: TaskPriority.values[json['priority'] ?? 1],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
  );
}
