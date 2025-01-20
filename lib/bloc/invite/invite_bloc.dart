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
  }

  Future<void> _onEmailInputChanged(
      EmailInputChanged event, Emitter<InviteState> emit) async {
    if (event.email.isEmpty) {
      emit(InviteInitial());
      return;
    }

    emit(InviteLoading());

    // Thêm độ trễ 1 giây trước khi xử lý
    await Future.delayed(const Duration(seconds: 1));

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

  Future<void> _onInviteUser(InviteUser event, Emitter<InviteState> emit) async {
    if (selectedUserEmail == null) {
      emit(InviteFailure("No user selected"));
      return;
    }

    try {
      final projectRef = firestore.collection('projects').doc(event.projectId);
      await projectRef.update({
        'members': FieldValue.arrayUnion([selectedUserEmail])
      });
      emit(InviteSuccess());
    } catch (e) {
      emit(InviteFailure("Failed to invite user: $e"));
    }
  }
}
