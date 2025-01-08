import 'package:flutter/material.dart';

class TaskDetailsDialog extends StatefulWidget {
  final Map task; // Dữ liệu của task hiện tại
  final List subtasks; // Danh sách các subtasks của task
  final Color priorityColor; // Màu sắc của ưu tiên task
  final int completedSubtasks; // Số lượng subtasks đã hoàn thành
  final int totalSubtasks; // Tổng số lượng subtasks
  final Function onStatusChanged; // Callback để thay đổi trạng thái của subtask
  final Function onDataUpdated; // Callback để cập nhật dữ liệu khi có thay đổi
  bool showCompletedTasks;
  final Function(bool)
      onShowCompletedTasksChanged; // Callback để thay đổi trạng thái

  TaskDetailsDialog({
    required this.task,
    required this.subtasks,
    required this.priorityColor,
    required this.completedSubtasks,
    required this.totalSubtasks,
    required this.onStatusChanged,
    required this.onDataUpdated,
    required this.showCompletedTasks,
    required this.onShowCompletedTasksChanged,
  });

  @override
  _TaskDetailsDialogState createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  // Hàm lấy màu sắc cho ưu tiên của task
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Cao':
        return Colors.red;
      case 'Trung bình':
        return Colors.orange;
      case 'Thấp':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Cập nhật trạng thái của task dựa trên trạng thái các subtasks
  void _updateTaskStatus() {
    bool allCompleted = true;
    // Kiểm tra tất cả subtasks, nếu có bất kỳ subtask nào chưa hoàn thành thì đánh dấu task là chưa hoàn thành
    for (var subtask in widget.subtasks) {
      if (subtask['status'] != 'Hoàn Thành') {
        allCompleted = false;
        break;
      }
    }

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

  // Cập nhật lại số lượng completedSubtasks sau mỗi thao tác
  int _getCompletedSubtasks() {
    int count = 0;
    for (var subtask in widget.subtasks) {
      if (subtask['status'] == 'Hoàn Thành') {
        count++;
      }
    }
    return count;
  }

  // Tạo CircleAvatar với chữ cái đầu tiên của email
  Widget buildCircleAvatar(String email) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: Text(
            email[0].toUpperCase(),
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
                  context), //Hiển thị priority và dialog chỉnh sửa
              const SizedBox(height: 8.0),
              _buildProjectText(), // Hiển thị thông tin Project
              const SizedBox(height: 8.0),
              _buildDescriptionEdit(
                  context), // Hiển thị description và dialog chỉnh sửa
              const SizedBox(height: 16.0),
              if (widget.subtasks.isNotEmpty)
                buildCompletedSubtasksRow(), //Hiển thị số subtask hoàn thành
              const SizedBox(height: 16.0),
              if (widget.subtasks.isNotEmpty) ...[
                const Divider(),
                Text('Subtasks:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                for (var subtask in widget.subtasks) ...[
                  const SizedBox(height: 16.0),
                  buildSubtaskRow(subtask), // Hiển thị các subtasks
                  if (subtask['subsubtasks'] != null) ...[
                    buildSubsubtasks(subtask), // Hiển thị các subsubtasks
                  ],
                ],
              ],
            ],
          ),
        ),
        actions: [
          buildAddSubtaskButton(), // Nút thêm subtask
          buildAddCommentAndUploadButton(), // Nút thêm comment và upload file
          buildCloseButton(context), // Nút đóng dialog
        ]);
  }

  // Widget để hiển thị tên task và dialog chỉnh sửa
  Widget _buildTaskNameEditDialog(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Edit Task Name'),
            content: TextField(
              controller: TextEditingController(text: widget.task['task']),
              onChanged: (value) {
                setState(() {
                  widget.task['task'] = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Task Name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  widget
                      .onDataUpdated(); // Cập nhật lại dữ liệu sau khi thay đổi
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.task['task'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (widget.task['email']?.isNotEmpty ?? false)
            buildCircleAvatar(widget.task['email']),
          const SizedBox(width: 8),
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
                  // Logic for changing the assignee of the task
                } else if (value == 'toggleCompletedTasksVisibility') {
                  _toggleShowCompletedTasks();
                } else if (value == 'deleteTask') {
                  // Logic for deleting the task
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
              value: widget.task['priority'],
              onChanged: (String? newValue) {
                setState(() {
                  widget.task['priority'] = newValue!;
                });
                Navigator.pop(context); // Đóng dialog
                widget.onDataUpdated(); // Cập nhật dữ liệu sau khi thay đổi
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
        'Priority: ${widget.task['priority']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget để hiển thị thông tin Project
  Widget _buildProjectText() {
    if (widget.task['type'] != null) {
      return Text(
        'Project: ${widget.task['type']}',
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
                  widget
                      .onDataUpdated(); // Cập nhật lại dữ liệu sau khi thay đổi
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

    return Row(
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
              _updateSubtaskStatus(subtask); // cập nhật trạng thái subtask
              _updateTaskStatus(); // cập nhật trạng thái task
              widget.onDataUpdated(); // cập nhật dữ liệu
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
        if (subtask['email']?.isNotEmpty ?? false)
          buildCircleAvatar(subtask['email']),
      ],
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onStatusChanged(
                        subsubtask); // Thay đổi trạng thái của subsubtask
                    _updateSubtaskStatus(
                        subtask); // Cập nhật trạng thái của subtask
                    setState(() {}); // Cập nhật lại trạng thái
                  },
                  child: AnimatedContainer(
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
                if (subsubtask['email']?.isNotEmpty ?? false)
                  buildCircleAvatar(subsubtask['email']),
              ],
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
            // Add your logic to add a subtask
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
}
