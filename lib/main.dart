import 'package:bee_task/bloc/account/account_bloc.dart';
import 'package:bee_task/bloc/auth/auth_bloc.dart';
import 'package:bee_task/bloc/comment/comment_bloc.dart';
import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/firebase/firebase_options.dart';
import 'package:bee_task/screen/auth/forget_password.dart';
import 'package:bee_task/screen/auth/welcome_screen.dart';
import 'package:bee_task/screen/setting/setting_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/bloc/comment/comment_bloc.dart'; // Add this line

import 'package:bee_task/data/repository/CommentRepository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
        BlocProvider(
          create: (context) => AccountBloc(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
        BlocProvider(
          create: (context) => TaskBloc(
            FirebaseFirestore.instance,
            FirebaseTaskRepository(firestore: FirebaseFirestore.instance),
            FirebaseUserRepository(
              firestore: FirebaseFirestore.instance,
              firebaseAuth: FirebaseAuth.instance,
            ),
          ),
          child: MyApp(),
        ),
        BlocProvider(
          create: (context) => ProjectBloc(
            FirebaseFirestore.instance,
          ),
        ),
        BlocProvider(
          create: (context) => CommentBloc(
            FirebaseCommentRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Quizlet App',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => WelcomeScreen(),
          '/setting': (context) => SettingScreen(),
          '/forgot_password': (context) => ForgetPasswordScreen(),
        },
      ),
    );
  }
}
