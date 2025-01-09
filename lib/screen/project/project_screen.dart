import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/bloc/task/task_state.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectScreen extends StatefulWidget {
  final String projectId;

  ProjectScreen({required this.projectId});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late TaskBloc _taskBloc;

  @override
  void initState() {
    super.initState();
    _taskBloc = TaskBloc(FirebaseFirestore.instance);
    _taskBloc.add(
        LoadTasks(widget.projectId)); // Gọi sự kiện LoadTasks với projectId
  }

  @override
  void dispose() {
    _taskBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _taskBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Testproject",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
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
        backgroundColor: Colors.white,
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return _buildTaskItem(task);
                },
              );
            } else if (state is TaskError) {
              return Center(child: Text('Error: ${state.error}'));
            } else {
              return Center(child: Text('No tasks available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      elevation: 0,
      child: ExpansionTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              margin
              value: task.completed,
              onChanged: (value) {
                // setState(() {
                //   task.completed = value!;
                // });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  if (task.dueDate.isNotEmpty)
                    Text(
                      task.dueDate,
                      style: TextStyle(color: Colors.purple, fontSize: 14),
                    ),
                ],
              ),
            ),
            if (task.avatar.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(task.avatar),
                radius: 15,
              ),
          ],
        ),
        children: task.subtasks.map<Widget>((subtask) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _buildSubtaskItem(subtask),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubtaskItem(Task subtask) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ExpansionTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: subtask.completed,
              onChanged: (value) {
                // setState(() {
                //   subtask.completed = value!;
                // });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtask.title,
                    style: TextStyle(
                      decoration:
                          subtask.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (subtask.description.isNotEmpty)
                    Text(
                      subtask.description,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  if (subtask.dueDate.isNotEmpty)
                    Text(
                      subtask.dueDate,
                      style: TextStyle(color: Colors.purple, fontSize: 14),
                    ),
                ],
              ),
            ),
            if (subtask.avatar.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(subtask.avatar),
                radius: 15,
              ),
          ],
        ),
        children: subtask.subtasks.map<Widget>((subsubtask) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: ListTile(
              leading: Checkbox(
                value: subsubtask.completed,
                onChanged: (value) {
                  // setState(() {
                  //   subsubtask.completed = value!;
                  // });
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subsubtask.title,
                    style: TextStyle(
                      decoration: subsubtask.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (subsubtask.description.isNotEmpty)
                    Text(
                      subsubtask.description,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  if (subsubtask.dueDate.isNotEmpty)
                    Text(
                      subsubtask.dueDate,
                      style: TextStyle(color: Colors.purple, fontSize: 14),
                    ),
                ],
              ),
              trailing: (subsubtask.avatar.isNotEmpty)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(subsubtask.avatar),
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
