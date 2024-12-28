import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bee_task/screen/auth/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<HomeScreen> {
  late User? user;
  late String userEmail = 'No Email';
  String userName = 'No Username';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
        backgroundColor: Color(0xFF4254FE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Color(0xFF4254FE),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFF4254FE),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.lock, color: Color(0xFF4254FE)),
                      title: const Text('Change Password'),
                      // onTap: () {
                      //   changePassword();
                      // },
                    ),
                    buildDividerWithPadding(),
                    ListTile(
                      leading: Icon(Icons.download_rounded,
                          color: Color(0xFF4254FE)),
                      title: const Text('Download Courses for Offline'),
                      subtitle: const Text(
                        'Your 8 most recently accessed courses will be automatically downloaded',
                      ),
                      onTap: () {
                        // Navigate to offline learning screen
                      },
                    ),
                    buildDividerWithPadding(),
                    ListTile(
                      leading: Icon(Icons.storage, color: Color(0xFF4254FE)),
                      title: const Text('Manage Storage'),
                      onTap: () {
                        // Navigate to storage management screen
                      },
                    ),
                    buildDividerWithPadding(),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text('Logout'),
                      onTap: () {
                        signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDividerWithPadding() {
    return Row(
      children: [
        SizedBox(width: 55), // adjust the width as needed
        Expanded(child: Divider()),
      ],
    );
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
      (route) => false,
    );
  }
}
