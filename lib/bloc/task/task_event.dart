import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final String projectId;

  const LoadTasks(this.projectId);

  @override
  List<Object> get props => [projectId];
}