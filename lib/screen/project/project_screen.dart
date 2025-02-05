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

class ProjectScreen extends StatefulWidget {
  final String projectId;
  String projectName;
  final bool isShare;
  final bool isEditProject;
  FirebaseTaskRepository taskRepository;
  FirebaseUserRepository userRepository;

  ProjectScreen(
      {required this.projectId,
      required this.projectName,
      required this.isShare,
      required this.isEditProject,
      required this.taskRepository,
      required this.userRepository});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late TaskBloc _taskBloc;

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
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              if (widget.isShare == true)
                IconButton(
                  icon: Icon(Icons.group, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ShareScreen(projectId: widget.projectId),
                      ),
                    );
                  },
                ),
              if (widget.isEditProject == true)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
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
                            ),
                          );
                        },
                      );
                    } else if (value == 'delete') {
                      context
                          .read<ProjectBloc>()
                          .add(DeleteProject(widget.projectId));
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
                    final task = state.tasks[index];
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
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              Checkbox(
                value: task.completed,
                onChanged: (value) {
                  // setState(() {
                  //   task.completed = value!;
                  // });
                },
              ),
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
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Text(
                        task.description!,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    if (task.dueDate != null && task.dueDate!.isNotEmpty)
                      Text(
                        formatDueDate(task.dueDate),
                        style:
                            TextStyle(color: AppColors.primary, fontSize: 14),
                      ),
                  ],
                ),
              ),
              // if (task.assignee.isNotEmpty)
              //   CircleAvatar(
              //     radius: 15, // Kích thước radius của avatar
              //     backgroundColor: Colors.white,
              //     child: Text(
              //       task.assignee[0].toUpperCase(),
              //       style: const TextStyle(
              //         color: Colors.black,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              FutureBuilder<String?>(
                future: widget.userRepository.getUserNameByEmail(task.assignee),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Text(
                        '?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    final userName = snapshot.data!;
                    return FutureBuilder<String?>(
                      future: widget.userRepository
                          .getUserColorByEmail(task.assignee),
                      builder: (context, colorSnapshot) {
                        if (colorSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: CircularProgressIndicator(),
                          );
                        } else if (colorSnapshot.hasError ||
                            !colorSnapshot.hasData ||
                            colorSnapshot.data == null) {
                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          final userColor = colorSnapshot.data!;
                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: _getColorFromString(userColor),
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
        children: task.subtasks.map<Widget>((subtask) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _buildSubtaskItem(subtask),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubtaskItem(Task subtask) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
              Checkbox(
                value: subtask.completed,
                onChanged: (value) {
                  // setState(() {
                  //   subtask.completed = value!;
                  // });
                },
              ),
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
                      Text(
                        formatDueDate(subtask.dueDate),
                        style:
                            TextStyle(color: AppColors.primary, fontSize: 14),
                      ),
                  ],
                ),
              ),
              FutureBuilder<String?>(
                future:
                    widget.userRepository.getUserNameByEmail(subtask.assignee),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Text(
                        '?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    final userName = snapshot.data!;
                    return FutureBuilder<String?>(
                      future: widget.userRepository
                          .getUserColorByEmail(subtask.assignee),
                      builder: (context, colorSnapshot) {
                        if (colorSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: CircularProgressIndicator(),
                          );
                        } else if (colorSnapshot.hasError ||
                            !colorSnapshot.hasData ||
                            colorSnapshot.data == null) {
                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          final userColor = colorSnapshot.data!;
                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: _getColorFromString(userColor),
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
        children: subtask.subtasks.map<Widget>((subsubtask) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _buildSubSubtaskItem(subsubtask),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubSubtaskItem(Task subsubtask) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
              Checkbox(
                value: subsubtask.completed,
                onChanged: (value) {
                  // setState(() {
                  //   subsubtask.completed = value!;
                  // });
                },
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
                      Text(
                        formatDueDate(subsubtask.dueDate),
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 14),
                      ),
                  ],
                ),
              ),
              if (subsubtask.assignee != null &&
                  subsubtask.assignee!.isNotEmpty)
                FutureBuilder<String?>(
                  future: widget.userRepository
                      .getUserNameByEmail(subsubtask.assignee),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null) {
                      return const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Text(
                          '?',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else {
                      final userName = snapshot.data!;
                      return FutureBuilder<String?>(
                        future: widget.userRepository
                            .getUserColorByEmail(subsubtask.assignee),
                        builder: (context, colorSnapshot) {
                          if (colorSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: CircularProgressIndicator(),
                            );
                          } else if (colorSnapshot.hasError ||
                              !colorSnapshot.hasData ||
                              colorSnapshot.data == null) {
                            return CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: Text(
                                userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            final userColor = colorSnapshot.data!;
                            return CircleAvatar(
                              radius: 15,
                              backgroundColor: _getColorFromString(userColor),
                              child: Text(
                                userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(Task task) {
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
            resetScreen: () => setState(() {}),
            permissions: true,
            isCompleted: task.completed ?? false,
            openFirst: true,
            selectDay: DateTime.now(),
          ),
        );
      },
    );
  }

  void _showSubTaskDetailsDialog(Task task) {
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
            resetScreen: () => setState(() {}),
            permissions: true,
            isCompleted: task.completed ?? false,
            openFirst: true,
            selectDay: DateTime.now(),
          ),
        );
      },
    );
  }

  void _showSubSubTaskDetailsDialog(Task task) {
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
            resetScreen: () => setState(() {}),
            permissions: true,
            isCompleted: task.completed ?? false,
            openFirst: true,
            selectDay: DateTime.now(),
          ),
        );
      },
    );
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
}
