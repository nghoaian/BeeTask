import 'package:flutter/material.dart';

class TaskDetailsDialog extends StatefulWidget {
  final Map task;
  final List subtasks;
  final Color priorityColor;
  final int completedSubtasks;
  final int totalSubtasks;
  final Function onStatusChanged;
  final Function onDataUpdated; // Thêm callback để cập nhật dữ liệu

  TaskDetailsDialog({
    required this.task,
    required this.subtasks,
    required this.priorityColor,
    required this.completedSubtasks,
    required this.totalSubtasks,
    required this.onStatusChanged,
    required this.onDataUpdated, // Nhận callback này
  });

  @override
  _TaskDetailsDialogState createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: GestureDetector(
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
                    Navigator.pop(context); // Close dialog
                    widget.onDataUpdated();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
        child: Text(
          widget.task['task'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Priority (with editing ability)
            GestureDetector(
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
                        Navigator.pop(context); // Close dialog
                        widget.onDataUpdated();
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
            ),
            const SizedBox(height: 8.0),

            // Task Project Type (if available)
            if (widget.task['type'] != null)
              Text(
                'Project: ${widget.task['type']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8.0),

            // Task Description (with editing ability)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Edit Description'),
                    content: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 300), // Giới hạn chiều cao của TextField
                        child: TextField(
                          controller: TextEditingController(
                              text: widget.task['description']),
                          onChanged: (value) {
                            setState(() {
                              widget.task['description'] = value;
                            });
                          },
                          maxLines: null, // Cho phép TextField tự động mở rộng
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
                          widget.onDataUpdated();
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
            ),
            const SizedBox(height: 16.0),

            // Display Completed Subtasks
            if (widget.subtasks.isNotEmpty)
              Row(
                children: [
                  Text(
                    'Completed Subtasks: ${_getCompletedSubtasks()} / ${widget.totalSubtasks}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),

            // Subtasks List
            if (widget.subtasks.isNotEmpty) ...[
              const Divider(),
              Text('Subtasks:', style: TextStyle(fontWeight: FontWeight.bold)),
              for (var subtask in widget.subtasks) ...[
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        String newStatus = subtask['status'] == 'Hoàn Thành'
                            ? 'Chưa Hoàn Thành'
                            : 'Hoàn Thành';

                        subtask['status'] = newStatus;

                        if (subtask['subsubtasks'] != null) {
                          for (var subsubtask in subtask['subsubtasks']) {
                            subsubtask['status'] = newStatus;
                          }
                        }

                        setState(() {});
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
                  ],
                ),
                if (subtask['subsubtasks'] != null) ...[
                  const SizedBox(height: 8.0),
                  Column(
                    children: [
                      for (var subsubtask in subtask['subsubtasks']) ...[
                        const SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  widget.onStatusChanged(subsubtask);
                                  _updateSubtaskStatus(subtask);
                                  setState(() {});
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
                                      color: _getPriorityColor(
                                          subsubtask['priority']),
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
                                    decoration:
                                        subsubtask['status'] == 'Hoàn Thành'
                                            ? TextDecoration.lineThrough
                                            : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
      actions: [
        // Add Subtask button
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
              ],
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
        ),
        // Add Comment Section with Upload File Icon
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
              ],
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
        ),
        // Close button (always at the bottom)
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
