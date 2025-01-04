import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final UserRepository userRepository;

  AccountBloc({required this.firebaseAuth, required this.firestore})
      : userRepository = FirebaseUserRepository(
            firestore: firestore, firebaseAuth: firebaseAuth),
        super(AccountInitial()) {
    on<FetchUserNameRequested>(_onFetchUserNameRequested);      
    on<UpdateUserNameRequested>(_onUpdateUserNameRequested);
    on<UpdateUserImageRequested>(_onUpdateUserImageRequested);
  }

  Future<void> _onFetchUserNameRequested(
      FetchUserNameRequested event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final String? userName = await userRepository.getUserName();
      final String? userEmail = await userRepository.getUserEmail();
      if (userName != null) {
        emit(AccountLoaded(userName, userEmail!));
      } else {
        emit(AccountError('User name not found'));
      }
    } catch (e) {
      emit(AccountError('Failed to fetch user name: $e'));
    }
  }

  // Xử lý cập nhật UserName
  Future<void> _onUpdateUserNameRequested(
      UpdateUserNameRequested event, Emitter<AccountState> emit) async {
    emit(AccountLoading());

    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        emit(AccountError("User not found."));
        return;
      }

      await userRepository.updateUserName(event.username);

      final String? userEmail = await userRepository.getUserEmail();

      emit(AccountLoaded(event.username, userEmail!));
    } catch (e) {
      emit(AccountError("Failed to update username: $e"));
    }
  }

  // Xử lý cập nhật UserName
  Future<void> _onUpdateUserImageRequested(
      UpdateUserImageRequested event, Emitter<AccountState> emit) async {
    emit(AccountLoading());

    // try {
    //   User? user = firebaseAuth.currentUser;
    //   if (user == null) {
    //     emit(UpdateUserImageFailure(errorMessage: "Không tìm thấy user."));
    //     return;
    //   }

    //   await userRepository.updateUserName(user.uid, event.userImage);

    //   emit(UpdateUserImageSuccess());
    // } on FirebaseAuthException catch (e) {
    //   emit(UpdateUserImageFailure(errorMessage: e.message ?? "Unknown error"));
    // }
  }
}
