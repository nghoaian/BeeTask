import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:bee_task/screen/upcoming/taskdetail_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<Map<String, dynamic>>> _tasks = {
    DateTime(2025, 1, 2): [
      {
        'task': 'Ngủ',
        'status': 'Chưa Hoàn Thành',
        'priority': 'Cao',
        'description':
            'Ngủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtNgủ đủ 8 tiếng để có sức khỏe tốtv',
        'type': 'Work',
        'email': '', // Email added here for the task
        'subtasks': [
          {
            'subtask': 'Đi ngủ đúng giờ',
            'status': 'Chưa Hoàn Thành',
            'priority': 'Cao',
            'email': '', // Email added here for the subtask
            'subsubtasks': [
              {
                'subsubtask': 'Tắt máy tính',
                'status': 'Chưa Hoàn Thành',
                'priority': 'Trung bình',
                'email':
                    'user3@example.com', // Email added here for the subsubtask
              },
              {
                'subsubtask': 'Đi vệ sinh',
                'status': 'Chưa Hoàn Thành',
                'priority': 'Thấp',
                'email':
                    'user4@example.com', // Email added here for the subsubtask
              },
            ],
          },
          {
            'subtask': 'Đi ngủ đúng giờ',
            'status': 'Chưa Hoàn Thành',
            'priority': 'Cao',
            'email': 'user5@example.com', // Email added here for the subtask
            'subsubtasks': [
              {
                'subsubtask': 'Tắt máy tính',
                'status': 'Chưa Hoàn Thành',
                'priority': 'Trung bình',
                'email':
                    'user6@example.com', // Email added here for the subsubtask
              },
              {
                'subsubtask': 'Đi vệ sinh',
                'status': 'Chưa Hoàn Thành',
                'priority': 'Thấp',
                'email':
                    'user7@example.com', // Email added here for the subsubtask
              },
            ],
          },
        ],
      },
      {
        'task': 'Tập thể dục',
        'status': 'Chưa Hoàn Thành',
        'priority': 'Trung bình',
        'description': 'Chạy bộ 30 phút vào buổi sáng',
        'type': 'Inbox',
        'email': 'user8@example.com', // Email added here for the task
        'subtasks': [
          {
            'subtask': 'Khởi động',
            'status': 'Chưa Hoàn Thành',
            'priority': 'Cao',
            'email': 'user9@example.com', // Email added here for the subtask
            'subsubtasks': [
              {
                'subsubtask': 'Giãn cơ',
                'status': 'Chưa Hoàn Thành',
                'priority': 'Cao',
                'email':
                    'user10@example.com', // Email added here for the subsubtask
              },
            ],
          },
        ],
      },
    ],
    DateTime(2025, 1, 3): [
      {
        'task': 'Học lập trình',
        'status': 'Chưa Hoàn Thành',
        'priority': 'Cao',
        'description': 'Học Flutter và Dart',
        'type': 'Work',
        'email': 'user11@example.com', // Email added here for the task
        'subtasks': [
          {
            'subtask': 'Xem video tutorial',
            'status': 'Chưa Hoàn Thành',
            'priority': 'Cao',
            'email': 'user12@example.com', // Email added here for the subtask
            'subsubtasks': [],
          },
          {
            'subtask': 'Thực hành viết mã',
            'status': 'Chưa Hoàn Thành',
            'priority': 'Trung bình',
            'email': 'user13@example.com', // Email added here for the subtask
            'subsubtasks': [],
          },
        ],
      },
    ],
    DateTime(2025, 1, 4): [
      {
        'task': 'Học lập trình',
        'status': 'Chưa Hoàn Thành',
        'priority': 'Cao',
        'description': 'Học Flutter và Dart',
        'type': 'Work',
        'email': 'user14@example.com', // Email added here for the task
        'subtasks': [],
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    List<DateTime> daysInMonth = [];
    for (int i = 0; i <= lastDayOfMonth.day - firstDayOfMonth.day; i++) {
      daysInMonth
          .add(DateTime(month.year, month.month, firstDayOfMonth.day + i));
    }
    return daysInMonth;
  }

  DateTime _getFirstDayOfWeek(DateTime date) {
    int difference = date.weekday - DateTime.monday;
    if (difference > 0) {
      return date.subtract(Duration(days: difference));
    } else {
      return date.add(Duration(days: difference));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCalendar(),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildTaskList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

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
          _calendarFormat = format;
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

  Widget _buildTaskList() {
    final selectedDateTasks = _tasks.entries
        .firstWhere(
          (entry) =>
              entry.key.year == _selectedDay!.year &&
              entry.key.month == _selectedDay!.month &&
              entry.key.day == _selectedDay!.day,
          orElse: () => MapEntry(DateTime(2000), []), // Nếu không có công việc
        )
        .value;

    return Expanded(
      child: selectedDateTasks.isNotEmpty
          ? ListView.builder(
              itemCount: selectedDateTasks.length,
              itemBuilder: (context, index) {
                final task = selectedDateTasks[index];
                final subtasks = (task['subtasks'] as List? ?? []);
                final totalSubtasks = subtasks.length;
                final completedSubtasks = subtasks
                    .where((subtask) => subtask['status'] == 'Hoàn Thành')
                    .length;

                bool isCompleted = subtasks.isNotEmpty
                    ? completedSubtasks == totalSubtasks
                    : task['status'] == 'Hoàn Thành';

                Color priorityColor = _getPriorityColor(task['priority']);

                // Get email and the first letter of it for the avatar
                String? email = task['email'];
                String avatarLetter =
                    email != null && email.isNotEmpty && email != ''
                        ? email[0].toUpperCase()
                        : ''; // Empty string if no email

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return TaskDetailsDialog(
                              task: task,
                              subtasks: subtasks,
                              priorityColor: priorityColor,
                              completedSubtasks: completedSubtasks,
                              totalSubtasks: totalSubtasks,
                              onStatusChanged: (subtask) {
                                setState(() {
                                  subtask['status'] =
                                      subtask['status'] == 'Hoàn Thành'
                                          ? 'Chưa Hoàn Thành'
                                          : 'Hoàn Thành';
                                });
                              },
                              onDataUpdated: () {
                                // Cập nhật lại dữ liệu sau khi dialog đóng
                                setState(() {
                                  // Cập nhật lại các giá trị hoặc trạng thái ở đây
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    task['status'] = isCompleted
                                        ? 'Chưa Hoàn Thành'
                                        : 'Hoàn Thành';

                                    // Update subtasks
                                    for (var subtask in subtasks) {
                                      subtask['status'] = isCompleted
                                          ? 'Chưa Hoàn Thành'
                                          : 'Hoàn Thành';
                                      for (var subsubtask
                                          in subtask['subsubtasks']) {
                                        subsubtask['status'] = isCompleted
                                            ? 'Chưa Hoàn Thành'
                                            : 'Hoàn Thành';
                                      }
                                    }

                                    final completedSubtasks = subtasks
                                        .where((subtask) =>
                                            subtask['status'] == 'Hoàn Thành')
                                        .length;

                                    bool allSubtasksCompleted =
                                        completedSubtasks == subtasks.length;
                                    task['status'] = allSubtasksCompleted
                                        ? 'Hoàn Thành'
                                        : 'Chưa Hoàn Thành';

                                    isCompleted = allSubtasksCompleted;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green
                                        : Colors.transparent,
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
                                  task['task'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              if (avatarLetter.isNotEmpty)
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
                          ),
                          const SizedBox(height: 8.0),
                          Row(
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
                                    task['type'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: priorityColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          if (task['description'] != null)
                            Text(
                              task['description'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons
                            .calendar_badge_plus, // Calendar icon with plus sign
                        size: 50,
                        color: CupertinoColors.activeGreen, // iOS green color
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        CupertinoIcons
                            .check_mark_circled, // Checked circle icon
                        size: 50,
                        color: CupertinoColors.activeGreen, // iOS green color
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
            ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Xử lý khi nhấn nút thêm công việc
        print('Add');
      },
      child:
          Icon(Icons.add, color: Colors.white), // Đặt màu biểu tượng là trắng
      backgroundColor: Colors.red, // Đặt nền màu đỏ
      shape: CircleBorder(), // Đảm bảo hình tròn
    );
  }

  String _getDayName(DateTime date) {
    final dayNames = [
      'Chủ Nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy'
    ];
    return dayNames[date.weekday % 7];
  }
}
