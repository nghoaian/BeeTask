import 'package:equatable/equatable.dart';

abstract class InviteState extends Equatable {
  @override
  List<Object> get props => [];
}

class InviteInitial extends InviteState {}

class InviteLoading extends InviteState {}

class InviteUserFound extends InviteState {
  final String name;
  final String email;

  InviteUserFound({required this.name, required this.email});

  @override
  List<Object> get props => [name, email];
}

class InviteUserNotFound extends InviteState {}

class InviteSuccess extends InviteState {}

class InviteUserSelected extends InviteState {
  final String email;

  InviteUserSelected({required this.email});

  @override
  List<Object> get props => [email];
}

class InviteFailure extends InviteState {
  final String errorMessage;

  InviteFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}