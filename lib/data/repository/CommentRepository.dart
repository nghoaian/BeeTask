import 'package:bee_task/screen/TaskData.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

abstract class CommentRepository {
  FirebaseAuth get firebaseAuth;
  Future<void> addComment(
    String id,
    String type,
    String author,
    String content,
  );
  Future<void> editComment(
    String commentId,
    String id,
    String type,
    String content,
  );

  Future<void> deleteComment(
    String commentId,
    String id,
    String type,
  );
  Future<List<Map<String, dynamic>>> getComments(
    String id,
    String type,
  );
}

class FirebaseCommentRepository implements CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseCommentRepository();

  @override
  FirebaseAuth get firebaseAuth => _firebaseAuth;

  List<Map<String, dynamic>> tasks = TaskData().tasks;
  List<Map<String, dynamic>> subtasks = TaskData().subtasks;
  List<Map<String, dynamic>> subsubtasks = TaskData().subsubtasks;
  List<Map<String, dynamic>> users = TaskData().users;
  List<Map<String, dynamic>> pr = TaskData().users;
  Future<void> addComment(
      String id, String type, String author, String content) async {
    try {
      String path = '';

      // Xây dựng đường dẫn dựa trên type
      if (type == 'task') {
        var taskData = tasks.firstWhere((task) => task['id'] == id);
        path = 'projects/${taskData['projectId']}/tasks/$id';
      } else if (type == 'subtask') {
        var subtaskData = subtasks.firstWhere((task) => task['id'] == id);
        path =
            'projects/${subtaskData['projectId']}/tasks/${subtaskData['taskId']}/subtasks/$id';
      } else if (type == 'subsubtask') {
        var subsubtaskData = subsubtasks.firstWhere((task) => task['id'] == id);
        path =
            'projects/${subsubtaskData['projectId']}/tasks/${subsubtaskData['taskId']}/subtasks/${subsubtaskData['subtaskId']}/subsubtasks/$id';
      } else {
        throw Exception('Invalid type or id');
      }

      // Lấy danh sách comments từ Firestore
      var commentsSnapshot =
          await FirebaseFirestore.instance.doc(path).collection('comments');

      Map<String, dynamic> comment = {
        'author': author,
        'text': content ?? null,
        'date': DateFormat('dd/MM/yyyy, HH:mm')
            .format(DateTime.now()), // Định dạng ngày/tháng/năm, giờ
      };

      await commentsSnapshot.add(comment);
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  // Chỉnh sửa comment
  Future<void> editComment(
      String commentId, String id, String type, String content) async {
    try {
      var taskData = tasks.firstWhere((task) => task['id'] == id);

      var commentRef = _firestore
          .collection('projects')
          .doc(taskData['projectId'])
          .collection('tasks')
          .doc(taskData['id'])
          .collection('comments')
          .doc(commentId);

      Map<String, dynamic> updatedComment = {
        'text': content ?? null,
      };

      await commentRef.update(updatedComment);
    } catch (e) {
      throw Exception('Error editing comment: $e');
    }
  }

  Future<void> deleteComment(String commentId, String id, String type) async {
    try {
      String path = '';

      // Xây dựng đường dẫn dựa trên type
      if (type == 'task') {
        var taskData = tasks.firstWhere((task) => task['id'] == id);
        path = 'projects/${taskData['projectId']}/tasks/$id';
      } else if (type == 'subtask') {
        var subtaskData = subtasks.firstWhere((task) => task['id'] == id);
        path =
            'projects/${subtaskData['projectId']}/tasks/${subtaskData['taskId']}/subtasks/$id';
      } else if (type == 'subsubtask') {
        var subsubtaskData = subsubtasks.firstWhere((task) => task['id'] == id);
        path =
            'projects/${subsubtaskData['projectId']}/tasks/${subsubtaskData['taskId']}/subtasks/${subsubtaskData['subtaskId']}/subsubtasks/$id';
      } else {
        throw Exception('Invalid type or id');
      }

      // Lấy danh sách comments từ Firestore
      var commentsSnapshot = await FirebaseFirestore.instance
          .doc(path)
          .collection('comments')
          .doc(commentId);

      // Xóa comment
      await commentsSnapshot.delete();
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }

  // Lấy tất cả comment
  Future<List<Map<String, dynamic>>> getComments(String id, String type) async {
    try {
      List<Map<String, dynamic>> allComments = [];
      String path = '';

      // Xây dựng đường dẫn dựa trên type
      if (type == 'task') {
        var taskData = tasks.firstWhere((task) => task['id'] == id);
        path = 'projects/${taskData['projectId']}/tasks/$id';
      } else if (type == 'subtask') {
        var subtaskData = subtasks.firstWhere((task) => task['id'] == id);
        path =
            'projects/${subtaskData['projectId']}/tasks/${subtaskData['taskId']}/subtasks/$id';
      } else if (type == 'subsubtask') {
        var subsubtaskData = subsubtasks.firstWhere((task) => task['id'] == id);
        path =
            'projects/${subsubtaskData['projectId']}/tasks/${subsubtaskData['taskId']}/subtasks/${subsubtaskData['subtaskId']}/subsubtasks/$id';
      } else {
        throw Exception('Invalid type or id');
      }

      // Lấy danh sách comments từ Firestore
      var commentsSnapshot = await FirebaseFirestore.instance
          .doc(path)
          .collection('comments')
          .get();

      for (var commentDoc in commentsSnapshot.docs) {
        var commentData = commentDoc.data();
        commentData['id'] = commentDoc.id;

        allComments.add({
          'id': commentData['id'],
          'author': commentData['author'] ?? '',
          'text': commentData['text'] ?? '',
          'date': commentData['date'] ?? '',
        });
      }

      return Future.value(allComments);
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }
}
