import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/bloc/project/project_state.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/screen/project/add_project_screen.dart';
import 'package:bee_task/screen/project/project_screen.dart';
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

  @override
  void initState() {
    super.initState();
    taskRepository =
        FirebaseTaskRepository(firestore: FirebaseFirestore.instance);
    userRepository = FirebaseUserRepository(
      firestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProjectBloc(FirebaseFirestore.instance)..add(LoadProjectsEvent()),
      child: Scaffold(
        body: buildBody(),
        floatingActionButton: _buildFloatingActionButton(context),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            'A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: AppColors.primary),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.settings, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
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
                  buildDividerWithPadding(),
                  buildButton("Activity log", Icons.history),
                  buildDividerWithPadding(),
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
                    return buildSectionGroup(
                      state.projects.map((project) {
                        return buildButton(
                          project["name"],
                          Icons.tag,
                          projectId: project["id"],
                        );
                      }).toList(),
                    );
                  } else if (state is ProjectError) {
                    return Center(child: Text(state.message));
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),

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
      backgroundColor: Colors.red,
      shape: CircleBorder(),
    );
  }

  Widget buildButton(String title, IconData icon,
      {int? count, String? projectId}) {
    return TextButton(
      onPressed: () {
        if (title == 'Inbox') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectScreen(
                  projectId: projectId!,
                  projectName: title,
                  isShare: true,
                  taskRepository: taskRepository,
                  userRepository: userRepository),
            ),
          );
        } else if (title == 'Activity log') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ActivityLogScreen()));
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
        Padding(
          padding: const EdgeInsets.only(left: 16.0), // Thụt vào bên phải
          child: TextButton.icon(
            onPressed: () {
              // Xử lý khi bấm vào "My Projects"
              print("My Projects clicked!");
            },
            icon: const Text(
              "My Projects",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            label: Icon(Icons.chevron_right, color: Colors.black),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.grey),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AddProjectScreen(
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
            IconButton(
              icon: Icon(Icons.expand_more, color: Colors.grey),
              onPressed: () {},
            ),
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
                  taskRepository: taskRepository,
                  userRepository: userRepository,
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
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AddTaskDialog(
            taskId: '', // Add appropriate taskId
            type: '', // Add appropriate type
            selectDay: DateTime.now(),
            resetDialog: () => {},
            resetScreen: () => {},
          ),
        );
      },
    );
  }

  // // Phần "Browse Templates" với nền trắng và bo tròn
  // Widget buildBrowseTemplates() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: TextButton(
  //       onPressed: () {
  //         // Xử lý sự kiện khi bấm vào Browse Templates
  //         print("Browse Templates clicked!");
  //       },
  //       style: TextButton.styleFrom(
  //         padding: EdgeInsets.zero,
  //       ),
  //       child: ListTile(
  //         leading: Icon(Icons.palette, color: Colors.black),
  //         title: Text(
  //           "Browse Templates",
  //           style: TextStyle(color: Colors.black),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
