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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Invite People",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<InviteBloc, InviteState>(
            builder: (context, state) {
              return TextButton(
                onPressed: selectedEmail != null
                    ? () {
                        context
                            .read<InviteBloc>()
                            .add(InviteUser(widget.projectId));
                            Navigator.pop(context);
                      }
                    : null,
                child: Text(
                  "Invite",
                  style: TextStyle(
                    color: selectedEmail != null ? Colors.red : Colors.grey,
                    fontSize: 16,
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
                          inputText = value; // Cập nhật giá trị nhập.
                        });
                        context.read<InviteBloc>().add(EmailInputChanged(value));
                      },
                      decoration: InputDecoration(
                        labelText: "To:",
                        labelStyle: TextStyle(color: Colors.black, fontSize: 16),
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
                            backgroundColor: AppColors.primary,
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
}
