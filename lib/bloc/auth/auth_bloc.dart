import 'dart:async';
import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bee_task/util/colors.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final UserRepository userRepository;
  late final StreamSubscription<User?> _authSubscription;

  AuthBloc({required this.firebaseAuth, required this.firestore})
      : userRepository = FirebaseUserRepository(
            firestore: firestore, firebaseAuth: firebaseAuth),
        super(AuthInitial()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<ForgetPasswordRequested>(_onForgetPasswordRequested);

    // Kiểm tra trạng thái đăng nhập
    _authSubscription = firebaseAuth.authStateChanges().listen((user) {
      add(AuthStatusChanged(user: user));
    });
  }

  // Xử lý trạng thái đăng nhập
  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // Xử lý đăng nhập
  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Kiểm tra định dạng email
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(event.email)) {
        emit(AuthFailure(errorMessage: "Email is not valid!"));
        debugPrint("Email is not valid!");
        return;
      }

      // Kiểm tra email đã được đăng ký chưa
      bool useremailExists =
          await userRepository.checkIfUserEmailExist(event.email);
      if (!useremailExists) {
        emit(AuthFailure(errorMessage: "Email is not registered!"));
        return;
      }

      await firebaseAuth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );

      emit(AuthAuthenticated(user: firebaseAuth.currentUser!));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        emit(AuthFailure(errorMessage: "Wrong password!"));
      } else {
        emit(AuthFailure(errorMessage: e.message ?? "Unknown error"));
      }
    }
  }

  // Xử lý đăng ký
  Future<void> _onSignupRequested(
      SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Kiểm tra useremail đã tồn tại chưa
      bool useremailExists =
          await userRepository.checkIfUserEmailExist(event.email);
      if (useremailExists) {
        debugPrint("Email đã tồn tại!");
        emit(AuthFailure(errorMessage: "Email đã tồn tại!"));
        return;
      }

      // Tạo tài khoản mới
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );

      // Thêm thông tin user vào Firestore
      String userId = userCredential.user!.uid;
      await userRepository.addUser(userId, event.username, event.email, 'blue');

      emit(AuthAuthenticated(user: userCredential.user!));
      debugPrint("Đã phát trạng thái AuthAuthenticated");
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(errorMessage: e.message ?? "Unknown error"));
    }
  }

  // Xử lý đổi mật khẩu
  Future<void> _onChangePasswordRequested(
      ChangePasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        emit(ChangePasswordFailure(errorMessage: "Không tìm thấy user."));
        return;
      }

      // Xác thực lại user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: event.currentPassword,
      );

      // Xác thực lại mật khẩu cũ của user
      try {
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (_) {
        emit(ChangePasswordFailure(
            errorMessage: "Mật khẩu hiện tại không đúng. Vui lòng thử lại."));
        return;
      }

      if (event.newPassword != event.confirmPassword) {
        emit(ChangePasswordFailure(
            errorMessage: "New password and confirm password do not match!"));
        return;
      }
      await user.updatePassword(event.newPassword);

      emit(ChangePasswordSuccess());
    } on FirebaseAuthException catch (e) {
      emit(ChangePasswordFailure(
          errorMessage:
              e.message ?? "Password change failed. Please try again."));
    }
  }

  // Xử lý quên mật khẩu
  Future<void> _onForgetPasswordRequested(
      ForgetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: event.email.trim());
      emit(ForgetPasswordSuccess());
    } on FirebaseAuthException catch (e) {
      emit(ForgetPasswordFailure(
          errorMessage: e.message ?? "An unexpected error occurred."));
    }
  }

  @override
  Future<void> close() {
    // Hủy luồng khi Bloc bị đóng
    _authSubscription.cancel();
    return super.close();
  }
}
