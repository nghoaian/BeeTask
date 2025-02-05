import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProjectsEvent extends ProjectEvent {}

class AddProjectEvent extends ProjectEvent {
  final Map<String, dynamic> project;

  AddProjectEvent(this.project);

  @override
  List<Object?> get props => [project];
}

class UpdateProject extends ProjectEvent {
  final String projectId;
  final String projectName;

  UpdateProject(this.projectId, this.projectName);

  @override
  List<Object> get props => [projectId, projectName];
}

class DeleteProject extends ProjectEvent {
  final String projectId;

  DeleteProject(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class GetColorForProjectEvent extends ProjectEvent {
  final String projectId;

  GetColorForProjectEvent({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class LoadProjectMembers extends ProjectEvent {
  final String projectId;

  LoadProjectMembers(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class RemoveProjectMember extends ProjectEvent {
  final String projectId;
  final String userEmail;

  RemoveProjectMember(this.projectId, this.userEmail);

  @override
  List<Object?> get props => [projectId, userEmail];
}

class LoadProjectPermissions extends ProjectEvent {
  final String projectId;
  final String userEmail;

  LoadProjectPermissions(this.projectId, this.userEmail);

  @override
  List<Object?> get props => [projectId, userEmail];
}