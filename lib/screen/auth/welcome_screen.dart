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
            TaskData().resetData();
            if (user != null && user.email != null) {
              TaskData().listenToAllData(user.email!);
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
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 120.0),
            // child: Text(
            //   'BeeTask',
            //   style: TextStyle(
            //     fontFamily: 'Times New Roman',
            //     fontSize: 40,
            //     color: AppColors.white,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            child: Image.asset(
              'lib/util/images/beetasklogo.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          const Text(
            'Welcome To BeeTask',
            style: TextStyle(
              fontSize: 35,
              fontFamily: 'Times New Roman',
              color: Colors.yellow,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.white),
              ),
              child: const Center(
                child: Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.white),
              ),
              child: const Center(
                child: Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
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
