import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchTasksDueToday();
  }

  Future<void> _fetchTasksDueToday() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot projectSnapshot = await FirebaseFirestore.instance.collection('projects').get();

      for (var projectDoc in projectSnapshot.docs) {
        QuerySnapshot taskSnapshot = await projectDoc.reference.collection('tasks')
            .where('dueDate', isGreaterThanOrEqualTo: startOfDay)
            .where('dueDate', isLessThanOrEqualTo: endOfDay)
            .get();

        for (var taskDoc in taskSnapshot.docs) {
          Map<String, dynamic> taskData = taskDoc.data() as Map<String, dynamic>;
          taskData['projectId'] = projectDoc.id;
          taskData['taskId'] = taskDoc.id;
          notifications.add(taskData);
          print('Task Data: $taskData'); // In ra dữ liệu của từng task
        }
      }

      setState(() {});
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

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
              child: Text(notification['title'][0].toUpperCase()),
            ),
            title: Text(notification['title']),
            subtitle: Text(notification['description']),
            trailing: Text(DateFormat('dd/MM/yyyy').format(notification['dueDate'].toDate())),
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}