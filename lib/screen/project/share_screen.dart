import 'package:bee_task/bloc/invite/invite_bloc.dart';
import 'package:bee_task/bloc/invite/invite_event.dart';
import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/bloc/project/project_state.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/screen/project/invite_screen.dart';
import 'package:bee_task/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShareScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  final Function resetScreen;

  ShareScreen(
      {required this.projectId,
      required this.projectName,
      required this.resetScreen});

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  late FirebaseUserRepository userRepository;
  late String currentUserPermission = 'Can View';
  @override
  void initState() {
    super.initState();
    userRepository = FirebaseUserRepository(
      firestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    );
    _fetchCurrentUserPermission();
    context.read<ProjectBloc>().add(LoadProjectMembers(widget.projectId));
  }

  Future<void> _fetchCurrentUserPermission() async {
    currentUserPermission =
        await userRepository.getCurrentUserPermission(widget.projectId);
    if (mounted) {
      setState(() {});
    }
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
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () => {
                  widget.resetScreen(),
                  Navigator.pop(context),
                }),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(8), // Thêm margin 8 cho Text
              child: Text(
                widget.projectName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: currentUserPermission == 'Can View'
                  ? null
                  : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InvitePeopleScreen(projectId: widget.projectId),
                        ),
                      );

                      if (result == true) {
                        context
                            .read<ProjectBloc>()
                            .add(LoadProjectMembers(widget.projectId));
                      }
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
                    Icon(Icons.add,
                        color: currentUserPermission == 'Can View'
                            ? Colors.grey
                            : AppColors.primary),
                    SizedBox(width: 10),
                    Text(
                      "Invite via email",
                      style: TextStyle(
                          color: currentUserPermission == 'Can View'
                              ? Colors.grey
                              : AppColors.primary,
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
                          userColor: member['userColor'],
                          projectId: widget.projectId,
                          userRepository: userRepository,
                          currentUserPermission: currentUserPermission,
                          resetScreen: widget.resetScreen,
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
  final String? userColor;
  final String projectId;
  final FirebaseUserRepository userRepository;
  final String currentUserPermission;
  final Function resetScreen;

  ProjectMembersCard(
      {required this.userName,
      required this.userEmail,
      required this.userColor,
      required this.projectId,
      required this.userRepository,
      required this.currentUserPermission,
      required this.resetScreen});

  @override
  _ProjectMembersCardState createState() => _ProjectMembersCardState();
}

class _ProjectMembersCardState extends State<ProjectMembersCard> {
  String _status = 'Can Edit';
  String _ownerEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchPermission();
    _fetchOwner();
  }

  Future<void> _fetchPermission() async {
    final inviteBloc = context.read<InviteBloc>();
    final permission =
        await inviteBloc.getPermission(widget.projectId, widget.userEmail);
    if (mounted) {
      setState(() {
        _status = permission;
      });
    }
  }

  Future<void> _fetchOwner() async {
    final inviteBloc = context.read<InviteBloc>();
    final ownerEmail = await inviteBloc.getOwner(widget.projectId);
    if (mounted) {
      setState(() {
        _ownerEmail = ownerEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: widget.userRepository.getUserEmail(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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
                  backgroundColor: _getColorFromString(widget.userColor),
                  child: Text(
                    widget.userName[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  widget.userName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(widget.userEmail),
              ),
            ),
          );
        } else {
          final currentUserEmail = snapshot.data!;
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
                  backgroundColor: _getColorFromString(widget.userColor),
                  child: Text(
                    widget.userName[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
                    Text(_status,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    if (widget.currentUserPermission != 'Can View' &&
                        currentUserEmail != widget.userEmail && _ownerEmail != widget.userEmail)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.grey, size: 16),
                        onSelected: (String value) {
                          setState(() {
                            _status = value;
                          });

                          if (value == 'Remove') {
                            context.read<ProjectBloc>().add(RemoveProjectMember(
                                widget.projectId, widget.userEmail));
                          }
                          if (value == 'Can View' || value == 'Can Edit') {
                            context.read<InviteBloc>().add(
                                  EditPermission(
                                    projectId: widget.projectId,
                                    userEmail: widget.userEmail,
                                    canEdit: value == 'Can Edit',
                                  ),
                                );
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
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
                        color: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Color _getColorFromString(String? colorString) {
    final color = colorString?.toLowerCase() ?? 'default';
    switch (color) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return const Color.fromARGB(255, 0, 140, 255);
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return const Color.fromARGB(255, 238, 211, 0);
      case 'purple':
        return Colors.deepPurpleAccent;
      case 'pink':
        return const Color.fromARGB(255, 248, 43, 211);
      default:
        return AppColors.primary; // Default color if the string is unknown
    }
  }
}
