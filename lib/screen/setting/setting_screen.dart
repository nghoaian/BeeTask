import 'package:bee_task/screen/account/account_screen.dart';
import 'package:bee_task/screen/auth/welcome_screen.dart';
import 'package:bee_task/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bee_task/screen/TaskData.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          children: [
            // First section
            _buildSection(
              children: [
                _buildListTile(
                  icon: Icons.person,
                  title: 'Account',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccountScreen()),
                    );
                  },
                ),
                // buildDividerWithPadding(),
                _buildListTile(
                  icon: Icons.settings,
                  title: 'General',
                ),
                // buildDividerWithPadding(),
                _buildListTile(
                  icon: Icons.calendar_today,
                  title: 'Calendar',
                ),
              ],
            ),
            // Second section
            _buildSectionTitle('PERSONALIZATION'),
            _buildSection(
              children: [
                _buildListTile(
                  icon: Icons.palette,
                  title: 'Theme',
                  trailingText: 'Todoist',
                ),
                _buildListTile(
                  icon: Icons.apps,
                  title: 'App Icon',
                  trailingText: 'Todoist',
                ),
                _buildListTile(
                  icon: Icons.menu,
                  title: 'Navigation',
                ),
                _buildListTile(
                  icon: Icons.add_circle_outline,
                  title: 'Quick Add',
                ),
              ],
            ),
            // Third section
            _buildSectionTitle('PRODUCTIVITY'),
            _buildSection(
              children: [
                _buildListTile(
                  icon: Icons.show_chart,
                  title: 'Productivity',
                ),
                _buildListTile(
                  icon: Icons.alarm,
                  title: 'Reminders',
                ),
                _buildListTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                ),
              ],
            ),
            // Fourth section
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
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

  // Widget buildDividerWithPadding() {
  //   return Row(
  //     children: [
  //       SizedBox(width: 55), // adjust the width as needed
  //       Expanded(child: Divider()),
  //     ],
  //   );
  // }

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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
      (route) => false,
    );
  }
}
