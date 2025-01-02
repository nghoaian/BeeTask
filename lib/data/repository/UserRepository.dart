import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class UserRepository {
  Future<bool> checkIfUserEmailExist(String username);
  Future<void> addUserName(String username, String email);
  Future<String?> getUserName();
  Future<void> updateUserName(String uid, String username);
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  FirebaseUserRepository({required this.firestore, required this.firebaseAuth});

  String get _uid => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<bool> checkIfUserEmailExist(String useremail) async {
    final CollectionReference usersCollection = firestore.collection('users');
    final QuerySnapshot result = await usersCollection
        .where('userEmail', isEqualTo: useremail)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  @override
  Future<void> addUserName(String username, String email) async {
    final CollectionReference usersCollection = firestore.collection('users');
    await usersCollection.add({
      'userName': username,
      'userEmail': email,
    });
  }

  @override
  Future<String?> getUserName() async {
    final String uid = _uid;
    final DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['userName'];
      debugPrint('userName: ${userDoc['userName']}');
    }
    return null;
  }

  @override
  Future<void> updateUserName(String uid, String username) async {
    final DocumentReference userDoc = firestore.collection('users').doc(uid);
    await userDoc.update({
      'userName': username,
    });
  }

  @override
  Future<void> updateUserImage(String uid, String userImage) async {
    final DocumentReference userDoc = firestore.collection('users').doc(uid);
    await userDoc.update({
      'userImage': userImage,
    });
  }
}
