import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProjectScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  final Function resetScreen;

  const EditProjectScreen(
      {Key? key,
      required this.projectId,
      required this.projectName,
      required this.resetScreen})
      : super(key: key);

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late TextEditingController projectNameController;
  late String selectedColor;
  late bool isFavorite;
  late final FirebaseUserRepository userRepository;

  final List<String> colors = ['Charcoal', 'Red', 'Blue', 'Green'];

  @override
  void initState() {
    super.initState();
    projectNameController = TextEditingController(text: widget.projectName);
    selectedColor = 'Charcoal'; // Màu mặc định
    isFavorite = false; // Trạng thái yêu thích mặc định
  }

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
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (projectNameController.text.trim().isNotEmpty) {
                    context.read<ProjectBloc>().add(UpdateProject(
                        widget.projectId,
                        projectNameController.text,
                        widget.projectName));
                    widget.resetScreen();
                    Navigator.pop(context);
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
          borderSide: BorderSide(
            color: Colors.grey, // Đặt màu viền mặc định
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey, // Đặt màu viền khi không được chọn
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey, // Đặt màu viền khi được chọn
          ),
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
