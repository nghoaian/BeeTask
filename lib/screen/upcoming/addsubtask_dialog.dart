import 'package:flutter/material.dart';

class AddSubTaskDialog extends StatefulWidget {
  final List data;
  final DateTime selectDay; // Ngày được chọn để thêm subtask
  final String typeID;
  const AddSubTaskDialog({
    Key? key,
    required this.data,
    required this.selectDay,
    required this.typeID,
  }) : super(key: key);

  @override
  _AddSubTaskDialogState createState() => _AddSubTaskDialogState();
}

class _AddSubTaskDialogState extends State<AddSubTaskDialog> {
  final TextEditingController taskNameController =
      TextEditingController(); // Controller cho tên công việc

  final TextEditingController priorityController = TextEditingController(
      text:
          'Thấp'); // Controller cho mức độ ưu tiên có giá trị mặc định là Thấp
  final TextEditingController dateController =
      TextEditingController(); // Controller cho ngày

  final TextEditingController assigneeController =
      TextEditingController(); // Controller cho người được giao việc

  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectDay;
    dateController.text = "${_selectedDay!.toLocal()}".split(' ')[0];
    final TextEditingController projectController = TextEditingController(
        text: widget
            .typeID); // Controller cho project có giá trị mặc định là TypeID
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

  Widget _buildProjectDropdown() {
    // Tìm kiếm project trong data dựa trên widget.typeID

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
        color: Colors.grey[100],
      ),
      child: Text(
        widget.typeID, // Hiển thị type của project
        style: TextStyle(
          color: widget.typeID == 'No Project Selected'
              ? Colors.grey
              : Colors.black,
        ),
      ),
    );
  }

// Dropdown chọn người được giao việc
  Widget _buildAssigneeDropdown() {
    // Tìm dự án bằng id
    print(widget.data);
    // Trả về widget rỗng khi không có thành viên
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
              'typeID': widget.typeID,
              'assignee': assignee,
              'avatar': avatar,
              'date': _selectedDay ?? DateTime.now(),
              'subtasks': [],
            };
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
            _buildDateField(),
          ],
        ),
      ),
      actions: [_buildDialogActions()],
    );
  }
}
