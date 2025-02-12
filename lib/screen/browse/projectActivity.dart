import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bee_task/screen/project/project_screen.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:bee_task/data/repository/UserRepository.dart';

class ProjectActivityScreen extends StatefulWidget {
  const ProjectActivityScreen({super.key});

  @override
  State<ProjectActivityScreen> createState() => _ProjectActivityScreenState();
}

class _ProjectActivityScreenState extends State<ProjectActivityScreen> {
  var projectActivity = TaskData().project_activity;
  var projects = TaskData().projects;
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, List<Map<String, dynamic>>> groupedActivities = {};
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

    Set<String> projectIds =
        projects.map<String>((project) => project['id'].toString()).toSet();

    projectActivity = projectActivity
        .where((activity) => projectIds.contains(activity['projectId']))
        .toList();

    projectActivity.sort((a, b) {
      DateTime timeA =
          DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').parse(a['timestamp']);
      DateTime timeB =
          DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').parse(b['timestamp']);
      return timeB.compareTo(timeA); // Sort descending (newest first)
    });

    for (var activity in projectActivity) {
      String date = DateFormat('MMM dd, yyyy').format(
        DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').parse(activity['timestamp']),
      );
      groupedActivities.putIfAbsent(date, () => []).add(activity);
    }
  }

  void reloadData() {
    setState(() {
      groupedActivities.clear(); // Xóa hết dữ liệu cũ

      Set<String> projectIds =
          projects.map<String>((project) => project['id'].toString()).toSet();

      // Lọc lại activity
      projectActivity = TaskData()
          .project_activity
          .where((activity) => projectIds.contains(activity['projectId']))
          .toList();

      // Sắp xếp lại
      projectActivity.sort((a, b) {
        DateTime timeA =
            DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').parse(a['timestamp']);
        DateTime timeB =
            DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').parse(b['timestamp']);
        return timeB.compareTo(timeA);
      });

      // Nhóm lại theo ngày
      for (var activity in projectActivity) {
        String date = DateFormat('MMM dd, yyyy').format(
          DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').parse(activity['timestamp']),
        );
        groupedActivities.putIfAbsent(date, () => []).add(activity);
      }
    });
  }

  IconData getActionIcon(String action) {
    switch (action) {
      case 'invite':
        return Icons.person_add;
      case 'remove':
        return Icons.person_remove;
      case 'canEdit':
        return Icons.edit;
      case 'canView':
        return Icons.visibility;
      case 'update':
        return Icons.update;
      case 'leave':
        return Icons.exit_to_app;
      default:
        return Icons.info;
    }
  }

  String getActionText(String action) {
    switch (action) {
      case 'invite':
        return 'invited';
      case 'remove':
        return 'removed';
      case 'canEdit':
        return 'granted edit access to';
      case 'canView':
        return 'granted view access to';
      default:
        return 'performed an action on';
    }
  }

  String formatTimestamp(String timestamp) {
    try {
      DateTime dateTime =
          DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').parse(timestamp);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return "Invalid time";
    }
  }

  void showActivityDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Activity Details"),
          content: Text(
            "Project has been deleted",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget buildActivityTile(Map<String, dynamic> activity) {
    String actor = activity['actor'];
    String target = activity['target'];
    if (actor == user?.email) actor = "You";
    if (target == user?.email) target = "you";
    var project = TaskData().projects.firstWhere(
        (project) => project['id'] == activity['projectId'],
        orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
        );
    String projectName = project['name'] ?? "Unknown project";
    String content = "$actor ${getActionText(activity['action'])} $target";
    if (activity['action'] == "update") {
      content =
          "$actor changed the project name from \"$target\" to \"$projectName\"";
    } else if (activity['action'] == "leave") {
      content = "$actor left the project";
    }
    return InkWell(
      onTap: () => {
        if (project.isEmpty)
          {showActivityDetails()}
        else
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectScreen(
                    projectId: project['id'],
                    projectName: project['name'],
                    isShare: true,
                    isEditProject: true,
                    taskRepository: taskRepository,
                    userRepository: userRepository,
                    resetScreen: () {
                      setState(() {
                        reloadData();
                      });
                    }),
              ),
            )
          }
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(getActionIcon(activity['action']), color: Colors.white),
          ),
          title: Text(
            content,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("At ${formatTimestamp(activity['timestamp'])}",
                  style: TextStyle(color: Colors.grey)),
              Text("$projectName", style: TextStyle(color: Colors.grey)),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Activity'),
        elevation: 0,
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      body: projectActivity.isEmpty
          ? Container(
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  "No activities available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: groupedActivities.keys.length,
                itemBuilder: (context, index) {
                  String date = groupedActivities.keys.elementAt(index);
                  List<Map<String, dynamic>> activities =
                      groupedActivities[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          date,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Activities List
                      ...activities
                          .map((activity) => buildActivityTile(activity)),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
