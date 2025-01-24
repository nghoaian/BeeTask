import 'dart:io';

import 'package:bee_task/bloc/account/account_bloc.dart';
import 'package:bee_task/bloc/account/account_event.dart';
import 'package:bee_task/bloc/account/account_state.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/screen/account/update_email.dart';
import 'package:bee_task/screen/auth/change_password.dart';
import 'package:bee_task/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late TextEditingController _nameController;
  String _avatarPath = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    final accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(FetchUserNameRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Future<void> _showEditOptions() async {
  //   final ImagePicker _picker = ImagePicker();
  //   final pickedFile = await showModalBottomSheet<XFile?>(
  //     context: context,
  //     builder: (context) {
  //       return Container(
  //         height: 200,
  //         child: Column(
  //           children: [
  //             ListTile(
  //               leading: Icon(Icons.camera),
  //               title: Text('Take Photo'),
  //               onTap: () async {
  //                 Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
  //               },
  //             ),
  //             ListTile(
  //               leading: Icon(Icons.photo),
  //               title: Text('Choose from Photos'),
  //               onTap: () async {
  //                 Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
  //               },
  //             ),
  //             ListTile(
  //               leading: Icon(Icons.delete),
  //               title: Text('Remove Current Photo'),
  //               onTap: () {
  //                 setState(() {
  //                   _avatarPath = ''; // Xóa ảnh
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );

  //   if (pickedFile != null) {
  //     setState(() {
  //       _avatarPath = pickedFile.path; // Cập nhật đường dẫn avatar
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountLoaded) {
              _nameController.text = state.userName;
              return Column(
                children: [
                  AvatarSection(
                      userName: state.userName,
                      userEmail: state.userEmail,
                      userColor: state.userColor),
                  const SizedBox(height: 0),
                  EditButton(),
                  const SizedBox(height: 0),
                  InfoSection(state.userName, state.userEmail),
                  const SizedBox(height: 20),
                  PasswordSection(),
                  const SizedBox(height: 20),
                  DeleteAccountButton(),
                ],
              );
            } else if (state is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(
                  child: Text('Error loading account information'));
            }
          },
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[200],
      elevation: 0,
      leadingWidth: 120,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          child: const Row(
            children: [
              Icon(Icons.arrow_back_ios, color: AppColors.primary),
              Text(
                'Settings',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'Account',
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget AvatarSection(
      {required String userName,
      required String userEmail,
      required String? userColor}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: _getColorFromString(userColor),
          backgroundImage:
              _avatarPath.isNotEmpty ? FileImage(File(_avatarPath)) : null,
          child: Text(
            _avatarPath.isEmpty ? userName[0].toUpperCase() : '',
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          userEmail,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget EditButton() {
    return TextButton(
      onPressed: () {}, //_showEditOptions,
      child: const Text('Edit', style: TextStyle(color: Colors.red)),
    );
  }

  Widget InfoSection(String userName, String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text('FULL NAME', style: TextStyle(color: Colors.grey[600])),
        ),
        TextFormField(
          controller: _nameController,
          onFieldSubmitted: (newName) {
            BlocProvider.of<AccountBloc>(context)
                .add(UpdateUserNameRequested(username: newName));
          },
          decoration: InputDecoration(
            hintText: 'Enter your name',
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget PasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text('PASSWORD', style: TextStyle(color: Colors.grey[600])),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen()),
            );
          },
          child: Text('Change Password'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget DeleteAccountButton() {
    return ElevatedButton(
      onPressed: () {},
      child: Text('Delete Account', style: TextStyle(color: Colors.red)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: Size(double.infinity, 50),
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
