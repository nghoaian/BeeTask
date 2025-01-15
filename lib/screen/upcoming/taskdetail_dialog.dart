import 'package:flutter/material.dart';
import 'package:bee_task/util/colors.dart';
import 'package:bee_task/screen/upcoming/addsubtask_dialog.dart';
import 'package:bee_task/screen/TaskData.dart';

class TaskDetailsDialog extends StatefulWidget {
  final String taskId;
  final String type;
  final String projectName;

  final bool showCompletedTasks;

  const TaskDetailsDialog(
      {required this.taskId,
      required this.type,
      required this.projectName,
      required this.showCompletedTasks});

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
                    buildSubtaskRow(subtask), // Hiển thị các subtasks
                    if (subtask['subsubtasks'] != null &&
                        subtask['subsubtasks'].isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      buildSubsubtasks(
                          subtask['subsubtasks']), // Hiển thị các subsubtasks
                    ],
                  ],
                ] else if (task['subsubtasks'] != null &&
                    task['subsubtasks'].isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  Text('Subtasks:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var subtask in task['subsubtasks']) ...[
                    buildSubtaskRow(subtask), // Hiển thị các subtasks
                    //     if (subtask['subsubtasks'] != null &&
                    //         subtask['subsubtasks'].isNotEmpty) ...[
                    //       const SizedBox(height: 8.0),
                    //       buildSubsubtasks(subtask), // Hiển thị các subsubtasks
                    //     ],
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
              ).then((value) {
                if (value == 'assignUser') {
                  _changeAssignee();
                } else if (value == 'toggleCompletedTasksVisibility') {
                } else if (value == 'deleteTask') {
                  _deleteTask();
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
                  taskData['priority'] = newValue; // Update priority
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
                  onChanged: (value) {},
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
  Widget buildSubtaskRow(var subtask) {
    return FutureBuilder<List<int>>(
      future: Future.wait([
        if (widget.type == 'task') ...[
          TaskData().getCountByTypeStream(subtask['id'], 'subtask').first,
          TaskData().getCompletedCountStream(subtask['id'], 'subtask').first
        ] else ...[
          TaskData().getCountByTypeStream(subtask['id'], 'subsubtask').first,
          TaskData().getCompletedCountStream(subtask['id'], 'subsubtask').first
        ]
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }
        int totalSubtasks = 0;
        int completedSubtasks = 0;

        var result = snapshot.data!;
        totalSubtasks = result[0];
        completedSubtasks = result[1];

        return GestureDetector(
          onTap: () {
            // showDialog(
            //   context: context,
            //   builder: (context) => TaskDetailsDialog(
            //     task: {},
            //     taskName: subtask['subtask'],
            //     subtasks: subtask,
            //     subsubtasks: {},
            //     project: widget.project,
            //     priorityColor: _getPriorityColor(subtask['priority']),
            //     completedSubtasks: completedSubtasks,
            //     totalSubtasks: totalSubtasks,
            //     data: widget.data,
            //     typeID: widget.typeID,
            //     selectedDate: widget.selectedDate,
            //     onStatusChanged: (subtask) {
            //       setState(() {
            //         subtask['status'] = subtask['status'] == 'Hoàn Thành'
            //             ? 'Chưa Hoàn Thành'
            //             : 'Hoàn Thành';
            //       });
            //     },
            //     resetScreen: () {
            //       setState(() {});
            //     },
            //     onShowCompletedTasksChanged: widget.onShowCompletedTasksChanged,
            //     showCompletedTasks: widget.showCompletedTasks,
            //     onDataUpdated: (updatedData) {
            //       setState(() {
            //         widget.onDataUpdated(updatedData);
            //       });
            //     },
            //   ),
            // );
          },
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  String newStatus = subtask['status'] == 'Hoàn Thành'
                      ? 'Chưa Hoàn Thành'
                      : 'Hoàn Thành';

                  // setState(() {
                  //   // Cập nhật trạng thái của subtask
                  //   subtask['status'] = newStatus;

                  //   // Cập nhật trạng thái của các subsubtask nếu có
                  //   if (subtask['subsubtasks'] != null) {
                  //     for (var subsubtask in subtask['subsubtasks']) {
                  //       subsubtask['status'] = newStatus;
                  //     }
                  //   }
                  //   // _updateSubtaskStatus(subtask); // Cập nhật trạng thái subtask
                  //   // _updateTaskStatus(); // Cập nhật trạng thái task
                  // });
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
              // if (subtask['assignee']?.isNotEmpty ?? false)
              //   buildCircleAvatar(subtask['assignee'], subtask['avatar']),
            ],
          ),
        );
      },
    );
  }

// Widget để hiển thị các subsubtasks bên trong một subtask
  Widget buildSubsubtasks(var subtask) {
    // Lọc subsubtasks dựa trên trạng thái và widget.showCompletedTasks

    return Column(
      children: [
        for (var subsubtask in subtask) ...[
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: GestureDetector(
              onTap: () {
                // Mở dialog khi nhấn vào bất kỳ dòng subsubtask nào
                // Mở thêm dialog mới với dữ liệu khác
                int completedSubtasks = 0;
                int totalSubtasks = 0;
                totalSubtasks = subtask['subsubtasks'].length;
                completedSubtasks = subtask['subsubtasks']
                    .where((subtask) => subtask['status'] == 'Hoàn Thành')
                    .length;

                // showDialog(
                //   context: context,
                //   builder: (context) => TaskDetailsDialog(
                //     task: {},
                //     taskName: subsubtask['subsubtask'],
                //     subtasks: {},
                //     subsubtasks: subsubtask,
                //     project: widget.project,
                //     priorityColor: _getPriorityColor(subsubtask['priority']),
                //     data: widget.data,
                //     completedSubtasks: completedSubtasks,
                //     totalSubtasks: totalSubtasks,
                //     selectedDate: widget.selectedDate,
                //     typeID: widget.typeID,
                //     onStatusChanged: (subtask) {
                //       setState(() {
                //         subtask['status'] = subtask['status'] == 'Hoàn Thành'
                //             ? 'Chưa Hoàn Thành'
                //             : 'Hoàn Thành';
                //       });
                //     },
                //     resetScreen: () {
                //       setState(() {});
                //     },
                //     onShowCompletedTasksChanged:
                //         widget.onShowCompletedTasksChanged,
                //     showCompletedTasks: widget.showCompletedTasks,
                //     onDataUpdated: (updatedData) {
                //       setState(() {
                //         widget.onDataUpdated(updatedData);
                //       });
                //     },
                //   ),
                //);
              },
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: subsubtask['completed'] == true
                          ? Colors.green
                          : Colors.transparent,
                      border: Border.all(
                        color:
                            TaskData().getPriorityColor(subsubtask['priority']),
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
        Navigator.pop(context);
      },
      child: const Text('Close'),
    );
  }

  void _changeAssignee() {}

  void _deleteTask() {}
}
