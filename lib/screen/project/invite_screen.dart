import 'package:bee_task/bloc/invite/invite_bloc.dart';
import 'package:bee_task/bloc/invite/invite_event.dart';
import 'package:bee_task/bloc/invite/invite_state.dart';
import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvitePeopleScreen extends StatefulWidget {
  final String projectId;

  InvitePeopleScreen({required this.projectId});

  @override
  _InvitePeopleScreenState createState() => _InvitePeopleScreenState();
}

class _InvitePeopleScreenState extends State<InvitePeopleScreen> {
  String inputText = "";
  String? selectedEmail;

  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Invite People",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<InviteBloc, InviteState>(
            builder: (context, state) {
              return TextButton(
                onPressed: selectedEmail != null
                    ? () async {
                        context
                            .read<InviteBloc>()
                            .add(InviteUser(widget.projectId));
                        await Future.delayed(Duration(milliseconds: 300));
                        Navigator.pop(context, true);
                      }
                    : null,
                child: Text(
                  "Invite",
                  style: TextStyle(
                    color:
                        selectedEmail != null ? AppColors.primary : Colors.grey,
                    fontSize: 18,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          inputText = value;
                        });
                        if (isValidEmail(value)) {
                          context
                              .read<InviteBloc>()
                              .add(EmailInputChanged(value));
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "To:",
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 16),
                        border: InputBorder.none,
                        hintText: "Enter email",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // BlocBuilder để hiển thị kết quả
              BlocBuilder<InviteBloc, InviteState>(
                builder: (context, state) {
                  if (state is InviteLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is InviteUserFound) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SELECT A PERSON",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _getColorFromString(state.color),
                            child: Text(
                              state.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            state.name,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(state.email),
                          onTap: () {
                            setState(() {
                              selectedEmail = state.email;
                            });
                            context
                                .read<InviteBloc>()
                                .add(UserSelected(state.email));
                            print("Selected: ${state.email}");
                          },
                        ),
                      ],
                    );
                  } else if (state is InviteUserNotFound) {
                    return Center(
                      child: Text(
                        "No user found",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
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
