import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:bee_task/screen/upcoming/taskdetail_dialog.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/bloc/task/task_state.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/screen/upcoming/addtask_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week; // Mặc định là tháng
  DateTime _focusedDay = DateTime.now(); // Mặc định là ngày hiện tại
  DateTime _selectedDay = DateTime.now();
  bool showCompletedTasks =
      true; // Biến trạng thái để hiển thị/ẩn task hoàn thành
  var tasks = TaskData().tasks;
  var subtasks = TaskData().subtasks;
  var subsubtasks = TaskData().subsubtasks;
  var users = TaskData().users;
  var project = TaskData().projects;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Mặc định ngày được chọn là ngày hiện tại
    _focusedDay = DateTime.now(); // Mặc định ngày được chọn là ngày hiện tại
    context.read<TaskBloc>().add(FetchTasksByDate(
        (_selectedDay != null
            ? DateTime(
                _selectedDay.year,
                _selectedDay.month,
                _selectedDay.day,
              ).toIso8601String().substring(0, 10)
            : DateTime.now().toIso8601String().substring(0, 10)),
        showCompletedTasks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(), // Gọi hàm để xây dựng AppBar
      body: Column(
        children: [
          _buildCalendar(), // Xây dựng giao diện lịch
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildToggleCompletedButton(), // Nút chuyển đổi hiển thị task hoàn thành

          Expanded(
            child: _buildTaskList(),
          ), // Danh sách các công việc theo ngày
          const SizedBox(height: 8.0),
        ],
      ),
      floatingActionButton:
          _buildFloatingActionButton(context), // Nút thả nổi thêm công việc
    );
  }

  // Widget xây dựng AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Upcoming',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  // Widget xây dựng lịch với TableCalendar
  Widget _buildCalendar() {
    return Container(
      color: Colors.white,
      child: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            context.read<TaskBloc>().add(FetchTasksByDate(
                (_selectedDay != null
                    ? DateTime(
                        _selectedDay.year,
                        _selectedDay.month,
                        _selectedDay.day,
                      ).toIso8601String().substring(0, 10)
                    : DateTime.now().toIso8601String().substring(0, 10)),
                showCompletedTasks));
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
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonTextStyle: TextStyle(color: Colors.black),
          titleTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
        calendarStyle: const CalendarStyle(
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
          outsideTextStyle: TextStyle(color: Colors.black),
          rowDecoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
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
                context.read<TaskBloc>().add(FetchTasksByDate(
                    (_selectedDay != null
                        ? DateTime(
                            _selectedDay.year,
                            _selectedDay.month,
                            _selectedDay.day,
                          ).toIso8601String().substring(0, 10)
                        : DateTime.now().toIso8601String().substring(0, 10)),
                    showCompletedTasks));
              });
            },
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is TaskLoaded) {
          final tasks = state.tasks;

          if (tasks.isEmpty) {
            return _buildNoTaskMessage();
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final Task item = tasks[index];
              return _buildItemCard(item);
            },
          );
        } else if (state is TaskError) {
          return Center(
            child: Text('Lỗi: ${state.error}',
                style: TextStyle(color: Colors.red)),
          );
        } else {
          return _buildNoTaskMessage();
        }
      },
    );
  }

  Widget _buildItemCard(Task item) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          _showTaskDetailsDialog(item.id, item.type, showCompletedTasks,
              item.projectName, item.completed);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeaderRow(item),
              _buildSubtaskAndTypeRow(item),
              _buildTaskDescription(item.description),
            ],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng hàng tiêu đề công việc

  Widget _buildTaskHeaderRow(Task task) {
    var user = users.firstWhere((user) => user['userEmail'] == task.assignee,
        orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
        );
    var t;
    if (task.type == 'task') {
      t = TaskData().tasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    } else if (task.type == 'subtask') {
      t = TaskData().subtasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    } else {
      t = TaskData().subsubtasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            String status = 'complete';
            if (task.completed == true) {
              status = 'uncomplete';
            }
            context.read<TaskBloc>().add(logTaskActivity(
                t['projectId'], task.id, status, {}, task.type));
            context.read<TaskBloc>().add(UpdateTask(task.id, task, task.type));

            setState(() {
              task.completed = !task.completed;
              if (task.completed == true) {
                if (task.type == 'task') {
                  var relevantTask = tasks.firstWhere((t) => t['id'] == task.id,
                      orElse: () => {});

                  // Nếu tìm thấy task, tìm các subtasks liên quan
                  if (relevantTask != null || relevantTask.isNotEmpty) {
                    relevantTask['completed'] = true;

                    var relevantSubtasks = subtasks
                        .where((subtask) =>
                            subtask['taskId'] == relevantTask['id'])
                        .toList();
                    relevantSubtasks.forEach((subtask) {
                      subtask['completed'] = true;
                      var relevantSubSubtasks = subsubtasks
                          .where((subsubtask) =>
                              subsubtask['subtaskId'] == subtask['id'])
                          .toList();
                      relevantSubSubtasks.forEach((subsubtask) {
                        subsubtask['completed'] = true;
                      });
                    });
                  }
                } else if (task.type == 'subtask') {
                  var relevantSubTask = subtasks
                      .firstWhere((t) => t['id'] == task.id, orElse: () => {});

                  if (relevantSubTask != null || relevantSubTask.isNotEmpty) {
                    relevantSubTask['completed'] = true;

                    var relevantSubSubtasks = subsubtasks
                        .where((subsubtask) =>
                            subsubtask['subtaskId'] == relevantSubTask['id'])
                        .toList();
                    relevantSubSubtasks.forEach((subsubtask) {
                      subsubtask['completed'] = true;
                    });
                  }
                }
              } else {
                if (task.type == 'subsubtask') {
                  var relevantSubSubTask = subsubtasks
                      .firstWhere((t) => t['id'] == task.id, orElse: () => {});

                  if (relevantSubSubTask != null ||
                      relevantSubSubTask.isNotEmpty) {
                    relevantSubSubTask['completed'] = false;

                    var relevantSubtasks = subtasks
                        .where((subtask) =>
                            subtask['id'] == relevantSubSubTask['subtaskId'])
                        .toList();
                    relevantSubtasks.forEach((subtask) {
                      subtask['completed'] = false;
                    });

                    var relevantTasks = tasks
                        .where((taskItem) =>
                            taskItem['id'] == relevantSubSubTask['taskId'])
                        .toList();
                    relevantTasks.forEach((taskItem) {
                      taskItem['completed'] = false;
                    });
                  }
                } else if (task.type == 'subtask') {
                  var relevantSubTask = subtasks
                      .firstWhere((t) => t['id'] == task.id, orElse: () => {});

                  if (relevantSubTask != null || relevantSubTask.isNotEmpty) {
                    relevantSubTask['completed'] = false;

                    var relevantTasks = tasks
                        .where((taskItem) =>
                            taskItem['id'] == relevantSubTask['taskId'])
                        .toList();
                    relevantTasks.forEach((taskItem) {
                      taskItem['completed'] = false;
                    });
                  }
                } else {
                  var relevantTask = tasks.firstWhere((t) => t['id'] == task.id,
                      orElse: () => {});

                  // Nếu tìm thấy task, tìm các subtasks liên quan
                  if (relevantTask != null || relevantTask.isNotEmpty) {
                    relevantTask['completed'] = false;
                  }
                }
              }
              context.read<TaskBloc>().add(FetchTasksByDate(
                  (_selectedDay != null
                      ? DateTime(
                          _selectedDay.year,
                          _selectedDay.month,
                          _selectedDay.day,
                        ).toIso8601String().substring(0, 10)
                      : DateTime.now().toIso8601String().substring(0, 10)),
                  showCompletedTasks));
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: task.completed ? Colors.green : Colors.transparent,
              border: Border.all(
                color: TaskData().getPriorityColor(task.priority),
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
            task.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (task.assignee != '') ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: TaskData().getColorFromString(user['userColor']),
            child: Text(
              user['userName'][0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubtaskAndTypeRow(Task task) {
    // Số lượng subtasks đã hoàn thành và tổng số subtasks
    int completedSubtasks = 0;
    int totalSubtasks = 0;
    int commentCount = 0;

    if (task.type == 'task') {
      // Kiểm tra nếu 'subtasks' không null và không rỗng
      // Tìm các subtasks có taskId trùng với id của task
      var relevantSubtasks =
          subtasks.where((subtask) => subtask['taskId'] == task.id).toList();

      totalSubtasks = relevantSubtasks.length;
      var t = TaskData().tasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
      commentCount = (t['commentCount'] is int)
          ? t['commentCount']
          : int.tryParse(t['commentCount'].toString()) ?? 0;

      // Đếm số subtask có completed = true
      completedSubtasks = relevantSubtasks
          .where((subtask) => subtask['completed'] == true)
          .length;
    } else if (task.type == 'subtask') {
      // Kiểm tra nếu 'subsubtasks' không null và không rỗng

      // Tương tự cho subsubtask
      var relevantSubsubtasks = subsubtasks
          .where((subsubtask) => subsubtask['subtaskId'] == task.id)
          .toList();
      var t = TaskData().subtasks.firstWhere((taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
      commentCount = (t['commentCount'] is int)
          ? t['commentCount']
          : int.tryParse(t['commentCount'].toString()) ?? 0;

      // Đếm số subtask có completed = true
      completedSubtasks = relevantSubsubtasks
          .where((subtask) => subtask['completed'] == true)
          .length;

      totalSubtasks = relevantSubsubtasks.length;
      completedSubtasks = relevantSubsubtasks
          .where((subsubtask) => subsubtask['completed'] == true)
          .length;
    } else {
      totalSubtasks = 0;
      completedSubtasks = 0;
      var t = TaskData().subsubtasks.firstWhere(
          (taskF) => taskF['id'] == task.id,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
      commentCount = (t['commentCount'] is int)
          ? t['commentCount']
          : int.tryParse(t['commentCount'].toString()) ?? 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Hiển thị số lượng subtasks nếu có subtasks
            if (totalSubtasks > 0)
              Text(
                '$completedSubtasks / $totalSubtasks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            if (commentCount > 0) ...[
              const SizedBox(
                  width: 16), // Thêm khoảng cách giữa subtasks và comment
              Row(
                children: [
                  Icon(Icons.comment,
                      size: 16, color: Colors.grey[600]), // Icon comment
                  const SizedBox(
                      width: 4), // Khoảng cách giữa icon và số lượng comment
                  Text(
                    '$commentCount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // Hiển thị projectName luôn căn phải
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              task.projectName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
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
        color: Colors.grey[800],
      ),
    );
  }

  // Widget hiển thị thông báo không có công việc
  Widget _buildNoTaskMessage() {
    return const Center(
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
              SizedBox(width: 10),
              Icon(
                CupertinoIcons.check_mark_circled,
                size: 50,
                color: CupertinoColors.activeGreen,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'You have a free day',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Let\'s relax',
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
      backgroundColor: AppColors.primary,
      shape: CircleBorder(),
    );
  }

  // Hàm hiển thị dialog chi tiết công việc
  void _showTaskDetailsDialog(String taskId, String type,
      bool showCompletedTask, String projectName, bool isCompleted) async {
    bool permissions =
        await TaskData().isUserInProjectPermissions(type, taskId);

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: TaskDetailsDialog(
            taskId: taskId,
            permissions: permissions,
            type: type,
            isCompleted: isCompleted,
            openFirst: true,
            selectDay: _selectedDay ?? DateTime.now(),
            projectName: projectName,
            showCompletedTasks: showCompletedTask,
            taskBloc: BlocProvider.of<TaskBloc>(context),
            resetDialog: () => {},
            resetScreen: () => setState(() {
              context.read<TaskBloc>().add(
                    FetchTasksByDate(
                        (_selectedDay != null
                            ? DateTime(
                                _selectedDay.year,
                                _selectedDay.month,
                                _selectedDay.day,
                              ).toIso8601String().substring(0, 10)
                            : DateTime.now()
                                .toIso8601String()
                                .substring(0, 10)),
                        showCompletedTasks),
                  );
            }),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        context.read<TaskBloc>().add(FetchTasksByDate(
            (_selectedDay != null
                ? DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                  ).toIso8601String().substring(0, 10)
                : DateTime.now().toIso8601String().substring(0, 10)),
            showCompletedTasks));
      });
    });
  }

  // void _showTaskDetailsDialog(String taskId, String type,
  //     bool showCompletedTask, String projectName, bool isCompleted) async {
  //   bool permissions =
  //       await TaskData().isUserInProjectPermissions(type, taskId);

  //   showModalBottomSheet(
  //     backgroundColor: Colors.white,
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return LayoutBuilder(
  //         builder: (context, constraints) {
  //           double heightFactor = 0.9; // Default height factor

  //           // Adjust heightFactor based on the height of the AlertDialog
  //           if (constraints.maxHeight < 600) {
  //             heightFactor = 0.8;
  //           } else if (constraints.maxHeight < 400) {
  //             heightFactor = 0.7;
  //           }

  //           return FractionallySizedBox(
  //             heightFactor: heightFactor,
  //             child: TaskDetailsDialog(
  //               taskId: taskId,
  //               permissions: permissions,
  //               type: type,
  //               isCompleted: isCompleted,
  //               openFirst: true,
  //               selectDay: _selectedDay ?? DateTime.now(),
  //               projectName: projectName,
  //               showCompletedTasks: showCompletedTask,
  //               taskBloc: BlocProvider.of<TaskBloc>(context),
  //               resetDialog: () => {},
  //               resetScreen: () => setState(() {
  //                 context.read<TaskBloc>().add(
  //                       FetchTasksByDate(
  //                           (_selectedDay != null
  //                               ? DateTime(
  //                                   _selectedDay.year,
  //                                   _selectedDay.month,
  //                                   _selectedDay.day,
  //                                 ).toIso8601String().substring(0, 10)
  //                               : DateTime.now()
  //                                   .toIso8601String()
  //                                   .substring(0, 10)),
  //                           showCompletedTasks),
  //                     );
  //               }),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   ).whenComplete(() {
  //     setState(() {
  //       context.read<TaskBloc>().add(FetchTasksByDate(
  //           (_selectedDay != null
  //               ? DateTime(
  //                   _selectedDay.year,
  //                   _selectedDay.month,
  //                   _selectedDay.day,
  //                 ).toIso8601String().substring(0, 10)
  //               : DateTime.now().toIso8601String().substring(0, 10)),
  //           showCompletedTasks));
  //     });
  //   });
  // }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: AddTaskDialog(
            projectId: '',
            taskId: '', // Add appropriate taskId
            type: '', // Add appropriate type
            selectDay: _selectedDay ?? DateTime.now(),
            resetDialog: () => {},
            resetScreen: () => setState(() {
              context.read<TaskBloc>().add(
                    FetchTasksByDate(
                        (_selectedDay != null
                            ? DateTime(
                                _selectedDay.year,
                                _selectedDay.month,
                                _selectedDay.day,
                              ).toIso8601String().substring(0, 10)
                            : DateTime.now()
                                .toIso8601String()
                                .substring(0, 10)),
                        showCompletedTasks),
                  );
            }),
          ),
        );
      },
    );
  }
}
