import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/screen/upcoming/taskdetail_dialog.dart';
import 'package:bee_task/screen/project/project_screen.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/data/model/task.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedSearchType = 'Task';
  String _searchQuery = '';
  late FirebaseTaskRepository taskRepository;
  late FirebaseUserRepository userRepository;
  var users = TaskData().users;

  var tasks = TaskData().tasks;
  var subtasks = TaskData().subtasks;
  var subsubtasks = TaskData().subsubtasks;
  var projects = TaskData().projects;

  @override
  void initState() {
    super.initState();

    taskRepository =
        FirebaseTaskRepository(firestore: FirebaseFirestore.instance);
    userRepository = FirebaseUserRepository(
      firestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Search',
          style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold), // Chữ màu đen
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Màu biểu tượng
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              focusNode: _searchFocusNode,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Cập nhật kết quả tìm kiếm
                });
              },
              decoration: InputDecoration(
                fillColor: Colors.grey[200],
                filled: true,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tasks, Pojects, Descriptions...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Nội dung thay đổi dựa trên trạng thái của thanh tìm kiếm
          Expanded(
            child: Column(
              children: [
                _searchQuery != ''
                    ? _buildSearchOptions() // Hiển thị ba lựa chọn khi nhấn vào thanh tìm kiếm
                    : _buildDefaultContent(), // Hiển thị nội dung mặc định khi chưa nhấn
                const SizedBox(height: 16.0),
                if (_searchQuery != '')
                  _buildSearchResults(), // Hiển thị kết quả tìm kiếm
              ],
            ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  /// Hiển thị ba lựa chọn tìm kiếm: Task, Project, Description
  Widget _buildSearchOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Search by:',
          //   style: Theme.of(context).textTheme.headlineSmall,
          // ),
          // const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Task', 'Project', 'Description'].map((type) {
              final isSelected = _selectedSearchType == type;
              return Theme(
                data: Theme.of(context).copyWith(
                  chipTheme: Theme.of(context).chipTheme.copyWith(
                        selectedColor: AppColors.primary,
                        secondarySelectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        secondaryLabelStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                ),
                child: ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.grey[100],
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSearchType = type;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Hiển thị nội dung mặc định
  Widget _buildDefaultContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Searching for Tasks, Projects, Descriptions',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Hiển thị kết quả tìm kiếm
  Widget _buildSearchResults() {
    // Tạo danh sách chứa các kết quả đã lọc
    List<Map<String, dynamic>> filteredTasks = [];
    List<Map<String, dynamic>> filteredProjects = [];

    if (_selectedSearchType == 'Task') {
      // Tìm trong danh sách tasks theo title hoặc description
      filteredTasks = [...tasks, ...subtasks, ...subsubtasks].where((task) {
        return task['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    } else if (_selectedSearchType == 'Project') {
      // Tìm trong danh sách projects theo name
      filteredProjects = projects.where((project) {
        return project['name']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    } else if (_selectedSearchType == 'Description') {
      // Tìm trong danh sách tasks theo description
      filteredTasks = [...tasks, ...subtasks, ...subsubtasks].where((task) {
        return task['description']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Kiểm tra nếu không có kết quả nào
    if (_selectedSearchType == 'Task' || _selectedSearchType == 'Description') {
      if (filteredTasks.isEmpty) {
        return Expanded(
          child: Center(
            child: Text(
              'No tasks found for "$_searchQuery"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      }

      // Hiển thị danh sách kết quả cho Task
      return Expanded(
        child: ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return _buildItemCard(task);
          },
        ),
      );
    } else if (_selectedSearchType == 'Project') {
      if (filteredProjects.isEmpty) {
        return Expanded(
          child: Center(
            child: Text(
              'No projects found for "$_searchQuery"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      }

      // Hiển thị danh sách kết quả cho Project
      return Expanded(
        child: ListView.builder(
          itemCount: filteredProjects.length,
          itemBuilder: (context, index) {
            final project = filteredProjects[index];
            return Card(
              color: Colors.grey[100],
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(
                  project['name'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Owner: ${project['owner']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                trailing: Icon(Icons.arrow_forward, color: Colors.grey[700]),
                onTap: () {
                  _navigateToProjectDetails(project);
                },
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

// Hàm điều hướng đến chi tiết Project
  void _navigateToProjectDetails(var project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectScreen(
            projectId: project['id'],
            projectName: project['name'],
            isShare: true,
            isEditProject: true,
            taskRepository: taskRepository,
            userRepository: userRepository),
      ),
    );
  }

  Widget _buildItemCard(var item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.grey[100],
      child: GestureDetector(
        onTap: () {
          _showTaskDetailsDialog(item['id'], item['type'], true,
              item['projectName'], item['completed']);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeaderRow(item),
              _buildSubtaskAndTypeRow(item),
              _buildTaskDescription(item['description']),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng hàng hiển thị số lượng subtasks và projectName
  Widget _buildSubtaskAndTypeRow(var task) {
    int completedSubtasks = 0;
    int totalSubtasks = 0;

    if (task['type'] == 'task') {
      var relevantSubtasks =
          subtasks.where((subtask) => subtask['taskId'] == task['id']).toList();

      totalSubtasks = relevantSubtasks.length;

      completedSubtasks = relevantSubtasks
          .where((subtask) => subtask['completed'] == true)
          .length;
    } else if (task['type'] == 'subtask') {
      var relevantSubsubtasks = subsubtasks
          .where((subsubtask) => subsubtask['subtaskId'] == task['id'])
          .toList();

      totalSubtasks = relevantSubsubtasks.length;
      completedSubtasks = relevantSubsubtasks
          .where((subsubtask) => subsubtask['completed'] == true)
          .length;
    } else {
      totalSubtasks = 0;
      completedSubtasks = 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (totalSubtasks > 0)
          Text(
            '$completedSubtasks / $totalSubtasks',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        if (totalSubtasks == 0) const SizedBox.shrink(),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              task['projectName'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TaskData().getPriorityColor(task['priority']),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDescription(String description) {
    return Text(
      description,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildTaskHeaderRow(var task) {
    var user =
        users.firstWhere((user) => user['userEmail'] == task['assignee']);

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Task updateTask = Task(
              id: task['id'],
              title: task['title'],
              description: task['description'],
              dueDate: task['dueDate'],
              priority: task['priority'],
              assignee: task['assignee'],
              type: task['type'],
              projectName: task['projectName'],
              completed: !task['completed'],
              subtasks: [],
            );
            setState(() {
              task['completed'] = !task['completed'];
              if (task['completed'] == true) {
                if (task['type'] == 'task') {
                  var relevantSubtasks = subtasks
                      .where((subtask) => subtask['taskId'] == task['id'])
                      .toList();
                  relevantSubtasks.forEach((subtask) {
                    subtask['completed'] = true;
                    var relevantSubSubtasks = subsubtasks
                        .where((subsubtask) =>
                            subsubtask['subtaskId'] == subtask['id'])
                        .toList();
                    relevantSubSubtasks.forEach((subsubtask) {
                      subsubtask['completed'] = true;
                    });
                  });
                } else if (task['type'] == 'subtask') {
                  var relevantSubSubtasks = subsubtasks
                      .where(
                          (subsubtask) => subsubtask['subtaskId'] == task['id'])
                      .toList();
                  relevantSubSubtasks.forEach((subsubtask) {
                    subsubtask['completed'] = true;
                  });
                }
              } else {
                if (task['type'] == 'subsubtask') {
                  var relevantSubtasks = subtasks
                      .where((subtask) => subtask['id'] == task['subtaskId'])
                      .toList();
                  relevantSubtasks.forEach((subtask) {
                    subtask['completed'] = false;
                  });

                  var relevantTasks = tasks
                      .where((taskItem) => taskItem['id'] == task['taskId'])
                      .toList();
                  relevantTasks.forEach((taskItem) {
                    taskItem['completed'] = false;
                  });
                } else if (task['type'] == 'subtask') {
                  var relevantTasks = tasks
                      .where((taskItem) => taskItem['id'] == task['taskId'])
                      .toList();
                  relevantTasks.forEach((taskItem) {
                    taskItem['completed'] = false;
                  });
                }
              }
            });
            Provider.of<TaskBloc>(context, listen: false)
                .add(UpdateTask(task['id'], updateTask, task['type']));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: task['completed'] ? Colors.green : Colors.transparent,
              border: Border.all(
                color: TaskData().getPriorityColor(task['priority']),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: task['completed']
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            task['title'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: task['completed'] ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (task['assignee'] != '') ...[
          CircleAvatar(
            radius: 15,
            backgroundColor: TaskData().getColorFromString(user['userColor']),
            child: Text(
              user['userName'][0].toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showTaskDetailsDialog(String taskId, String type,
      bool showCompletedTask, String projectName, bool isCompleted) async {
    bool permissions =
        await TaskData().isUserInProjectPermissions(type, taskId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return SingleChildScrollView(
          child: TaskDetailsDialog(
            taskId: taskId,
            permissions: permissions,
            type: type,
            isCompleted: isCompleted,
            openFirst: true,
            selectDay: DateTime.now(),
            projectName: projectName,
            showCompletedTasks: showCompletedTask,
            taskBloc: BlocProvider.of<TaskBloc>(context),
            resetDialog: () => {},
            resetScreen: () => setState(() {}),
          ),
        );
      },
    );
  }
}
