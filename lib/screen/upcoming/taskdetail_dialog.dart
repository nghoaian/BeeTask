import 'package:bee_task/bloc/task/task_event.dart';
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
  final TaskBloc taskBloc; // Accept TaskBloc via constructor
  final Function resetScreen;
  final Function resetDialog;
  final bool permissions;
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
      required this.openFirst});

  @override
  _TaskDetailsDialogState createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isNotOneMem = false;
  @override
  void initState() {
    super.initState();
    check();
    _fetchTask();
  }

  Future<void> check() async {
    isNotOneMem = await checkMember();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskState>(
      stream: BlocProvider.of<TaskBloc>(context).stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error fetching task details: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          final state = snapshot.data;

          if (state is DetailTaskLoaded) {
            // Find the specific task by ID
            final task = state.tasks;

            if (task == {}) {
              return const Center(child: Text('Task not found.'));
            }

            return AlertDialog(
              title: _buildTaskNameEditDialog(context, task),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriorityEditDialog(context, task),
                    const SizedBox(height: 8.0),
                    _buildProjectText(widget.projectName),
                    const SizedBox(height: 8.0),
                    _buildDescriptionEdit(context, task),
                    const SizedBox(height: 16.0),
                    buildCompletedSubtasksRow(),
                    const SizedBox(height: 12.0),

                    // Dynamically display subtasks and subsubtasks
                    if ((task['subtasks'] != null &&
                        task['subtasks'].isNotEmpty)) ...[
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Subtasks:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8.0),
                                for (var subtask in task['subtasks'] ?? []) ...[
                                  if (!widget.showCompletedTasks &&
                                      !subtask['completed']) ...[
                                    buildSubtaskRow(subtask, 'subtask'),
                                    if (subtask['subsubtasks'] != null &&
                                        subtask['subsubtasks'].isNotEmpty)
                                      for (var subsubtask
                                          in subtask['subsubtasks'] ?? [])
                                        if (!subsubtask['completed'])
                                          buildSubsubtasks(subsubtask,
                                              'subsubtask', subtask['id']),
                                  ] else if (widget.showCompletedTasks) ...[
                                    buildSubtaskRow(subtask, 'subtask'),
                                    if (subtask['subsubtasks'] != null &&
                                        subtask['subsubtasks'].isNotEmpty)
                                      for (var subsubtask
                                          in subtask['subsubtasks'] ?? [])
                                        buildSubsubtasks(subsubtask,
                                            'subsubtask', subtask['id']),
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
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Subtasks:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8.0),
                                for (var subsubtask
                                    in task['subsubtasks'] ?? []) ...[
                                  if (widget.showCompletedTasks == false) ...[
                                    if (subsubtask['completed'] == false)
                                      buildSubtaskRow(subsubtask, 'subsubtask'),
                                  ] else ...[
                                    buildSubtaskRow(subsubtask, 'subsubtask'),
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
                if (widget.type != 'subsubtask' && widget.permissions == true)
                  buildAddSubtaskButton(),
                buildAddCommentAndUploadButton(),
                buildCloseButton(context),
              ],
            );
          } else if (state is TaskError) {
            return Center(child: Text('Error: ${state.error}'));
          }
        }

        return const Center(child: Text('No data available'));
      },
    );
  }

  // Widget để hiển thị tên task và dialog chỉnh sửa
  Widget _buildTaskNameEditDialog(
      BuildContext context, Map<String, dynamic> taskData) {
    return GestureDetector(
      onTap: () async {
        // Hiển thị dialog chỉnh sửa tên task
        if (widget.permissions == true) {
          showDialog(
            context: context,
            builder: (_) {
              String initialValue = taskData['title'] ?? '';
              final TextEditingController _controller =
                  TextEditingController(text: initialValue);
              final FocusNode _focusNode = FocusNode();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNode.requestFocus();
              });

              String temporaryTitle = initialValue;

              return AlertDialog(
                title: const Text('Edit Name'),
                content: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  onChanged: (value) {
                    temporaryTitle = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      taskData['title'] = temporaryTitle;

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
                      setState(() {
                        taskData['title'] = temporaryTitle;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Row(
        children: [
          if (taskData['assignee'] != '') ...[
            _buildAssigneeAvatar(taskData['assignee']),
            const SizedBox(width: 8), // Khoảng cách giữa avatar và tiêu đề
          ],
          Expanded(
            child: Text(
              taskData['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                items: [
                  if (widget.permissions == true) ...[
                    if (isNotOneMem != false) ...[
                      PopupMenuItem(
                        value: 'assignUser',
                        child: const Text('Change Assignee'),
                      ),
                    ],
                  ],
                  PopupMenuItem(
                    value: 'markAsComplete',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mark Task as Complete'),
                        if (taskData['completed'] == true)
                          const Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ),
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
                  if (widget.permissions == true) {
                    var taskData;

                    // Lấy thông tin task
                    if (widget.type == 'task') {
                      taskData = TaskData().tasks.firstWhere(
                          (task) => task['id'] == widget.taskId,
                          orElse: () =>
                              {} // Nếu không tìm thấy, trả về một Map trống
                          );
                    } else if (widget.type == 'subtask') {
                      taskData = TaskData().subtasks.firstWhere(
                          (task) => task['id'] == widget.taskId,
                          orElse: () =>
                              {} // Nếu không tìm thấy, trả về một Map trống
                          );
                    } else {
                      taskData = TaskData().subsubtasks.firstWhere(
                          (task) => task['id'] == widget.taskId,
                          orElse: () =>
                              {} // Nếu không tìm thấy, trả về một Map trống
                          );
                    }

                    if (taskData != null && taskData.isNotEmpty) {
                      // Lấy danh sách project members
                      var projectMembers = await TaskData()
                          .getProjectMembers(taskData['projectId']);
                      if (projectMembers != null && projectMembers.length > 2) {
                        String newAssignee = await _changeAssignee(
                            taskData['assignee'], projectMembers);
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

                        // Gửi cập nhật lên Firestore
                        _updateTask(updateTask.id, updateTask, updateTask.type);
                        setState(() {
                          taskData['assignee'] = newAssignee;
                        });
                      }
                    }
                  }
                } else if (value == 'toggleCompletedTasksVisibility') {
                  changeShowCompletedTasksVisibility();
                } else if (value == 'deleteTask') {
                  await _confirmAndDeleteTask();
                  _fetchTask();
                  Navigator.pop(context);
                } else if (value == 'markAsComplete') {
                  taskData['completed'] = !(taskData['completed'] ?? false);

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

                  _fetchTask();
                }
              });
            },
          ),
        ],
      ),
    );
  }

// Widget để hiển thị nút thêm subtask
  Widget buildAddSubtaskButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        ),
        child: TextButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: AddTaskDialog(
                    taskId: widget.taskId, // Add appropriate taskId
                    type: widget.type, // Add appropriate type
                    selectDay: widget.selectDay ?? DateTime.now(),
                    resetDialog: () => setState(() {
                      _fetchTask();
                    }),
                    resetScreen: () => widget.resetScreen,
                  ),
                );
              },
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            minimumSize: Size(double.infinity, 40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Add Subtask',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
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
              title: const Text('Edit Priority'),
              content: DropdownButton<String>(
                value: taskData['priority'] ?? 'Trung bình', // Default priority
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      taskData['priority'] = newValue; // Update priority
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
                items: ['Cao', 'Trung bình', 'Thấp']
                    .map((priority) => DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
              ),
            ),
          );
        }
      },
      child: Text(
        'Priority: ${taskData['priority'] ?? 'Trung bình'}', // Display priority
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
              title: const Text('Edit Description'),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxHeight: 300), // Giới hạn chiều cao
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode, // Gán FocusNode vào TextField
                    onChanged: (value) {
                      temporaryDescription = value; // Lưu giá trị vào biến tạm
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
                  child: const Text('Cancel'),
                ),
                // Nút Save
                TextButton(
                  onPressed: () {
                    setState(() {
                      taskData['description'] =
                          temporaryDescription; // Lưu mô tả tạm vào taskData
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
      child: Text(
        'Description: ${taskData['description']}',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }

// Widget để hiển thị số lượng subtask đã hoàn thành
  Widget buildCompletedSubtasksRow() {
    return FutureBuilder<List<int>>(
      future: Future.wait([
        TaskData().getCountByTypeStream(widget.taskId, widget.type).first,
        TaskData().getCompletedCountStream(widget.taskId, widget.type).first
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        var result = snapshot.data!;
        int totalSubtasks = result[0];
        int completedSubtasks = result[1];

        return Row(
          children: [
            if (totalSubtasks > 0)
              Text(
                'Completed Subtasks: $completedSubtasks / $totalSubtasks',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
          ],
        );
      },
    );
  }

//Widget để hiển thị subtask
  bool isUpdating = false;

  Widget buildSubtaskRow(var subtask, String type) {
    return StreamBuilder<List<int>>(
      stream: Stream.fromFuture(Future.wait([
        if (widget.type == 'task') ...[
          TaskData().getCountByTypeStream(subtask['id'], 'subtask').first,
          TaskData().getCompletedCountStream(subtask['id'], 'subtask').first
        ] else ...[
          TaskData().getCountByTypeStream(subtask['id'], 'subsubtask').first,
          TaskData().getCompletedCountStream(subtask['id'], 'subsubtask').first
        ]
      ])),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || isUpdating) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        var result = snapshot.data!;
        int completedSubtasks;
        int totalSubtasks = result[0];
        completedSubtasks = result[1];

        return GestureDetector(
          onTap: () async {
            showModalBottomSheet(
              context: context,
              isDismissible: false,
              isScrollControlled:
                  true, // Allow the bottom sheet to adjust its height based on content
              builder: (context) {
                return SingleChildScrollView(
                  child: TaskDetailsDialog(
                    taskId: subtask['id'],
                    type: type,
                    openFirst: false,
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
            );
          },
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (isUpdating) return;
                  setState(() {
                    isUpdating = true;
                  });

                  subtask['completed'] = !subtask['completed'];
                  Task task = Task(
                    id: subtask['id'],
                    title: subtask['title'],
                    description: subtask['description'],
                    dueDate: subtask['dueDate'],
                    priority: subtask['priority'],
                    assignee: subtask['assignee'],
                    type: type,
                    projectName: widget.projectName,
                    completed: subtask['completed'],
                    subtasks: [],
                  );

                  _updateTask(task.id, task, task.type);

                  if (subtask['completed'] == true) {
                    if (subtask['subsubtasks'] != null &&
                        subtask['subsubtasks'].isNotEmpty) {
                      for (var subsubtask in subtask['subsubtasks']) {
                        if (subsubtask['completed'] == false) {
                          Task task = Task(
                            id: subsubtask['id'],
                            title: subsubtask['title'],
                            description: subsubtask['description'],
                            dueDate: subsubtask['dueDate'],
                            priority: subsubtask['priority'],
                            assignee: subsubtask['assignee'],
                            type: 'subsubtask',
                            projectName: widget.projectName,
                            completed: true,
                            subtasks: [],
                          );
                          _updateTask(task.id, task, task.type);
                        }
                      }
                    }
                  }
                  await Future.delayed(const Duration(milliseconds: 300));

                  setState(() {
                    _fetchTask();

                    isUpdating = false;
                  });
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
                    color: subtask['completed'] == true
                        ? Colors.green
                        : Colors.black,
                    decoration: subtask['completed'] == true
                        ? TextDecoration.lineThrough
                        : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Hiển thị avatar hoặc khoảng trống
              if (subtask['assignee'] != '') ...[
                _buildAssigneeAvatar(subtask['assignee']),
                const SizedBox(width: 8), // Khoảng cách giữa avatar và tiêu đề
              ],
            ],
          ),
        );
      },
    );
  }

  Widget buildSubsubtasks(var subsubtask, String type, String subtaskId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                isScrollControlled:
                    true, // Allow the bottom sheet to adjust its height based on content
                builder: (context) {
                  return SingleChildScrollView(
                    child: TaskDetailsDialog(
                      taskId: subsubtask['id'],
                      type: type,
                      openFirst: false,
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
              );
            },
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (isUpdating) return; // Ngăn thao tác khi đang cập nhật
                    setState(() {
                      isUpdating = true; // Bắt đầu cập nhật
                    });

                    // Cập nhật trạng thái `completed` cho subsubtask
                    subsubtask['completed'] = !subsubtask['completed'];
                    Task task = Task(
                      id: subsubtask['id'],
                      title: subsubtask['title'],
                      description: subsubtask['description'],
                      dueDate: subsubtask['dueDate'],
                      priority: subsubtask['priority'],
                      assignee: subsubtask['assignee'],
                      type: type,
                      projectName: widget.projectName,
                      completed: subsubtask['completed'],
                      subtasks: [],
                    );

                    // Gửi cập nhật lên Firestore
                    _updateTask(task.id, task, task.type);
                    if (subsubtask['completed'] == false) {
                      var taskData = TaskData().subtasks.firstWhere(
                          (subtask) => subtask['id'] == subtaskId,
                          orElse: () =>
                              {} // Nếu không tìm thấy, trả về một Map trống
                          );
                      if (taskData['completed'] == true) {
                        Task task = Task(
                          id: taskData['id'],
                          title: taskData['title'],
                          description: taskData['description'],
                          dueDate: taskData['dueDate'],
                          priority: taskData['priority'],
                          assignee: taskData['assignee'],
                          type: 'subtask',
                          projectName: widget.projectName,
                          completed: false,
                          subtasks: [],
                        );
                        _updateTask(task.id, task, task.type);
                      }
                    }

                    setState(() {
                      isUpdating = false; // Hoàn tất cập nhật
                      _fetchTask();
                    });
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
                if (subsubtask['assignee'] != '') ...[
                  _buildAssigneeAvatar(subsubtask['assignee']),
                  const SizedBox(
                      width: 8), // Khoảng cách giữa avatar và tiêu đề
                ],
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
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  // Open CommentsDialog in a modal bottom sheet and pass idTask
                  List<Map<String, dynamic>>? updatedComments =
                      await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => CommentsDialog(
                      idTask: widget.taskId, // Pass idTask to dialog
                      type: widget.type, // Pass type to dialog
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  minimumSize: Size(double.infinity, 40),
                ),
                child: const Text(
                  'Add Comment',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget để hiển thị nút đóng dialog
  Widget buildCloseButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          if (widget.openFirst == true) widget.resetScreen();

          widget.resetDialog();
        });
        Navigator.pop(context);
      },
      child: const Text('Close'),
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
                    value: member, // Giá trị là tên của member
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
      // Hiển thị dialog với vòng tròn xoay
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

      // Thực hiện thêm sự kiện để xoá task
      widget.taskBloc.add(DeleteTask(widget.taskId, widget.type));

      // Chờ Firebase cập nhật hoàn tất
      await Future.delayed(Duration(seconds: 2));

      // Đóng dialog sau khi cập nhật xong
      Navigator.pop(dialogContext); // Dùng context đã lưu ở trên
      _fetchTask();

      // Cập nhật lại màn hình
      widget.resetScreen();
    } catch (e) {
      // Xử lý lỗi nếu có
      print("Error deleting task: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  void changeShowCompletedTasksVisibility() async {
    setState(() {
      widget.showCompletedTasks = !widget.showCompletedTasks;
      ;
    });
  }

  Widget _buildAssigneeAvatar(String assingee) {
    if (assingee != '') {
      return CircleAvatar(
        radius: 15, // Kích thước radius của avatar
        backgroundColor: Colors.white,
        child: Text(
          assingee[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Trả về khoảng trống có kích thước tương đương CircleAvatar
      return const SizedBox(
        width: 30, // 2 * radius
        height: 30, // 2 * radius
      );
    }
  }

  Future<void> _fetchTask() async {
    final completer = Completer<void>();
    final subscription =
        BlocProvider.of<TaskBloc>(context).stream.listen((state) {
      if (state is TaskDetailsDialog || state is TaskError) {
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
      if (projectMembers != null && projectMembers.length > 2) {
        return true;
      }
    }

    return false;
  }
}
