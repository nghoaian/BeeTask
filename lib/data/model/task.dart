import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String priority;
  final bool completed;
  final String asssignee;
  final String type;
  final List<Task> subtasks;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.completed,
    required this.asssignee,
    required this.type,
    required this.subtasks,
  });

  factory Task.fromFirestore(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: data['dueDate'] is Timestamp
          ? (data['dueDate'] as Timestamp)
              .toDate()
              .toString() // Nếu là Timestamp, chuyển đổi thành DateTime
          : data['dueDate'] ?? '',
      asssignee: data['asssignee'] ?? '',
      priority: data['priority'] ?? '',
      completed: data['completed'] ?? false,
      type: data['type'] ?? '',
      subtasks: [], // Subtasks sẽ được thêm sau
    );
  }
  factory Task.copyTasks(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: data['dueDate'] is Timestamp
          ? (data['dueDate'] as Timestamp)
              .toDate()
              .toString() // Nếu là Timestamp, chuyển đổi thành DateTime
          : data['dueDate'] ?? '',
      priority: data['priority'] ?? '',
      asssignee: data['asssignee'] ?? '',
      completed: data['completed'] ?? false,
      type: data['type'] ?? '',
      subtasks: data['subtasks'] ?? data['subsubtasks'] ?? [],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? dueDate,
    String? priority,
    String? avatar,
    String? type,
    bool? completed,
    List<Task>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      asssignee: asssignee ?? this.asssignee,
      type: type ?? this.type,
      completed: completed ?? this.completed,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
