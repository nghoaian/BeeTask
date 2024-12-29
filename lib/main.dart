import 'package:bee_task/bloc/auth/auth_bloc.dart';
import 'package:bee_task/firebase/firebase_options.dart';
import 'package:bee_task/screen/auth/welcome_screen.dart';
import 'package:bee_task/screen/setting_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return BlocProvider(
      create: (context) => AuthBloc(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
      child: MaterialApp(
        title: 'Quizlet App',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => WelcomeScreen(),
          '/setting': (context) => SettingScreen(),
        },
      ),
    );
  }
}