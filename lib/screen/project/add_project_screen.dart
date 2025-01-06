import 'package:flutter/material.dart';

class NewProjectPage extends StatefulWidget {
  @override
  _NewProjectPageState createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  String projectName = '';
  String selectedColor = 'Charcoal';
  bool isFavorite = false;

  final List<String> colors = ['Charcoal', 'Red', 'Blue', 'Green'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Project'),
        actions: [
          TextButton(
            onPressed: projectName.isNotEmpty ? () {} : null,
            child: Text(
              'Done',
              style: TextStyle(color: projectName.isNotEmpty ? Colors.blue : Colors.grey),
            ),
          ),
        ],
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Input
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  projectName = value;
                });
              },
            ),
            SizedBox(height: 16),
            // Color Picker
            ListTile(
              leading: Icon(Icons.palette),
              title: Text('Color'),
              trailing: DropdownButton<String>(
                value: selectedColor,
                items: colors.map((color) {
                  return DropdownMenuItem<String>(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedColor = value!;
                  });
                },
              ),
            ),
            Divider(),
            // Parent Project Selector
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Parent project'),
              trailing: TextButton(
                onPressed: () {
                  // Handle Parent Project Selection
                },
                child: Text('No Parent'),
              ),
            ),
            Divider(),
            // Favorite Toggle
            ListTile(
              leading: Icon(Icons.favorite_border),
              title: Text('Favorite'),
              trailing: Switch(
                value: isFavorite,
                onChanged: (value) {
                  setState(() {
                    isFavorite = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NewProjectPage(),
  ));
}
