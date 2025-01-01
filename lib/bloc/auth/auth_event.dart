import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthStatusChanged extends AuthEvent {
  final User? user;

  AuthStatusChanged({required this.user});

  @override
  List<Object> get props => [user ?? "Guest"];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  SignupRequested({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword, confirmPassword];
}

class ForgetPasswordRequested extends AuthEvent {
  final String email;

  ForgetPasswordRequested({required this.email});
}