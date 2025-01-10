import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:bee_task/screen/upcoming/taskdetail_dialog.dart';
import 'package:bee_task/screen/upcoming/addtask_dialog.dart';
import 'package:bee_task/util/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month; // Mặc định là tháng
  DateTime _focusedDay = DateTime.now(); // Mặc định là ngày hiện tại
  DateTime? _selectedDay;
  bool showCompletedTasks =
      true; // Biến trạng thái để hiển thị/ẩn task hoàn thành

  final List<Map<String, dynamic>> _tasks = [
    {
      "id": 'task1',
      "task": "Ngủ",
      "status": "Chưa Hoàn Thành",
      "priority": "Cao",
      "description": "Ngủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng...",
      "typeID": "type3",
      "assignee": "thong@example.com",
      "avatar": "",
      "date": "2025-01-02",
      "subtasks": [
        {
          "id": 'subtask11',
          "subtask": "Đi ngủ đúng giờ",
          "status": "Chưa Hoàn Thành",
          "priority": "Cao",
          "assignee": "thong@example.com",
          "avatar": "",
          "date": "2025-01-02",
          "subsubtasks": [
            {
              "id": 'subbsubtask111',
              "subsubtask": "Tắt máy tính",
              "status": "Chưa Hoàn Thành",
              "priority": "Trung bình",
              "assignee": "an@example.com",
              "avatar": "",
              "date": "2025-01-02"
            },
            {
              "id": 'subsubtask112',
              "subsubtask": "Đi vệ sinh",
              "status": "Chưa Hoàn Thành",
              "priority": "Thấp",
              "assignee": "an@example.com",
              "avatar": "",
              "date": "2025-01-02"
            }
          ]
        },
        {
          "id": 'subtask12',
          "subtask": "Đi ngủ đúng giờ",
          "status": "Chưa Hoàn Thành",
          "priority": "Cao",
          "assignee": "an@example.com",
          "avatar": "",
          "date": "2025-01-02",
          "subsubtasks": [
            {
              "id": 'subsubtask121',
              "subsubtask": "Tắt máy tính",
              "status": "Chưa Hoàn Thành",
              "priority": "Trung bình",
              "assignee": "thong@example.com",
              "avatar": "",
              "date": "2025-01-02"
            },
            {
              "id": 'subsubtask122',
              "subsubtask": "Đi vệ sinh",
              "status": "Chưa Hoàn Thành",
              "priority": "Thấp",
              "assignee": "an@example.com",
              "avatar": "",
              "date": "2025-01-02"
            }
          ]
        }
      ]
    },
    {
      "id": 'task2',
      "task": "Tập thể dục",
      "status": "Chưa Hoàn Thành",
      "priority": "Trung bình",
      "description": "Chạy bộ 30 phút vào buổi sáng",
      "typeID": "type1",
      "assignee": "",
      "avatar": "",
      "date": "2025-01-02",
      "subtasks": [
        {
          "id": 'subtask21',
          "subtask": "Khởi động",
          "status": "Chưa Hoàn Thành",
          "priority": "Cao",
          "assignee": "",
          "avatar": "",
          "date": "2025-01-02",
          "subsubtasks": [
            {
              "id": 'subsubtask211',
              "subsubtask": "Giãn cơ",
              "status": "Chưa Hoàn Thành",
              "priority": "Cao",
              "assignee": "",
              "avatar": "",
              "date": "2025-01-02"
            }
          ]
        }
      ]
    },
    {
      "id": 'task3',
      "task": "Học lập trình",
      "status": "Chưa Hoàn Thành",
      "priority": "Cao",
      "description": "Học Flutter và Dart",
      "typeID": "type2",
      "assignee": "user11@example.com",
      "avatar": "",
      "date": "2025-01-03",
      "subtasks": [
        {
          "id": 'subtask31',
          "subtask": "Xem video tutorial",
          "status": "Chưa Hoàn Thành",
          "priority": "Cao",
          "assignee": "user12@example.com",
          "avatar": "",
          "date": "2025-01-03",
          "subsubtasks": []
        },
        {
          "id": 'subtask32',
          "subtask": "Thực hành viết mã",
          "status": "Chưa Hoàn Thành",
          "priority": "Trung bình",
          "assignee": "user13@example.com",
          "avatar": "",
          "date": "2025-01-03",
          "subsubtasks": []
        }
      ]
    },
    {
      "id": 'task4',
      "task": "Học lập trình",
      "status": "Chưa Hoàn Thành",
      "priority": "Cao",
      "description": "Học Flutter và Dart",
      "typeID": "type2",
      "assignee": "user14@example.com",
      "avatar": "",
      "date": "2025-01-04",
      "subtasks": []
    }
  ];

  List<Map<String, dynamic>> data = [
    {"id": 'type1', "type": "Inbox", "members": []},
    {
      "id": 'type2',
      "type": "Work",
      "members": [
        {"id": 'member101', "assignee": "user8@example.com", "avatar": ""},
        {"id": 'member102', "assignee": "user14@example.com", "avatar": ""}
      ]
    },
    {
      "id": 'type3',
      "type": "Test",
      "members": [
        {"id": 'member103', "assignee": "thong@example.com", "avatar": ""},
        {"id": 'member104', "assignee": "an@example.com", "avatar": ""}
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Mặc định ngày được chọn là ngày hiện tại
    _focusedDay = DateTime.now(); // Mặc định ngày được chọn là ngày hiện tại
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Gọi hàm để xây dựng AppBar
      body: Column(
        children: [
          _buildCalendar(), // Xây dựng giao diện lịch
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildToggleCompletedButton(), // Nút chuyển đổi hiển thị task hoàn thành

          Expanded(
            child: _buildTaskList(),
          ), // Danh sách các công việc theo ngày
        ],
      ),
      floatingActionButton:
          _buildFloatingActionButton(context), // Nút thả nổi thêm công việc
    );
  }

  // Widget xây dựng AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Upcoming', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.grey[300],
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  // Widget xây dựng lịch với TableCalendar
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat =
              format; // Thay đổi định dạng của lịch (tháng hay tuần)
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      availableCalendarFormats: const {
        CalendarFormat.month: 'Week',
        CalendarFormat.week: 'Month',
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonTextStyle: TextStyle(color: Colors.black),
        titleTextStyle:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(color: Colors.black),
        weekendTextStyle: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildToggleCompletedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Show Completed Tasks',
            style: TextStyle(fontSize: 16.0),
          ),
          Switch(
            value: showCompletedTasks,
            onChanged: (value) {
              setState(() {
                showCompletedTasks = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Hàm lấy màu sắc ưu tiên cho task
  Color _getPriorityColor(String priority) {
    return AppColors.getPriorityColor(priority);
  }

  Widget _buildTaskList() {
    final items =
        _getSubtasksAndSubsubtasksBySelectedDate(); // lấy toàn bộ task, subtask, subsubtask theo ngày được chọn

    if (items.isEmpty) {
      return _buildNoTaskMessage(); // Show message if no data is found
    }

    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    int totalSubtasks = 0;
    int completedSubtasks = 0;
    String? assignee = item['assignee'];
    String avatar = item['avatar'] ?? '';

    String avatarLetter = assignee != null && assignee.isNotEmpty
        ? assignee[0].toUpperCase()
        : '';

    bool isCompleted;

    // Kiểm tra loại công việc
    if (item['type'] == 'subtask') {
      final subsubtasks = (item['subsubtasks'] as List? ?? []);
      totalSubtasks = subsubtasks.length;
      completedSubtasks = subsubtasks
          .where((subtask) => subtask['status'] == 'Hoàn Thành')
          .length;
      isCompleted = subsubtasks.isNotEmpty
          ? completedSubtasks == totalSubtasks
          : item['status'] == "Hoàn Thành";
    } else if (item['type'] == 'subsubtask') {
      isCompleted = item['status'] == 'Hoàn Thành';
    } else {
      final subtasks = (item['subtasks'] as List? ?? []);
      totalSubtasks = subtasks.length;
      completedSubtasks =
          subtasks.where((subtask) => subtask['status'] == 'Hoàn Thành').length;
      isCompleted = subtasks.isNotEmpty
          ? completedSubtasks == totalSubtasks
          : item['status'] == 'Hoàn Thành';
    }

    Color priorityColor = _getPriorityColor(item['priority']); // Priority color

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          if (item['type'] == 'subtask') {
            _showTaskDetailsDialog(
              {},
              item['subtask'],
              item,
              {},
              item['category'],
              priorityColor,
              completedSubtasks,
              totalSubtasks,
              data,
              item['typeID'],
            );
          } else if (item['type'] == 'subsubtask') {
            _showTaskDetailsDialog(
                {},
                item['subsubtask'],
                {},
                item,
                item['category'],
                priorityColor,
                completedSubtasks,
                totalSubtasks,
                data,
                item['typeID']);
          } else {
            _showTaskDetailsDialog(
                item,
                item['task'],
                {},
                {},
                item['category'],
                priorityColor,
                completedSubtasks,
                totalSubtasks,
                data,
                item['typeID']);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item['type'] == 'subtask') ...[
                _buildTaskHeaderRow(
                    item,
                    item['subsubtasks'], // Pass subsubtasks for subtasks
                    isCompleted,
                    priorityColor,
                    avatarLetter,
                    avatar),
                const SizedBox(height: 8.0),
                _buildSubtaskAndTypeRow(totalSubtasks, completedSubtasks,
                    item['category'], priorityColor),
                const SizedBox(height: 8.0),
              ] else if (item['type'] == 'subsubtask') ...[
                _buildTaskHeaderRow(
                    item,
                    [], // Pass empty list for subsubtasks in subsubtask
                    isCompleted,
                    priorityColor,
                    avatarLetter,
                    avatar),
                const SizedBox(height: 8.0),
                _buildSubtaskAndTypeRow(totalSubtasks, completedSubtasks,
                    item['category'], priorityColor),
                const SizedBox(height: 8.0),
              ] else ...[
                _buildTaskHeaderRow(
                    item, // Use the full task object for header row
                    item['subtasks'],
                    isCompleted, // Check task completion
                    priorityColor,
                    avatarLetter,
                    avatar),
                const SizedBox(height: 8.0),
                _buildSubtaskAndTypeRow(totalSubtasks, completedSubtasks,
                    item['category'], priorityColor),
                const SizedBox(height: 8.0),
                if (item['description'] != null)
                  _buildTaskDescription(item['description']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng hàng tiêu đề công việc
  Widget _buildTaskHeaderRow(
    Map<String, dynamic> item,
    List subtasks,
    bool isCompleted,
    Color priorityColor,
    String avatarLetter,
    String avatar,
  ) {
    String title = '';

    // Kiểm tra và hiển thị đúng thông tin tùy theo 'type' của item
    if (item['type'] == 'subtask') {
      title = item['subtask'] ??
          'No Subtask Name'; // Kiểm tra nếu không có subtask thì hiển thị 'No Subtask Name'
    } else if (item['type'] == 'subsubtask') {
      title = item['subsubtask'] ??
          'No Subsubtask Name'; // Kiểm tra nếu không có subsubtask thì hiển thị 'No Subsubtask Name'
    } else {
      title = item[
          'task']; // Kiểm tra nếu không có task thì hiển thị 'No Task Name'
    }

    return Row(children: [
      GestureDetector(
        onTap: () => _toggleTaskCompletion(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : Colors.transparent,
            border: Border.all(
              color: priorityColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: isCompleted
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
          title, // Sử dụng title đã cập nhật
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
      if (avatar.isNotEmpty || avatar != '') ...[
        CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage('assets/$avatar'),
        ),
      ] else if (avatarLetter.isNotEmpty) ...[
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: Text(
            avatarLetter,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ]);
  }

  // Widget hiển thị số subtask hoàn thành và type
  Widget _buildSubtaskAndTypeRow(int totalSubtasks, int completedSubtasks,
      String taskType, Color priorityColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (totalSubtasks > 0)
          Text(
            '$completedSubtasks / $totalSubtasks',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              taskType,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: priorityColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget hiển thị mô tả công việc
  Widget _buildTaskDescription(String description) {
    return Text(
      description,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
    );
  }

  // Widget hiển thị thông báo không có công việc
  Widget _buildNoTaskMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.calendar_badge_plus,
                size: 50,
                color: CupertinoColors.activeGreen,
              ),
              const SizedBox(width: 10),
              Icon(
                CupertinoIcons.check_mark_circled,
                size: 50,
                color: CupertinoColors.activeGreen,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Bạn có một ngày rảnh rỗi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hãy thư giãn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng nút thả nổi thêm công việc
  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showAddTaskDialog(context);
      },
      child: Icon(Icons.add, color: Colors.white),
      backgroundColor: Colors.red,
      shape: CircleBorder(),
    );
  }

  // Hàm hiển thị dialog chi tiết công việc
  void _showTaskDetailsDialog(
    Map<String, dynamic> task,
    String taskName,
    Map<String, dynamic> subtasks,
    Map<String, dynamic> subsubtasks,
    String project,
    Color priorityColor,
    int completedSubtasks,
    int totalSubtasks,
    List<Map<String, dynamic>> data,
    String typeID,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return TaskDetailsDialog(
          task: task,
          taskName: taskName,
          subtasks: subtasks,
          subsubtasks: subsubtasks,
          project: project,
          priorityColor: priorityColor,
          completedSubtasks: completedSubtasks,
          totalSubtasks: totalSubtasks,
          typeID: typeID,
          data: data,
          selectedDate: _selectedDay ?? DateTime.now(),
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
          onShowCompletedTasksChanged: _toggleShowCompletedTasks,
          showCompletedTasks: showCompletedTasks,
          onDataUpdated: (updatedData) {
            setState(() {
              updateTaskById(updatedData['id'], updatedData);
            });
          },
        );
      },
    );
  }

  void _toggleShowCompletedTasks(bool newStatus) {
    setState(() {
      showCompletedTasks = newStatus;
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(
        data: data,
        selectDay: _selectedDay ?? DateTime.now(),
        onTaskAdded: (task) {
          _tasks.add(task);
          setState(() {});
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getSubtasksAndSubsubtasksBySelectedDate() {
    final List<Map<String, dynamic>> results = [];

    // Make sure _selectedDay is non-null
    if (_selectedDay == null) return results;

    for (var task in _tasks) {
      // Check if the task has a date that matches the selected date
      DateTime taskDate = task['date'] is DateTime
          ? task['date']
          : DateTime.parse(task['date']);

      if (taskDate.year == _selectedDay!.year &&
          taskDate.month == _selectedDay!.month &&
          taskDate.day == _selectedDay!.day) {
        // Add the task to the results
        results.add({
          'type': 'task',
          'category': findTypeById(task['typeID']), // Add task type here
          ...task, // Include all task information
        });
      }

      final subtasks = (task['subtasks'] as List? ?? []);

      for (var subtask in subtasks) {
        DateTime taskDateSubTask = subtask['date'] is DateTime
            ? subtask['date']
            : DateTime.parse(subtask['date']);
        // Check if the subtask has a date that matches the selected date
        if (taskDateSubTask.year == _selectedDay!.year &&
            taskDateSubTask.month == _selectedDay!.month &&
            taskDateSubTask.day == _selectedDay!.day) {
          // Add the subtask to the results, including the task type
          results.add({
            'type': 'subtask',
            'typeID': task['typeID'],
            'category': findTypeById(task['typeID']), // Add task type here
            ...subtask, // Include all subtask information
          });

          // Check for subsubtasks
          final subsubtasks = (subtask['subsubtasks'] as List? ?? []);
          for (var subsubtask in subsubtasks) {
            DateTime taskDateSubSubTask = subsubtask['date'] is DateTime
                ? subsubtask['date']
                : DateTime.parse(subsubtask['date']);
            if (taskDateSubSubTask.year == _selectedDay!.year &&
                taskDateSubSubTask.month == _selectedDay!.month &&
                taskDateSubSubTask.day == _selectedDay!.day) {
              // Add the subsubtask to the results, including the task type
              results.add({
                'type': 'subsubtask',
                'typeID': task['typeID'],
                'category': findTypeById(task['typeID']), // Add task type here
                ...subsubtask, // Include all subsubtask information
              });
            }
          }
        }
      }
    }

    return results;
  }

  String findTypeById(String id) {
    try {
      // Tìm kiếm trong danh sách data
      var project = data.firstWhere((project) => project['id'] == id);
      return project['type']; // Trả về giá trị type
    } catch (e) {
      return 'Project not found'; // Trường hợp không tìm thấy
    }
  }

  void updateTaskById(int id, Map<String, dynamic> updatedData) {
    for (var task in _tasks) {
      if (task['id'] == id) {
        updatedData.forEach((key, value) {
          // Nếu giá trị là null, thay thế bằng chuỗi rỗng hoặc danh sách rỗng
          if (value == null) {
            if (key == 'subtasks' || key == 'subsubtasks') {
              task[key] = []; // Nếu là danh sách, thay thế bằng []
            } else {
              task[key] = ''; // Nếu là chuỗi, thay thế bằng ''
            }
          } else {
            task[key] = value;
          }
        });
        return;
      }

      if (task.containsKey('subtasks')) {
        for (var subtask in task['subtasks']) {
          if (subtask['id'] == id) {
            updatedData.forEach((key, value) {
              if (value == null) {
                if (key == 'subsubtasks') {
                  subtask[key] = []; // Nếu là danh sách, thay thế bằng []
                } else {
                  subtask[key] = ''; // Nếu là chuỗi, thay thế bằng ''
                }
              } else {
                subtask[key] = value;
              }
            });
            return;
          }

          if (subtask.containsKey('subsubtasks')) {
            for (var subsubtask in subtask['subsubtasks']) {
              if (subsubtask['id'] == id) {
                updatedData.forEach((key, value) {
                  if (value == null) {
                    if (key == 'subsubtasks') {
                      subsubtask[key] =
                          []; // Nếu là danh sách, thay thế bằng []
                    } else {
                      subsubtask[key] = ''; // Nếu là chuỗi, thay thế bằng ''
                    }
                  } else {
                    subsubtask[key] = value;
                  }
                });
                return;
              }
            }
          }
        }
      }
    }
  }

  ///Đối trạng thái task,subtask,subsubtask
  void _toggleTaskCompletion(Map<String, dynamic> item) {}
}
