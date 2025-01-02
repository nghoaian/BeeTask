import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _tasks = {
    DateTime(2025, 1, 2): ['Ngủ'],
    DateTime(2025, 1, 3): ['Ngủ'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCalendar(),
          Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          _buildTaskList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Upcoming', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
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

          // Điều chỉnh lại _selectedDay khi chuyển giữa chế độ tháng và tuần
          if (_calendarFormat == CalendarFormat.month) {
            // Nếu chuyển sang chế độ tháng, đảm bảo ngày chọn không vượt quá tháng hiện tại
            if (_selectedDay == null ||
                _selectedDay!.month != focusedDay.month) {
              _selectedDay = DateTime(focusedDay.year, focusedDay.month, 1);
            }
          } else if (_calendarFormat == CalendarFormat.week) {
            // Nếu chuyển sang chế độ tuần, đảm bảo ngày chọn là ngày đầu tuần của tháng hiện tại
            _selectedDay = _getFirstDayOfWeek(focusedDay);
            if (_selectedDay!.month != focusedDay.month) {
              // Nếu ngày đầu tuần không nằm trong tháng hiện tại, cập nhật lại
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

  // Helper function to get the first day of the week
  DateTime _getFirstDayOfWeek(DateTime date) {
    int difference = date.weekday - DateTime.monday;
    if (difference > 0) {
      return date.subtract(Duration(days: difference));
    } else {
      return date.add(Duration(days: difference));
    }
  }

  Widget _buildTaskList() {
    final daysInMonth = _getDaysInMonth(_focusedDay);
    final startIndex = _selectedDay != null
        ? daysInMonth.indexWhere((date) => isSameDay(date, _selectedDay!))
        : 0;
    final daysFromSelectedDay = daysInMonth.sublist(startIndex);

    return Expanded(
      child: ListView(
        children: [
          ...daysFromSelectedDay.map((date) {
            final tasks = _tasks[date] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 8.0),
                  child: Text(
                    '${date.day}/${date.month} · ${_getDayName(date)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                  ),
                ...tasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: Icon(Icons.circle_outlined),
                        title: Text(task),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Inbox',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Icon(
                              Icons.mail_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    )),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[300],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: Colors.red,
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 30,
      ),
      shape: CircleBorder(),
      elevation: 6,
    );
  }

  String _getDayName(DateTime date) {
    final weekday = date.weekday;
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}
