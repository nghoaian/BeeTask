import 'package:bee_task/bloc/task/task_event.dart';
import 'package:flutter/material.dart';
import 'package:bee_task/util/colors.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/data/model/task.dart';

class TaskDetailsDialog extends StatefulWidget {
  final String taskId;
  final String type;
  final String projectName;
  final bool showCompletedTasks;
  final TaskBloc taskBloc; // Accept TaskBloc via constructor
  final Function resetScreen;
  final Function resetDialog;

  const TaskDetailsDialog(
      {required this.taskId,
      required this.type,
      required this.projectName,
      required this.showCompletedTasks,
      required this.taskBloc,
      required this.resetScreen,
      required this.resetDialog});

  @override
  _TaskDetailsDialogState createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  late Future<Map<String, dynamic>?> task; // Make the task nullable

  @override
  void initState() {
    super.initState();
    task = TaskData()
        .fetchDataFromFirestore(widget.type, widget.taskId); // task is nullable
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: task,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        // Dữ liệu đã có sẵn, giờ bạn có thể lấy subtask từ task
        var task = snapshot.data;

        // Check if task is null before using it
        if (task == null) {
          return Center(child: Text('Task data is null.'));
        }

        return AlertDialog(
          title: _buildTaskNameEditDialog(context, task),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriorityEditDialog(context, task),
                const SizedBox(height: 8.0),
                _buildProjectText(widget.projectName),
                const SizedBox(height: 8.0),
                _buildDescriptionEdit(context, task),
                const SizedBox(height: 16.0),
                buildCompletedSubtasksRow(),
                // Handle subtasks
                if (task['subtasks'] != null &&
                    task['subtasks'].isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  Text('Subtasks:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var subtask in task['subtasks']) ...[
                    buildSubtaskRow(
                        subtask, 'subtask'), // Hiển thị các subtasks
                    if (subtask['subsubtasks'] != null &&
                        subtask['subsubtasks'].isNotEmpty) ...[
                      buildSubsubtasks(subtask['subsubtasks'],
                          'subsubtask'), // Hiển thị các subsubtasks
                      const SizedBox(height: 8.0),
                    ],
                  ],
                ] else if (task['subsubtasks'] != null &&
                    task['subsubtasks'].isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  Text('Subtasks:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var subtask in task['subsubtasks']) ...[
                    buildSubtaskRow(
                        subtask, 'subsubtask'), // Hiển thị các subtasks
                  ],
                ],
              ],
            ),
          ),
          actions: [
            buildAddSubtaskButton(),
            buildAddCommentAndUploadButton(),
            buildCloseButton(context),
          ],
        );
      },
    );
  }

  // Widget để hiển thị tên task và dialog chỉnh sửa
  Widget _buildTaskNameEditDialog(
      BuildContext context, Map<String, dynamic> taskData) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            // Extract the title directly from the task
            String initialValue = taskData['title'] ?? '';

            // Create a TextEditingController with the initial value
            final TextEditingController _controller = TextEditingController(
              text: initialValue,
            );

            return AlertDialog(
              title: const Text('Edit Name'),
              content: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    // Update the task's title
                    taskData['title'] = value;
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
                    widget.taskBloc
                        .add(UpdateTask(widget.taskId, task, widget.type));
                    widget.resetScreen();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              taskData['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Add avatar or assignee information if needed
          if (taskData['assignee'] != null) const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 'assignUser',
                    child: const Text('Change Assignee'),
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
                  PopupMenuItem(
                    value: 'deleteTask',
                    child: const Text('Delete Task'),
                  ),
                ],
              ).then((value) async {
                if (value == 'assignUser') {
                  _changeAssignee(taskData['assignee']);
                } else if (value == 'toggleCompletedTasksVisibility') {
                } else if (value == 'deleteTask') {
                  await _confirmAndDeleteTask();

// Chỉ chạy khi _confirmAndDeleteTask hoàn tất
                  widget.resetScreen();
                  Navigator.pop(context);
                  // Dùng context đã lưu ở trên
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
            // showDialog(
            //   context: context,
            //   builder: (context) => AddSubTaskDialog(
            //     data: widget.data,
            //     selectDay: widget.selectedDate,
            //     typeID: widget.typeID,
            //   ),
            // );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            minimumSize: Size(double.infinity, 40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Colors.red, size: 18),
              const SizedBox(width: 8),
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
                    widget.taskBloc
                        .add(UpdateTask(widget.taskId, task, widget.type));
                    widget.resetScreen();
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
          builder: (_) => AlertDialog(
            title: const Text('Edit Description'),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: TextField(
                  controller:
                      TextEditingController(text: taskData['description']),
                  onChanged: (value) {
                    setState(() {
                      taskData['description'] = value; // Update priority
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
                      widget.taskBloc
                          .add(UpdateTask(widget.taskId, task, widget.type));
                      widget.resetScreen();
                    });
                  },
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                },
                child: const Text('Save'),
              ),
            ],
          ),
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        var result = snapshot.data!;
        int totalSubtasks = result[0];
        int completedSubtasks = result[1];

        return GestureDetector(
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => TaskDetailsDialog(
                taskId: subtask['id'],
                type: type,
                projectName: widget.projectName,
                showCompletedTasks: widget.showCompletedTasks,
                taskBloc: widget.taskBloc,
                resetScreen: widget.resetScreen,
                resetDialog: () => setState(() {
                  task = TaskData()
                      .fetchDataFromFirestore(widget.type, widget.taskId);
                }),
              ),
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

                  // Gửi cập nhật lên Firestore
                  widget.taskBloc.add(UpdateTask(subtask['id'], task, type));

                  // Chờ Firebase cập nhật trước khi render lại
                  await Future.delayed(Duration(milliseconds: 300));
                  widget.resetDialog();

                  setState(() {
                    isUpdating = false; // Hoàn tất cập nhật
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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
            ],
          ),
        );
      },
    );
  }

  Widget buildSubsubtasks(var subtask, String type) {
    return Column(
      children: [
        for (var subsubtask in subtask) ...[
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => TaskDetailsDialog(
                    taskId: subsubtask['id'],
                    type: type,
                    projectName: widget.projectName,
                    showCompletedTasks: widget.showCompletedTasks,
                    taskBloc: widget.taskBloc,
                    resetScreen: widget.resetScreen,
                    resetDialog: () => setState(() {
                      task = TaskData()
                          .fetchDataFromFirestore(widget.type, widget.taskId);
                    }),
                  ),
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
                      widget.taskBloc
                          .add(UpdateTask(subsubtask['id'], task, type));

                      // Chờ Firebase cập nhật trước khi render lại
                      await Future.delayed(Duration(milliseconds: 300));
                      widget.resetDialog();

                      setState(() {
                        isUpdating = false; // Hoàn tất cập nhật
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
                          color: TaskData()
                              .getPriorityColor(subsubtask['priority']),
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
                  // Uncomment if assignee info is needed
                  // if (subsubtask['assignee']?.isNotEmpty ?? false)
                  //   buildCircleAvatar(
                  //       subsubtask['assignee'], subsubtask['avatar']),
                ],
              ),
            ),
          ),
        ],
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
                onPressed: () {
                  // Add your logic to add a comment
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
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              onPressed: () {
                // Handle file upload logic
              },
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
          widget.resetScreen();
        });
        Navigator.pop(context);
      },
      child: const Text('Close'),
    );
  }

  void _changeAssignee(String currentAssignee) async {
    // Lấy thông tin task
    var task = TaskData().fetchDataFromFirestore(widget.type, widget.taskId);
    var taskData = await task;

    if (taskData != null && taskData.isNotEmpty) {
      // Lấy danh sách project members
      var projectMembers =
          await TaskData().getProjectMembers(taskData['projectId']);

      if (projectMembers.isNotEmpty) {
        showDialog(
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
                    return RadioListTile(
                      title: Text(member), // Hiển thị tên người dùng
                      value: member, // Giá trị là tên của member
                      groupValue: selectedAssignee,
                      onChanged: (value) {
                        selectedAssignee = value as String?;
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
        ).then((selectedMemberName) {
          if (selectedMemberName != null) {
            if (isUpdating) return; // Ngăn thao tác khi đang cập nhật
            setState(() {
              isUpdating = true; // Bắt đầu cập nhật
            });

            // Cập nhật trạng thái `completed` cho subsubtask
            Task updateTask = Task(
              id: taskData['id'],
              title: taskData['title'],
              description: taskData['description'],
              dueDate: taskData['dueDate'],
              priority: taskData['priority'],
              assignee: selectedMemberName,
              type: widget.type,
              projectName: widget.projectName,
              completed: taskData['completed'],
              subtasks: [],
            );

            // Gửi cập nhật lên Firestore
            widget.taskBloc
                .add(UpdateTask(taskData['id'], updateTask, widget.type));

            // Chờ Firebase cập nhật trước khi render lại
            widget.resetDialog();

            setState(() {
              isUpdating = false; // Hoàn tất cập nhật
            });
            // TODO: Cập nhật assignee cho task tại đây
          }
        });
      }
    }
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
}
