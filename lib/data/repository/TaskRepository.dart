import 'package:bee_task/screen/TaskData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class TaskRepository {
  FirebaseAuth get firebaseAuth;
  Future<List<Map<String, dynamic>>> fetchTasksByDate(
      String date, String email);
  Future<void> addTask(Map<String, dynamic> task);
  Future<void> updateTask(String taskId, Map<String, dynamic> updatedTask);
  Future<void> deleteTask(String taskId);
}

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseTaskRepository({required this.firestore});

  @override
  FirebaseAuth get firebaseAuth => _firebaseAuth;

  List<Map<String, dynamic>> tasks = TaskData().tasks;
  List<Map<String, dynamic>> subtasks = TaskData().subtasks;
  List<Map<String, dynamic>> subsubtasks = TaskData().subsubtasks;
  List<Map<String, dynamic>> users = TaskData().users;

  @override
  Future<List<Map<String, dynamic>>> fetchTasksByDate(
      String date, String email) async {
    try {
      List<Map<String, dynamic>> allTasks = [];

      // Tạo các Future để chạy song song
      var tasksFuture = Future(() {
        return tasks.where((task) => task['dueDate'] == date).map((task) {
          task['type'] = 'task';
          return task;
        }).toList();
      });

      var subtasksFuture = Future(() {
        return subtasks
            .where((subtask) => subtask['dueDate'] == date)
            .map((subtask) {
          subtask['type'] = 'subtask';
          return subtask;
        }).toList();
      });

      var subsubtasksFuture = Future(() {
        return subsubtasks
            .where((subsubtask) => subsubtask['dueDate'] == date)
            .map((subsubtask) {
          subsubtask['type'] = 'subsubtask';
          return subsubtask;
        }).toList();
      });

      // Chạy song song các Future
      var results =
          await Future.wait([tasksFuture, subtasksFuture, subsubtasksFuture]);

      // Kết hợp các kết quả lại với nhau
      allTasks.addAll(results[0]);
      allTasks.addAll(results[1]);
      allTasks.addAll(results[2]);
      return allTasks;
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    try {
      await firestore.collection('tasks').add(task);
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }

  Future<void> updateTask(
      String taskId, Map<String, dynamic> updatedTask) async {
    try {
      await firestore.collection('tasks').doc(taskId).update(updatedTask);
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }
}
