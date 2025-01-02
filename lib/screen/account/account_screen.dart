import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isTwoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AvatarSection(),
            SizedBox(height: 0),
            EditButton(),
            SizedBox(height: 0),
            InfoSection(),
            SizedBox(height: 20),
            PasswordSection(),
            SizedBox(height: 20),
            DeleteAccountButton(),
          ],
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

  Widget AvatarSection() {
    String userName = 'An Nguyen';

    return Column(
      children: [
        CircleAvatar(
          radius: 50, 
          backgroundColor: AppColors.primary,
          child: Text(
            userName.isNotEmpty
                ? userName[0].toUpperCase()
                : '',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 30), // Màu chữ trắng và kích thước chữ
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

  Widget InfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'FULL NAME',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        TextFormField(
          initialValue: 'an66528',
          decoration: InputDecoration(
            hintText: 'Enter your full name',
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
        TextFormField(
          initialValue: 'an66528@gmail.com',
          decoration: InputDecoration(
            hintText: 'Enter your email',
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
            suffixIcon: Icon(Icons.arrow_forward_ios),
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
          child: Text(
            'PASSWORD',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {},
          child: Text('Add Password'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
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
