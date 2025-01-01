import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
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
                    title: const Text('Search Screen'),
                    subtitle: const Text('This is Search Screen'),
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