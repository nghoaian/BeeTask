import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/bloc/project/project_state.dart';
import 'package:bee_task/screen/project/invite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShareScreen extends StatefulWidget {
  final String projectId;

  ShareScreen({required this.projectId});

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(LoadProjectMembers(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          "Share",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(8), // Thêm margin 8 cho Text
              child: const Text(
                "Testproject",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InvitePeopleScreen(projectId: widget.projectId),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 8), // Thêm margin horizontal 16
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      "Invite via email",
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
              child: const Text(
                "IN THIS PROJECT",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ProjectMemberLoaded) {
                    return ListView.builder(
                      itemCount: state.members.length,
                      itemBuilder: (context, index) {
                        final member = state.members[index];
                        return ProjectMembersCard(
                          userName: member['userName'],
                          userEmail: member['userEmail'],
                          projectId: widget.projectId,
                        );
                      },
                    );
                  } else if (state is ProjectError) {
                    return Center(child: Text(state.message));
                  } else {
                    return Center(child: Text('No members found'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectMembersCard extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String projectId;

  ProjectMembersCard(
      {required this.userName,
      required this.userEmail,
      required this.projectId});

  @override
  _ProjectMembersCardState createState() => _ProjectMembersCardState();
}

class _ProjectMembersCardState extends State<ProjectMembersCard> {
  String _status = 'Can Edit';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue,
            child: Text(
              widget.userName[0].toUpperCase(),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            widget.userName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(widget.userEmail),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_status, style: TextStyle(color: Colors.grey, fontSize: 14)),
              PopupMenuButton<String>(
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 16),
                onSelected: (String value) {
                  setState(() {
                    _status = value;
                  });
                  if (value == 'Remove') {
                    context.read<ProjectBloc>().add(RemoveProjectMember(
                        widget.projectId, widget.userEmail));
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Can View',
                    child: Text('Can View'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Can Edit',
                    child: Text('Can Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Remove',
                    child: Text('Remove'),
                  ),
                ],
                color: Colors.grey[50], // Đặt màu nền trắng
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bo góc 16px
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
