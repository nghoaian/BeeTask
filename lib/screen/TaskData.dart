import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';

class TaskData {
  static final TaskData _instance = TaskData._internal();

  factory TaskData() => _instance;

  TaskData._internal();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Biến lưu dữ liệu chung
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> subtasks = [];
  List<Map<String, dynamic>> subsubtasks = [];
  List<Map<String, dynamic>> users = [];
  void loadData(String email) {
    resetData();
    listenToAllData(email);
  }

  // Lắng nghe dữ liệu từ Firestore
  void listenToAllData(String userEmail) {
    resetData();
    listenToUserChanges();
    firestore
        .collection('projects')
        .where('members', arrayContains: userEmail)
        .snapshots()
        .listen((projectSnapshot) {
      for (var projectChange in projectSnapshot.docChanges) {
        _updateProjects(projectChange);

        String projectId = projectChange.doc.id;
        String projectName = projectChange.doc['name'];
        // Lắng nghe sự thay đổi của các thành viên trong project

        _listenToTasks(projectId, projectName);
      }
    });
  }

  void listenToUserChanges() {
    firestore.collection('users').snapshots().listen((userSnapshot) {
      // Duyệt qua các tài liệu đã thay đổi và cập nhật danh sách users
      for (var userChange in userSnapshot.docChanges) {
        _updateUserInfo(userChange);
      }
    });
  }

  // Phương thức cập nhật thông tin người dùng khi có sự thay đổi
  void _updateUserInfo(DocumentChange userChange) {
    var userData = userChange.doc.data() as Map<String, dynamic>;

    // Nếu là trường hợp thêm người dùng mới
    if (userChange.type == DocumentChangeType.added) {
      // Kiểm tra xem người dùng đã tồn tại trong danh sách chưa
      if (!users.any((user) => user['userEmail'] == userData['userEmail'])) {
        users.add(userData); // Thêm người dùng mới vào danh sách
      }
    }
    // Nếu là trường hợp cập nhật thông tin người dùng
    else if (userChange.type == DocumentChangeType.modified) {
      int index = users
          .indexWhere((user) => user['userEmail'] == userData['userEmail']);
      if (index != -1) {
        // Cập nhật thông tin của người dùng trong danh sách
        users[index] = userData;
      }
    }
    // Nếu là trường hợp xóa người dùng
    else if (userChange.type == DocumentChangeType.removed) {
      int index = users
          .indexWhere((user) => user['userEmail'] == userData['userEmail']);
      if (index != -1) {
        // Xóa người dùng khỏi danh sách
        users.removeAt(index);
      }
    }
  }

  // Cập nhật danh sách projects
  void _updateProjects(DocumentChange projectChange) {
    String projectId = projectChange.doc.id;
    var projectData = projectChange.doc.data() as Map<String, dynamic>;
    projectData['id'] = projectId;

    int index = projects.indexWhere((project) => project['id'] == projectId);

    if (projectChange.type == DocumentChangeType.added) {
      if (index == -1) {
        // Kiểm tra nếu chưa tồn tại
        projects.add(projectData);
      }
    } else if (projectChange.type == DocumentChangeType.modified) {
      if (index != -1) {
        // Cập nhật nếu đã tồn tại
        projects[index] = projectData;
      }
    } else if (projectChange.type == DocumentChangeType.removed) {
      if (index != -1) {
        // Xóa nếu đã tồn tại
        projects.removeAt(index);
      }
    }
  }

  // Lắng nghe danh sách tasks trong project
  void _listenToTasks(String projectId, String projectName) {
    firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .snapshots()
        .listen((taskSnapshot) {
      for (var taskChange in taskSnapshot.docChanges) {
        _updateTasks(taskChange, projectId, projectName);

        String taskId = taskChange.doc.id;
        _listenToSubtasks(projectId, projectName, taskId);
      }
    });
  }

  // Cập nhật danh sách tasks
  void _updateTasks(
      DocumentChange taskChange, String projectId, String projectName) {
    String taskId = taskChange.doc.id;
    var taskData = taskChange.doc.data() as Map<String, dynamic>;
    taskData['id'] = taskId;
    taskData['projectId'] = projectId;
    taskData['type'] = 'task';
    taskData['projectName'] = projectName;

    if (taskChange.type == DocumentChangeType.added) {
      // Kiểm tra xem task đã tồn tại hay chưa
      if (!tasks.any((task) => task['id'] == taskId)) {
        tasks.add(taskData);
      }
    } else if (taskChange.type == DocumentChangeType.modified) {
      // Cập nhật task nếu đã tồn tại
      int index = tasks.indexWhere((task) => task['id'] == taskId);
      if (index != -1) {
        tasks[index] = taskData;
      }
    } else if (taskChange.type == DocumentChangeType.removed) {
      // Xóa task khỏi danh sách nếu tồn tại
      tasks.removeWhere((task) => task['id'] == taskId);
    }
  }

  // Lắng nghe danh sách subtasks trong task
  void _listenToSubtasks(String projectId, String projectName, String taskId) {
    firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('subtasks')
        .snapshots()
        .listen((subtaskSnapshot) {
      for (var subtaskChange in subtaskSnapshot.docChanges) {
        _updateSubtasks(subtaskChange, taskId, projectName, projectId);

        String subtaskId = subtaskChange.doc.id;
        _listenToSubsubtasks(projectId, projectName, taskId, subtaskId);
      }
    });
  }

  // Cập nhật danh sách subtasks
  void _updateSubtasks(DocumentChange subtaskChange, String taskId,
      String projectName, String projectId) {
    String subtaskId = subtaskChange.doc.id;
    var subtaskData = subtaskChange.doc.data() as Map<String, dynamic>;
    subtaskData['id'] = subtaskId;
    subtaskData['taskId'] = taskId;
    subtaskData['projectId'] = projectId;
    subtaskData['type'] = 'subtask';
    subtaskData['projectName'] = projectName;

    if (subtaskChange.type == DocumentChangeType.added) {
      // Kiểm tra xem subtask đã tồn tại hay chưa
      if (!subtasks.any((subtask) => subtask['id'] == subtaskId)) {
        subtasks.add(subtaskData);
      }
    } else if (subtaskChange.type == DocumentChangeType.modified) {
      // Cập nhật subtask nếu đã tồn tại
      int index = subtasks.indexWhere((subtask) => subtask['id'] == subtaskId);
      if (index != -1) {
        subtasks[index] = subtaskData;
      }
    } else if (subtaskChange.type == DocumentChangeType.removed) {
      // Xóa subtask khỏi danh sách nếu tồn tại
      subtasks.removeWhere((subtask) => subtask['id'] == subtaskId);
    }
  }

  // Lắng nghe danh sách subsubtasks trong subtask
  void _listenToSubsubtasks(
      String projectId, String projectName, String taskId, String subtaskId) {
    firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('subtasks')
        .doc(subtaskId)
        .collection('subsubtasks')
        .snapshots()
        .listen((subsubtaskSnapshot) {
      for (var subsubtaskChange in subsubtaskSnapshot.docChanges) {
        _updateSubsubtasks(
            subsubtaskChange, subtaskId, projectName, projectId, taskId);
      }
    });
  }

  // Cập nhật danh sách subsubtasks
  void _updateSubsubtasks(DocumentChange subsubtaskChange, String subtaskId,
      String projectName, String projectId, String taskId) {
    String subsubtaskId = subsubtaskChange.doc.id;
    var subsubtaskData = subsubtaskChange.doc.data() as Map<String, dynamic>;
    subsubtaskData['id'] = subsubtaskId;
    subsubtaskData['subtaskId'] = subtaskId;
    subsubtaskData['type'] = 'subsubtask';
    subsubtaskData['projectName'] = projectName;
    subsubtaskData['projectId'] = projectId;
    subsubtaskData['taskId'] = taskId;

    if (subsubtaskChange.type == DocumentChangeType.added) {
      // Kiểm tra xem subsubtask đã tồn tại hay chưa
      if (!subsubtasks.any((subsubtask) => subsubtask['id'] == subsubtaskId)) {
        subsubtasks.add(subsubtaskData);
      }
    } else if (subsubtaskChange.type == DocumentChangeType.modified) {
      // Cập nhật subsubtask nếu đã tồn tại
      int index = subsubtasks
          .indexWhere((subsubtask) => subsubtask['id'] == subsubtaskId);
      if (index != -1) {
        subsubtasks[index] = subsubtaskData;
      }
    } else if (subsubtaskChange.type == DocumentChangeType.removed) {
      // Xóa subsubtask khỏi danh sách nếu tồn tại
      subsubtasks.removeWhere((subsubtask) => subsubtask['id'] == subsubtaskId);
    }
  }

  void resetData() {
    projects.clear();
    tasks.clear();
    subtasks.clear();
    subsubtasks.clear();
  }

  String getUserAvatarFromList(String email) {
    try {
      // Tìm người dùng trong danh sách users có email trùng khớp
      var user = users.firstWhere((user) => user['userEmail'] == email,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );

      if (user.isNotEmpty) {
        return user['avatar']; // Trả về avatar của người dùng
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  String getUserNameFromList(String email) {
    try {
      // Tìm người dùng trong danh sách users có email trùng khớp
      var user = users.firstWhere((user) => user['userEmail'] == email,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
      if (user.isNotEmpty) {
        return user['userName']; // Trả về avatar của người dùng
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  // Tính tổng số subtasks tương ứng với taskId
  Stream<int> getCountByTypeStream(String id, String type) async* {
    try {
      if (type == 'task') {
        var taskData = tasks.firstWhere((task) => task['id'] == id);

        // Lắng nghe sự thay đổi số lượng subtasks của task
        await for (var subtaskSnapshot in FirebaseFirestore.instance
            .collection('projects')
            .doc(taskData['projectId'])
            .collection('tasks')
            .doc(taskData['id'])
            .collection('subtasks')
            .snapshots()) {
          // Mỗi khi có thay đổi trong subtask, yield giá trị mới
          yield subtaskSnapshot.docs.length;
        }
      } else if (type == 'subtask') {
        var subtaskData = subtasks.firstWhere((task) => task['id'] == id);

        // Lắng nghe sự thay đổi số lượng subsubtasks của subtask
        await for (var subsubtaskSnapshot in FirebaseFirestore.instance
            .collection('projects')
            .doc(subtaskData['projectId'])
            .collection('tasks')
            .doc(subtaskData['taskId'])
            .collection('subtasks')
            .doc(subtaskData['id'])
            .collection('subsubtasks')
            .snapshots()) {
          // Mỗi khi có thay đổi trong subsubtask, yield giá trị mới
          yield subsubtaskSnapshot.docs.length;
        }
      } else {
        yield 0;
      }
    } catch (e) {
      yield 0; // Trả về giá trị mặc định nếu có lỗi
    }
  }

  Stream<int> getCompletedCountStream(String id, String type) async* {
    try {
      if (type == 'task') {
        var taskData = tasks.firstWhere((task) => task['id'] == id);

        // Lắng nghe sự thay đổi số lượng subtasks hoàn thành của task
        await for (var subtasksSnapshot in FirebaseFirestore.instance
            .collection('projects')
            .doc(taskData['projectId']) // Lấy projectId từ task
            .collection('tasks')
            .doc(taskData['id']) // Lấy taskId từ task
            .collection('subtasks')
            .where('completed', isEqualTo: true)
            .snapshots()) {
          // Mỗi khi có thay đổi trong subtasks hoàn thành, yield giá trị mới
          yield subtasksSnapshot.docs.length;
        }
      } else if (type == 'subtask') {
        var subtaskData = subtasks.firstWhere((task) => task['id'] == id);

        // Lắng nghe sự thay đổi số lượng subsubtasks hoàn thành của subtask
        await for (var subsubtasksSnapshot in FirebaseFirestore.instance
            .collection('projects')
            .doc(subtaskData['projectId'])
            .collection('tasks')
            .doc(subtaskData['taskId'])
            .collection('subtasks')
            .doc(subtaskData['id']) // Lấy subtaskId từ subtask
            .collection('subsubtasks')
            .where('completed', isEqualTo: true)
            .snapshots()) {
          // Mỗi khi có thay đổi trong subsubtasks hoàn thành, yield giá trị mới
          yield subsubtasksSnapshot.docs.length;
        }
      } else {
        yield 0;
      }
    } catch (e) {
      yield 0; // Trả về giá trị mặc định nếu có lỗi
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

  Future<Map<String, dynamic>?> fetchDataFromFirestore(
      String type, String id) async {
    try {
      // Tìm đối tượng trong danh sách tương ứng
      Map<String, dynamic>? localData = findById(type, id);

      if (localData == null) {
        print('Object not found in local data');
        return null;
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
          return null;
      }
    } catch (e) {
      print('Error fetching data from Firestore: $e');
      return null;
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

    return subsubtaskData;
  }

  // Hàm lấy màu sắc ưu tiên cho task
  Color getPriorityColor(String priority) {
    return AppColors.getPriorityColor(priority);
  }

  Future<List<String>> getProjectMembers(String projectId) async {
    try {
      var projectDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .get();

      if (!projectDoc.exists) {
        throw Exception('Project not found');
      }

      // Lấy dữ liệu members và ép kiểu về List<String>
      var members = projectDoc.data()?['members'] ?? [];

      // Nếu members là List<dynamic>, ép kiểu thành List<String>
      if (members is List) {
        return members.map((member) => member.toString()).toList();
      } else {
        throw Exception('Invalid members format');
      }
    } catch (e) {
      print('Error fetching project members: $e');
      return [];
    }
  }
}
