import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String avatar;
  final bool completed;
  final List<Task> subtasks;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.avatar,
    required this.completed,
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
      avatar: data['avatar'] ?? '',
      completed: data['completed'] ?? false,
      subtasks: [], // Subtasks sẽ được thêm sau
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? dueDate,
    String? avatar,
    bool? completed,
    List<Task>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      avatar: avatar ?? this.avatar,
      completed: completed ?? this.completed,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
