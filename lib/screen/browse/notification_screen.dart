import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      "avatar": "T",
      "username": "dangminhthongbt2003",
      "action": "added a comment to",
      "task": "Do homework",
      "content": "\"Test\"",
      "time": "16 days ago",
      "status": "comment"
    },
    {
      "avatar": "T",
      "username": "dangminhthongbt2003",
      "action": "completed a task in",
      "task": "Testproject",
      "content": "Workout",
      "time": "28 days ago",
      "status": "completed"
    },
    {
      "avatar": "T",
      "username": "dangminhthongbt2003",
      "action": "uncompleted a task in",
      "task": "Testproject",
      "content": "Do homework",
      "time": "31 days ago",
      "status": "uncompleted"
    },
    {
      "avatar": "T",
      "username": "dangminhthongbt2003",
      "action": "completed a task in",
      "task": "Testproject",
      "content": "Do homework",
      "time": "31 days ago",
      "status": "completed"
    },
    {
      "avatar": "T",
      "username": "dangminhthongbt2003",
      "action": "joined",
      "task": "Testproject",
      "content": "",
      "time": "34 days ago",
      "status": "joined"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var notification = notifications[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(
                notification["avatar"],
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: "${notification["username"]} ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: "${notification["action"]} "),
                  TextSpan(
                    text: notification["task"],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification["content"].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(notification["content"],
                        style: TextStyle(fontSize: 12)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(notification["time"],
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(left: 70),
          child: Divider(),
        ),
      ),
    );
  }
}
