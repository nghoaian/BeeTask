import 'dart:io';

import 'package:bee_task/bloc/account/account_bloc.dart';
import 'package:bee_task/bloc/account/account_event.dart';
import 'package:bee_task/bloc/account/account_state.dart';
import 'package:bee_task/screen/account/account_screen.dart';
import 'package:bee_task/screen/auth/change_password.dart';
import 'package:bee_task/screen/auth/welcome_screen.dart';
import 'package:bee_task/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/screen/setting/statisticsScreen.dart';
import 'package:bee_task/screen/browse/activityLogScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/screen/browse/projectActivity.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late TextEditingController _nameController;
  String _avatarPath = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    // final accountBloc = BlocProvider.of<AccountBloc>(context);
    // accountBloc.add(FetchUserNameRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            // --- Hiển thị thông tin tài khoản trên cùng ---
            BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                if (state is AccountLoaded) {
                  _nameController.text = state.userName;
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AvatarSection(
                            userName: state.userName,
                            userEmail: state.userEmail,
                            userColor: state.userColor),
                        const SizedBox(height: 20),
                        InfoSection(state.userName, state.userEmail),
                      ],
                    ),
                  );
                } else if (state is AccountLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(
                      child: Text('Error loading account information'));
                }
              },
            ),

            // --- Danh sách tùy chọn ---
            Expanded(
              child: ListView(
                children: [
                  _buildSection(
                    children: [
                      _buildSectionTitle('PERSONALIZATION'),
                      // _buildListTile(
                      //   icon: Icons.person,
                      //   title: 'Account',
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => AccountScreen()),
                      //     );
                      //   },
                      // ),
                      _buildListTile(
                        icon: Icons.show_chart,
                        title: 'Statistics',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StatisScreen()),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.history,
                        title: 'Task Activity log',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ActivityLogScreen()),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.list_alt,
                        title: 'Project Activity log',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProjectActivityScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: PasswordSection(),
                  ),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ],
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

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
        trailing: trailingText != null
            ? Text(
                trailingText,
                style: TextStyle(color: Colors.grey),
              )
            : null,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          signOut();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Log Out",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void signOut() {
    TaskData().resetData();
    FirebaseAuth.instance.signOut();

    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false,
      );
    });
  }

  Widget buildDividerWithPadding() {
    return Row(
      children: [
        SizedBox(width: 55), // Điều chỉnh độ thụt lề
        Expanded(child: Divider()),
      ],
    );
  }
}
