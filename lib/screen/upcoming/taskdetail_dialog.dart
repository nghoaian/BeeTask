import 'package:bee_task/bloc/task/task_event.dart';
import 'package:intl/intl.dart';
import 'package:bee_task/util/colors.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:bee_task/screen/upcoming/addtask_dialog.dart';
import 'package:bee_task/screen/upcoming/CommentsDialog.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/bloc/task/task_state.dart';

class TaskDetailsDialog extends StatefulWidget {
  final String taskId;
  final String type;
  final String projectName;
  final DateTime selectDay; // Ngày được chọn để thêm task

  bool showCompletedTasks;
  final TaskBloc taskBloc;
  final Function resetScreen;
  final Function resetDialog;
  final bool permissions;
  bool isCompleted;
  bool openFirst;

  TaskDetailsDialog(
      {required this.taskId,
      required this.type,
      required this.projectName,
      required this.showCompletedTasks,
      required this.taskBloc,
      required this.resetScreen,
      required this.selectDay,
      required this.resetDialog,
      required this.permissions,
      required this.isCompleted,
      required this.openFirst});

  @override
  _TaskDetailsDialogState createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isNotOneMem = false;

  var users = TaskData().users;
  var project = TaskData().projects;
  var tasks = TaskData().tasks;
  var subtasks = TaskData().subtasks;
  var subsubtasks = TaskData().subsubtasks;
  var task;
  @override
  void initState() {
    super.initState();
    check();
    _fetchTask();
  }

  Future<void> check() async {
    isNotOneMem = await checkMember();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(26.0),
        topRight: Radius.circular(26.0),
      ),
      child: Container(
        color: Colors.white,
        child: StreamBuilder<TaskState>(
          stream: BlocProvider.of<TaskBloc>(context).stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Error fetching task details: ${snapshot.error}'));
            }

            if (snapshot.hasData) {
              final state = snapshot.data;

              if (state is DetailTaskLoaded) {
                task = state.tasks;

                if (task == {}) {
                  return const Center(child: Text('Task not found.'));
                }

                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: _buildTaskNameEditDialog(context, task),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDueDatePicker(context, task),
                        const SizedBox(height: 8.0),
                        _buildPriorityEditDialog(context, task),
                        const SizedBox(height: 8.0),
                        _buildProjectText(widget.projectName),
                        const SizedBox(height: 8.0),
                        _buildDescriptionEdit(context, task),
                        const SizedBox(height: 8.0),
                        buildCompletedSubtasksRow(task),
                        const SizedBox(height: 8.0),

                        // Dynamically display subtasks and subsubtasks
                        if ((task['subtasks'] != null &&
                            task['subtasks'].isNotEmpty)) ...[
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.8,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var subtask
                                        in task['subtasks'] ?? []) ...[
                                      if (!widget.showCompletedTasks &&
                                          !subtask['completed']) ...[
                                        buildSubtaskRow(task, subtask),
                                        const SizedBox(height: 2.0),
                                        if (subtask['subsubtasks'] != null &&
                                            subtask['subsubtasks'].isNotEmpty)
                                          for (var subsubtask
                                              in subtask['subsubtasks'] ?? [])
                                            if (!subsubtask['completed'])
                                              buildSubsubtasks(
                                                  task, subtask, subsubtask),
                                        const SizedBox(height: 2.0),
                                      ] else if (widget.showCompletedTasks) ...[
                                        buildSubtaskRow(task, subtask),
                                        const SizedBox(height: 2.0),
                                        if (subtask['subsubtasks'] != null &&
                                            subtask['subsubtasks'].isNotEmpty)
                                          for (var subsubtask
                                              in subtask['subsubtasks'] ?? [])
                                            buildSubsubtasks(
                                                task, subtask, subsubtask),
                                        const SizedBox(height: 2.0),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ] else if ((task['subsubtasks'] != null &&
                            task['subsubtasks'].isNotEmpty)) ...[
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.8,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Subtasks:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8.0),
                                    for (var subsubtask
                                        in task['subsubtasks'] ?? []) ...[
                                      if (widget.showCompletedTasks ==
                                          false) ...[
                                        if (subsubtask['completed'] == false)
                                          buildSubtaskRow(task, subsubtask),
                                      ] else ...[
                                        buildSubtaskRow(task, subsubtask),
                                      ]
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Căn giữa theo chiều ngang
                      children: [
                        if (widget.type != 'subsubtask' &&
                            widget.permissions == true) ...[
                          Expanded(
                            child: buildAddSubtaskButton(),
                          ),
                          const SizedBox(
                              width: 10), // Tạo khoảng cách giữa 2 nút
                        ],
                        Expanded(
                          child: buildAddCommentAndUploadButton(),
                        ),
                      ],
                    )
                  ],
                );
              } else if (state is TaskError) {
                return Center(child: Text('Error: ${state.error}'));
              }
            }

            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  Widget _buildDueDatePicker(BuildContext context, Map<String, dynamic> task) {
    // Chuyển đổi chuỗi dueDate sang DateTime
    DateTime dueDate = task['dueDate'] != null
        ? DateTime.parse(task['dueDate']) // Chuyển đổi chuỗi "YYYY-MM-DD"
        : DateTime.now(); // Nếu không có thì lấy ngày hiện tại

    return GestureDetector(
      onTap: () async {
        if (widget.permissions == true) {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: dueDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (pickedDate != null) {
            String formattedDate =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}"; // Định dạng "YYYY-MM-DD"
            context.read<TaskBloc>().add(logTaskActivity(
                task['projectId'],
                task['id'],
                'update',
                {
                  'dueDate': {
                    'oldValue': task['dueDate'],
                    'newValue': formattedDate,
                  },
                },
                widget.type));

            setState(() {
              task['dueDate'] = formattedDate;
            });
            Task taskUpdate = Task(
              id: task['id'],
              title: task['title'],
              description: task['description'],
              dueDate: task['dueDate'],
              priority: task['priority'],
              assignee: task['assignee'],
              type: widget.type,
              projectName: widget.projectName,
              completed: task['completed'],
              subtasks: [],
            );
            _updateTask(taskUpdate.id, taskUpdate, taskUpdate.type);
          }

          // Cập nhật Firestore
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Due Date: ${DateFormat('dd/MM/yyyy').format(dueDate)}', // Hiển thị đúng định dạng
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Widget để hiển thị tên task và dialog chỉnh sửa
  Widget _buildTaskNameEditDialog(BuildContext context, var taskData) {
    final GlobalKey _menuKey = GlobalKey();
    return GestureDetector(
      onTap: () async {
        // Hiển thị dialog chỉnh sửa tên task
        if (widget.permissions == true) {
          String? newTitle = await _returnTaskName(context, taskData);

          if (newTitle != null && newTitle.trim().isNotEmpty) {
            setState(() {
              taskData['title'] = newTitle; // Cập nhật UI ở đây
            });
          }
        }
      },
      child: Row(
        children: [
          _buildAssigneeAvatar(taskData['assignee']),
          const SizedBox(width: 16), // Khoảng cách giữa avatar và tiêu đề
          Expanded(
            child: Text(
              taskData['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            key: _menuKey,
            onPressed: () {
              final RenderBox renderBox =
                  _menuKey.currentContext!.findRenderObject() as RenderBox;
              final Offset offset = renderBox.localToGlobal(Offset.zero);
              final Size size = renderBox.size;

              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  offset.dx, // Tọa độ X của widget
                  offset.dy + size.height, // Ngay dưới widget
                  offset.dx + size.width,
                  offset.dy + size.height * 2,
                ),
                items: [
                  if (widget.permissions == true) ...[
                    if (isNotOneMem != false) ...[
                      PopupMenuItem(
                        value: 'assignUser',
                        child: const Text('Change Assignee'),
                      ),
                    ],
                  ],
                  if (widget.isCompleted == false) ...[
                    PopupMenuItem(
                      value: 'markAsComplete',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mark Task as Complete'),
                        ],
                      ),
                    ),
                  ] else ...[
                    PopupMenuItem(
                      value: 'markAsComplete',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mark Task as Uncomplete'),
                        ],
                      ),
                    ),
                  ],
                  PopupMenuItem(
                    value: 'toggleCompletedTasksVisibility',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Show Completed Sub-Tasks'),
                        if (widget.showCompletedTasks)
                          const Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ),
                  if (widget.permissions != false)
                    PopupMenuItem(
                      value: 'deleteTask',
                      child: const Text('Delete Task'),
                    ),
                ],
              ).then((value) async {
                FocusScope.of(context).requestFocus(FocusNode());

                if (value == 'assignUser') {
                  var task;

                  // Lấy thông tin task
                  if (widget.type == 'task') {
                    task = TaskData().tasks.firstWhere(
                        (task) => task['id'] == widget.taskId,
                        orElse: () =>
                            {} // Nếu không tìm thấy, trả về một Map trống
                        );
                  } else if (widget.type == 'subtask') {
                    task = TaskData().subtasks.firstWhere(
                        (task) => task['id'] == widget.taskId,
                        orElse: () =>
                            {} // Nếu không tìm thấy, trả về một Map trống
                        );
                  } else {
                    task = TaskData().subsubtasks.firstWhere(
                        (task) => task['id'] == widget.taskId,
                        orElse: () =>
                            {} // Nếu không tìm thấy, trả về một Map trống
                        );
                  }

                  if (task != null && task.isNotEmpty) {
                    // Lấy danh sách project members
                    var projectMembers =
                        await TaskData().getProjectMembers(task['projectId']);
                    if (projectMembers != null && projectMembers.length > 1) {
                      String newAssignee = await _changeAssignee(
                          task['assignee'], projectMembers);
                      context.read<TaskBloc>().add(logTaskActivity(
                          taskData['projectId'],
                          taskData['id'],
                          'update',
                          {
                            'assignee': {
                              'oldValue': taskData['assignee'],
                              'newValue': newAssignee,
                            },
                          },
                          widget.type));

                      Task updateTask = Task(
                        id: taskData['id'],
                        title: taskData['title'],
                        description: taskData['description'],
                        dueDate: taskData['dueDate'],
                        priority: taskData['priority'],
                        assignee: newAssignee, // Cập nhật assignee
                        type: widget.type,
                        projectName: widget.projectName,
                        completed: taskData['completed'],
                        subtasks: [],
                      );
                      setState(() {
                        taskData['assignee'] = newAssignee;
                      });
                      // Gửi cập nhật lên Firestore
                      _updateTask(updateTask.id, updateTask, updateTask.type);
                    }
                  }
                } else if (value == 'toggleCompletedTasksVisibility') {
                  changeShowCompletedTasksVisibility();
                } else if (value == 'deleteTask') {
                  await _confirmAndDeleteTask();
                  context.read<TaskBloc>().add(logTaskActivity(
                      taskData['projectId'],
                      taskData['id'],
                      'delete',
                      taskData,
                      widget.type));
                  Navigator.pop(context);
                } else if (value == 'markAsComplete') {
                  String status = 'complete';
                  if (taskData['completed'] == true) {
                    status = 'uncomplete';
                  }
                  context.read<TaskBloc>().add(logTaskActivity(
                      taskData['projectId'],
                      taskData['id'],
                      status,
                      {},
                      widget.type));

                  setState(() {
                    widget.isCompleted = !widget.isCompleted;
                    taskData['completed'] = !taskData['completed'];

                    if (taskData['completed'] == true) {
                      if (taskData['type'] == 'task') {
                        var relevantTask = tasks.firstWhere(
                            (t) => t['id'] == taskData['id'],
                            orElse: () => {});

                        // Nếu tìm thấy task, tìm các subtasks liên quan
                        if (relevantTask != null || relevantTask.isNotEmpty) {
                          relevantTask['completed'] = true;

                          var relevantSubtasks = subtasks
                              .where((subtask) =>
                                  subtask['taskId'] == relevantTask['id'])
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
                        }
                      } else if (taskData['type'] == 'subtask') {
                        var relevantSubTask = subtasks.firstWhere(
                            (t) => t['id'] == taskData['id'],
                            orElse: () => {});

                        if (relevantSubTask != null ||
                            relevantSubTask.isNotEmpty) {
                          relevantSubTask['completed'] = true;

                          var relevantSubSubtasks = subsubtasks
                              .where((subsubtask) =>
                                  subsubtask['subtaskId'] ==
                                  relevantSubTask['id'])
                              .toList();
                          relevantSubSubtasks.forEach((subsubtask) {
                            subsubtask['completed'] = true;
                          });
                        }
                      }
                    } else {
                      if (taskData['type'] == 'subsubtask') {
                        var relevantSubSubTask = subsubtasks.firstWhere(
                            (t) => t['id'] == taskData['id'],
                            orElse: () => {});

                        if (relevantSubSubTask != null ||
                            relevantSubSubTask.isNotEmpty) {
                          relevantSubSubTask['completed'] = false;

                          var relevantSubtasks = subtasks
                              .where((subtask) =>
                                  subtask['id'] ==
                                  relevantSubSubTask['subtaskId'])
                              .toList();
                          relevantSubtasks.forEach((subtask) {
                            subtask['completed'] = false;
                          });

                          var relevantTasks = tasks
                              .where((taskItem) =>
                                  taskItem['id'] ==
                                  relevantSubSubTask['taskId'])
                              .toList();
                          relevantTasks.forEach((taskItem) {
                            taskItem['completed'] = false;
                          });
                        }
                      } else if (taskData['type'] == 'subtask') {
                        var relevantSubTask = subtasks.firstWhere(
                            (t) => t['id'] == taskData['id'],
                            orElse: () => {});

                        if (relevantSubTask != null ||
                            relevantSubTask.isNotEmpty) {
                          relevantSubTask['completed'] = false;

                          var relevantTasks = tasks
                              .where((taskItem) =>
                                  taskItem['id'] == relevantSubTask['taskId'])
                              .toList();
                          relevantTasks.forEach((taskItem) {
                            taskItem['completed'] = false;
                          });
                        }
                      } else {
                        var relevantTask = tasks.firstWhere(
                            (t) => t['id'] == taskData['id'],
                            orElse: () => {});

                        // Nếu tìm thấy task, tìm các subtasks liên quan
                        if (relevantTask != null || relevantTask.isNotEmpty) {
                          relevantTask['completed'] = false;
                        }
                      }
                    }
                  });

                  Task task = Task(
                    id: taskData['id'],
                    title: taskData['title'],
                    description: taskData['description'],
                    dueDate: taskData['dueDate'],
                    priority: taskData['priority'],
                    assignee: taskData['assignee'],
                    type: widget.type,
                    projectName: widget.projectName,
                    completed: taskData['completed'],
                    subtasks: [],
                  );
                  _updateTask(task.id, task, task.type);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _returnTaskName(BuildContext context, var taskData) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        String initialValue = taskData['title'] ?? '';
        final TextEditingController _controller =
            TextEditingController(text: initialValue);
        final FocusNode _focusNode = FocusNode();
        String temporaryTitle = initialValue;
        String taskNameError = '';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
        });

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Name'),
              content: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    temporaryTitle = value;
                    taskNameError =
                        value.trim().isEmpty ? 'Task name cannot be empty' : '';
                  });
                },
                decoration: InputDecoration(
                  errorText: taskNameError.isNotEmpty ? taskNameError : null,
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Trả về null khi Cancel
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (temporaryTitle.trim().isNotEmpty) {
                      context.read<TaskBloc>().add(logTaskActivity(
                          taskData['projectId'],
                          taskData['id'],
                          'update',
                          {
                            'title': {
                              'oldValue': taskData['title'],
                              'newValue': temporaryTitle,
                            },
                          },
                          widget.type));

                      Task task = Task(
                        id: taskData['id'],
                        title: temporaryTitle,
                        description: taskData['description'],
                        dueDate: taskData['dueDate'],
                        priority: taskData['priority'],
                        assignee: taskData['assignee'],
                        type: widget.type,
                        projectName: widget.projectName,
                        completed: taskData['completed'],
                        subtasks: [],
                      );
                      _updateTask(task.id, task, task.type);

                      Navigator.pop(
                          dialogContext, temporaryTitle); // Trả về giá trị mới
                    } else {
                      setState(() {
                        taskNameError = 'Task name cannot be empty';
                      });
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Widget để hiển thị nút thêm subtask
  Widget buildAddSubtaskButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Container(
        width: 140, // Giảm chiều rộng
        height: 36, // Giảm chiều cao
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: Colors.white,
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor: 0.9,
                  child: AddTaskDialog(
                      projectId: '',
                      taskId: widget.taskId,
                      type: widget.type,
                      selectDay: widget.selectDay ?? DateTime.now(),
                      resetDialog: () => setState(() {
                            _fetchTask();
                            widget.isCompleted = false;
                          }),
                      resetScreen: () => () {
                            widget.resetScreen;
                          }),
                );
              },
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            minimumSize: Size(140, 36),
          ),
          child: const Text(
            'Add Subtask',
            style: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityEditDialog(
      BuildContext context, Map<String, dynamic> taskData) {
    return GestureDetector(
      onTap: () {
        // Hiển thị dialog chỉnh sửa tên task
        if (widget.permissions == true) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Edit Priority'),
              content: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButton<String>(
                  value: taskData['priority'] ?? 'Low',
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<TaskBloc>().add(logTaskActivity(
                          taskData['projectId'],
                          taskData['id'],
                          'update',
                          {
                            'priority': {
                              'oldValue': taskData['priority'],
                              'newValue': newValue,
                            },
                          },
                          widget.type));
                      setState(() {
                        taskData['priority'] = newValue;
                        Task task = Task(
                          id: taskData['id'],
                          title: taskData['title'],
                          description: taskData['description'],
                          dueDate: taskData['dueDate'],
                          priority: taskData['priority'],
                          assignee: taskData['assignee'],
                          type: widget.type,
                          projectName: widget.projectName,
                          completed: taskData['completed'],
                          subtasks: [],
                        );
                        _updateTask(task.id, task, task.type);
                      });
                      Navigator.pop(context); // Close the dialog
                    }
                  },
                  items: ['High', 'Medium', 'Low']
                      .map((priority) => DropdownMenuItem<String>(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        }
      },
      child: Text(
        'Priority: ${taskData['priority'] ?? 'Low'}', // Display priority
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

// Widget để hiển thị thông tin Project
  Widget _buildProjectText(String projectName) {
    return Text(
      'Project: $projectName',
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

// Widget để hiển thị description và dialog chỉnh sửa
  Widget _buildDescriptionEdit(
      BuildContext context, Map<String, dynamic> taskData) {
    return GestureDetector(
      onTap: () {
        if (widget.permissions == true) {
          showDialog(
            context: context,
            builder: (_) {
              // Tạo FocusNode để quản lý focus của TextField
              final FocusNode _focusNode = FocusNode();
              // Tạo TextEditingController
              final TextEditingController _controller =
                  TextEditingController(text: taskData['description']);
              // Lưu trữ giá trị mô tả tạm thời để so sánh khi nhấn Save hoặc Cancel
              String temporaryDescription = taskData['description'];

              // Kích hoạt bàn phím khi dialog hiển thị
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNode.requestFocus();
              });

              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('Edit Description'),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: 300), // Giới hạn chiều cao
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode, // Gán FocusNode vào TextField
                      onChanged: (value) {
                        temporaryDescription =
                            value; // Lưu giá trị vào biến tạm
                      },
                      maxLines: null, // Cho phép nhập nhiều dòng
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.multiline, // Hỗ trợ nhập nhiều dòng
                      textInputAction:
                          TextInputAction.newline, // Cho phép nhập nhiều dòng
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                actions: [
                  // Nút Cancel
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng dialog mà không lưu
                    },
                    child: const Text('Cancel',
                        style: TextStyle(
                          color: AppColors.primary,
                        )),
                  ),
                  // Nút Save
                  TextButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(logTaskActivity(
                          taskData['projectId'],
                          taskData['id'],
                          'update',
                          {
                            'description': {
                              'oldValue': taskData['description'],
                              'newValue': temporaryDescription,
                            },
                          },
                          widget.type));
                      setState(() {
                        taskData['description'] = temporaryDescription;
                        Task task = Task(
                          id: taskData['id'],
                          title: taskData['title'],
                          description: taskData['description'],
                          dueDate: taskData['dueDate'],
                          priority: taskData['priority'],
                          assignee: taskData['assignee'],
                          type: widget.type,
                          projectName: widget.projectName,
                          completed: taskData['completed'],
                          subtasks: [],
                        );
                        _updateTask(task.id, task, task.type);
                      });
                      Navigator.pop(context); // Đóng dialog sau khi lưu
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Text(
        'Description: ${taskData['description']}',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }

// Widget để hiển thị số lượng subtask đã hoàn thành
  Widget buildCompletedSubtasksRow(var task) {
    int totalSubtasks = 0;
    int completedSubtasks = 0;
    if (task['type'] == 'task' && task['subtasks'] != null) {
      totalSubtasks = task['subtasks'].length;
      completedSubtasks = task['subtasks']
          .where((subtask) => subtask['completed'] == true)
          .length;
    } else if (task['type'] == 'subtask' && task['subsubtasks'] != null) {
      totalSubtasks = task['subsubtasks'].length;
      completedSubtasks = task['subsubtasks']
          .where((subsubtask) => subsubtask['completed'] == true)
          .length;
    }

    return Row(
      children: [
        if (totalSubtasks > 0)
          Text(
            'Completed Subtasks: $completedSubtasks / $totalSubtasks',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
      ],
    );
  }

  Widget buildSubtaskRow(var task, var subtask) {
    int completedSubtasks = 0;
    int totalSubtasks = 0;
    if (subtask['type'] == 'subtask' && subtask['subsubtasks'] != null) {
      totalSubtasks = subtask['subsubtasks'].length;
      completedSubtasks = subtask['subsubtasks']
          .where((subsubtask) => subsubtask['completed'] == true)
          .length;
    }
    if (widget.isCompleted == true) {
      subtask['completed'] = true;
    }

    return GestureDetector(
      onTap: () async {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return SingleChildScrollView(
              child: TaskDetailsDialog(
                taskId: subtask['id'],
                type: subtask['type'],
                openFirst: false,
                isCompleted: subtask['completed'],
                selectDay: widget.selectDay,
                projectName: widget.projectName,
                showCompletedTasks: widget.showCompletedTasks,
                permissions: widget.permissions,
                taskBloc: widget.taskBloc,
                resetScreen: widget.resetScreen,
                resetDialog: () => setState(() {
                  _fetchTask();
                }),
              ),
            );
          },
        ).whenComplete(() {
          _fetchTask();
        });
      },
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              CompleteTask(subtask, task, subtask);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: subtask['completed'] == true
                    ? Colors.green
                    : Colors.transparent,
                border: Border.all(
                  color: TaskData().getPriorityColor(subtask['priority']),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: subtask['completed'] == true
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
              '${subtask['title']}'
              '${subtask['subsubtasks'] != null && subtask['subsubtasks'].isNotEmpty ? ' ($completedSubtasks/$totalSubtasks)' : ''}',
              style: TextStyle(
                color:
                    subtask['completed'] == true ? Colors.green : Colors.black,
                decoration: subtask['completed'] == true
                    ? TextDecoration.lineThrough
                    : null,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Hiển thị avatar hoặc khoảng trống
          _buildAssigneeAvatar(subtask['assignee']),
          const SizedBox(width: 16), // Khoảng cách giữa avatar và tiêu đề
        ],
      ),
    );
  }

  Widget buildSubsubtasks(var task, var subtask, var subsubtask) {
    if (widget.isCompleted == true) {
      subsubtask['completed'] = true;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return SingleChildScrollView(
                    child: TaskDetailsDialog(
                      taskId: subsubtask['id'],
                      type: subsubtask['type'],
                      openFirst: false,
                      isCompleted: subsubtask['completed'],
                      permissions: widget.permissions,
                      selectDay: widget.selectDay,
                      projectName: widget.projectName,
                      showCompletedTasks: widget.showCompletedTasks,
                      taskBloc: widget.taskBloc,
                      resetScreen: widget.resetScreen,
                      resetDialog: () => setState(() {
                        _fetchTask();
                      }),
                    ),
                  );
                },
              ).whenComplete(() {
                _fetchTask();
              });
            },
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    CompleteTask(subsubtask, task, subtask);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: subsubtask['completed'] == true
                          ? Colors.green
                          : Colors.transparent,
                      border: Border.all(
                        color: TaskData().getPriorityColor(
                          subsubtask['priority'],
                        ),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: subsubtask['completed'] == true
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
                    subsubtask['title'],
                    style: TextStyle(
                      color: subsubtask['completed'] == true
                          ? Colors.green
                          : Colors.black,
                      decoration: subsubtask['completed'] == true
                          ? TextDecoration.lineThrough
                          : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Hiển thị avatar người được giao hoặc khoảng trống
                _buildAssigneeAvatar(subsubtask['assignee']),
                const SizedBox(width: 16), // Khoảng cách giữa avatar và tiêu đề
              ],
            ),
          ),
        ),
      ],
    );
  }

// Widget để hiển thị nút thêm comment và upload file
  Widget buildAddCommentAndUploadButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Container(
        width: 140, // Giảm chiều rộng tổng thể của button
        height: 36, // Giảm chiều cao
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: () async {
            await showModalBottomSheet(
              backgroundColor: Colors.white,
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor: 0.8,
                  child: CommentsDialog(
                    idTask: widget.taskId,
                    type: widget.type,
                  ),
                );
              },
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            minimumSize: Size(140, 36), // Giảm kích thước nhỏ hơn nữa
          ),
          child: const Text(
            'Add Comment',
            style: TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
        ),
      ),
    );
  }

  Future<String> _changeAssignee(
      String currentAssignee, var projectMembers) async {
    String? newAssignee = currentAssignee;

    if (projectMembers.isNotEmpty) {
      // Hiển thị dialog cho việc chọn assignee mới
      newAssignee = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          // Đặt currentAssignee làm giá trị mặc định nếu nó không rỗng
          String? selectedAssignee =
              currentAssignee.isNotEmpty ? currentAssignee : null;

          return AlertDialog(
            title: const Text('Change Assignee'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: projectMembers.length,
                itemBuilder: (context, index) {
                  var member = projectMembers[index];
                  return RadioListTile<String>(
                    title: Text(member), // Hiển thị tên người dùng
                    value: member,
                    groupValue: selectedAssignee,
                    onChanged: (value) {
                      selectedAssignee = value;
                      Navigator.of(context)
                          .pop(selectedAssignee); // Đóng dialog sau khi chọn
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog nếu nhấn Cancel
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      // Kiểm tra nếu assignee được chọn và không null
      if (newAssignee != null && newAssignee.isNotEmpty) {
        return newAssignee;
      }
    }

    return newAssignee ?? ''; // Trả về assignee mới
  }

  Future<void> _confirmAndDeleteTask() async {
    // Hiển thị hộp thoại xác nhận
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Hủy (No)
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Xác nhận (Yes)
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    // Nếu người dùng chọn Yes, tiến hành xóa task
    if (confirmDelete == true) {
      await _deleteTask();
    }
  }

  Future<void> _deleteTask() async {
    try {
      var dialogContext;
      showDialog(
        context: context,
        barrierDismissible:
            false, // Không cho phép đóng dialog khi nhấn bên ngoài
        builder: (BuildContext context) {
          dialogContext = context; // Lưu context của dialog để đóng sau
          return AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text('Deleting task...'), // Thông báo đang xoá
              ],
            ),
          );
        },
      );

      widget.taskBloc.add(DeleteTask(widget.taskId, widget.type));

      // Chờ Firebase cập nhật hoàn tất
      await Future.delayed(Duration(seconds: 2));

      // Đóng dialog sau khi cập nhật xong
      Navigator.pop(dialogContext);
      if (widget.openFirst != true) {
        widget.resetDialog();
      } else {
        widget.resetScreen();
      }
    } catch (e) {
      print("Error deleting task: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  void changeShowCompletedTasksVisibility() async {
    setState(() {
      widget.showCompletedTasks = !widget.showCompletedTasks;
    });
  }

  Widget _buildAssigneeAvatar(String assingee) {
    if (assingee != '') {
      var user = users.firstWhere((user) => user['userEmail'] == assingee);

      return CircleAvatar(
        radius: 15,
        backgroundColor: TaskData().getColorFromString(user['userColor']),
        child: Text(
          user['userName'][0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox(
      width: 30,
      height: 30,
    );
  }

  Future<void> _fetchTask() async {
    final completer = Completer<void>();
    final subscription =
        BlocProvider.of<TaskBloc>(context).stream.listen((state) {
      if (state is DetailTaskLoaded || state is TaskError) {
        completer.complete();
      }
    });

    BlocProvider.of<TaskBloc>(context).add(
      DetailsTask(widget.type, widget.taskId),
    );

    await completer.future;
    subscription.cancel(); // Hủy đăng ký sau khi hoàn tất
  }

  Future<void> _updateTask(String id, Task task, String type) async {
    final completer = Completer<void>();
    final subscription =
        BlocProvider.of<TaskBloc>(context).stream.listen((state) {
      if (state is TaskDetailsDialog || state is TaskError) {
        completer.complete();
      }
    });

    BlocProvider.of<TaskBloc>(context).add(UpdateTask(id, task, type));

    await completer.future;
    subscription.cancel(); // Hủy đăng ký sau khi hoàn tất
  }

  Future<bool> checkMember() async {
    var taskData;

    // Lấy thông tin task
    if (widget.type == 'task') {
      taskData = TaskData().tasks.firstWhere(
          (task) => task['id'] == widget.taskId,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    } else if (widget.type == 'subtask') {
      taskData = TaskData().subtasks.firstWhere(
          (task) => task['id'] == widget.taskId,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    } else {
      taskData = TaskData().subsubtasks.firstWhere(
          (task) => task['id'] == widget.taskId,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    }
    if (taskData != null && taskData.isNotEmpty) {
      // Lấy danh sách project members
      var projectMembers =
          await TaskData().getProjectMembers(taskData['projectId']);
      if (projectMembers != null && projectMembers.length > 1) {
        return true;
      }
    }

    return false;
  }

  void CompleteTask(var taskData, var taskF, var subtaskF) {
    print("click");
    Task task = Task(
      id: taskData['id'],
      title: taskData['title'],
      description: taskData['description'],
      dueDate: taskData['dueDate'],
      priority: taskData['priority'],
      assignee: taskData['assignee'],
      type: taskData['type'],
      projectName: widget.projectName,
      completed: taskData['completed'],
      subtasks: [],
    );
    var user = users.firstWhere((user) => user['userEmail'] == task.assignee,
        orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
        );
    var t;
    if (task.type == 'task') {
      t = TaskData().tasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    } else if (task.type == 'subtask') {
      t = TaskData().subtasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    } else {
      t = TaskData().subsubtasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    }

    String status = 'complete';
    if (task.completed == true) {
      status = 'uncomplete';
    }
    context
        .read<TaskBloc>()
        .add(logTaskActivity(t['projectId'], task.id, status, {}, task.type));
    context.read<TaskBloc>().add(UpdateTask(task.id, task, task.type));

    setState(() {
      taskData['completed'] = !taskData['completed'];
      task.completed = !task.completed;
      if (task.completed == true) {
        if (task.type == 'task') {
          for (var subtask in taskData['subtasks']) {
            subtask['completed'] = true;
            for (var subsubtask in subtask['subsubtasks']) {
              subsubtask['completed'] = true;
            }
          }
        } else if (task.type == 'subtask') {
          for (var subsubtask in taskData['subsubtasks']) {
            subsubtask['completed'] = true;
          }
        }
      } else {
        if (task.type == 'subsubtask') {
          subtaskF['completed'] = false;
          widget.isCompleted = false;
          taskF['completed'] = false;
        } else if (task.type == 'subtask') {
          widget.isCompleted = false;

          taskF['completed'] = false;
        }
      }
    });
  }
}
