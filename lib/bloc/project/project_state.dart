import 'package:equatable/equatable.dart';

class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Map<String, dynamic>> projects;

  ProjectLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class ProjectError extends ProjectState {
  final String message;

  ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectColorLoaded extends ProjectState {
  final String color;

  ProjectColorLoaded({required this.color});

  @override
  List<Object?> get props => [color];
}

