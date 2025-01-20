import 'package:equatable/equatable.dart';

abstract class InviteEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class EmailInputChanged extends InviteEvent {
  final String email;

  EmailInputChanged(this.email);

  @override
  List<Object> get props => [email];
}

class UserSelected extends InviteEvent {
  final String email;

  UserSelected(this.email);

  @override
  List<Object> get props => [email];
}

class InviteUser extends InviteEvent {
  final String projectId;

  InviteUser(this.projectId);

  @override
  List<Object> get props => [projectId];
}
