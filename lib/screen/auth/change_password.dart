import 'package:bee_task/bloc/auth/auth_bloc.dart';
import 'package:bee_task/bloc/auth/auth_event.dart';
import 'package:bee_task/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: Color(0xFF4254FE),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is ChangePasswordSuccess ||
              state is ChangePasswordFailure) {
            if (Navigator.of(context).canPop())
              Navigator.of(context).pop(); // Đóng loading dialog nếu đang mở
            if (state is ChangePasswordSuccess) {
              _showMessage(context, 'Password changed successfully.', true);
            } else if (state is ChangePasswordFailure) {
              _showMessage(context, state.errorMessage, false);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPasswordField(
                controller: currentPasswordController,
                labelText: 'Current Password',
                isVisible: _currentPasswordVisible,
                onVisibilityToggle: () {
                  setState(() {
                    _currentPasswordVisible = !_currentPasswordVisible;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildPasswordField(
                controller: newPasswordController,
                labelText: 'New Password',
                isVisible: _newPasswordVisible,
                onVisibilityToggle: () {
                  setState(() {
                    _newPasswordVisible = !_newPasswordVisible;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildPasswordField(
                controller: confirmPasswordController,
                labelText: 'Confirm New Password',
                isVisible: _confirmPasswordVisible,
                onVisibilityToggle: () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                },
              ),
              SizedBox(height: 35),
              ElevatedButton(
                onPressed: () {
                  _changePassword(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4254FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: Text(
                  'Đổi mật khẩu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFF4254FE),
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(
      ChangePasswordRequested(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      ),
    );
  }

  void _showMessage(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          message,
          style: TextStyle(color: isSuccess ? Color(0xFF00C853) : Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              //if (isSuccess) Navigator.popUntil(context, ModalRoute.withName('/setting'));
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
