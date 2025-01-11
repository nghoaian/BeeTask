import 'package:bee_task/screen/TaskData.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:bee_task/screen/upcoming/taskdetail_dialog.dart';
import 'package:bee_task/screen/upcoming/addtask_dialog.dart';
import 'package:bee_task/util/colors.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/bloc/task/task_state.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Mặc định ngày được chọn là ngày hiện tại
    _focusedDay = DateTime.now(); // Mặc định ngày được chọn là ngày hiện tại
    context.read<TaskBloc>().add(FetchTasksByDate(_selectedDay != null
        ? DateTime(
            _focusedDay.year,
            _focusedDay.month,
            _focusedDay.day,
          ).toIso8601String().substring(0, 10)
        : DateTime.now().toIso8601String().substring(0, 10)));
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
          context.read<TaskBloc>().add(FetchTasksByDate(_selectedDay != null
              ? DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                ).toIso8601String().substring(0, 10)
              : DateTime.now().toIso8601String().substring(0, 10)));
        });
        print(_selectedDay);
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
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          // Hiển thị vòng tròn loading khi dữ liệu đang được tải
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is TaskLoaded) {
          // Khi dữ liệu đã được tải, hiển thị danh sách các task
          final tasks = state.tasks; // Lấy danh sách task từ state

          if (tasks.isEmpty) {
            return _buildNoTaskMessage();
          }
          return Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final Task item = tasks[index];
                return _buildItemCard(item);
              },
            ),
          );
        } else if (state is TaskError) {
          // Khi có lỗi xảy ra, hiển thị thông báo lỗi
          return Center(
            child: Text('Lỗi: ${state.error}'),
          );
        } else {
          // Mặc định hiển thị màn hình trống
          return _buildNoTaskMessage();
          ;
        }
      },
    );
  }

  Widget _buildItemCard(Task item) {
    int totalSubtasks = 0;
    int completedSubtasks = 0;
    String? assignee = item.asssignee;
    String avatar = item.asssignee ?? '';

    String avatarLetter = assignee != null && assignee.isNotEmpty
        ? assignee[0].toUpperCase()
        : '';

    bool isCompleted;

    Color priorityColor = _getPriorityColor(item.priority); // Priority color

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          //   if (item['type'] == 'subtask') {
          //     _showTaskDetailsDialog(
          //       {},
          //       item['subtask'],
          //       item,
          //       {},
          //       item['category'],
          //       priorityColor,
          //       completedSubtasks,
          //       totalSubtasks,
          //       data,
          //       item['typeID'],
          //     );
          //   } else if (item['type'] == 'subsubtask') {
          //     _showTaskDetailsDialog(
          //         {},
          //         item['subsubtask'],
          //         {},
          //         item,
          //         item['category'],
          //         priorityColor,
          //         completedSubtasks,
          //         totalSubtasks,
          //         data,
          //         item['typeID']);
          //   } else {
          //     _showTaskDetailsDialog(
          //         item,
          //         item['task'],
          //         {},
          //         {},
          //         item['category'],
          //         priorityColor,
          //         completedSubtasks,
          //         totalSubtasks,
          //         data,
          //         item['typeID']);
          //   }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTaskHeaderRow(item)],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng hàng tiêu đề công việc
  Widget _buildTaskHeaderRow(Task task) {
    return Row(children: [
      GestureDetector(
        // onTap: () => _toggleTaskCompletion(task),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: task.completed ? Colors.green : Colors.transparent,
            border: Border.all(
              color: _getPriorityColor(task.priority),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: task.completed
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
          task.title, // Sử dụng title đã cập nhật
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
      if (TaskData().getUserAvatarFromList(task.asssignee) != '') ...[
        CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage(
              'assets/$TaskData().getUserAvatarFromList(task.asssignee)'),
        ),
      ] else if (task.asssignee != '') ...[
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: Text(
            task.asssignee,
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
            setState(() {});
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
    // showDialog(
    //   context: context,
    //   builder: (_) => AddTaskDialog(
    //     data: data,
    //     selectDay: _selectedDay ?? DateTime.now(),
    //     onTaskAdded: (task) {
    //       _tasks.add(task);
    //       setState(() {});
    //     },
    //   ),
    // );
  }

  ///Đối trạng thái task,subtask,subsubtask
  void _toggleTaskCompletion(Map<String, dynamic> item) {}
}
