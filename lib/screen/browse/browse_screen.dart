import 'package:flutter/material.dart';

class BrowseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
      backgroundColor: Colors.grey[200], // Light grey background
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
                  buildSection("Inbox", Icons.inbox, count: 4),
                  buildDividerWithPadding(),
                  buildSection("Filters & Labels", Icons.grid_view),
                  buildDividerWithPadding(),
                  buildSection("Completed", Icons.check_circle),
                ],
              ),

              // Dòng "My Projects" nằm giữa các khối
              buildMyProjectsSection(),

              // Khối 2: Home, Project Tracker, Testproject
              buildSectionGroup(
                [
                  buildProjectItem("Home🏡", 5),
                  buildDividerWithPadding(),
                  buildProjectItem("Project Tracker", 35),
                  buildDividerWithPadding(),
                  buildProjectItem("Testproject 👥", 2),
                  buildDividerWithPadding(),
                  buildListTile(Icons.edit, "Manage Projects"),
                ],
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
      onPressed: () {},
      backgroundColor: Colors.red, // Màu nền của nút
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 40, // Kích thước biểu tượng
      ),
      shape: CircleBorder(), // Đảm bảo rằng nó có hình dạng tròn
      elevation: 6, // Độ bóng
      mini: false,
    );
  }

  Widget buildSection(String title, IconData icon, {int? count}) {
    return ListTile(
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
    );
  }

  Widget buildProjectItem(String title, int count) {
    return ListTile(
      leading: Icon(Icons.tag, color: Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      trailing: Text(
        count.toString(),
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget buildMyProjectsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () {},
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
      child: ListTile(
        leading: Icon(Icons.palette, color: Colors.black),
        title: Text(
          "Browse Templates",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
