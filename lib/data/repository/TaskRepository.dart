import 'package:bee_task/screen/TaskData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bee_task/data/model/task.dart';

abstract class TaskRepository {
  FirebaseAuth get firebaseAuth;
  Future<List<Map<String, dynamic>>> fetchTasksByDate(
      String date, bool showCompletedTasks, String email);
  Future<void> addTask(Map<String, dynamic> task);
  Future<void> updateTask(String taskId, Task updatedTaskData, String type);
  Future<void> deleteTask(String id, String type);
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
  List<Map<String, dynamic>> pr = TaskData().users;

  @override
  Future<List<Map<String, dynamic>>> fetchTasksByDate(
      String date, bool showCompletedTasks, String email) async {
    try {
      List<Map<String, dynamic>> allTasks = [];

      // Lấy danh sách projects từ TaskData()
      List<Map<String, dynamic>> projects = TaskData().projects;

      // Lặp qua tất cả các project để lấy dữ liệu task, subtask và subsubtask
      for (var project in projects) {
        String projectId = project['id']; // Lấy projectId từ project

        // Lấy dữ liệu tasks từ Firestore trong collection 'projects'
        var tasksFuture = FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .collection('tasks')
            .where('dueDate', isEqualTo: date)
            .get()
            .then((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            var taskData = doc.data();
            taskData['id'] = doc.id;
            taskData['type'] = 'task';
            taskData['projectId'] = projectId; // Thêm projectId vào task
            taskData['projectName'] =
                project['name']; // Thêm projectId vào task
            return taskData;
          }).toList();
        });

        // Lấy dữ liệu subtasks từ Firestore cho từng task
        var subtasksFuture = tasksFuture.then((tasks) async {
          List<Map<String, dynamic>> allSubtasks = [];
          for (var task in tasks) {
            // Lấy subtasks của task trong collection 'subtasks' của task
            var subtasksSnapshot = await FirebaseFirestore.instance
                .collection('projects')
                .doc(projectId)
                .collection('tasks')
                .doc(task['id'])
                .collection('subtasks')
                .where('dueDate', isEqualTo: date)
                .get();

            for (var subtaskDoc in subtasksSnapshot.docs) {
              var subtaskData = subtaskDoc.data();
              subtaskData['id'] = subtaskDoc.id;
              subtaskData['type'] = 'subtask';
              subtaskData['projectName'] =
                  project['name']; // Thêm projectId vào task

              // Lấy subsubtasks của subtask
              var subsubtasksSnapshot = await FirebaseFirestore.instance
                  .collection('projects')
                  .doc(projectId)
                  .collection('tasks')
                  .doc(task['id'])
                  .collection('subtasks')
                  .doc(subtaskDoc.id)
                  .collection('subsubtasks')
                  .where('dueDate', isEqualTo: date)
                  .get();

              for (var subsubtaskDoc in subsubtasksSnapshot.docs) {
                var subsubtaskData = subsubtaskDoc.data();
                subsubtaskData['id'] = subsubtaskDoc.id;
                subsubtaskData['type'] = 'subsubtask';
                subsubtaskData['projectName'] = project['name'];
                allSubtasks.add(subsubtaskData);
              }

              allSubtasks.add(subtaskData);
            }
          }
          return allSubtasks;
        });

        // Chạy song song các Future
        var tasks = await tasksFuture;
        var subtasks = await subtasksFuture;

        // Kết hợp các kết quả lại với nhau
        allTasks.addAll(tasks);
        allTasks.addAll(subtasks);
      }
      allTasks.sort((a, b) {
        bool completedA = a['completed'] ?? true;
        bool completedB = b['completed'] ?? true;
        return completedA ? 1 : -1;
      });
      if (showCompletedTasks == false) {
        allTasks.removeWhere((task) => task['completed'] == true);
      }

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
      String taskId, Task updatedTaskData, String type) async {
    try {
      // Biến tham chiếu đến tài liệu
      DocumentReference? docRef;
      var task;

      // Xác định tài liệu cần cập nhật dựa trên type
      switch (type) {
        case 'task':
          task = tasks.firstWhere((item) => item['id'] == taskId,
              orElse: () => throw Exception(
                  'Task not found')); // Throw exception if task not found

          docRef = FirebaseFirestore.instance
              .collection('projects')
              .doc(task['projectId']) // Lấy projectId từ task
              .collection('tasks')
              .doc(taskId); // Tìm task theo taskId

          break;

        case 'subtask':
          task = subtasks.firstWhere((item) => item['id'] == taskId,
              orElse: () => throw Exception(
                  'Subtask not found')); // Throw exception if subtask not found

          docRef = FirebaseFirestore.instance
              .collection('projects')
              .doc(task['projectId'])
              .collection('tasks')
              .doc(task['taskId'])
              .collection('subtasks')
              .doc(task['id']); // Tìm subtask theo subtaskId
          break;

        case 'subsubtask':
          task = subsubtasks.firstWhere((item) => item['id'] == taskId,
              orElse: () => throw Exception(
                  'Subsubtask not found')); // Throw exception if subsubtask not found

          docRef = FirebaseFirestore.instance
              .collection('projects')
              .doc(task['projectId'])
              .collection('tasks')
              .doc(task['taskId'])
              .collection('subtasks')
              .doc(task['subtaskId'])
              .collection('subsubtasks')
              .doc(task['id']); // Tìm subsubtask theo subsubtaskId
          break;

        default:
          throw Exception('Invalid type');
      }

      // Lấy dữ liệu hiện tại từ tài liệu Firestore
      DocumentSnapshot snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('Document not found');
      }

      // Chuyển đối tượng Task thành Map
      Map<String, dynamic> updatedTaskMap = updatedTaskData.toMap();

      // Lọc các trường hợp hợp lệ để cập nhật
      Map<String, dynamic> existingData =
          snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> filteredData = {};

      updatedTaskMap.forEach((key, value) {
        if (existingData.containsKey(key)) {
          filteredData[key] = value;
        }
      });

      // Cập nhật chỉ những trường hợp hợp lệ
      if (filteredData.isNotEmpty) {
        await docRef.update(filteredData);
      }
      bool newCompletedStatus = updatedTaskData.completed;
      if (newCompletedStatus == true) {
        if (type == 'task') {
          // Cập nhật completed cho tất cả các subtasks của task
          await updateSubtasksCompletedStatus(
              task['projectId'], taskId, newCompletedStatus);
        } else if (type == 'subtask') {
          await updateSubsubtasksCompletedStatus(task['projectId'],
              task['taskId'], task['id'], newCompletedStatus);
        }
      }
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Error updating task: $e');
    }
  }

  // Hàm cập nhật completed cho tất cả các subtasks của task
  Future<void> updateSubtasksCompletedStatus(
      String projectId, String taskId, bool completedStatus) async {
    try {
      // Lấy tất cả các subtasks của task
      var subtasksSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .get();

      // Lặp qua tất cả các subtasks và cập nhật completed
      for (var subtask in subtasksSnapshot.docs) {
        await subtask.reference.update({
          'completed': completedStatus,
        });

        // Cập nhật completed cho tất cả các subsubtasks của subtask này
        await updateSubsubtasksCompletedStatus(
            projectId, taskId, subtask.id, completedStatus);
      }
    } catch (e) {
      print('Error updating subtasks completed status: $e');
    }
  }

// Hàm cập nhật completed cho tất cả các subsubtasks của subtask
  Future<void> updateSubsubtasksCompletedStatus(String projectId, String taskId,
      String subtaskId, bool completedStatus) async {
    try {
      // Lấy tất cả các subsubtasks của subtask
      var subsubtasksSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .doc(subtaskId)
          .collection('subsubtasks')
          .get();

      // Lặp qua tất cả các subsubtasks và cập nhật completed
      for (var subsubtask in subsubtasksSnapshot.docs) {
        await subsubtask.reference.update({
          'completed': completedStatus,
        });
      }
    } catch (e) {
      print('Error updating subsubtasks completed status: $e');
    }
  }

  Future<void> deleteTask(String id, String type) async {
    DocumentReference? docRef;
    var task;

    // Xác định tài liệu cần cập nhật dựa trên type
    switch (type) {
      case 'task':
        // Tìm task trong danh sách tasks
        task = tasks.firstWhere((item) => item['id'] == id,
            orElse: () => throw Exception('Task not found'));

        // Xác định document reference của task
        docRef = FirebaseFirestore.instance
            .collection('projects')
            .doc(task['projectId']) // Lấy projectId từ task
            .collection('tasks')
            .doc(id); // Tìm task theo taskId

        // Xoá tất cả subtasks và subsubtasks trước khi xoá task
        await _deleteSubtasksAndSubsubtasks(task['projectId'], id);
        break;

      case 'subtask':
        // Tìm subtask trong danh sách subtasks
        task = subtasks.firstWhere((item) => item['id'] == id,
            orElse: () => throw Exception('Subtask not found'));

        // Xác định document reference của subtask
        docRef = FirebaseFirestore.instance
            .collection('projects')
            .doc(task['projectId']) // Lấy projectId từ subtask
            .collection('tasks')
            .doc(task['taskId']) // Lấy taskId từ subtask
            .collection('subtasks')
            .doc(task['id']); // Tìm subtask theo subtaskId

        // Xoá tất cả subsubtasks trước khi xoá subtask
        await _deleteSubsubtasks(task['projectId'], task['taskId'], task['id']);
        break;

      case 'subsubtask':
        // Tìm subsubtask trong danh sách subsubtasks
        task = subsubtasks.firstWhere((item) => item['id'] == id,
            orElse: () => throw Exception('Subsubtask not found'));

        // Xác định document reference của subsubtask
        docRef = FirebaseFirestore.instance
            .collection('projects')
            .doc(task['projectId']) // Lấy projectId từ subsubtask
            .collection('tasks')
            .doc(task['taskId']) // Lấy taskId từ subsubtask
            .collection('subtasks')
            .doc(task['subtaskId']) // Lấy subtaskId từ subsubtask
            .collection('subsubtasks')
            .doc(task['id']); // Tìm subsubtask theo subsubtaskId
        break;

      default:
        throw Exception('Invalid type');
    }

    // Lấy dữ liệu hiện tại từ tài liệu Firestore
    DocumentSnapshot snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception('Document not found');
    }

    // Xoá tài liệu khỏi Firestore
    try {
      await docRef.delete();
    } catch (e) {
      throw Exception('Error deleting $type: $e');
    }
  }

// Hàm xoá tất cả subtasks và subsubtasks trong một task
  Future<void> _deleteSubtasksAndSubsubtasks(
      String projectId, String taskId) async {
    var subtasksRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('subtasks');

    // Lấy danh sách subtasks
    var subtasksSnapshot = await subtasksRef.get();

    // Xoá từng subtask và các subsubtasks trong đó
    for (var doc in subtasksSnapshot.docs) {
      // Xoá subsubtasks của subtask hiện tại
      await _deleteSubsubtasks(projectId, taskId, doc.id);

      // Xoá subtask
      await doc.reference.delete();
    }
  }

// Hàm xoá tất cả subsubtasks trong một subtask
  Future<void> _deleteSubsubtasks(
      String projectId, String taskId, String subtaskId) async {
    var subsubtasksRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('subtasks')
        .doc(subtaskId)
        .collection('subsubtasks');

    // Lấy danh sách subsubtasks
    var subsubtasksSnapshot = await subsubtasksRef.get();

    // Xoá từng subsubtask
    for (var doc in subsubtasksSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
