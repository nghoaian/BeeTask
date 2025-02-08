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

class EditPermission extends InviteEvent {
  final String projectId;
  final String userEmail;
  final bool canEdit;

  EditPermission({
    required this.projectId,
    required this.userEmail,
    required this.canEdit,
  });
}

class GetOwner extends InviteEvent {
  final String projectId;

  GetOwner(this.projectId);

  @override
  List<Object> get props => [projectId];
}