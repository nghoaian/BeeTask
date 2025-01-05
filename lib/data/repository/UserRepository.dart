import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class UserRepository {
  FirebaseAuth get firebaseAuth;
  Future<bool> checkIfUserEmailExist(String username);
  Future<void> addUser(String id, String username, String email);
  Future<String?> getUserName();
  Future<String?> getUserEmail();
  Future<void> updateUserName(String username);
  Future<void> updateUserEmail(String useremail);
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  FirebaseUserRepository({required this.firestore, required this.firebaseAuth});

  @override
  Future<bool> checkIfUserEmailExist(String useremail) async {
    final CollectionReference usersCollection = firestore.collection('users');
    final QuerySnapshot result = await usersCollection
        .where('userEmail', isEqualTo: useremail)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> addUser(String userId, String username, String email) async {
    final CollectionReference usersCollection = firestore.collection('users');
    await usersCollection.doc(userId).set({
      'userName': username,
      'userEmail': email,
    });
  }

  @override
  Future<String?> getUserName() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc =
            await firestore.collection('users').doc(user.uid).get();
        return doc.get('userName') as String?;
      } catch (e) {
        debugPrint('Error fetching user name: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Future<String?> getUserEmail() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc =
            await firestore.collection('users').doc(user.uid).get();
        return doc.get('userEmail') as String?;
      } catch (e) {
        debugPrint('Error fetching user name: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> updateUserName(String username) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await firestore.collection('users').doc(user.uid).update({
        'userName': username,
      });
    }
  }

  @override
  Future<void> updateUserEmail(String useremail) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      final emailExists =
          await checkIfUserEmailExist(useremail);
      if (emailExists) {
        throw Exception("Email already exists in the system.");
      }

      try {
        await user.updateEmail(useremail);

        await firestore.collection('users').doc(user.uid).update({
          'userEmail': useremail,
        });
      } on FirebaseAuthException catch (e) {
        debugPrint('Error updating email: ${e.message}');
        rethrow;
      }
    }
  }

  @override
  Future<void> updateUserImage(String uid, String userImage) async {
    final DocumentReference userDoc = firestore.collection('users').doc(uid);
    await userDoc.update({
      'userImage': userImage,
    });
  }
}
