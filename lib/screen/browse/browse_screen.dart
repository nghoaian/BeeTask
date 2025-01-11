import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/bloc/project/project_state.dart';
import 'package:bee_task/screen/project/project_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowseScreen extends StatefulWidget {
  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectBloc()..add(LoadProjectsEvent()),
      child: Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
        floatingActionButton: buildFloatingActionButton(),
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
          icon: Icon(Icons.notifications, color: Colors.red),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.settings, color: Colors.red),
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
                  buildButton("Inbox", Icons.inbox, count: 4),
                  buildDividerWithPadding(),
                  buildButton("Filters & Labels", Icons.grid_view),
                  buildDividerWithPadding(),
                  buildButton("Completed", Icons.check_circle),
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
              buildBrowseTemplates(),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton buildFloatingActionButton() {
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

  Widget buildButton(String title, IconData icon,
      {int? count, String? projectId}) {
    return TextButton(
      onPressed: () {
        // Điều hướng đến ProjectScreen với projectId
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ProjectScreen(projectId: projectId!),
        //   ),
        // );
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
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
            icon: Text(
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
              onPressed: () {},
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
        borderRadius: BorderRadius.circular(10),
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

  // Phần "Browse Templates" với nền trắng và bo tròn
  Widget buildBrowseTemplates() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          // Xử lý sự kiện khi bấm vào Browse Templates
          print("Browse Templates clicked!");
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: ListTile(
          leading: Icon(Icons.palette, color: Colors.black),
          title: Text(
            "Browse Templates",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
