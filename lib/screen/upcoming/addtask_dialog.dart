import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(Map<String, dynamic>)
      onTaskAdded; // Hàm callback để xử lý khi thêm task
  final List<Map<String, dynamic>>
      data; // Danh sách các project và thông tin chi tiết
  final DateTime selectDay; // Ngày được chọn để thêm task

  const AddTaskDialog({
    Key? key,
    required this.onTaskAdded,
    required this.data,
    required this.selectDay,
  }) : super(key: key);

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
  final TextEditingController projectController = TextEditingController(
      text: 'Inbox'); // Controller cho project có giá trị mặc định là Inbox
  final TextEditingController assigneeController =
      TextEditingController(); // Controller cho người được giao việc

  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectDay;
    dateController.text = "${_selectedDay!.toLocal()}".split(' ')[0];
  }

  // Widget chung để tạo trường nhập văn bản
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isMultiline = false,
    GestureTapCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: onTap != null,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          maxLines: isMultiline ? 2 : 1,
        ),
      ),
    );
  }

  // Widget chung để tạo dropdown
  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  // Trường nhập tên công việc
  Widget _buildTaskNameField() {
    return _buildTextField(
      controller: taskNameController,
      label: 'Task Name',
    );
  }

// Dropdown chọn project
  Widget _buildProjectDropdown() {
    return _buildDropdown<int>(
      label: 'Project',
      value: projectController.text.isEmpty
          ? null
          : int.tryParse(projectController.text),
      items: widget.data.map((project) {
        return DropdownMenuItem<int>(
          value: project['id'], // Lưu id vào giá trị
          child: Text(project['type']), // Hiển thị type (tên dự án)
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          projectController.text = value.toString(); // Lưu id của project
          assigneeController.clear(); // Xóa dữ liệu của assignee
        });
      },
    );
  }

// Dropdown chọn người được giao việc
  Widget _buildAssigneeDropdown() {
    // Lấy id dự án từ projectController
    final int? selectedProjectId = int.tryParse(projectController.text);

    // Tìm dự án bằng id
    final selectedProject = widget.data.firstWhere(
      (project) => project['id'] == selectedProjectId,
      orElse: () => {},
    );

    if (selectedProject.isNotEmpty &&
        selectedProject['members'] != null &&
        selectedProject['members'].isNotEmpty) {
      return _buildDropdown<String>(
        label: 'Assignee',
        value: selectedProject['members']
                .any((member) => member['assignee'] == assigneeController.text)
            ? assigneeController.text
            : null, // Đồng bộ giá trị Assignee
        items: selectedProject['members']
            .where((member) => member['assignee'] != null)
            .map<DropdownMenuItem<String>>((member) {
          return DropdownMenuItem<String>(
            value: member['assignee'],
            child: Text(member['assignee']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            assigneeController.text = value!;
          });
        },
      );
    }
    return const SizedBox.shrink();
  }

  // Dropdown chọn mức độ ưu tiên
  Widget _buildPriorityDropdown() {
    return _buildDropdown<String>(
      label: 'Priority',
      value: priorityController.text,
      items: ['Thấp', 'Trung Bình', 'Cao'].map((priority) {
        return DropdownMenuItem<String>(
          value: priority,
          child: Text(priority),
        );
      }).toList(),
      onChanged: (value) {
        priorityController.text = value!;
      },
    );
  }

  // Trường nhập mô tả
  Widget _buildDescriptionField() {
    return _buildTextField(
      controller: descriptionController,
      label: 'Description',
      isMultiline: true,
    );
  }

  // Trường nhập ngày
  Widget _buildDateField() {
    return _buildTextField(
      controller: dateController,
      label: 'Date',
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDay ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null && pickedDate != _selectedDay) {
          _selectedDay = pickedDate;
          dateController.text = "${_selectedDay!.toLocal()}".split(' ')[0];
        }
      },
    );
  }

  // Nút hành động của dialog
  Widget _buildDialogActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
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
        ElevatedButton(
          onPressed: () {
            // Tìm thông tin project và assignee
            String type = '';
            String avatar = '';
            String assignee = '';

            // Lấy id từ projectController
            final int? projectId = int.tryParse(projectController.text);

            // Tìm type của project dựa trên id
            final project = widget.data.firstWhere(
              (proj) => proj['id'] == projectId,
              orElse: () => {},
            );
            if (project.isNotEmpty) {
              type = project['type'] ?? '';
            }

            if (assigneeController.text.isNotEmpty) {
              for (var project in widget.data) {
                if (project['members'] != null &&
                    project['members'].isNotEmpty) {
                  for (var member in project['members']) {
                    if (member['assignee'] == assigneeController.text) {
                      avatar = member['avatar'] ?? ''; // Gán avatar
                      assignee = member['assignee'] ?? ''; // Gán mail assignee

                      break;
                    }
                  }
                }
              }
            }
            final task = {
              'id': DateTime.now().millisecondsSinceEpoch,
              'task': taskNameController.text,
              'status': 'Chưa Hoàn Thành',
              'priority': priorityController.text,
              'description': descriptionController.text,
              'type': type,
              'assignee': assignee,
              'avatar': avatar,
              'date': _selectedDay ?? DateTime.now(),
              'subtasks': [],
            };
            widget.onTaskAdded(task);
            Navigator.pop(context); // Close dialog
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Add New Task',
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
}
