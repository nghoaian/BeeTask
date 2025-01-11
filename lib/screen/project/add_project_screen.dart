import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddProjectScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)
      onProjectAdded; // Callback khi thêm project

  const AddProjectScreen({Key? key, required this.onProjectAdded})
      : super(key: key);

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController projectNameController =
      TextEditingController(); // Controller cho tên project
  String selectedColor = 'Charcoal'; // Màu mặc định
  bool isFavorite = false; // Trạng thái yêu thích mặc định
  late final FirebaseUserRepository userRepository;

  final List<String> colors = ['Charcoal', 'Red', 'Blue', 'Green'];


  // Widget chung để tạo trường nhập văn bản
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // Dropdown chọn màu sắc
  Widget _buildColorDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedColor,
      decoration: InputDecoration(
        labelText: 'Color',
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
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
    );
  }

  // Switch để đánh dấu yêu thích
  Widget _buildFavoriteSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Favorite',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Switch(
          value: isFavorite,
          onChanged: (value) {
            setState(() {
              isFavorite = value;
            });
          },
        ),
      ],
    );
  }

  // Nút hành động
  Widget _buildDialogActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Đóng màn hình
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async{
            if (projectNameController.text.isNotEmpty) {
              String? userEmail = FirebaseAuth.instance.currentUser?.email;
              final project = {
                //'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': projectNameController.text,
                'color': selectedColor,
                'isFavorite': isFavorite,
                'owner': userEmail,
                'members': userEmail,
              };

              print(
                  'Project to be added: $project'); // Debug: In ra thông tin project

              try {
                widget.onProjectAdded(project); // Gửi dữ liệu project
                print(
                    'Project added successfully'); // Debug: Thành công gửi dữ liệu
                Navigator.pop(context); // Đóng màn hình
              } catch (e) {
                print('Error adding project: $e'); // Debug: In lỗi
              }
            } else {
              print('Project name is empty'); // Debug: Tên project trống
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: projectNameController.text.isNotEmpty
                ? Colors.blue
                : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: projectNameController,
              label: 'Project Name',
            ),
            const SizedBox(height: 16),
            _buildColorDropdown(),
            const SizedBox(height: 16),
            _buildFavoriteSwitch(),
            const SizedBox(height: 32),
            Center(child: _buildDialogActions()),
          ],
        ),
      ),
    );
  }
}
