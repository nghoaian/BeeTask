import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/screen/upcoming/taskdetail_dialog.dart';
import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  String _selectedStatus = 'Today';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    List<Map<String, dynamic>> allTasks = [];
    allTasks.addAll(TaskData().tasks);
    allTasks.addAll(TaskData().subtasks);
    allTasks.addAll(TaskData().subsubtasks);

    List<Map<String, dynamic>> filteredTasks = [];
    DateTime currentDate = DateTime.now();
    DateTime tomorrowDate = currentDate.add(Duration(days: 1));
    DateTime yesterdayDate = currentDate.subtract(Duration(days: 1));

    switch (_selectedStatus) {
      case 'Today':
        filteredTasks = allTasks.where((task) {
          DateTime dueDate = DateTime.parse(task['dueDate']);
          return dueDate.year == currentDate.year &&
              dueDate.month == currentDate.month &&
              dueDate.day == currentDate.day;
        }).toList();
        break;
      case 'Tomorrow':
        filteredTasks = allTasks.where((task) {
          DateTime dueDate = DateTime.parse(task['dueDate']);
          return dueDate.year == tomorrowDate.year &&
              dueDate.month == tomorrowDate.month &&
              dueDate.day == tomorrowDate.day;
        }).toList();
        break;
      case 'Yesterday':
        filteredTasks = allTasks.where((task) {
          DateTime dueDate = DateTime.parse(task['dueDate']);
          return dueDate.year == yesterdayDate.year &&
              dueDate.month == yesterdayDate.month &&
              dueDate.day == yesterdayDate.day;
        }).toList();
        break;
      case 'All':
      default:
        filteredTasks = allTasks;
        break;
    }

    setState(() {
      notifications = filteredTasks;
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    print('Tasks from TaskData: ${TaskData().users}');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppColors.primary),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
              _fetchTasks();
            },
            itemBuilder: (BuildContext context) {
              return [
                _buildPopupMenuItem('Today', Icons.today),
                _buildPopupMenuItem('Tomorrow', Icons.calendar_today),
                _buildPopupMenuItem('Yesterday', Icons.history),
                _buildPopupMenuItem('All', Icons.all_inbox),
              ];
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var notification = notifications[index];
          DateTime dueDate = DateTime.parse(notification['dueDate']);
          String dueText = "";

          switch (_selectedStatus) {
            case 'Today':
              if (dueDate.year == DateTime.now().year &&
                  dueDate.month == DateTime.now().month &&
                  dueDate.day == DateTime.now().day) {
                dueText = "is due today!";
              }
              break;
            case 'Tomorrow':
              if (dueDate.year == DateTime.now().add(Duration(days: 1)).year &&
                  dueDate.month ==
                      DateTime.now().add(Duration(days: 1)).month &&
                  dueDate.day == DateTime.now().add(Duration(days: 1)).day) {
                dueText = "is due tomorrow!";
              }
              break;
            case 'Yesterday':
              if (dueDate.year ==
                      DateTime.now().subtract(Duration(days: 1)).year &&
                  dueDate.month ==
                      DateTime.now().subtract(Duration(days: 1)).month &&
                  dueDate.day ==
                      DateTime.now().subtract(Duration(days: 1)).day) {
                dueText = "was due yesterday!";
              }
              break;
            default:
              dueText = "is due on ${DateFormat('dd/MM/yyyy').format(dueDate)}";
              break;
          }

          return GestureDetector(
            onTap: () {
              String type = notification['type'] ?? 'task'; // Get task type
              String taskId = notification['id'] ?? ''; // Get task ID
              String projectName =
                  notification['projectName'] ?? ''; // Get project name
              bool isCompleted =
                  notification['completed'] ?? false; // Get completion status
              bool showCompletedTask = true; // Adjust this value as needed

              _showTaskDetailsDialog(
                taskId,
                type,
                showCompletedTask,
                projectName,
                isCompleted,
              );
            },
            child: Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.toc_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "📌 ${notification['title']} ",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary),
                                ),
                                TextSpan(
                                  text: dueText,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            notification['description'],
                            style: TextStyle(color: Colors.black87),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(dueDate),
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String status, IconData icon) {
    bool isSelected = _selectedStatus == status;
    return PopupMenuItem<String>(
      value: status,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(String taskId, String type,
      bool showCompletedTask, String projectName, bool isCompleted) async {
    bool permissions =
        await TaskData().isUserInProjectPermissions(type, taskId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return SingleChildScrollView(
          child: TaskDetailsDialog(
            taskId: taskId,
            permissions: permissions,
            type: type,
            isCompleted: isCompleted,
            openFirst: true,
            selectDay: DateTime.now(),
            projectName: projectName,
            showCompletedTasks: showCompletedTask,
            taskBloc: BlocProvider.of<TaskBloc>(context),
            resetDialog: () => {},
            resetScreen: () => {},
          ),
        );
      },
    );
  }
}
