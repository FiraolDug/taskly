import '../core/constants/enums/task_priority.dart';
class Task {
  final String id;
  String text;
  bool done;
  final DateTime createdAt;
  DateTime? completedAt;
  TaskPriority priority;
  DateTime? dueDate;

  Task({
    String? id,
    required this.text,
    required this.done,
    DateTime? createdAt,
    this.completedAt,
    this.priority = TaskPriority.medium,
    this.dueDate,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'priority': priority.index,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    text: json['text'],
    done: json['done'],
    createdAt: DateTime.parse(json['createdAt']),
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt']) 
        : null,
    priority: TaskPriority.values[json['priority'] ?? 1],
    dueDate: json['dueDate'] != null 
        ? DateTime.parse(json['dueDate']) 
        : null,
  );
}
