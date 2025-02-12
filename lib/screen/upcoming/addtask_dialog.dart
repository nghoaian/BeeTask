import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/util/colors.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTaskDialog extends StatefulWidget {
  final String projectId;
  final String taskId; 
  final DateTime selectDay; // Ngày được chọn để thêm task
  final String type;
  final Function resetScreen;
  final Function resetDialog;
  AddTaskDialog(
      {Key? key,
      required this.projectId,
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
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController taskNameController =
      TextEditingController(); // Controller cho tên công việc
  final TextEditingController descriptionController =
      TextEditingController(); // Controller cho mô tả
  final TextEditingController priorityController = TextEditingController(
      text: 'Low'); // Controller cho mức độ ưu tiên có giá trị mặc định là Thấp
  final TextEditingController dateController =
      TextEditingController(); // Controller cho ngày

  final TextEditingController projectController =
      TextEditingController(); // Controller cho dự án

  final TextEditingController assigneeController =
      TextEditingController(); // Controller cho người được giao việc
  String taskNameError = '';

  DateTime? _selectedDay;
  late String projectID;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectDay;
    _selectedDay = widget.selectDay;
    projectID = widget.projectId;
    projectController.text = user != null
        ? user?.email ?? ''
        : ''; // Nếu user không null, gán email, nếu null thì để rỗng
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
            child: TextField(
              controller: taskNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                hintText: 'Enter task name',
                errorText: taskNameError.isNotEmpty ? taskNameError : null,
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
                true, 
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
                taskNameController.text = _controller.text;
                if (taskNameController.text.trim() != '') {
                  setState(() {
                    taskNameError = '';
                  });
                } else {
                  setState(() {
                    taskNameError = 'Task name cannot be empty';
                  });
                }

                Navigator.pop(context); // Đóng dialog sau khi lưu
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<Widget> _buildProjectDropdown() async {
    // Kiểm tra nếu widget.taskId không phải là rỗng
    if (widget.taskId.isNotEmpty || widget.taskId != '') {
      var task;

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
    } else if (projectID != '') {
      bool check = await TaskData().ProjectPermissions(widget.projectId);
      if (check == true) {
        projectController.text = projectID;
        return _buildProjectDropdownWithChoices();
      }
    }

    // Nếu widget.taskId rỗng, kiểm tra nếu projectController là user?.email
    if (projectController.text == user?.email) {
      var userProject = TaskData().projects.firstWhere(
            (proj) => proj['id'] == user?.email,
            orElse: () => {}, // Trả về đối tượng rỗng nếu không tìm thấy
          );
      if (userProject.isEmpty) {
        projectController.text = '';

        return _buildProjectDropdownWithChoices();
      }

      return _buildProjectDropdownWithChoices();
    }

    return _buildProjectDropdownWithChoices();
  }

// Hàm dựng dropdown để người dùng chọn project
  Widget _buildProjectDropdownWithChoices() {

    var projects = TaskData().projects;

    final filteredProjects = projects.where((project) {
      return project['permissions'] != null &&
          project['permissions'].contains(user?.email);
    }).toList();

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
          items: filteredProjects.map((project) {
            return DropdownMenuItem<String>(
              value: project['id'], // Sử dụng id cho value
              child: Text(project['name']), // Hiển thị name 
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              projectController.text = value ?? ''; 
              assigneeController.clear(); 
              projectID = '';
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: 'Select a project',
          ),
        ),
      ],
    );
  }

  Future<Widget> _buildAssigneeDropdown() async {
    // Lấy ID dự án từ projectController

    String selectedProjectId =
        projectController.text.isEmpty ? '' : projectController.text;

    var task;

    if (widget.projectId.isNotEmpty) {
      bool check = await TaskData().ProjectPermissions(widget.projectId);
      if (check == true) {
        selectedProjectId = widget.projectId;
      }
    } else if (widget.taskId.isNotEmpty || widget.taskId != '') {
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

      // Nếu chỉ có một thành viên trong danh sách, không hiển thị dropdown
      if (members.length == 1) {
        return const SizedBox.shrink();
      }

      // Nếu có nhiều hơn một thành viên, hiển thị dropdown
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assignee',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity, // Giúp dropdown không bị tràn
            child: DropdownButtonFormField<String>(
              isExpanded: true, // Mở rộng dropdown để tránh lỗi tràn chữ
              value: assigneeController.text.isEmpty ||
                      !members.contains(assigneeController.text)
                  ? null
                  : assigneeController.text,
              items: members.map<DropdownMenuItem<String>>((member) {
                return DropdownMenuItem<String>(
                  value: member,
                  child: SizedBox(
                    width: 200, // Giới hạn chiều rộng của dropdown item
                    child: Text(
                      member,
                      overflow:
                          TextOverflow.ellipsis, // Nếu quá dài thì hiển thị ...
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  assigneeController.text = value ?? '';
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return members.map<Widget>((String member) {
                  return SizedBox(
                    width: 150, // Giới hạn chiều rộng của item đã chọn
                    child: Text(
                      member,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList();
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select an assignee',
              ),
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
          items: ['Low', 'Medium', 'Hign'].map((priority) {
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ), // Viền ngoài cho trường nhập
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
    if (_selectedDay != null) {
      dateController.text = "${_selectedDay!.toLocal()}".split(' ')[0];
    }

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
          readOnly: true, 
          decoration: const InputDecoration(
            hintText: 'Select a date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ), 
            suffixIcon:
                Icon(Icons.calendar_today), 
          ),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDay ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null && pickedDate != _selectedDay) {
              setState(() {
                _selectedDay = pickedDate; 
                dateController.text = "${_selectedDay!.toLocal()}"
                    .split(' ')[0]; 
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
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 16),
        // Nút Save
        ElevatedButton(
          onPressed: () async {
            if (taskNameController.text.trim() == '') {
              setState(() {
                taskNameError = 'Task name cannot be empty';
              });

              // Trỏ lại vào ô nhập liệu
            } else {
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
              String assignee = assigneeController.text.isNotEmpty
                  ? assigneeController.text
                  : (user?.email ?? '');

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

              final task = {
                'task': taskNameController.text,
                'status': 'Chưa Hoàn Thành',
                'priority': priorityController.text,
                'description': descriptionController.text,
                'typeID': type,
                'assignee': assignee ?? user?.email,
                'date': _selectedDay ?? DateTime.now(),
              };

              // Tạo đối tượng Task
              Task taskData = Task(
                id: '',
                title: task['task'].toString(),
                description: task['description'].toString(),
                dueDate: _formatDueDate(_selectedDay?.toIso8601String() ?? ''),
                priority: task['priority'].toString(),
                assignee: task['assignee'].toString(),
                completed: false,
                type: type, 
                projectName: '', 
                subtasks: [],
              );

              try {
                if (widget.type == 'task') {
                  context.read<TaskBloc>().add(AddTask(
                      'noID', 'subtask', taskData, widget.taskId, projectId));
                } else if (widget.type == 'subtask') {
                  context.read<TaskBloc>().add(AddTask('noID', 'subsubtask',
                      taskData, widget.taskId, projectId));
                } else {
                  context.read<TaskBloc>().add(AddTask(
                      'noID', 'task', taskData, widget.taskId, projectId));
                }

                await Future.delayed(Duration(seconds: 2));
                if (widget.type == '') {
                  widget.resetScreen();
                } else {
                  widget.resetDialog();
                }

                Navigator.pop(context); 

                Navigator.pop(context); 

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task added successfully!')),
                );
              } catch (e) {
                Navigator.pop(context); 

                Navigator.pop(context);

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error while adding task: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
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
      backgroundColor: Colors.white,
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
            FutureBuilder<Widget>(
              future: _buildProjectDropdown(),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data ?? SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<Widget>(
              future: _buildAssigneeDropdown(),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data ?? SizedBox.shrink();
                }
              },
            ),
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
