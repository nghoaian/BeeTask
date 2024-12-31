import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserRepository {
  Future<bool> checkIfUsernameExist(String username);
  Future<void> addUserName(String username, String email);
  Future<String?> getUserName(String uid);
  Future<void> updateUserName(String uid, String username);
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  FirebaseUserRepository({required this.firestore, required this.firebaseAuth});

  @override
  Future<bool> checkIfUsernameExist(String username) async {
    final CollectionReference usersCollection = firestore.collection('users');
    final QuerySnapshot result = await usersCollection
        .where('userName', isEqualTo: username)
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
  Future<String?> getUserName(String uid) async {
    final DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['userName'];
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