import 'package:bee_task/bloc/auth/auth_bloc.dart';
import 'package:bee_task/bloc/auth/auth_event.dart';
import 'package:bee_task/bloc/auth/auth_state.dart';
import 'package:bee_task/screen/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSignedUp) {
            // Navigate to HomeScreen after successful signup
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          }
          if (state is AuthSignUpFailure) {
            // Show error message if signup fails
            _showErrorMsg(context, state.errorMessage);
          }
        },
        child: SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                // Background Gradient
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4254FE), Color(0xFF691FDC)],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 60.0, left: 22),
                    child: Text(
                      'Create Your\nAccount',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Signup Form
                Padding(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            // Username Field
                            TextField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                suffixIcon:
                                    Icon(Icons.check, color: Colors.grey),
                                label: Text(
                                  'Username',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4254FE),
                                  ),
                                ),
                              ),
                            ),
                            // Email Field
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                suffixIcon:
                                    Icon(Icons.check, color: Colors.grey),
                                label: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4254FE),
                                  ),
                                ),
                              ),
                            ),
                            // Password Field
                            TextField(
                              controller: passwordController,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
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
                                    color: Color(0xFF4254FE),
                                  ),
                                ),
                              ),
                            ),
                            // Confirm Password Field
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: !_passwordVisible,
                              decoration: const InputDecoration(
                                label: Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4254FE),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Sign Up Button
                            GestureDetector(
                              onTap: () {
                                if (passwordController.text ==
                                    confirmPasswordController.text) {
                                  BlocProvider.of<AuthBloc>(context).add(
                                    SignupRequested(
                                      email: emailController.text,
                                      password: passwordController.text,
                                      username: usernameController.text,
                                    ),
                                  );
                                } else {
                                  _showErrorMsg(
                                      context, "Passwords don't match");
                                }
                              },
                              child: Container(
                                height: 55,
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xFF4254FE),
                                ),
                                child: const Center(
                                  child: Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 80),
                            // Existing User Sign In Text
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                children: [
                                  const Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => LoginScreen()),
                                      );
                                    },
                                    child: const Text(
                                      "Sign in",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _showErrorMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
