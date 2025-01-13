import 'package:bee_task/bloc/auth/auth_bloc.dart';
import 'package:bee_task/bloc/auth/auth_event.dart';
import 'package:bee_task/bloc/auth/auth_state.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/screen/auth/signup_screen.dart';
import 'package:bee_task/screen/nav/nav_ui_screen.dart';
import 'package:bee_task/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AuthAuthenticated) {
            // Xoa dialog loading
            Navigator.of(context).pop();
            // Navigate to homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => NavUIScreen()),
            );
          } else if (state is AuthFailure) {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(state.errorMessage),
              ),
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              _buildBackground(),
              Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: _buildLoginForm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary,
          AppColors.secondary,
        ]),
      ),
      child: const Padding(
        padding: EdgeInsets.only(top: 60.0, left: 22),
        child: Text(
          'Hello\nSign in!',
          style: TextStyle(
            fontSize: 30,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        color: Colors.white,
      ),
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmailField(),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildForgotPassword(),
            const SizedBox(height: 70),
            _buildSignInButton(context),
            const SizedBox(height: 150),
            _buildSignUp(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailController,
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.check, color: AppColors.grey),
        label: Text(
          'Email',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.grey,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        label: const Text(
          'Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/forgot_password');
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _handleLogin(context);
      },
      // {
      //   BlocProvider.of<AuthBloc>(context).add(
      //     LoginRequested(
      //       email: emailController.text,
      //       password: passwordController.text,
      //     ),
      //   );

      // },
      child: Container(
        height: 55,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.primary,
        ),
        child: const Center(
          child: Text(
            'SIGN IN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorMsg(context, "Please fill in all fields!");
      return;
    }
    
    // Kiểm tra định dạng email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorMsg(context, "Email is not valid!");
      return;
    }

    // Kiểm tra email đã được đăng ký chưa
    final userRepository = FirebaseUserRepository(
      firestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    );
    bool useremailExists = await userRepository.checkIfUserEmailExist(email);
    if (!useremailExists) {
      _showErrorMsg(context, "Email is not registered!");
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavUIScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorMsg(context, "Invalid email or password!");
    }
  }

  Widget _buildSignUp() {
        return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Not a member?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SignupScreen()),
              );
            },
            child: const Text(
              "Sign up",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMsg(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
