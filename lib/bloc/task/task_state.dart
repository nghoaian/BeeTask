import 'package:bee_task/data/model/task.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  TaskLoaded(this.tasks);
}

class DetailTaskLoaded extends TaskState {
  final Map<String, dynamic> tasks;
  DetailTaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String error;

  TaskError(this.error);
}

class TaskSuccess extends TaskState {}

class TaskFailure extends TaskState {
  final String error; // You can pass the error message
  TaskFailure(this.error);
}
