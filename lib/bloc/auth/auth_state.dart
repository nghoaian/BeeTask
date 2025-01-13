import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}
class AuthFailure extends AuthState {
  final String errorMessage;

  AuthFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class ChangePasswordSuccess extends AuthState {}

class ChangePasswordFailure extends AuthState {
  final String errorMessage;
  
  ChangePasswordFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class ForgetPasswordSuccess extends AuthState {}

class ForgetPasswordFailure extends AuthState {
  final String errorMessage;

  ForgetPasswordFailure({required this.errorMessage});
}