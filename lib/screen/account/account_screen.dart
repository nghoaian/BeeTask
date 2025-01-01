import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isTwoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
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
            TwoFactorSection(isTwoFactorEnabled, (value) {
              setState(() {
                isTwoFactorEnabled = value;
              });
            }),
            SizedBox(height: 20),
            DeleteAccountButton(),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[200], // Nền xám nhạt
      elevation: 0,
      leadingWidth: 120, // Giới hạn chiều rộng của leading
      leading: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.red), // Dấu "<"
            onPressed: () {},
          ),
          SizedBox(width: 0), // Khoảng cách nhỏ giữa nút "<" và chữ "Settings"
          Text(
            'Settings',
            overflow: TextOverflow.ellipsis, // Xử lý tràn text
            style: TextStyle(
              color: Colors.red,
              fontSize: 17, // Chữ "Settings" nhỏ hơn
            ),
          ),
        ],
      ),
      centerTitle: true, // Căn giữa tiêu đề
      title: Text(
        'Account',
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
      ),
    );
  }

  // Avatar section
  Widget AvatarSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 30, // Kích thước nhỏ hơn
          backgroundColor: Colors.teal,
          child: Text(
            'A',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Your avatar photo will be public',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Edit Button
  Widget EditButton() {
    return TextButton(
      onPressed: () {},
      child: Text(
        'Edit',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  // Info Section (Full Name, Email)
  Widget InfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0,
              bottom: 8.0), // Xích qua phải một chút và lên một chút
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
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 20),

        // Email
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0,
              bottom: 8.0), // Xích qua phải một chút và lên một chút
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
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Icon(Icons.arrow_forward_ios),
          ),
        ),
      ],
    );
  }

// Password Section
  Widget PasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0), // Xích qua phải một chút
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
            backgroundColor: Colors.white, // Nền màu trắng
            foregroundColor: Colors.black, // Chữ màu đen
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize:
                Size(double.infinity, 50), // Kích thước lớn bằng thanh box
          ),
        ),
      ],
    );
  }

// Two-Factor Authentication Section
  Widget TwoFactorSection(bool isTwoFactorEnabled, Function(bool) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16), // Xích qua phải một chút
          child: Text(
            'TWO-FACTOR AUTHENTICATION',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Require 2FA', style: TextStyle(color: Colors.black)),
              Switch(
                value: isTwoFactorEnabled,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Delete Account Button
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
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}
