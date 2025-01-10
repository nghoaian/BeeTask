import 'package:flutter/material.dart';
import 'package:bee_task/util/colors.dart';
import 'package:bee_task/screen/upcoming/addsubtask_dialog.dart';

class TaskDetailsDialog extends StatefulWidget {
  final Map task; // Dữ liệu của task
  final String taskName;
  final String project;
  final Map subtasks; // Danh sách các subtasks của task
  final Map subsubtasks; // Danh sách các subtasks của task
  final Color priorityColor; // Màu sắc của ưu tiên task
  final int completedSubtasks; // Số lượng subtasks đã hoàn thành
  final int totalSubtasks; // Tổng số lượng subtasks
  final Function onStatusChanged; // Callback để thay đổi trạng thái của subtask
  final Function onDataUpdated; // Callback để cập nhật dữ liệu khi có thay đổi
  bool showCompletedTasks;
  final Function resetScreen;
  final Function(bool)
      onShowCompletedTasksChanged; // Callback để thay đổi trạng thái
  final List data;
  final DateTime selectedDate;
  final String typeID;

  TaskDetailsDialog(
      {required this.task,
      required this.taskName,
      required this.project,
      required this.subtasks,
      required this.subsubtasks,
      required this.priorityColor,
      required this.completedSubtasks,
      required this.totalSubtasks,
      required this.onStatusChanged,
      required this.onDataUpdated,
      required this.resetScreen,
      required this.showCompletedTasks,
      required this.onShowCompletedTasksChanged,
      required this.data,
      required this.selectedDate,
      required this.typeID});

  @override
  _TaskDetailsDialogState createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  // Hàm lấy màu sắc cho ưu tiên của task
  Color _getPriorityColor(String priority) {
    return AppColors.getPriorityColor(priority);
  }

  // Cập nhật trạng thái của task dựa trên trạng thái các subtasks
  void _updateTaskStatus() {
    bool allCompleted = true;

    // Duyệt qua tất cả các subtask trong Map
    widget.subtasks.forEach((key, subtask) {
      // Kiểm tra trạng thái của từng subtask
      if (subtask['status'] != 'Hoàn Thành') {
        allCompleted = false;
        return; // Nếu có subtask chưa hoàn thành, thoát khỏi vòng lặp
      }
    });

    // Cập nhật trạng thái của task chính
    setState(() {
      widget.task['status'] = allCompleted ? 'Hoàn Thành' : 'Chưa Hoàn Thành';
    });
  }

  // Cập nhật trạng thái của subtask sau khi thay đổi trạng thái của subsubtask
  void _updateSubtaskStatus(Map subtask) {
    if (subtask['subsubtasks'] != null && subtask['subsubtasks'].isNotEmpty) {
      bool allCompleted = true;
      for (var subsubtask in subtask['subsubtasks']) {
        if (subsubtask['status'] != 'Hoàn Thành') {
          allCompleted = false;
          break;
        }
      }
      subtask['status'] = allCompleted ? 'Hoàn Thành' : 'Chưa Hoàn Thành';
    }
  }

  // Hàm tính số lượng subsubtasks đã hoàn thành
  int _getCompletedSubsubtasks(List subsubtasks) {
    return subsubtasks
        .where((subsubtask) => subsubtask['status'] == 'Hoàn Thành')
        .length;
  }

  int _getCompletedSubtasks() {
    int count = 0;
    if (widget.task.isNotEmpty) {
      for (var subtask in widget.task['subtasks']) {
        // Kiểm tra từng subtask trong task
        // Kiểm tra trạng thái của subtask
        if (subtask['status'] == 'Hoàn Thành') {
          count++;
        }
      }
    } else if (widget.subtasks.isNotEmpty) {
      for (var subtask in widget.subtasks['subsubtasks']) {
        // Kiểm tra từng subtask trong task
        // Kiểm tra trạng thái của subtask
        if (subtask['status'] == 'Hoàn Thành') {
          count++;
        }
      }
    }

    return count;
  }

  // Tạo CircleAvatar với chữ cái đầu tiên của email
  Widget buildCircleAvatar(String assignment, String avatar) {
    if (avatar.isEmpty && assignment.isEmpty) {
      return SizedBox
          .shrink(); // Không hiển thị gì nếu cả avatar và assignment đều rỗng
    }

    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: avatar.isNotEmpty
            ? CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(avatar), // Hiển thị ảnh từ avatar
              )
            : CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  assignment[0]
                      .toUpperCase(), // Hiển thị ký tự đầu của assignment
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTaskNameEditDialog(
          context), // Hiển thị tên task và dialog chỉnh sửa
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriorityEditDialog(
                context), // Hiển thị priority và dialog chỉnh sửa
            const SizedBox(height: 8.0),
            _buildProjectText(), // Hiển thị thông tin Project
            const SizedBox(height: 8.0),
            if (widget.task.isNotEmpty) ...[
              _buildDescriptionEdit(
                  context), // Hiển thị description và dialog chỉnh sửa
              const SizedBox(height: 16.0),
            ],
            if (widget.subtasks.isNotEmpty || widget.task.isNotEmpty)
              if (widget.totalSubtasks != 0) ...[
                buildCompletedSubtasksRow(), // Hiển thị số subtask hoàn thành
                const SizedBox(height: 16.0),
                const Divider(),
                Text('Subtasks:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (widget.task.isNotEmpty) ...[
                  for (var subtask in widget.task['subtasks']) ...[
                    const SizedBox(height: 16.0),
                    // Kiểm tra subtask có thông tin hợp lệ hay không trước khi hiển thị
                    buildSubtaskRow(subtask), // Hiển thị các subtasks
                    if (subtask['subsubtasks'] != null &&
                        subtask['subsubtasks'].isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      buildSubsubtasks(subtask), // Hiển thị các subsubtasks
                    ]
                  ],
                ],
                if (widget.subtasks.isNotEmpty)
                  if (widget.subtasks['subsubtasks'] != null) ...[
                    const SizedBox(height: 16.0),
                    buildSubsubtasks(
                        widget.subtasks), // Hiển thị các subsubtasks
                  ]
              ]
          ],
        ),
      ),
      actions: [
        if (widget.subsubtasks.isEmpty)
          buildAddSubtaskButton(), // Nút thêm subtask
        buildAddCommentAndUploadButton(), // Nút thêm comment và upload file
        buildCloseButton(context), // Nút đóng dialog
      ],
    );
  }

  // Widget để hiển thị tên task và dialog chỉnh sửa
  Widget _buildTaskNameEditDialog(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            String initialValue = '';
            if (widget.task.isNotEmpty) {
              initialValue = widget.task['task'] ?? '';
            } else if (widget.subtasks.isNotEmpty) {
              initialValue = widget.subtasks['subtask'] ?? '';
            } else if (widget.subsubtasks.isNotEmpty) {
              initialValue = widget.subsubtasks['subsubtask'] ?? '';
            }

            // Tạo TextEditingController để quản lý giá trị nhập
            final TextEditingController _controller = TextEditingController(
              text: initialValue,
            );

            return AlertDialog(
              title: const Text('Edit Name'),
              content: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    // Cập nhật giá trị tương ứng
                    if (widget.task.isNotEmpty) {
                      widget.task['task'] = value;
                    } else if (widget.subtasks.isNotEmpty) {
                      widget.subtasks['subtask'] = value;
                    } else if (widget.subsubtasks.isNotEmpty) {
                      widget.subsubtasks['subsubtask'] = value;
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng dialog
                    if (widget.task.isNotEmpty) {
                      widget.onDataUpdated(
                          widget.task); // Gọi lại hàm cập nhật dữ liệu
                    } else if (widget.subtasks.isNotEmpty) {
                      widget.onDataUpdated(
                          widget.subtasks); // Gọi lại hàm cập nhật dữ liệu
                    } else if (widget.subsubtasks.isNotEmpty) {
                      widget.onDataUpdated(
                          widget.subsubtasks); // Gọi lại hàm cập nhật dữ liệu
                    }
                    widget.resetScreen(); // cập nhật dữ liệu
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
            child: (widget.task.isNotEmpty)
                ? Text(
                    widget.task['task'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : (widget.subtasks.isNotEmpty)
                    ? Text(
                        widget.subtasks['subtask'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : (widget.subsubtasks.isNotEmpty)
                        ? Text(
                            widget.subsubtasks['subsubtask'],
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          )
                        : Container(), // Trả về một Container rỗng nếu không có task, subtask hoặc subsubtask
          ),
          if (widget.task.isNotEmpty) ...[
            buildCircleAvatar(widget.task['assignee'], widget.task['avatar']),
            const SizedBox(width: 8),
          ] else if (widget.subtasks.isNotEmpty) ...[
            buildCircleAvatar(
                widget.subtasks['assignee'], widget.subtasks['avatar']),
            const SizedBox(width: 8),
          ] else ...[
            buildCircleAvatar(
                widget.subsubtasks['assignee'], widget.subsubtasks['avatar']),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(
                    100, 100, 0, 0), // Adjust menu position
                items: [
                  if (widget.task['type'] !=
                      'Inbox') // Chỉ hiển thị nếu không phải "Inbox"
                    PopupMenuItem(
                      value: 'assignUser',
                      child: const Text(
                          'Change Assignee'), // Thay đổi người làm task
                    ),
                  PopupMenuItem(
                    value: 'toggleCompletedTasksVisibility',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                            'Show Completed Sub-Tasks'), // Ẩn/hiện công việc đã hoàn thành
                        if (widget.showCompletedTasks)
                          const Icon(
                            Icons
                                .check, // Dấu check nếu công việc hoàn thành đang hiển thị
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'deleteTask',
                    child: const Text('Delete Task'), // Xóa task
                  ),
                ],
              ).then((value) {
                if (value == 'assignUser') {
                  _changeAssignee(); // Gọi hàm thay đổi người làm task
                } else if (value == 'toggleCompletedTasksVisibility') {
                  _toggleShowCompletedTasks();
                } else if (value == 'deleteTask') {
                  _deleteTask(); // Gọi hàm xóa task
                }
              });
            },
          ),
        ],
      ),
    );
  }

  void _toggleShowCompletedTasks() {
    bool newStatus =
        !widget.showCompletedTasks; // thay đổi giá trị show completed tasks
    widget.onShowCompletedTasksChanged(
        newStatus); // Gọi callback để cập nhật lại trong widget cha
    setState(() {
      widget.showCompletedTasks = newStatus;
    });
  }

  //Widget để hiển thị priority và dialog chỉnh sửa
  Widget _buildPriorityEditDialog(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Edit Priority'),
            content: DropdownButton<String>(
              // Kiểm tra để hiển thị priority từ task, subtask hoặc subsubtask
              value: _getPriority(),
              onChanged: (String? newValue) {
                setState(() {
                  // Cập nhật priority tương ứng
                  if (widget.task.isNotEmpty) {
                    // Cập nhật cho subtask nếu có
                    widget.task['priority'] = newValue!;
                  } else if (widget.subtasks.isNotEmpty) {
                    // Cập nhật cho subsubtask nếu có
                    widget.subtasks['priority'] = newValue!;
                  } else {
                    // Cập nhật cho task nếu không có subtask hay subsubtask
                    widget.subsubtasks['priority'] = newValue!;
                  }
                });
                Navigator.pop(context); // Đóng dialog
                if (widget.task.isNotEmpty) {
                  widget.onDataUpdated(
                      widget.task); // Cập nhật dữ liệu sau khi thay đổi
                } else if (widget.subtasks.isNotEmpty) {
                  widget.onDataUpdated(
                      widget.subtasks); // Cập nhật dữ liệu sau khi thay đổi
                } else {
                  widget.onDataUpdated(
                      widget.subsubtasks); // Cập nhật dữ liệu sau khi thay đổi
                }
                widget.resetScreen(); // cập nhật dữ liệu
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
        'Priority: ${_getPriority()}', // Hiển thị priority phù hợp
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getPriority() {
    if (widget.task.isNotEmpty) {
      // Trả về priority của subtask nếu có
      return widget.task['priority'];
    } else if (widget.subtasks.isNotEmpty) {
      // Trả về priority của subsubtask nếu có
      return widget.subtasks['priority'];
    } else {
      // Trả về priority của task nếu không có subtask hay subsubtask
      return widget.subsubtasks['priority'];
    }
  }

  // Widget để hiển thị thông tin Project
  Widget _buildProjectText() {
    if (widget.task.isNotEmpty) {
      return Text(
        'Project: ${widget.project}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else if (widget.task.isEmpty) {
      return Text(
        'Project: ${widget.project} - SubTask',
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      return SizedBox.shrink(); // Trả về SizedBox nếu không có project
    }
  }

  // Widget để hiển thị description và dialog chỉnh sửa
  Widget _buildDescriptionEdit(BuildContext context) {
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
                      TextEditingController(text: widget.task['description']),
                  onChanged: (value) {
                    setState(() {
                      widget.task['description'] = value;
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
                  widget.onDataUpdated(
                      widget.task); // Cập nhật lại dữ liệu sau khi thay đổi
                  widget.resetScreen(); // cập nhật dữ liệu
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
      child: Text(
        'Description: ${widget.task['description']}',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }

  // Widget để hiển thị số lượng subtask đã hoàn thành
  Widget buildCompletedSubtasksRow() {
    return Row(
      children: [
        Text(
          'Completed Subtasks: ${_getCompletedSubtasks()} / ${widget.totalSubtasks}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  // Widget để hiển thị subtask
  Widget buildSubtaskRow(var subtask) {
    // Kiểm tra nếu `showCompletedTasks` là false và subtask đã "Hoàn Thành", không hiển thị
    if (!widget.showCompletedTasks && subtask['status'] == 'Hoàn Thành') {
      return const SizedBox.shrink(); // Trả về một widget rỗng
    }

    return GestureDetector(
      onTap: () {
        // Mở thêm dialog mới với dữ liệu khác
        int completedSubtasks = 0;
        int totalSubtasks = 0;
        totalSubtasks = subtask['subsubtasks'].length;
        completedSubtasks = subtask['subsubtasks']
            .where((subtask) => subtask['status'] == 'Hoàn Thành')
            .length;

        showDialog(
          context: context,
          builder: (context) => TaskDetailsDialog(
            task: {},
            taskName: subtask['subtask'],
            subtasks: subtask,
            subsubtasks: {},
            project: widget.project,
            priorityColor: _getPriorityColor(subtask['priority']),
            completedSubtasks: completedSubtasks,
            totalSubtasks: totalSubtasks,
            data: widget.data,
            typeID: widget.typeID,
            selectedDate: widget.selectedDate,
            onStatusChanged: (subtask) {
              setState(() {
                subtask['status'] = subtask['status'] == 'Hoàn Thành'
                    ? 'Chưa Hoàn Thành'
                    : 'Hoàn Thành';
              });
            },
            resetScreen: () {
              setState(() {});
            },
            onShowCompletedTasksChanged: widget.onShowCompletedTasksChanged,
            showCompletedTasks: widget.showCompletedTasks,
            onDataUpdated: (updatedData) {
              setState(() {
                widget.onDataUpdated(updatedData);
              });
            },
          ),
        );
      },
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              String newStatus = subtask['status'] == 'Hoàn Thành'
                  ? 'Chưa Hoàn Thành'
                  : 'Hoàn Thành';

              setState(() {
                // Cập nhật trạng thái của subtask
                subtask['status'] = newStatus;

                // Cập nhật trạng thái của các subsubtask nếu có
                if (subtask['subsubtasks'] != null) {
                  for (var subsubtask in subtask['subsubtasks']) {
                    subsubtask['status'] = newStatus;
                  }
                }
                _updateSubtaskStatus(subtask); // Cập nhật trạng thái subtask
                _updateTaskStatus(); // Cập nhật trạng thái task
                widget.resetScreen(); // Cập nhật dữ liệu
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: subtask['status'] == 'Hoàn Thành'
                    ? Colors.green
                    : Colors.transparent,
                border: Border.all(
                  color: _getPriorityColor(subtask['priority']),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: subtask['status'] == 'Hoàn Thành'
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
              '${subtask['subtask']}'
              '${subtask['subsubtasks'] != null && subtask['subsubtasks'].isNotEmpty ? ' (${_getCompletedSubsubtasks(subtask['subsubtasks'])}/${subtask['subsubtasks'].length})' : ''}',
              style: TextStyle(
                color: subtask['status'] == 'Hoàn Thành'
                    ? Colors.green
                    : Colors.black,
                decoration: subtask['status'] == 'Hoàn Thành'
                    ? TextDecoration.lineThrough
                    : null,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (subtask['assignee']?.isNotEmpty ?? false)
            buildCircleAvatar(subtask['assignee'], subtask['avatar']),
        ],
      ),
    );
  }

  // Widget để hiển thị các subsubtasks bên trong một subtask
  Widget buildSubsubtasks(Map subtask) {
    // Lọc subsubtasks dựa trên trạng thái và widget.showCompletedTasks
    final filteredSubsubtasks = widget.showCompletedTasks
        ? subtask['subsubtasks']
        : subtask['subsubtasks']
            .where((subsubtask) => subsubtask['status'] != 'Hoàn Thành')
            .toList();

    return Column(
      children: [
        for (var subsubtask in filteredSubsubtasks) ...[
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

                showDialog(
                  context: context,
                  builder: (context) => TaskDetailsDialog(
                    task: {},
                    taskName: subsubtask['subsubtask'],
                    subtasks: {},
                    subsubtasks: subsubtask,
                    project: widget.project,
                    priorityColor: _getPriorityColor(subsubtask['priority']),
                    data: widget.data,
                    completedSubtasks: completedSubtasks,
                    totalSubtasks: totalSubtasks,
                    selectedDate: widget.selectedDate,
                    typeID: widget.typeID,
                    onStatusChanged: (subtask) {
                      setState(() {
                        subtask['status'] = subtask['status'] == 'Hoàn Thành'
                            ? 'Chưa Hoàn Thành'
                            : 'Hoàn Thành';
                      });
                    },
                    resetScreen: () {
                      setState(() {});
                    },
                    onShowCompletedTasksChanged:
                        widget.onShowCompletedTasksChanged,
                    showCompletedTasks: widget.showCompletedTasks,
                    onDataUpdated: (updatedData) {
                      setState(() {
                        widget.onDataUpdated(updatedData);
                      });
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: subsubtask['status'] == 'Hoàn Thành'
                          ? Colors.green
                          : Colors.transparent,
                      border: Border.all(
                        color: _getPriorityColor(subsubtask['priority']),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: subsubtask['status'] == 'Hoàn Thành'
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
                      subsubtask['subsubtask'],
                      style: TextStyle(
                        color: subsubtask['status'] == 'Hoàn Thành'
                            ? Colors.green
                            : Colors.black,
                        decoration: subsubtask['status'] == 'Hoàn Thành'
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (subsubtask['assignee']?.isNotEmpty ?? false)
                    buildCircleAvatar(
                        subsubtask['assignee'], subsubtask['avatar']),
                ],
              ),
            ),
          ),
        ],
      ],
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
