import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String priority;
  final bool completed;
  final String assignee;
  final String type;
  final String projectName;
  final List<Task> subtasks;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.completed,
    required this.assignee,
    required this.type,
    required this.projectName,
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
      assignee: data['assignee'] ?? '',
      priority: data['priority'] ?? '',
      completed: data['completed'] ?? false,
      projectName: data['projectName'] ?? '',
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
      assignee: data['assignee'] ?? '',
      projectName: data['projectName'] ?? '',
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
    String? assignee,
    String? type,
    String? projectName,
    bool? completed,
    List<Task>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      assignee: assignee ?? this.assignee,
      type: type ?? this.type,
      projectName: projectName ?? this.projectName,
      completed: completed ?? this.completed,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
