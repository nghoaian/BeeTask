import 'package:bee_task/bloc/auth/auth_bloc.dart';
import 'package:bee_task/bloc/auth/auth_state.dart';
import 'package:bee_task/screen/auth/login_screen.dart';
import 'package:bee_task/screen/auth/signup_screen.dart';
import 'package:bee_task/screen/nav/nav_ui_screen.dart';
import 'package:bee_task/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/screen/TaskData.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null && user.email != null) {
              TaskData().loadData(user.email!);
            }
            return NavUIScreen();
          } else if (state is AuthUnauthenticated) {
            return _buildWelcomeScreen(context);
          } else if (state is AuthLoading) {
            return _buildLoadingScreen();
          } else if (state is AuthFailure) {
            return _buildErrorScreen(state.errorMessage);
          } else {
            return _buildWelcomeScreen(context);
          }
        },
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(), // Đẩy nội dung xuống giữa màn hình

            // Logo hoặc hình ảnh ứng dụng
            SizedBox(
              height: screenHeight * 0.25, // Chiếm khoảng 25% màn hình
              child: Image.asset(
                'lib/util/images/beetasklogo.png',
                width: screenWidth * 0.6, // 60% chiều rộng màn hình
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: screenHeight * 0.05), // Khoảng cách linh hoạt

            // Chữ Welcome
            const Text(
              'Welcome To BeeTask',
              style: TextStyle(
                fontSize: 32, // Giữ cố định hoặc điều chỉnh theo tỷ lệ
                fontFamily: 'Times New Roman',
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.04), // Khoảng cách linh hoạt

            // Nút SIGN IN
            SizedBox(
              width: screenWidth * 0.8, // 80% chiều rộng màn hình
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: AppColors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(fontSize: 18, color: AppColors.white),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02), // Khoảng cách linh hoạt

            // Nút SIGN UP
            SizedBox(
              width: screenWidth * 0.8, // 80% chiều rộng màn hình
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignupScreen()),
                  );
                },
                child: const Text(
                  'SIGN UP',
                  style: TextStyle(fontSize: 18, color: AppColors.black),
                ),
              ),
            ),

            const Spacer(), // Đẩy nội dung lên trên một chút
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorScreen(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
