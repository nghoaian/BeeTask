import 'package:bee_task/screen/TaskData.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bee_task/data/model/task.dart';

abstract class TaskRepository {
  FirebaseAuth get firebaseAuth;
  Future<List<Map<String, dynamic>>> fetchTasksByDate(
      String date, bool showCompletedTasks, String email);
  Future<void> addTask(
    String thisTaskId,
    String type, // Type: 'task', 'subtask', or 'subsubtask'
    Task task, // Đối tượng Task chứa thông tin cần thiết
    String taskId, // taskId nếu là subtask hoặc subsubtask
    String projectId,
  );
  Future<void> updateTask(String taskId, Task updatedTaskData, String type);
  Future<void> deleteTask(String id, String type);
  Future<Map<String, dynamic>> fetchDataFromFirestore(String type, String id);
  Future<void> logTaskActivity(
    String projectId,
    String taskId,
    String action,
    Map<String, dynamic> changedFields,
    String userEmail,
    String type,
  );
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

      // Lọc các tasks có dueDate trùng với ngày
      var filteredTasks =
          tasks.where((task) => task['dueDate'] == date).toList();
      allTasks.addAll(filteredTasks);

      // Lọc tất cả các subtasks có dueDate trùng với ngày
      var filteredSubtasks =
          subtasks.where((subtask) => subtask['dueDate'] == date).toList();
      filteredSubtasks.forEach((subtask) {
        subtask['type'] =
            'subtask'; // Đảm bảo rằng subtask có type là 'subtask'
        allTasks.add(subtask);
      });

      // Lọc tất cả các subsubtasks có dueDate trùng với ngày
      var filteredSubsubtasks = subsubtasks
          .where((subsubtask) => subsubtask['dueDate'] == date)
          .toList();
      filteredSubsubtasks.forEach((subsubtask) {
        subsubtask['type'] =
            'subsubtask'; // Đảm bảo rằng subsubtask có type là 'subsubtask'
        allTasks.add(subsubtask);
      });

      // Sắp xếp kết quả theo completed
      allTasks.sort((a, b) {
        // 1. Sắp xếp theo completed (false trước, true sau)
        bool completedA = a['completed'] ?? true;
        bool completedB = b['completed'] ?? true;
        if (completedA != completedB) {
          return completedA ? 1 : -1;
        }

        // 2. Sắp xếp theo priority (High -> Medium -> Low)
        Map<String, int> priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
        int priorityA = priorityOrder[a['priority']] ?? 0;
        int priorityB = priorityOrder[b['priority']] ?? 0;
        if (priorityA != priorityB) {
          return priorityB
              .compareTo(priorityA); // Sắp xếp giảm dần (High trước)
        }

        // 3. Sắp xếp theo projectId
        return (a['projectId'] ?? "").compareTo(b['projectId'] ?? "");
      });

      if (showCompletedTasks == false) {
        allTasks.removeWhere((task) => task['completed'] == true);
      }

      return allTasks;
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  @override
  Future<String?> addTask(String thisTaskId, String type, Task task,
      String taskId, String projectId) async {
    try {
      // Lấy thông tin cần thiết từ đối tượng Task
      Map<String, dynamic> taskDataAdd = {
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate,
        'priority': task.priority,
        'assignee': task.assignee,
        'completed': task.completed,
      };

      DocumentReference? docRef; // Biến để lưu ID của tài liệu mới thêm

      if (thisTaskId == 'noID') {
        if (type == 'task') {
          // Thêm task vào collection 'tasks' trong project
          docRef = await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .add(taskDataAdd);
        } else if (type == 'subtask' && taskId.isNotEmpty) {
          // Thêm vào collection 'subtasks' của task
          docRef = await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(taskId)
              .collection('subtasks')
              .add(taskDataAdd);

          // Cập nhật completed của task cha thành false
          await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(taskId)
              .update({'completed': false});
        } else if (type == 'subsubtask' && taskId.isNotEmpty) {
          var findTask = subtasks.firstWhere((item) => item['id'] == taskId,
              orElse: () => throw Exception('Task not found'));

          // Thêm vào collection 'subsubtasks' của subtask
          docRef = await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(findTask['taskId'])
              .collection('subtasks')
              .doc(taskId)
              .collection('subsubtasks')
              .add(taskDataAdd);

          // Cập nhật completed của subtask cha và task cha thành false
          await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(findTask['taskId'])
              .collection('subtasks')
              .doc(taskId)
              .update({'completed': false});

          await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(findTask['taskId'])
              .update({'completed': false});
        } else {
          return null; // Trả về null nếu không thể thêm task
        }
      } else {
        if (type == 'task') {
          // Thêm task vào collection 'tasks' trong project
          docRef = await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(thisTaskId);
          await docRef.set(taskDataAdd);
        } else if (type == 'subtask' && taskId.isNotEmpty) {
          // Thêm vào collection 'subtasks' của task
          docRef = await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(taskId)
              .collection('subtasks')
              .doc(thisTaskId);
          await docRef.set(taskDataAdd);
          // Cập nhật completed của task cha thành false
          await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(taskId)
              .update({'completed': false});
        } else if (type == 'subsubtask' && taskId.isNotEmpty) {
          var findTask = subtasks.firstWhere((item) => item['id'] == taskId,
              orElse: () => throw Exception('Task not found'));

          // Thêm vào collection 'subsubtasks' của subtask
          docRef = await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(findTask['taskId'])
              .collection('subtasks')
              .doc(taskId)
              .collection('subsubtasks')
              .doc(thisTaskId);
          await docRef.set(taskDataAdd);
          // Cập nhật completed của subtask cha và task cha thành false
          await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(findTask['taskId'])
              .collection('subtasks')
              .doc(taskId)
              .update({'completed': false});

          await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc(findTask['taskId'])
              .update({'completed': false});
        } else {
          return null; // Trả về null nếu không thể thêm task
        }
      }

      if (docRef != null) {
        User? user = firebaseAuth.currentUser;
        if (user != null && user.email != null) {
          logTaskActivity(projectId, docRef.id, 'add', {}, user.email!, type);
        }
        return docRef.id; // Trả về ID của task vừa được thêm
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
    return null;
  }

  Future<bool> updateTask(
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
      } else {
        if (type == 'subsubtask') {
          // Update the parent subtask to completed = false
          await updateSubtaskCompletedStatus(
              task['projectId'], task['taskId'], task['subtaskId'], false);
        } else if (type == 'subtask') {
          // Update the parent task to completed = false
          await updateTaskCompletedStatus(
              task['projectId'], task['taskId'], false);
        }
      }

      return true;
    } catch (e) {
      return false;
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

  Future<void> updateSubtaskCompletedStatus(String projectId, String taskId,
      String subtaskId, bool completedStatus) async {
    try {
      DocumentReference subtaskRef = FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .doc(subtaskId);

      await subtaskRef.update({'completed': completedStatus});
      await updateTaskCompletedStatus(projectId, taskId, completedStatus);
    } catch (e) {
      throw Exception('Failed to update subtask completed status');
    }
  }

  Future<void> updateTaskCompletedStatus(
      String projectId, String taskId, bool completedStatus) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId);

      await taskRef.update({'completed': completedStatus});
    } catch (e) {
      throw Exception('Failed to update task completed status');
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
      var commentsRef = snapshot.reference.collection('comments');

      // Lấy danh sách comment
      var commentsSnapshot = await commentsRef.get();

      // Xoá từng comment
      for (var commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.delete();
      }
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
      var commentsRef = doc.reference.collection('comments');

      // Lấy danh sách comment
      var commentsSnapshot = await commentsRef.get();

      // Xoá từng comment
      for (var commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.delete();
      }
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

    // Xoá từng subsubtask và các comment trong đó
    for (var doc in subsubtasksSnapshot.docs) {
      // Lấy reference của collection comment trong subsubtask
      var commentsRef = doc.reference.collection('comments');

      // Lấy danh sách comment
      var commentsSnapshot = await commentsRef.get();

      // Xoá từng comment
      for (var commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.delete();
      }

      // Sau khi xóa các comment, xoá subsubtask
      await doc.reference.delete();
    }
  }

  Map<String, dynamic>? findById(String type, String id) {
    // Kiểm tra type để xác định danh sách cần tìm kiếm
    switch (type) {
      case 'task':
        return tasks.firstWhere((task) => task['id'] == id, orElse: () => {});

      case 'subtask':
        return subtasks.firstWhere((subtask) => subtask['id'] == id,
            orElse: () => {});

      case 'subsubtask':
        return subsubtasks.firstWhere((subsubtask) => subsubtask['id'] == id,
            orElse: () => {});

      default:
        // Nếu type không hợp lệ, trả về null
        print('Invalid type: $type');
        return null;
    }
  }

  Future<Map<String, dynamic>> fetchDataFromFirestore(
      String type, String id) async {
    try {
      // Tìm đối tượng trong danh sách tương ứng
      Map<String, dynamic>? localData = findById(type, id);

      if (localData == null) {
        print('Object not found in local data');
        return {};
      }

      // Dựa vào type, gọi các hàm phù hợp
      switch (type) {
        case 'task':
          return await fetchTaskWithSubcollections(localData, id);

        case 'subtask':
          return await fetchSubtaskWithSubcollections(localData, id);

        case 'subsubtask':
          return await fetchSubsubtask(localData, id);

        default:
          print('Invalid type: $type');
          return {};
      }
    } catch (e) {
      print('Error fetching data from Firestore: $e');
      return {};
    }
  }

// Hàm lấy task và toàn bộ subtasks, subsubtasks
  Future<Map<String, dynamic>> fetchTaskWithSubcollections(
      Map<String, dynamic> localData, String taskId) async {
    String projectId = localData['projectId'];

    // Lấy thông tin task
    var taskDoc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .get();

    if (!taskDoc.exists) {
      throw Exception('Task not found');
    }

    Map<String, dynamic> taskData = taskDoc.data()!;
    taskData['id'] = taskDoc.id; // Lưu lại id của task
    taskData['projectId'] = projectId;
    taskData['subtasks'] = [];
    taskData['type'] = 'task';

    // Lấy danh sách subtasks
    var subtasksSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('subtasks')
        .get();

    for (var subtaskDoc in subtasksSnapshot.docs) {
      Map<String, dynamic> subtaskData = subtaskDoc.data();
      subtaskData['id'] = subtaskDoc.id; // Lưu lại id của subtask
      subtaskData['subsubtasks'] = [];
      subtaskData['type'] = 'subtask';

      // Lấy danh sách subsubtasks
      var subsubtasksSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .doc(subtaskDoc.id)
          .collection('subsubtasks')
          .get();

      subtaskData['subsubtasks'] = subsubtasksSnapshot.docs.map((doc) {
        Map<String, dynamic> subsubtaskData = doc.data();
        subsubtaskData['id'] = doc.id; // Lưu lại id của subsubtask
        subsubtaskData['type'] = 'subsubtask';
        return subsubtaskData;
      }).toList();

      taskData['subtasks'].add(subtaskData);
    }

    return taskData;
  }

// Hàm lấy subtask và toàn bộ subsubtasks
  Future<Map<String, dynamic>> fetchSubtaskWithSubcollections(
      Map<String, dynamic> localData, String subtaskId) async {
    String projectId = localData['projectId'];
    String taskId = localData['taskId'];

    // Lấy thông tin subtask
    var subtaskDoc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('subtasks')
        .doc(subtaskId)
        .get();

    if (!subtaskDoc.exists) {
      throw Exception('Subtask not found');
    }

    // Thêm id vào subtask
    Map<String, dynamic> subtaskData = subtaskDoc.data()!;
    subtaskData['id'] = subtaskDoc.id; // Lưu id của subtask
    subtaskData['projectId'] = projectId;
    subtaskData['subsubtasks'] = [];
    subtaskData['type'] = 'subtask';

    // Lấy danh sách subsubtasks
    var subsubtasksSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('subtasks')
        .doc(subtaskId)
        .collection('subsubtasks')
        .get();

    // Thêm id vào mỗi subsubtask
    subtaskData['subsubtasks'] = subsubtasksSnapshot.docs.map((doc) {
      Map<String, dynamic> subsubtaskData = doc.data();
      subsubtaskData['id'] = doc.id; // Lưu id của subsubtask
      subsubtaskData['type'] = 'subsubtask';
      return subsubtaskData;
    }).toList();

    return subtaskData;
  }

  Future<Map<String, dynamic>> fetchSubsubtask(
      Map<String, dynamic> localData, String subsubtaskId) async {
    String projectId = localData['projectId'];
    String taskId = localData['taskId'];
    String subtaskId = localData['subtaskId'];

    // Lấy thông tin subsubtask
    var subsubtaskDoc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('subtasks')
        .doc(subtaskId)
        .collection('subsubtasks')
        .doc(subsubtaskId)
        .get();

    if (!subsubtaskDoc.exists) {
      throw Exception('Subsubtask not found');
    }

    // Thêm thông tin subsubtaskId và projectId vào kết quả trả về
    Map<String, dynamic> subsubtaskData = subsubtaskDoc.data()!;
    subsubtaskData['id'] = subsubtaskId;
    subsubtaskData['projectId'] = projectId;
    subsubtaskData['type'] = 'subsubtask';

    return subsubtaskData;
  }

  Future<void> logTaskActivity(
    String projectId,
    String taskId,
    String action,
    Map<String, dynamic> changedFields,
    String userEmail,
    String type,
  ) async {
    final taskActivitiesCollection =
        FirebaseFirestore.instance.collection('task_activities');

    try {
      // Lấy thời gian hiện tại và định dạng ngày giờ
      final now = DateTime.now();
      final formattedDate = DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').format(now);

      await taskActivitiesCollection.add({
        'projectId': projectId,
        'taskId': taskId,
        'action': action,
        'changedFields': changedFields ?? {},
        'userEmail': userEmail,
        'type': type,
        'timestamp': formattedDate,
      });
    } catch (e) {
      print('Failed to log activity: $e');
    }
  }
}
