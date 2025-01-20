import 'package:bee_task/screen/TaskData.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class CommentRepository {
  FirebaseAuth get firebaseAuth;
  Future<void> addComment(String id, String type, String content, String author,
      {String? filePath, String? imageUrl});
  Future<void> editComment(
      String commentId, String id, String type, String content, String author,
      {String? filePath, String? imageUrl});
  Future<List<Map<String, dynamic>>> getComments(String id, String type);
}

class FirebaseCommentRepository implements CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseCommentRepository();

  @override
  FirebaseAuth get firebaseAuth => _firebaseAuth;

  List<Map<String, dynamic>> tasks = TaskData().tasks;
  List<Map<String, dynamic>> subtasks = TaskData().subtasks;
  List<Map<String, dynamic>> subsubtasks = TaskData().subsubtasks;
  List<Map<String, dynamic>> users = TaskData().users;
  List<Map<String, dynamic>> pr = TaskData().users;
  Future<void> addComment(String id, String type, String content, String author,
      {String? filePath, String? imageUrl}) async {
    try {
      var taskData = tasks.firstWhere((task) => task['id'] == id);

      String? fileUrl;
      if (type == 'file' && filePath != null) {
        // Tải file lên Firebase Storage
        var fileRef = _storage
            .ref()
            .child('comments/${DateTime.now().millisecondsSinceEpoch}');
        var uploadTask = await fileRef.putFile(File(filePath));
        fileUrl = await uploadTask.ref.getDownloadURL();
      }

      var commentsRef = _firestore
          .collection('projects')
          .doc(taskData['projectId'])
          .collection('tasks')
          .doc(taskData['id'])
          .collection('comments');

      Map<String, dynamic> comment = {
        'author': author,
        'text': type == 'text' ? content : null,
        'fileUrl': type == 'file' ? fileUrl : null,
        'imageUrl': type == 'image' ? imageUrl : null,
        'date': DateTime.now().toIso8601String(),
        'type': type,
      };

      await commentsRef.add(comment);
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  // Chỉnh sửa comment
  Future<void> editComment(
      String commentId, String id, String type, String content, String author,
      {String? filePath, String? imageUrl}) async {
    try {
      var taskData = tasks.firstWhere((task) => task['id'] == id);

      var commentRef = _firestore
          .collection('projects')
          .doc(taskData['projectId'])
          .collection('tasks')
          .doc(taskData['id'])
          .collection('comments')
          .doc(commentId);

      String? fileUrl;
      if (type == 'file' && filePath != null) {
        var fileRef = _storage
            .ref()
            .child('comments/${DateTime.now().millisecondsSinceEpoch}');
        var uploadTask = await fileRef.putFile(File(filePath));
        fileUrl = await uploadTask.ref.getDownloadURL();
      }

      Map<String, dynamic> updatedComment = {
        'author': author,
        'text': type == 'text' ? content : null,
        'fileUrl': type == 'file' ? fileUrl : null,
        'imageUrl': type == 'image' ? imageUrl : null,
        'date': DateTime.now().toIso8601String(),
        'type': type,
      };

      await commentRef.update(updatedComment);
    } catch (e) {
      throw Exception('Error editing comment: $e');
    }
  }

  // Lấy tất cả comment
  Future<List<Map<String, dynamic>>> getComments(
      String id, String type) async {
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
          'author': commentData['author'] ?? '',
          'text': commentData['text'] ?? '',
          'fileUrl': commentData['fileUrl'] ?? '',
          'imageUrl': commentData['imageUrl'] ?? '',
          'date': commentData['date'] ?? '',
          'type': commentData['type'] ?? '',
        });
      }

      return Future.value(allComments);
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }
}
