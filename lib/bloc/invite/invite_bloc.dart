import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'invite_event.dart';
import 'invite_state.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final FirebaseFirestore firestore;
  String? selectedUserEmail;

  InviteBloc(this.firestore) : super(InviteInitial()) {
    on<EmailInputChanged>(_onEmailInputChanged);
    on<UserSelected>(_onUserSelected);
    on<InviteUser>(_onInviteUser);
    on<EditPermission>(_onEditPermission);
  }

  Future<void> _onEmailInputChanged(
      EmailInputChanged event, Emitter<InviteState> emit) async {
    if (event.email.isEmpty) {
      emit(InviteInitial());
      return;
    }

    emit(InviteLoading());

    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: event.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final user = querySnapshot.docs.first;
        emit(InviteUserFound(
          name: user['userName'],
          email: user['userEmail'],
        ));
      } else {
        emit(InviteUserNotFound());
      }
    } catch (e) {
      emit(InviteUserNotFound());
    }
  }

  void _onUserSelected(UserSelected event, Emitter<InviteState> emit) {
    selectedUserEmail = event.email;
    emit(InviteUserSelected(email: event.email));
  }

  Future<void> _onInviteUser(
      InviteUser event, Emitter<InviteState> emit) async {
    if (selectedUserEmail == null) {
      emit(InviteFailure("No user selected"));
      return;
    }

    try {
      final projectRef = firestore.collection('projects').doc(event.projectId);
      await projectRef.update({
        'members': FieldValue.arrayUnion([selectedUserEmail]),
        'permissions': FieldValue.arrayUnion([selectedUserEmail])
      });
      emit(InviteSuccess());
    } catch (e) {
      emit(InviteFailure("Failed to invite user: $e"));
    }
  }

  Future<String> getPermission(String projectId, String userEmail) async {
    try {
      final projectDoc =
          await firestore.collection('projects').doc(projectId).get();
      final permissions =
          projectDoc.data()?['permissions'] as List<dynamic>? ?? [];

      if (permissions.contains(userEmail)) {
        return 'Can Edit';
      } else {
        return 'Can View';
      }
    } catch (e) {
      return 'Can View';
    }
  }

  Future<void> _onEditPermission(
      EditPermission event, Emitter<InviteState> emit) async {
    try {
      final projectRef = firestore.collection('projects').doc(event.projectId);
      final projectDoc = await projectRef.get();
      final permissions =
          List<String>.from(projectDoc.data()?['permissions'] ?? []);

      if (event.canEdit) {
        if (!permissions.contains(event.userEmail)) {
          permissions.add(event.userEmail);
          debugPrint('Added permission for ${event.userEmail}');
        }
      } else {
        debugPrint('Removed permission for ${event.userEmail}');
        permissions.remove(event.userEmail);
      }

      await projectRef.update({'permissions': permissions});

      emit(InviteSuccess());
    } catch (e) {
      emit(InviteFailure("Failed to update permissions: $e"));
    }
  }
}
