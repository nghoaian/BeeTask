import 'package:bee_task/bloc/task/task_event.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:intl/intl.dart';

class AddTaskDialog extends StatefulWidget {
  final String taskId; // Có thể là null nếu tạo mới
  final DateTime selectDay; // Ngày được chọn để thêm task
  final String type;
  final Function resetScreen;
  final Function resetDialog;
  const AddTaskDialog(
      {Key? key,
      required this.taskId,
      required this.selectDay,
      required this.type,
      required this.resetScreen,
      required this.resetDialog})
      : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController taskNameController =
      TextEditingController(); // Controller cho tên công việc
  final TextEditingController descriptionController =
      TextEditingController(); // Controller cho mô tả
  final TextEditingController priorityController = TextEditingController(
      text:
          'Thấp'); // Controller cho mức độ ưu tiên có giá trị mặc định là Thấp
  final TextEditingController dateController =
      TextEditingController(); // Controller cho ngày
  final TextEditingController projectController =
      TextEditingController(); // Controller cho project có giá trị mặc định là Inbox
  final TextEditingController assigneeController =
      TextEditingController(); // Controller cho người được giao việc

  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectDay;
    dateController.text = "${_selectedDay!.toLocal()}".split(' ')[0];
  }

// Widget nhập tên công việc
  Widget _buildTaskNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Name',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Khi người dùng nhấn vào để mở dialog chỉnh sửa tên task
            _showTaskNameDialog();
          },
          child: AbsorbPointer(
            // Không cho phép nhập trực tiếp vào TextField, thay vào đó mở dialog
            child: TextField(
              controller: taskNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter task name',
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
        ),
      ],
    );
  }

  void _showTaskNameDialog() {
    showDialog(
      context: context,
      builder: (_) {
        String initialValue = taskNameController.text;
        final TextEditingController _controller =
            TextEditingController(text: initialValue);

        return AlertDialog(
          title: const Text('Enter Task Name'),
          content: TextField(
            controller: _controller,
            autofocus:
                true, // Đảm bảo TextField có tiêu điểm khi dialog xuất hiện
            decoration: const InputDecoration(
              labelText: 'Task Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog mà không lưu
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lưu giá trị đã nhập vào taskNameController
                taskNameController.text = _controller.text;

                Navigator.pop(context); // Đóng dialog sau khi lưu
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Dropdown chọn project
  Widget _buildProjectDropdown() {
    var task;
    // Kiểm tra nếu widget.taskId không phải là rỗng
    if (widget.taskId.isNotEmpty || widget.taskId != '') {
      if (widget.type == 'task') {
        // Lấy projectId và projectName từ task
        task = TaskData().tasks.firstWhere(
              (proj) => proj['id'] == widget.taskId,
              orElse: () =>
                  {}, // Nếu không tìm thấy thì trả về một đối tượng trống
            );
      } else if (widget.type == "subtask") {
        task = TaskData().subtasks.firstWhere(
              (proj) => proj['id'] == widget.taskId,
              orElse: () =>
                  {}, // Nếu không tìm thấy thì trả về một đối tượng trống
            );
      } else {
        task = TaskData().subsubtasks.firstWhere(
              (proj) => proj['id'] == widget.taskId,
              orElse: () =>
                  {}, // Nếu không tìm thấy thì trả về một đối tượng trống
            );
      }

      // Nếu tìm thấy task
      String projectId = task['projectId'] ?? '';
      String projectName = task['projectName'] ?? '';

      // Trả về chỉ thị thông tin của project
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            projectName.isEmpty ? 'No project assigned' : projectName,
            style: TextStyle(fontSize: 16),
          ),
        ],
      );
    }

    // Nếu widget.taskId rỗng, thì hiển thị Dropdown để chọn project
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: projectController.text.isEmpty ? null : projectController.text,
          items: TaskData().projects.map((project) {
            return DropdownMenuItem<String>(
              value: project['id'], // Sử dụng 'id' làm giá trị
              child: Text(project['name']), // Hiển thị 'name' trong danh sách
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              projectController.text =
                  value ?? ''; // Cập nhật projectController
              assigneeController.clear(); // Xóa dữ liệu người được giao
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select a project',
          ),
        ),
      ],
    );
  }

  Widget _buildAssigneeDropdown() {
    // Lấy ID dự án từ projectController
    String selectedProjectId =
        projectController.text.isEmpty ? '' : projectController.text;
    var task;
    // Kiểm tra nếu widget.taskId không phải là rỗng
    if (widget.taskId.isNotEmpty || widget.taskId != '') {
      if (widget.type == 'task') {
        // Lấy projectId và projectName từ task
        task = TaskData().tasks.firstWhere(
              (proj) => proj['id'] == widget.taskId,
              orElse: () =>
                  {}, // Nếu không tìm thấy thì trả về một đối tượng trống
            );
        selectedProjectId = task['projectId'] ?? '';
      } else if (widget.type == "subtask") {
        task = TaskData().subtasks.firstWhere(
              (proj) => proj['id'] == widget.taskId,
              orElse: () =>
                  {}, // Nếu không tìm thấy thì trả về một đối tượng trống
            );
        selectedProjectId = task['projectId'] ?? '';
      } else {
        task = TaskData().subsubtasks.firstWhere(
              (proj) => proj['id'] == widget.taskId,
              orElse: () =>
                  {}, // Nếu không tìm thấy thì trả về một đối tượng trống
            );
      }
      selectedProjectId = task['projectId'] ?? '';
    }

    // Tìm dự án dựa trên ID
    final selectedProject = TaskData().projects.firstWhere(
          (project) => project['id'] == selectedProjectId,
          orElse: () => {}, // Trả về null nếu không tìm thấy
        );

    // Kiểm tra nếu dự án hợp lệ và có danh sách thành viên
    if (selectedProject.isNotEmpty &&
        selectedProject.containsKey('members') &&
        selectedProject['members'] is List &&
        (selectedProject['members'] as List).isNotEmpty) {
      final List<String> members =
          List<String>.from(selectedProject['members']); // Ép kiểu danh sách

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assignee',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: assigneeController.text.isEmpty ||
                    !members.contains(assigneeController.text)
                ? null
                : assigneeController.text, // Nếu không tìm thấy assignee, null
            items: members.map<DropdownMenuItem<String>>((member) {
              return DropdownMenuItem<String>(
                value: member, // Giá trị là email
                child: Text(member), // Hiển thị email
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                assigneeController.text = value ?? ''; // Cập nhật assignee
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select an assignee',
            ),
          ),
        ],
      );
    }

    // Trả về widget rỗng nếu không có thành viên
    return const SizedBox.shrink();
  }

  // Dropdown chọn mức độ ưu tiên
  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: priorityController.text.isEmpty
              ? null
              : priorityController.text, // Giá trị hiện tại trong controller
          items: ['Thấp', 'Trung Bình', 'Cao'].map((priority) {
            return DropdownMenuItem<String>(
              value: priority,
              child: Text(priority),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              priorityController.text = value!; // Cập nhật controller
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select priority',
          ),
        ),
      ],
    );
  }

// Trường nhập mô tả
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Khi người dùng nhấn vào, hiển thị dialog để nhập mô tả
            _showDescriptionDialog();
          },
          child: AbsorbPointer(
            child: TextField(
              controller: descriptionController,
              maxLines: null, // Cho phép nhập nhiều dòng
              keyboardType:
                  TextInputType.multiline, // Loại bàn phím hỗ trợ nhiều dòng
              decoration: const InputDecoration(
                hintText: 'Enter task description',
                border: OutlineInputBorder(), // Viền ngoài cho trường nhập
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDescriptionDialog() {
    final TextEditingController _dialogController =
        TextEditingController(text: descriptionController.text);
    final FocusNode _focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Đảm bảo FocusNode được kích hoạt khi dialog xuất hiện
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
        });

        return AlertDialog(
          title: const Text('Enter Description'),
          content: TextField(
            controller: _dialogController,
            focusNode: _focusNode, // Đưa focus vào TextField khi dialog mở
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Enter task description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Đóng dialog mà không lưu thay đổi
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lưu giá trị từ _dialogController vào descriptionController
                setState(() {
                  descriptionController.text = _dialogController.text;
                });
                Navigator.pop(context); // Đóng dialog sau khi lưu
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

// Trường nhập ngày
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: dateController,
          readOnly: true, // Ngăn người dùng nhập trực tiếp
          decoration: const InputDecoration(
            hintText: 'Select a date',
            border: OutlineInputBorder(), // Viền ngoài cho trường nhập
            suffixIcon: Icon(Icons.calendar_today), // Icon lịch ở bên phải
          ),
          onTap: () async {
            // Hiển thị trình chọn ngày
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDay ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null && pickedDate != _selectedDay) {
              setState(() {
                _selectedDay = pickedDate; // Lưu giá trị ngày được chọn
                dateController.text =
                    "${_selectedDay!.toLocal()}".split(' ')[0];
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDialogActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nút Cancel
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Đóng dialog khi người dùng nhấn Cancel
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),

        // Nút Save
        ElevatedButton(
          onPressed: () async {
            // Hiển thị dialog thông báo đang thêm task
            showDialog(
              context: context,
              barrierDismissible:
                  false, // Không cho phép đóng dialog bằng cách nhấn ngoài
              builder: (_) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );

            // Lấy thông tin dự án và assignee
            String type = '';
            String avatar = '';
            String assignee = assigneeController.text;

            // Lấy id từ projectController
            String projectId = projectController.text;
            if (widget.taskId.isNotEmpty || widget.taskId != '') {
              if (widget.type == 'task') {
                var task = TaskData().tasks.firstWhere(
                      (proj) => proj['id'] == widget.taskId,
                      orElse: () =>
                          {}, // Nếu không tìm thấy thì trả về một đối tượng trống
                    );
                projectId = task['projectId'];
              } else if (widget.type == 'subtask') {
                var task = TaskData().subtasks.firstWhere(
                      (proj) => proj['id'] == widget.taskId,
                      orElse: () =>
                          {}, // Nếu không tìm thấy thì trả về một đối tượng trống
                    );
                projectId = task['projectId'];
              } else {
                var task = TaskData().subsubtasks.firstWhere(
                      (proj) => proj['id'] == widget.taskId,
                      orElse: () =>
                          {}, // Nếu không tìm thấy thì trả về một đối tượng trống
                    );
                projectId = task['projectId'];
              }
            }

            // Tìm type của project dựa trên id
            final project = TaskData().projects.firstWhere(
                  (proj) => proj['id'] == projectId,
                  orElse: () => {},
                );
            if (project.isNotEmpty) {
              type = project['id'] ?? '';
            }

            // Cập nhật task với các thông tin từ các trường nhập liệu
            final task = {
              'task': taskNameController.text,
              'status': 'Chưa Hoàn Thành',
              'priority': priorityController.text,
              'description': descriptionController.text,
              'typeID': type,
              'assignee': assignee,
              'date': _selectedDay ?? DateTime.now(),
            };

            // Tạo đối tượng Task
            Task taskData = Task(
              id: '', // Sử dụng widget.taskId nếu có, nếu không để trống
              title: task['task'].toString(),
              description: task['description'].toString(),
              dueDate: _formatDueDate(_selectedDay?.toIso8601String() ?? ''),
              priority: task['priority'].toString(),
              assignee: task['assignee'].toString(),
              completed: false,
              type: type, // Dùng 'type' là type của project
              projectName: '', // Dùng tên task hoặc projectName nếu cần
              subtasks: [],
            );

            try {
              if (widget.type == 'task') {
                context.read<TaskBloc>().add(
                    AddTask('subtask', taskData, widget.taskId, projectId));
              } else if (widget.type == 'subtask') {
                context.read<TaskBloc>().add(
                    AddTask('subsubtask', taskData, widget.taskId, projectId));
              } else {
                context
                    .read<TaskBloc>()
                    .add(AddTask('task', taskData, widget.taskId, projectId));
              }

              // Simulate a delay of 2 seconds before closing the dialog and adding the task
              await Future.delayed(Duration(seconds: 2));
              widget.resetScreen();

              widget.resetDialog();
              // Close the loading dialog
              Navigator.pop(context); // Close loading dialog

              // Now close the task creation dialog as well
              Navigator.pop(context); // Close the main task dialog

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task added successfully!')),
              );
            } catch (e) {
              // Close the loading dialog on failure
              Navigator.pop(context); // Close loading dialog

              // Optionally, close the task creation dialog as well
              Navigator.pop(context); // Close the task creation dialog

              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error while adding task: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    if (widget.type == 'task' || widget.type == 'subtask') {
      title = 'Add New Subtask';
    } else {
      title = 'Add New Task';
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskNameField(),
            const SizedBox(height: 12),
            _buildProjectDropdown(),
            const SizedBox(height: 12),
            _buildAssigneeDropdown(),
            const SizedBox(height: 12),
            _buildPriorityDropdown(),
            const SizedBox(height: 12),
            _buildDescriptionField(),
            const SizedBox(height: 12),
            _buildDateField(),
          ],
        ),
      ),
      actions: [_buildDialogActions()],
    );
  }

  String _formatDueDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString); // Chuyển chuỗi thành DateTime
      return DateFormat('yyyy-MM-dd')
          .format(date); // Định dạng thành yyyy-MM-dd
    } catch (e) {
      return ''; // Nếu có lỗi thì trả về chuỗi rỗng
    }
  }
}
