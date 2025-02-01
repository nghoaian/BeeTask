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
  final String thisTaskId;
  AddTask(this.thisTaskId, this.type, this.task, this.taskId, this.projectId);

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

class DetailsTask extends TaskEvent {
  final String id;
  final String type;

  const DetailsTask(this.type, this.id);

  @override
  List<Object> get props => [type, id];
}

class logTaskActivity extends TaskEvent {
  final projectId;
  final String taskId;
  final String action;
  final Map<String, dynamic> changedFields;

  final String type;
  const logTaskActivity(
      this.projectId, this.taskId, this.action, this.changedFields, this.type);
}
