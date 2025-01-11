import 'package:cloud_firestore/cloud_firestore.dart';

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
    String userEmail = userChange.doc['userEmail'];
    var userData = userChange.doc.data() as Map<String, dynamic>;

    // Kiểm tra xem người dùng đã có trong danh sách chưa
    int index = users.indexWhere((user) => user['userEmail'] == userEmail);

    if (userChange.type == DocumentChangeType.added) {
      // Thêm người dùng mới vào danh sách
      if (index == -1) {
        users.add(userData);
      }
    } else if (userChange.type == DocumentChangeType.modified) {
      // Cập nhật thông tin người dùng trong danh sách
      if (index != -1) {
        users[index] = userData;
      }
    } else if (userChange.type == DocumentChangeType.removed) {
      // Xóa người dùng khỏi danh sách
      if (index != -1) {
        users.removeAt(index);
      }
    }
  }

  // Cập nhật danh sách projects
  void _updateProjects(DocumentChange projectChange) {
    String projectId = projectChange.doc.id;
    var projectData = projectChange.doc.data() as Map<String, dynamic>;
    projectData['id'] = projectId;

    if (projectChange.type == DocumentChangeType.added) {
      projects.add(projectData);
    } else if (projectChange.type == DocumentChangeType.modified) {
      int index = projects.indexWhere((project) => project['id'] == projectId);
      if (index != -1) projects[index] = projectData;
    } else if (projectChange.type == DocumentChangeType.removed) {
      projects.removeWhere((project) => project['id'] == projectId);
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
      tasks.add(taskData);
    } else if (taskChange.type == DocumentChangeType.modified) {
      int index = tasks.indexWhere((task) => task['id'] == taskId);
      if (index != -1) tasks[index] = taskData;
    } else if (taskChange.type == DocumentChangeType.removed) {
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
    subtaskData['projectId'] = taskId;
    subtaskData['type'] = 'subtask';
    subtaskData['projectName'] = projectName;

    if (subtaskChange.type == DocumentChangeType.added) {
      subtasks.add(subtaskData);
    } else if (subtaskChange.type == DocumentChangeType.modified) {
      int index = subtasks.indexWhere((subtask) => subtask['id'] == subtaskId);
      if (index != -1) subtasks[index] = subtaskData;
    } else if (subtaskChange.type == DocumentChangeType.removed) {
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
      subsubtasks.add(subsubtaskData);
    } else if (subsubtaskChange.type == DocumentChangeType.modified) {
      int index = subsubtasks
          .indexWhere((subsubtask) => subsubtask['id'] == subsubtaskId);
      if (index != -1) subsubtasks[index] = subsubtaskData;
    } else if (subsubtaskChange.type == DocumentChangeType.removed) {
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

  // Tính tổng số subtasks tương ứng với taskId
  int getSubtaskCount(String taskId) {
    int count = subtasks.where((subtask) => subtask['taskId'] == taskId).length;
    return count;
  }

  // Tính tổng số subsubtasks tương ứng với subtaskId
  int getSubsubtaskCount(String subtaskId) {
    int count = subsubtasks
        .where((subsubtask) => subsubtask['subtaskId'] == subtaskId)
        .length;
    return count;
  }

  int getCompletedSubtaskCount(String taskId) {
    int count = subtasks
        .where((subtask) =>
            subtask['taskId'] == taskId && subtask['completed'] == true)
        .length;
    return count;
  }

  int getCompletedSubSubtaskCount(String subtaskId) {
    int count = subtasks
        .where((subtask) =>
            subtask['subtaskId'] == subtaskId && subtask['completed'] == true)
        .length;
    return count;
  }
}
