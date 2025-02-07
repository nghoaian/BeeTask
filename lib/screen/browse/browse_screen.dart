import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/bloc/project/project_state.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/screen/browse/notification_screen.dart';
import 'package:bee_task/screen/project/add_project_screen.dart';
import 'package:bee_task/screen/project/project_screen.dart';
import 'package:bee_task/screen/setting/statisticsScreen.dart';
import 'package:bee_task/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/screen/upcoming/addtask_dialog.dart';
import 'package:bee_task/screen/browse/activityLogScreen.dart';

class BrowseScreen extends StatefulWidget {
  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late FirebaseTaskRepository taskRepository;
  late FirebaseUserRepository userRepository;
  var projects = TaskData().projects;
  var users = TaskData().users;

  @override
  void initState() {
    super.initState();
    taskRepository =
        FirebaseTaskRepository(firestore: FirebaseFirestore.instance);
    userRepository = FirebaseUserRepository(
      firestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    );
    BlocProvider.of<ProjectBloc>(context).add(LoadProjectsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ProjectBloc>(context),
      child: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: buildAppBar(),
          body: buildBody(),
          floatingActionButton: _buildFloatingActionButton(context),
          backgroundColor: Colors.grey[200],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(
        'Browse',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
      ),
      backgroundColor: Colors.grey[200],
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  Widget buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Khối 1: Inbox, Filters & Labels, Completed
              buildSectionGroup(
                [
                  buildInboxButton(userRepository.getUserEmail(), Icons.inbox),
                  // buildDividerWithPadding(),
                  // buildButton("Statistics", Icons.show_chart),
                  // buildDividerWithPadding(),
                  buildButton('Notifications', Icons.notifications),
                ],
              ),

              // Dòng "My Projects" nằm giữa các khối
              buildMyProjectsSection(),

              // Hiển thị các project
              BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ProjectLoaded) {
                    final projects = state.projects
                        .where((project) => project["name"] != "Inbox")
                        .toList();
                    return buildSectionGroup(
                      projects.map((project) {
                        final isEditProject =
                            state.projectPermissions[project["id"]!] ?? false;
                        return buildButton(
                          project["name"],
                          Icons.tag,
                          projectId: project["id"],
                          isEditProject: isEditProject,
                        );
                      }).toList(),
                    );
                  } else if (state is ProjectError) {
                    return Center(child: Text(state.message));
                  } else {
                    return SizedBox.shrink();
                  }
                },
              )

              // Dòng "Browse Templates" với nền trắng và bo tròn
              //buildBrowseTemplates(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget buildButton(String title, IconData icon,
      {int? count, String? projectId, bool? isEditProject}) {
    return TextButton(
      onPressed: () async {
        if (title == 'Notifications') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationScreen()),
          );
        } else if (title == 'Statistics') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StatisScreen()),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectScreen(
                projectId: projectId!,
                projectName: title,
                isShare: true,
                isEditProject: isEditProject!,
                taskRepository: taskRepository,
                userRepository: userRepository,
                resetScreen: () {
                  setState(() {
                    BlocProvider.of<ProjectBloc>(context)
                        .add(LoadProjectsEvent());
                  });
                },
              ),
            ),
          );
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        trailing: count != null
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[200],
                child: Text(
                  count.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              )
            : null,
      ),
    );
  }

  Widget buildMyProjectsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0), // Thụt vào bên phải
          child: Text(
            "My Projects",
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.grey[800]),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      content: AddProjectScreen(
                        onProjectAdded: (project) {
                          // Thêm logic xử lý sau khi nhận project mới
                          print('New project added: $project');
                          // Có thể dispatch event thêm project tại đây
                          BlocProvider.of<ProjectBloc>(context)
                              .add(AddProjectEvent(project));
                        },
                      ),
                    );
                  },
                );
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.expand_more, color: Colors.grey),
            //   onPressed: () {},
            // ),
          ],
        ),
      ],
    );
  }

  // Nhóm các mục thành một khối
  Widget buildSectionGroup(List<Widget> sectionWidgets) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        children: sectionWidgets,
      ),
    );
  }

  // Divider với khoảng cách thụt vào để phân chia rõ ràng
  Widget buildDividerWithPadding() {
    return Row(
      children: [
        SizedBox(width: 55), // Điều chỉnh độ thụt lề
        Expanded(child: Divider()),
      ],
    );
  }

  Widget buildInboxButton(Future<String?> future, IconData icon) {
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        final email = snapshot.data ?? "No email";
        return TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectScreen(
                  projectId: email,
                  projectName: 'Inbox',
                  isShare: false,
                  isEditProject: false,
                  taskRepository: taskRepository,
                  userRepository: userRepository,
                  resetScreen: () => setState(() {
                    BlocProvider.of<ProjectBloc>(context)
                        .add(LoadProjectsEvent());
                  }),
                ),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: ListTile(
            leading: Icon(icon, color: AppColors.primary),
            title: Text(
              "Inbox",
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            child: AddTaskDialog(
              projectId: '',
              taskId: '', // Add appropriate taskId
              type: '', // Add appropriate type
              selectDay: DateTime.now(),
              resetDialog: () => {},
              resetScreen: () => {},
            ),
          ),
        );
      },
    );
  }
}
