import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bee_task/screen/project/project_screen.dart';

class StatisScreen extends StatefulWidget {
  @override
  _StatisScreenState createState() => _StatisScreenState();
}

class _StatisScreenState extends State<StatisScreen> {
  var projects = TaskData().projects;
  var tasks = TaskData().tasks;
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Task Completion Statistics",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.grey[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(height: 20),
                Column(
                  children: projects.map((project) {
                    return _buildProjectChart(project);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectChart(Map<String, dynamic> project) {
    String projectId = project['id'];
    String projectName = project['name'];
    String projectOwner = project['owner'];

    int completedTasks = tasks
        .where((task) =>
            task['projectId'] == projectId && task['completed'] == true)
        .length;
    int totalTasks =
        tasks.where((task) => task['projectId'] == projectId).length;

    double completedPercentage =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: completedTasks.toDouble(),
        title: "${completedPercentage.toStringAsFixed(1)}%",
        color: AppColors.primary,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white, // Đặt màu chữ thành màu trắng
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: (totalTasks - completedTasks).toDouble(),
        title: '',
        color: Colors.grey[300]!,
        radius: 50,
      ),
    ];

    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectScreen(
                  projectId: project['id'],
                  projectName: project['name'],
                  isShare: project['name'] == 'Inbox' ? false : true,
                  isEditProject: project['name'] == 'Inbox' ? false : true,
                  taskRepository: taskRepository,
                  userRepository: userRepository),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 1,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  projectName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Owner: $projectOwner",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$completedTasks",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "/ $totalTasks",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
