import 'package:bee_task/bloc/account/account_bloc.dart';
import 'package:bee_task/bloc/account/account_event.dart';
import 'package:bee_task/bloc/account/account_state.dart';
import 'package:bee_task/screen/account/update_email.dart';
import 'package:bee_task/screen/auth/change_password.dart';
import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    // Lấy thông tin khi khởi tạo
    final accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(FetchUserNameRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
                  AvatarSection(userName: state.userName),
                  SizedBox(height: 0),
                  EditButton(),
                  SizedBox(height: 0),
                  InfoSection(state.userName, state.userEmail),
                  SizedBox(height: 20),
                  PasswordSection(),
                  SizedBox(height: 20),
                  DeleteAccountButton(),
                ],
              );
            } else if (state is AccountLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Center(child: Text('Error loading account information'));
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

  Widget AvatarSection({required String userName}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : '',
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your avatar photo will be public',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget EditButton() {
    return TextButton(
      onPressed: () {},
      child: Text(
        'Edit',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget InfoSection(String userName, String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'NAME',
            style: TextStyle(color: Colors.grey[600]),
          ),
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'EMAIL',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UpdateEmailScreen()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userEmail ?? 'Email not found',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.black),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget PasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'PASSWORD',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        SizedBox(height: 10),
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
      child: Text(
        'Delete Account',
        style: TextStyle(color: Colors.red),
      ),
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
}
