import 'package:equatable/equatable.dart';

abstract class AccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final String userName;
  final String userEmail;

  AccountLoaded(this.userName, this.userEmail);

  @override
  List<Object> get props => [userName, userEmail];
}

class AccountError extends AccountState {
  final String message;

  AccountError(this.message);

  @override
  List<Object> get props => [message];
}

class UpdateUserImageSuccess extends AccountState {}

class UpdateUserImageFailure extends AccountState {
  final String errorMessage;

  UpdateUserImageFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}