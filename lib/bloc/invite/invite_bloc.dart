import 'dart:async';
import 'package:bee_task/bloc/project/project_bloc.dart';
import 'package:bee_task/bloc/project/project_event.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
          color: user['userColor'],
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
      final user = FirebaseAuth.instance.currentUser;

      logProjectActivity(event.projectId, 'invite', user?.email ?? '',
          selectedUserEmail ?? '');
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

  Future<String> getOwner(String projectId) async {
    try {
      final projectDoc =
          await firestore.collection('projects').doc(projectId).get();
      final ownerUserEmail = projectDoc.data()?['owner'] as String?;

      if (ownerUserEmail != null) {
        return ownerUserEmail;
      } else {
        throw Exception('Owner not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch owner: $e');
    }
  }

  Future<void> _onEditPermission(
      EditPermission event, Emitter<InviteState> emit) async {
    try {
      final projectRef = firestore.collection('projects').doc(event.projectId);
      final projectDoc = await projectRef.get();
      final permissions =
          List<String>.from(projectDoc.data()?['permissions'] ?? []);
      final user = FirebaseAuth.instance.currentUser;

      if (event.canEdit) {
        if (!permissions.contains(event.userEmail)) {
          permissions.add(event.userEmail);
          logProjectActivity(
              event.projectId, 'canEdit', user?.email ?? '', event.userEmail);

          debugPrint('Added permission for ${event.userEmail}');
        }
      } else {
        debugPrint('Removed permission for ${event.userEmail}');
        logProjectActivity(
            event.projectId, 'canView', user?.email ?? '', event.userEmail);
        permissions.remove(event.userEmail);
      }

      await projectRef.update({'permissions': permissions});

      emit(InviteSuccess());
    } catch (e) {
      emit(InviteFailure("Failed to update permissions: $e"));
    }
  }

  Future<void> logProjectActivity(
      String projectId, String action, String actor, String target) async {
    final projectActivitiesCollection =
        FirebaseFirestore.instance.collection('project_activities');

    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('HH:mm, dd-MM-yyyy').format(now);

      await projectActivitiesCollection.add({
        'projectId': projectId,
        'action': action,
        'actor': actor,
        'target': target,
        'timestamp': formattedDate,
      });
    } catch (e) {
      print('Failed to log activity: $e');
    }
  }
}
