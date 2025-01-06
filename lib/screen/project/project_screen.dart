import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProjectScreen(),
    );
  }
}

class ProjectScreen extends StatefulWidget {
  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final List<Map<String, dynamic>> tasks = [
    {
      "title": "Do homework",
      "description": "Complete math and science homework",
      "dueDate": "Jan 3",
      "avatar": "https://via.placeholder.com/40",
      "completed": false,
      "subtasks": [
        {
          "title": "Math exercises",
          "description": "Solve algebra problems",
          "dueDate": "Today",
          "avatar": "https://via.placeholder.com/40",
          "completed": false,
          "subtasks": [
            {"title": "Equations", "description": "", "dueDate": "Today", "avatar": "", "completed": false},
            {"title": "Graph plotting", "description": "", "dueDate": "", "avatar": "", "completed": false},
          ],
        },
        {
          "title": "Science project",
          "description": "Prepare presentation",
          "dueDate": "Tomorrow",
          "avatar": "https://via.placeholder.com/40",
          "completed": false,
          "subtasks": [],
        },
      ],
    },
    {
      "title": "Workout",
      "description": "Let's workout",
      "dueDate": "Thursday",
      "avatar": "https://via.placeholder.com/40",
      "completed": false,
      "subtasks": [
        {
          "title": "Morning run",
          "description": "Run for 30 minutes",
          "dueDate": "Today",
          "avatar": "https://via.placeholder.com/40",
          "completed": false,
          "subtasks": [
            {"title": "Stretching", "description": "", "dueDate": "", "avatar": "", "completed": false},
            {"title": "Run 5km", "description": "", "dueDate": "", "avatar": "", "completed": false},
          ],
        },
      ],
    },
  ];

  void toggleCompletion(Map<String, dynamic> task) {
    setState(() {
      task["completed"] = !task["completed"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Testproject",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.group, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskItem(task);
        },
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ExpansionTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task["completed"],
              onChanged: (value) => toggleCompletion(task),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task["title"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration:
                          task["completed"] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task["description"] != null && task["description"].isNotEmpty)
                    Text(
                      task["description"],
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  if (task["dueDate"] != null && task["dueDate"].isNotEmpty)
                    Text(
                      task["dueDate"],
                      style: TextStyle(color: Colors.purple, fontSize: 14),
                    ),
                ],
              ),
            ),
            if (task["avatar"] != null && task["avatar"].isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(task["avatar"]),
                radius: 15,
              ),
          ],
        ),
        children: task["subtasks"].map<Widget>((subtask) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _buildSubtaskItem(subtask),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubtaskItem(Map<String, dynamic> subtask) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ExpansionTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: subtask["completed"],
              onChanged: (value) => toggleCompletion(subtask),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtask["title"],
                    style: TextStyle(
                      decoration:
                          subtask["completed"] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (subtask["description"] != null && subtask["description"].isNotEmpty)
                    Text(
                      subtask["description"],
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  if (subtask["dueDate"] != null && subtask["dueDate"].isNotEmpty)
                    Text(
                      subtask["dueDate"],
                      style: TextStyle(color: Colors.purple, fontSize: 14),
                    ),
                ],
              ),
            ),
            if (subtask["avatar"] != null && subtask["avatar"].isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(subtask["avatar"]),
                radius: 15,
              ),
          ],
        ),
        children: subtask["subtasks"].map<Widget>((subsubtask) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: ListTile(
              leading: Checkbox(
                value: subsubtask["completed"],
                onChanged: (value) {
                  setState(() {
                    subsubtask["completed"] = value!;
                  });
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subsubtask["title"],
                    style: TextStyle(
                      decoration: subsubtask["completed"]
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (subsubtask["description"] != null &&
                      subsubtask["description"].isNotEmpty)
                    Text(
                      subsubtask["description"],
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  if (subsubtask["dueDate"] != null && subsubtask["dueDate"].isNotEmpty)
                    Text(
                      subsubtask["dueDate"],
                      style: TextStyle(color: Colors.purple, fontSize: 14),
                    ),
                ],
              ),
              trailing: (subsubtask["avatar"] != null &&
                      subsubtask["avatar"].isNotEmpty)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(subsubtask["avatar"]),
                      radius: 15,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}