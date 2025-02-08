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
  final String color;

  InviteUserFound({required this.name, required this.email, required this.color});

  @override
  List<Object> get props => [name, email, color];
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

class OwnerLoaded extends InviteState {
  final String ownerUserEmail;

  OwnerLoaded(this.ownerUserEmail);

  @override
  List<Object> get props => [ownerUserEmail];
}