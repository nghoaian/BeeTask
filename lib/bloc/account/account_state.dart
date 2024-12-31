import 'package:equatable/equatable.dart';

abstract class AccountState extends Equatable {
  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class UpdateUserNameSuccess extends AccountState {}

class UpdateUserNameFailure extends AccountState {
  final String errorMessage;

  UpdateUserNameFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class UpdateUserImageSuccess extends AccountState {}

class UpdateUserImageFailure extends AccountState {
  final String errorMessage;

  UpdateUserImageFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}