import 'dart:math';

import 'package:bee_task/bloc/account/account_bloc.dart';
import 'package:bee_task/bloc/account/account_event.dart';
import 'package:bee_task/bloc/auth/auth_bloc.dart';
import 'package:bee_task/bloc/auth/auth_event.dart';
import 'package:bee_task/bloc/auth/auth_state.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/screen/auth/login_screen.dart';
import 'package:bee_task/screen/nav/nav_ui_screen.dart';
import 'package:bee_task/screen/upcoming/home_screen.dart';
import 'package:bee_task/util/colors.dart';
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (_) => AuthBloc(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint("Đã nhận trạng thái: $state");
          if (state is AuthAuthenticated) {
            debugPrint('AuthAuthenticated state emitted');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signup successful!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            Future.delayed(Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            });
          } else if (state is AuthFailure) {
            debugPrint('AuthFailure state emitted');
            _showErrorMsg(context, state.errorMessage);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // Background Gradient
              Container(
                height: screenHeight,
                width: screenWidth,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4254FE), Color(0xFF691FDC)],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.08, left: screenWidth * 0.06),
                  child: const Text(
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: screenHeight * 0.75,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        // _buildTextField(
                        //     usernameController, "Username", Icons.person),
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.check, color: Colors.grey),
                            label: Text(
                              'Username',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4254FE),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // _buildTextField(emailController, "Email", Icons.email),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.check, color: Colors.grey),
                            label: Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4254FE),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // _buildPasswordField(),
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
                        SizedBox(height: screenHeight * 0.02),
                        // _buildTextField(confirmPasswordController,
                        //     "Confirm Password", Icons.lock),
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
                        SizedBox(height: screenHeight * 0.05),

                        // Sign Up Button
                        GestureDetector(
                          onTap: () async {
                            await _handleSignup();
                          },
                          child: Container(
                            height: screenHeight * 0.07,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color(0xFF4254FE),
                            ),
                            child: const Center(
                              child: Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),

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
                                    color: Color(0xFF4254FE),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Text Field Builder
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF4254FE),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

// Password Field Builder
  Widget _buildPasswordField() {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            labelText: 'Password',
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4254FE),
            ),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Future<void> _handleSignup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final username = usernameController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorMsg(context, "Please fill in all fields");
      return;
    }

    // Kiểm tra định dạng email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorMsg(context, "Email is not valid!");
      return;
    }

    if (password != confirmPassword) {
      _showErrorMsg(context, "Passwords don't match");
      return;
    }

    // Kiểm tra email đã tồn tại chưa
    final userRepository = FirebaseUserRepository(
      firestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    );
    bool useremailExists = await userRepository.checkIfUserEmailExist(email);
    if (useremailExists) {
      _showErrorMsg(context, "Email already exists!");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String userColor = getRandomColor();
      // Thêm thông tin user vào Firestore
      String userId = userCredential.user!.uid;
      await userRepository.addUser(userId, username, email, userColor);

      // Tạo project với ID là userName
      final project = {
        'name': 'Inbox',
        'color': 'Charcoal',
        'owner': email,
        'members': [email],
        'permissions': [email],
      };

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(email)
          .set(project);

      await FirebaseAuth.instance.signOut();

      // Future.delayed(Duration(seconds: 2), () {
      //   // Navigator.pushReplacement(
      //   //   context,
      //   //   MaterialPageRoute(builder: (_) => NavUIScreen()),
      //   // );
      //   // Navigator.pushReplacement(
      //   //   context,
      //   //   MaterialPageRoute(builder: (_) => LoginScreen()),
      //   // );

      // });
      // context.read<AuthBloc>().add(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      _showErrorMsg(context, e.message ?? "Unknown error");
    }
  }

  String getRandomColor() {
    List<String> colors = [
      'orange',
      'blue',
      'red',
      'green',
      'yellow',
      'purple',
      'pink'
    ];

    Random random = Random();
    int index = random.nextInt(colors.length);
    return colors[index];
  }

  void _showErrorMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
