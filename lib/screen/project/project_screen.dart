import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/bloc/project/project_state.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/bloc/task/task_state.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:bee_task/screen/project/edit_project_screen.dart';
import 'package:bee_task/screen/project/share_screen.dart';
import 'package:bee_task/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/screen/upcoming/taskdetail_dialog.dart';
import 'package:intl/intl.dart';
import 'package:bee_task/screen/upcoming/addtask_dialog.dart';

class ProjectScreen extends StatefulWidget {
  final String projectId;
  String projectName;
  final bool isShare;
  final bool isEditProject;
  FirebaseTaskRepository taskRepository;
  FirebaseUserRepository userRepository;
  final Function resetScreen;

  ProjectScreen(
      {required this.projectId,
      required this.projectName,
      required this.isShare,
      required this.isEditProject,
      required this.taskRepository,
      required this.resetScreen,
      required this.userRepository});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late TaskBloc _taskBloc;
  var tasks = TaskData().tasks;
  var subtasks = TaskData().subtasks;
  var subsubtasks = TaskData().subsubtasks;
  var users = TaskData().users;

  late var task;

  @override
  void initState() {
    super.initState();
    _taskBloc = TaskBloc(FirebaseFirestore.instance, widget.taskRepository,
        widget.userRepository);
    _taskBloc.add(
        LoadTasks(widget.projectId)); // Gọi sự kiện LoadTasks với projectId
  }

  @override
  void dispose() {
    _taskBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _taskBloc,
      child: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectUpdated) {
            setState(() {
              widget.projectName = state.projectName;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              widget.projectName,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
              onPressed: () {
                widget.resetScreen();
                Navigator.pop(context);
              },
            ),
            actions: [
              if (widget.isShare == true)
                IconButton(
                  icon: Icon(Icons.group, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShareScreen(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            resetScreen: () {
                              setState(() {
                                _taskBloc.add(LoadTasks(widget
                                    .projectId)); // Gọi sự kiện LoadTasks với projectId
                              });
                            }),
                      ),
                    );
                  },
                ),
              if (widget.isEditProject == true)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.primary),
                  onSelected: (value) {
                    print('Selected value: $value');
                    if (value == 'edit') {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            content: EditProjectScreen(
                              projectId: widget.projectId,
                              projectName: widget.projectName,
                              resetScreen: widget.resetScreen,
                            ),
                          );
                        },
                      );
                    } else if (value == 'delete') {
                      context
                          .read<ProjectBloc>()
                          .add(DeleteProject(widget.projectId));
                      tasks.removeWhere(
                          (task) => task['projectId'] == widget.projectId);
                      subtasks.removeWhere((subtask) =>
                          subtask['projectId'] == widget.projectId);
                      subsubtasks.removeWhere((subsubtask) =>
                          subsubtask['projectId'] == widget.projectId);
                      Navigator.pop(context);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          title: Text('Edit',
                              style: TextStyle(color: Colors.black)),
                          leading: Icon(Icons.edit),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          title: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          leading: Icon(Icons.delete),
                          iconColor: Colors.red,
                        ),
                      ),
                    ];
                  },
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
          backgroundColor: Colors.white,
          body: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is TaskLoaded) {
                return ListView.builder(
                  itemCount: state.tasks.length,
                  itemBuilder: (context, index) {
                    task = state.tasks[index];
                    return _buildTaskItem(task);
                  },
                );
              } else if (state is TaskError) {
                return Center(child: Text('Error: ${state.error}'));
              } else {
                return Center(child: Text('No tasks available'));
              }
            },
          ),
          floatingActionButton:
              _buildFloatingActionButton(context, widget.projectId),
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(
      BuildContext context, String projectId) {
    return FloatingActionButton(
      onPressed: () {
        _showAddTaskDialog(context, projectId);
      },
      child: Icon(Icons.add, color: Colors.white),
      backgroundColor: AppColors.primary,
      shape: CircleBorder(),
    );
  }

  void _showAddTaskDialog(BuildContext context, String projectId) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            child: AddTaskDialog(
              projectId: projectId,
              taskId: '', // Add appropriate taskId
              type: '', // Add appropriate type
              selectDay: DateTime.now(),
              resetDialog: () => {},
              resetScreen: () => setState(() {}),
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _taskBloc.add(LoadTasks(widget.projectId));
      });
    });
  }

  Widget _buildTaskItem(Task task) {
    var user = users.firstWhere(
      (user) => user['userEmail'] == task.assignee,
      orElse: () => {}, // Return an empty map if not found
    );
    int completedSubtasks = 0;
    int totalSubtasks = 0;
    int commentCount = 0;
    var t = TaskData().tasks.firstWhere((taskF) => taskF['id'] == task.id,
        orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
        );
    commentCount = (t['commentCount'] is int)
        ? t['commentCount']
        : int.tryParse(t['commentCount'].toString()) ?? 0;
    totalSubtasks = task.subtasks.length;

// Đếm số subtask có completed = true
    completedSubtasks =
        task.subtasks.where((subtask) => subtask.completed == true).length;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      elevation: 0,
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        title: GestureDetector(
          onTap: () {
            _showTaskDetailsDialog(task);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  String status = 'complete';
                  if (task.completed == true) {
                    status = 'uncomplete';
                  }
                  setState(() {
                    task.completed = !task.completed;
                    if (task.completed == true) {
                      if (task.subtasks.isNotEmpty) {
                        for (var subtask in task.subtasks) {
                          subtask.completed = true;
                          if (subtask.subtasks.isNotEmpty) {
                            for (var subsubtask in subtask.subtasks) {
                              subsubtask.completed = true;
                            }
                          }
                        }
                      }
                    }
                  });
                  context.read<TaskBloc>().add(logTaskActivity(
                      widget.projectId, task.id, status, {}, 'task'));
                  context
                      .read<TaskBloc>()
                      .add(UpdateTask(task.id, task, 'task'));
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 7),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: task.completed ? Colors.green : Colors.transparent,
                      border: Border.all(
                        color: TaskData().getPriorityColor(task.priority),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: task.completed
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title ?? 'No Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        decoration:
                            task.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    SizedBox(height: 2),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Text(
                        task.description!,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    SizedBox(height: 2),
                    if (task.dueDate != null && task.dueDate!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDueDate(task.dueDate),
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 14),
                          ),
                          Row(
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
                              if (commentCount > 0) ...[
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(Icons.comment,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$commentCount',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(width: 50),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (task.assignee != '' && user.isNotEmpty) ...[
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          TaskData().getColorFromString(user['userColor']),
                      child: Text(
                        user['userName'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        children: task.subtasks.map<Widget>((subtask) {
          return Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: _buildSubtaskItem(subtask, task),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubtaskItem(Task subtask, Task task) {
    var user = users.firstWhere(
      (user) => user['userEmail'] == subtask.assignee,
      orElse: () => {}, // Return an empty map if not found
    );
    int completedSubtasks = 0;
    int totalSubtasks = 0;
    int commentCount = 0;

    var t = TaskData().subtasks.firstWhere((taskF) => taskF['id'] == subtask.id,
        orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
        );
    commentCount = (t['commentCount'] is int)
        ? t['commentCount']
        : int.tryParse(t['commentCount'].toString()) ?? 0;
    totalSubtasks = subtask.subtasks.length;

// Đếm số subtask có completed = true
    completedSubtasks = subtask.subtasks
        .where((subsubtask) => subsubtask.completed == true)
        .length;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      elevation: 0,
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        title: GestureDetector(
          onTap: () {
            _showSubTaskDetailsDialog(subtask);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  String status = 'complete';
                  if (subtask.completed == true) {
                    status = 'uncomplete';
                  }
                  setState(() {
                    subtask.completed = !subtask.completed;
                    if (subtask.completed == true) {
                      if (subtask.subtasks.isNotEmpty) {
                        for (var subsubtask in subtask.subtasks) {
                          subsubtask.completed = true;
                        }
                      }
                    } else {
                      task.completed = false;
                    }
                  });
                  context.read<TaskBloc>().add(logTaskActivity(
                      widget.projectId, subtask.id, status, {}, 'subtask'));
                  context
                      .read<TaskBloc>()
                      .add(UpdateTask(subtask.id, subtask, 'subtask'));
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 7),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color:
                          subtask.completed ? Colors.green : Colors.transparent,
                      border: Border.all(
                        color: TaskData().getPriorityColor(subtask.priority),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: subtask.completed
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtask.title ?? 'No Title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: subtask.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (subtask.description != null &&
                        subtask.description!.isNotEmpty)
                      Text(
                        subtask.description!,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    if (subtask.dueDate != null && subtask.dueDate!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDueDate(subtask.dueDate),
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 14),
                          ),
                          Row(
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
                              if (commentCount > 0) ...[
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(Icons.comment,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$commentCount',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(width: 50),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (subtask.assignee != '' && user.isNotEmpty) ...[
                // If there's an assignee, show their avatar
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          TaskData().getColorFromString(user['userColor']),
                      child: Text(
                        user['userName'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        children: subtask.subtasks.map<Widget>((subsubtask) {
          return Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: _buildSubSubtaskItem(subsubtask, subtask, task),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubSubtaskItem(Task subsubtask, Task subtask, Task task) {
    var user = users.firstWhere(
      (user) => user['userEmail'] == subsubtask.assignee,
      orElse: () => {}, // Return an empty map if not found
    );
    int commentCount = 0;
    var t = TaskData().subsubtasks.firstWhere(
        (taskF) => taskF['id'] == subsubtask.id,
        orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
        );
    commentCount = (t['commentCount'] is int)
        ? t['commentCount']
        : int.tryParse(t['commentCount'].toString()) ?? 0;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      elevation: 0,
      child: GestureDetector(
        onTap: () {
          _showSubSubTaskDetailsDialog(
              subsubtask); // Gọi _showSubSubTaskDetailsDialog khi nhấn vào task
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  String status = 'complete';
                  if (subsubtask.completed == true) {
                    status = 'uncomplete';
                  }
                  setState(() {
                    subsubtask.completed = !subsubtask.completed;
                    if (subsubtask.completed == false) {
                      task.completed = false;
                      subtask.completed = false;
                    }
                  });
                  context.read<TaskBloc>().add(logTaskActivity(widget.projectId,
                      subsubtask.id, status, {}, 'subsubtask'));
                  context
                      .read<TaskBloc>()
                      .add(UpdateTask(subsubtask.id, subsubtask, 'subsubtask'));
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 7, right: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: subsubtask.completed
                          ? Colors.green
                          : Colors.transparent,
                      border: Border.all(
                        color: TaskData().getPriorityColor(subtask.priority),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: subsubtask.completed
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subsubtask.title ?? 'No Title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: subsubtask.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (subsubtask.description != null &&
                        subsubtask.description!.isNotEmpty)
                      Text(
                        subsubtask.description!,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    if (subsubtask.dueDate != null &&
                        subsubtask.dueDate!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDueDate(subsubtask.dueDate),
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 14),
                          ),
                          if (commentCount > 0) ...[
                            Row(
                              children: [
                                Icon(Icons.comment,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '$commentCount',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(width: 50),
                        ],
                      ),
                  ],
                ),
              ),
              if (subsubtask.assignee != '' && user.isNotEmpty) ...[
                // If there's an assignee, show their avatar
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          TaskData().getColorFromString(user['userColor']),
                      child: Text(
                        user['userName'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(Task task) async {
    bool permissions =
        await TaskData().isUserInProjectPermissions('task', task.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: TaskDetailsDialog(
            taskId: task.id.isNotEmpty ? task.id : 'unknown_id',
            type: 'task',
            projectName: widget.projectName,
            showCompletedTasks: true,
            taskBloc: _taskBloc,
            resetDialog: () => {},
            resetScreen: () => setState(() {
              _taskBloc.add(LoadTasks(widget.projectId));
            }),
            permissions: permissions,
            isCompleted: task.completed ?? false,
            openFirst: true,
            selectDay: DateTime.now(),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _taskBloc.add(LoadTasks(widget.projectId));
      });
    });
  }

  void _showSubTaskDetailsDialog(Task task) async {
    bool permissions =
        await TaskData().isUserInProjectPermissions('subtask', task.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: TaskDetailsDialog(
            taskId: task.id.isNotEmpty ? task.id : 'unknown_id',
            type: 'subtask',
            projectName: widget.projectName,
            showCompletedTasks: true,
            taskBloc: _taskBloc,
            resetDialog: () => {},
            resetScreen: () => setState(() {
              _taskBloc.add(LoadTasks(widget.projectId));
            }),
            permissions: permissions,
            isCompleted: task.completed ?? false,
            openFirst: true,
            selectDay: DateTime.now(),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _taskBloc.add(LoadTasks(widget.projectId));
      });
    });
  }

  void _showSubSubTaskDetailsDialog(Task task) async {
    bool permissions =
        await TaskData().isUserInProjectPermissions('subsubtask', task.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: TaskDetailsDialog(
            taskId: task.id.isNotEmpty ? task.id : 'unknown_id',
            type: 'subsubtask',
            projectName: widget.projectName,
            showCompletedTasks: true,
            taskBloc: _taskBloc,
            resetDialog: () => {},
            resetScreen: () => setState(() {
              _taskBloc.add(LoadTasks(widget.projectId));
            }),
            permissions: permissions,
            isCompleted: task.completed ?? false,
            openFirst: true,
            selectDay: DateTime.now(),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _taskBloc.add(LoadTasks(widget.projectId));
      });
    });
  }

  String formatDueDate(String? dueDate) {
    if (dueDate == null || dueDate.isEmpty)
      return 'No date'; // Kiểm tra null hoặc rỗng
    try {
      DateTime parsedDate = DateTime.parse(dueDate);
      return DateFormat('MMM d').format(parsedDate); // Định dạng "Feb 1"
    } catch (e) {
      return 'Invalid date'; // Nếu lỗi parse, trả về chuỗi mặc định
    }
  }

  Color _getColorFromString(String? colorString) {
    final color = colorString?.toLowerCase() ?? 'default';
    switch (color) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return const Color.fromARGB(255, 0, 140, 255);
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return const Color.fromARGB(255, 238, 211, 0);
      case 'purple':
        return Colors.deepPurpleAccent;
      case 'pink':
        return const Color.fromARGB(255, 248, 43, 211);
      default:
        return AppColors.primary; // Default color if the string is unknown
    }
  }

  Widget _buildSubtaskAndTypeRow(Task task) {
    // Số lượng subtasks đã hoàn thành và tổng số subtasks
    int completedSubtasks = 0;
    int totalSubtasks = 0;
    int commentCount = 0;

    if (task.type == 'task') {
      // Kiểm tra nếu 'subtasks' không null và không rỗng
      // Tìm các subtasks có taskId trùng với id của task
      var relevantSubtasks =
          subtasks.where((subtask) => subtask['taskId'] == task.id).toList();

      totalSubtasks = relevantSubtasks.length;
      var t = TaskData().tasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
      commentCount = (t['commentCount'] is int)
          ? t['commentCount']
          : int.tryParse(t['commentCount'].toString()) ?? 0;

      // Đếm số subtask có completed = true
      completedSubtasks = relevantSubtasks
          .where((subtask) => subtask['completed'] == true)
          .length;
    } else if (task.type == 'subtask') {
      // Kiểm tra nếu 'subsubtasks' không null và không rỗng

      // Tương tự cho subsubtask
      var relevantSubsubtasks = subsubtasks
          .where((subsubtask) => subsubtask['subtaskId'] == task.id)
          .toList();
      var t = TaskData().subtasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
      commentCount = (t['commentCount'] is int)
          ? t['commentCount']
          : int.tryParse(t['commentCount'].toString()) ?? 0;

      // Đếm số subtask có completed = true
      completedSubtasks = relevantSubsubtasks
          .where((subtask) => subtask['completed'] == true)
          .length;

      totalSubtasks = relevantSubsubtasks.length;
      completedSubtasks = relevantSubsubtasks
          .where((subsubtask) => subsubtask['completed'] == true)
          .length;
    } else {
      totalSubtasks = 0;
      completedSubtasks = 0;
      var t = TaskData().subsubtasks.firstWhere(
          (taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
      commentCount = (t['commentCount'] is int)
          ? t['commentCount']
          : int.tryParse(t['commentCount'].toString()) ?? 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Hiển thị số lượng subtasks nếu có subtasks
            if (totalSubtasks > 0)
              Text(
                '$completedSubtasks / $totalSubtasks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            if (commentCount > 0) ...[
              const SizedBox(
                  width: 16), // Thêm khoảng cách giữa subtasks và comment
              Row(
                children: [
                  Icon(Icons.comment,
                      size: 16, color: Colors.grey[600]), // Icon comment
                  const SizedBox(
                      width: 4), // Khoảng cách giữa icon và số lượng comment
                  Text(
                    '$commentCount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}
