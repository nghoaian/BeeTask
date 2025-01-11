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

class FetchTasksByDate extends TaskEvent {
  final String date;

  const FetchTasksByDate(this.date);

  @override
  List<Object> get props => [date];
}

class AddTask extends TaskEvent {
  final Map<String, dynamic> task;

  AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final String taskId;
  final Map<String, dynamic> updatedTask;

  UpdateTask(this.taskId, this.updatedTask);

  @override
  List<Object> get props => [taskId, updatedTask];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  DeleteTask(this.taskId);
}
