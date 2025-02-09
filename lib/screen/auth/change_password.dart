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
          if (state is ChangePasswordSuccess ||
              state is ChangePasswordFailure) {
            if (state is ChangePasswordSuccess) {
              _showMessage(context, 'Password changed successfully.', true);
            } else if (state is ChangePasswordFailure) {
              _showErrorMessage(context, state.errorMessage, false);
            }

            // if (Navigator.of(context).canPop())
            //   Navigator.of(context).pop(); // Đóng loading dialog nếu đang mở
          }
        },
        child: Container(
          color: Colors.white,
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
                    'Change Password',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _showErrorMessage(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
