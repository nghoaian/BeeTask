import 'package:flutter/material.dart';

class InvitePeopleScreen extends StatefulWidget {
  @override
  _InvitePeopleScreenState createState() => _InvitePeopleScreenState();
}

class _InvitePeopleScreenState extends State<InvitePeopleScreen> {
  String inputText = ""; // Dùng để lưu giá trị nhập vào.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
        title: Text(
          "Invite People",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (inputText.isNotEmpty) {
                print("Invite: $inputText");
              }
            },
            child: Text(
              "Invite",
              style: TextStyle(
                color: inputText.isNotEmpty ? Colors.red : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    },
                    decoration: InputDecoration(
                      labelText: "To:",
                      labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                      border: InputBorder.none,
                      hintText: "Enter name or email",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.red),
                  onPressed: () {
                    print("Add user: $inputText");
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Section label
            Text(
              "SELECT A PERSON",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 10),
            // List item
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  "T",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                "dangminhthongbt2003",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("dangminhthongbt2003@gmail.com"),
              onTap: () {
                print("Selected: dangminhthongbt2003");
              },
            ),
          ],
        ),
      ),
    );
  }
}