import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/util/colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            controller: projectNameController,
            label: 'Project Name',
          ),
          const SizedBox(height: 16),
          _buildFavoriteSwitch(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng màn hình
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(color: AppColors.primary),),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (projectNameController.text.trim().isNotEmpty) {
                    String? userEmail = FirebaseAuth.instance.currentUser?.email;
                    final project = {
                      'name': projectNameController.text,
                      'isFavorite': isFavorite,
                      'owner': userEmail,
                      'members': [userEmail],
                      'permissions': [userEmail],
                    };

                    try {
                      widget.onProjectAdded(project); // Gửi dữ liệu project
                      print('Project added successfully'); // Debug: Thành công gửi dữ liệu
                      Navigator.pop(context); // Đóng màn hình
                    } catch (e) {
                      print('Error adding project: $e'); // Debug: In lỗi
                    }
                  } else {
                    print('Project name is empty'); // Debug: Tên project trống
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[400],
        ),
      ],
    );
  }
}
