import 'package:equatable/equatable.dart';
import 'package:bee_task/data/model/task.dart';

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
  final bool showCompletedTasks;

  const FetchTasksByDate(this.date, this.showCompletedTasks);

  @override
  List<Object> get props => [date, showCompletedTasks];
}

class AddTask extends TaskEvent {
  final Task task;
  final String type;
  final String taskId;
  final String projectId;

  AddTask(this.type, this.task, this.taskId, this.projectId);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final String taskId;
  final Task updatedTask;
  final String type;

  UpdateTask(this.taskId, this.updatedTask, this.type);

  @override
  List<Object> get props => [taskId, updatedTask];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  final String type;

  DeleteTask(this.taskId, this.type);
}
