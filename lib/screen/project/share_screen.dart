import 'package:flutter/material.dart';

class ShareScreen extends StatefulWidget {
  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: Text(
          "Share",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {},
        //     child: Text(
        //       "Done",
        //       style: TextStyle(color: Ap, fontSize: 16),
        //     ),
        //   )
        // ],
      ),
      backgroundColor:
          Colors.grey[200], // Đặt màu nền của toàn màn hình là màu grey 200
      body: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 8), // Thay đổi từ padding sang margin
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(8), // Thêm margin 8 cho Text
              child: Text(
                "Testproject",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                print("Invite via name or email tapped");
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 8), // Thêm margin horizontal 16
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      "Invite via name or email",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: 8), // Thêm margin horizontal 16
              child: Text(
                "IN THIS PROJECT",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            ProjectMembersCard(), // Sử dụng widget ProjectMembersCard
          ],
        ),
      ),
    );
  }
}

class ProjectMembersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 0), // Thêm margin horizontal 16
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: const [
            ListTile(
              // contentPadding: EdgeInsets.symmetric(horizontal: 8),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue,
                child: Text(
                  "A",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                "Me (An N.)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("an66528@gmail.com"),
              trailing:
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ),
            ListTile(
              // contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.orange,
                child: Text(
                  "T",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                "dangminhthongbt2003",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("dangminhthongbt2003@gmail.com"),
              trailing: Icon(Icons.person, color: Colors.orange, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ShareScreen(),
  ));
}
