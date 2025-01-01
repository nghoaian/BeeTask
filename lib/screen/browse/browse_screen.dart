import 'package:flutter/material.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        backgroundColor: Color(0xFF4254FE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: const Text('Browse Screen'),
                    subtitle: const Text('This is Browse Screen'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}