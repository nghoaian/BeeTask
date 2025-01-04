import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sticky_headers/sticky_headers.dart'; // Thư viện cần thiết

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
      {'task': 'Ngủ', 'status': 'Chưa Hoàn Thành', 'priority': 'Cao'},
      {'task': 'Ăn cơm', 'status': 'Chưa Hoàn Thành', 'priority': 'Trung Bình'}
    ],
    DateTime(2025, 1, 3): [
      {'task': 'Ngủ', 'status': 'Hoàn Thành', 'priority': 'Thấp'},
      {'task': 'Học bài', 'status': 'Chưa Hoàn Thành', 'priority': 'Cao'},
      {'task': 'Đi dạo', 'status': 'Chưa Hoàn Thành', 'priority': 'Trung Bình'}
    ],
    DateTime(2025, 1, 4): [
      {'task': 'Học bài', 'status': 'Chưa Hoàn Thành', 'priority': 'Cao'},
      {'task': 'Chơi game', 'status': 'Hoàn Thành', 'priority': 'Thấp'},
      {
        'task': 'Dọn dẹp',
        'status': 'Chưa Hoàn Thành',
        'priority': 'Trung Bình'
      },
      {'task': 'Gọi điện thoại', 'status': 'Hoàn Thành', 'priority': 'Thấp'}
    ],
    DateTime(2025, 1, 5): [
      {'task': 'Làm việc', 'status': 'Chưa Hoàn Thành', 'priority': 'Cao'},
      {
        'task': 'Tập thể dục',
        'status': 'Chưa Hoàn Thành',
        'priority': 'Trung Bình'
      },
      {'task': 'Đi shopping', 'status': 'Chưa Hoàn Thành', 'priority': 'Thấp'}
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

  // Hàm để lấy ngày đầu tiên của tuần
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

          // Nếu ngày được chọn thuộc tháng trước hoặc sau, điều chỉnh _selectedDay để không bị lỗi
          if (_selectedDay!.month != _focusedDay.month) {
            _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
          }
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
          // Điều chỉnh lại _selectedDay khi chuyển tháng
          if (_calendarFormat == CalendarFormat.month) {
            if (_selectedDay == null ||
                _selectedDay!.month != focusedDay.month) {
              _selectedDay = DateTime(focusedDay.year, focusedDay.month, 1);
            }
          } else if (_calendarFormat == CalendarFormat.week) {
            _selectedDay = _getFirstDayOfWeek(focusedDay);
            if (_selectedDay!.month != focusedDay.month) {
              _selectedDay = DateTime(focusedDay.year, focusedDay.month, 1);
            }
          }
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

  Widget _buildTaskList() {
    final daysInMonth = _getDaysInMonth(_focusedDay);
    final startIndex = _selectedDay != null
        ? daysInMonth.indexWhere((date) => isSameDay(date, _selectedDay!))
        : 0;
    final daysFromSelectedDay = daysInMonth.sublist(startIndex);

    return Expanded(
      child: ListView.builder(
        itemCount: daysFromSelectedDay.length,
        itemBuilder: (context, index) {
          final date = daysFromSelectedDay[index];
          final tasks = _tasks[date] ?? [];

          // Nhóm công việc theo độ ưu tiên trong ngày
          Map<String, List<Map<String, dynamic>>> groupedTasks = {};
          for (var task in tasks) {
            String priority = task['priority'];
            if (groupedTasks[priority] == null) {
              groupedTasks[priority] = [];
            }
            groupedTasks[priority]?.add(task);
          }

          // Sắp xếp các độ ưu tiên theo thứ tự
          List<String> priorities = ['Cao', 'Trung Bình', 'Thấp'];
          List<String> existingPriorities = priorities
              .where((priority) => groupedTasks.containsKey(priority))
              .toList();

          return StickyHeader(
            header: Container(
              color: Colors.grey[200],
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${date.day}/${date.month} · ${_getDayName(date)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(existingPriorities.length, (i) {
                String priority = existingPriorities[i];
                final tasksWithPriority = groupedTasks[priority] ?? [];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '$priority',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ...tasksWithPriority.map((taskData) {
                      bool isCompleted = taskData['status'] == 'Hoàn Thành';

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isCompleted
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isCompleted
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        // Toggle task completion status
                                        isCompleted = !isCompleted;
                                        taskData['status'] = isCompleted
                                            ? 'Hoàn Thành'
                                            : 'Chưa Hoàn Thành';
                                      });
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Xử lý khi nhấn vào nội dung công việc
                                      print(
                                          'Clicked on task: ${taskData['task']}');
                                    },
                                    child: Text(
                                      taskData['task'],
                                      style: TextStyle(
                                        color: isCompleted
                                            ? Colors.green
                                            : Colors.black,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    }).toList(),
                    // Chỉ hiển thị Divider giữa các nhóm công việc có độ ưu tiên khác nhau
                    if (i < existingPriorities.length - 1) Divider(),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }

  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Xử lý khi nhấn nút thêm công việc
        print('Add new task');
      },
      child:
          Icon(Icons.add, color: Colors.white), // Đặt màu biểu tượng là trắng
      backgroundColor: Colors.red, // Đặt nền màu đỏ
      shape: CircleBorder(), // Đảm bảo hình tròn
    );
  }
}
