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
  CalendarFormat _calendarFormat = CalendarFormat.month; // Mặc định là tháng
  DateTime _focusedDay = DateTime.now(); // Mặc định là ngày hiện tại
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
        'email': 'user8@example.com',
        'subtasks': [
          {
            'subtask': 'Đi ngủ đúng giờ',
            'status': 'Chưa Hoàn Thành',
            'priority': 'Cao',
            'email': '',
            'subsubtasks': [
              {
                'subsubtask': 'Tắt máy tính',
                'status': 'Chưa Hoàn Thành',
                'priority': 'Trung bình',
                'email': 'user3@example.com',
              },
              {
                'subsubtask': 'Đi vệ sinh',
                'status': 'Chưa Hoàn Thành',
                'priority': 'Thấp',
                'email': 'user4@example.com',
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
        'email': '', // Email added here for the task
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
          _buildTaskList(), // Danh sách các công việc theo ngày
        ],
      ),
      floatingActionButton:
          _buildFloatingActionButton(), // Nút thả nổi thêm công việc
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

  // Hàm lấy màu sắc ưu tiên cho task
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

  // Xây dựng danh sách công việc theo ngày đã chọn
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
                return _buildTaskCard(
                    task); // Gọi hàm để xây dựng từng thẻ công việc
              },
            )
          : _buildNoTaskMessage(), // Nếu không có công việc, hiển thị thông báo
    );
  }

  // Widget xây dựng thẻ công việc
  Widget _buildTaskCard(Map<String, dynamic> task) {
    final subtasks = (task['subtasks'] as List? ?? []);
    final totalSubtasks = subtasks.length;
    final completedSubtasks =
        subtasks.where((subtask) => subtask['status'] == 'Hoàn Thành').length;

    bool isCompleted = subtasks.isNotEmpty
        ? completedSubtasks == totalSubtasks
        : task['status'] == 'Hoàn Thành';

    Color priorityColor =
        _getPriorityColor(task['priority']); // Màu sắc của độ ưu tiên

    // Lấy email và chữ cái đầu của email để làm avatar
    String? email = task['email'];
    String avatarLetter =
        email != null && email.isNotEmpty ? email[0].toUpperCase() : '';

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => _showTaskDetailsDialog(
              task, subtasks, priorityColor, completedSubtasks, totalSubtasks),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeaderRow(
                  task, subtasks, isCompleted, priorityColor, avatarLetter),
              const SizedBox(height: 8.0),
              _buildSubtaskAndTypeRow(totalSubtasks, completedSubtasks,
                  task['type'], priorityColor),
              const SizedBox(height: 8.0),
              if (task['description'] != null)
                _buildTaskDescription(task['description']),
            ],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng hàng tiêu đề công việc
  Widget _buildTaskHeaderRow(
    Map<String, dynamic> task,
    List subtasks,
    bool isCompleted,
    Color priorityColor,
    String avatarLetter,
  ) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _toggleTaskCompletion(task, subtasks),
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
            task['task'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
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
    );
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

  // hàm cập nhật trạng thái task
  void _toggleTaskCompletion(Map<String, dynamic> task, List subtasks) {
    setState(() {
      bool isCompleted = task['status'] == 'Hoàn Thành';
      task['status'] = isCompleted ? 'Chưa Hoàn Thành' : 'Hoàn Thành';

      for (var subtask in subtasks) {
        subtask['status'] = isCompleted ? 'Chưa Hoàn Thành' : 'Hoàn Thành';
      }
    });
  }

  // Hàm hiển thị dialog chi tiết công việc
  void _showTaskDetailsDialog(Map<String, dynamic> task, List subtasks,
      Color priorityColor, int completedSubtasks, int totalSubtasks) {
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
              subtask['status'] = subtask['status'] == 'Hoàn Thành'
                  ? 'Chưa Hoàn Thành'
                  : 'Hoàn Thành';
            });
          },
          onDataUpdated: () {
            setState(() {});
          },
        );
      },
    );
  }

  // Widget xây dựng nút thả nổi thêm công việc
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Xử lý khi nhấn nút thêm công việc
        print('Add');
      },
      child: Icon(Icons.add, color: Colors.white),
      backgroundColor: Colors.red,
      shape: CircleBorder(),
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
