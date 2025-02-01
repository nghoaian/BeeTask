import 'dart:math';

import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/bloc/task/task_state.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/data/repository/TaskRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bee_task/data/repository/UserRepository.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseFirestore firestore;

  final FirebaseTaskRepository taskRepository;
  final FirebaseUserRepository userRepository;

  TaskBloc(this.firestore, this.taskRepository, this.userRepository)
      : super(TaskInitial()) {
    on<FetchTasksByDate>(_onFetchTasksByDate);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<LoadTasks>(_loadTasks);
    on<DetailsTask>(_onDetailTaskLoaded);
    on<logTaskActivity>(_onLogTaskActivity);
  }

  /// Hàm xử lý sự kiện LoadTasks
  Future<bool> _loadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading()); // Phát trạng thái loading
    try {
      // Lấy danh sách tasks dựa trên projectId
      final snapshot = await firestore
          .collection('projects')
          .doc(event.projectId)
          .collection('tasks')
          .get();

      final tasks = await Future.wait(snapshot.docs.map((doc) async {
        final task = Task.fromFirestore(doc.data(), doc.id);

        // Lấy danh sách subtasks dựa trên taskId
        final subtaskSnapshot = await firestore
            .collection('projects')
            .doc(event.projectId)
            .collection('tasks')
            .doc(doc.id)
            .collection('subtasks')
            .get();

        final subtasks =
            await Future.wait(subtaskSnapshot.docs.map((subtaskDoc) async {
          final subtask = Task.fromFirestore(subtaskDoc.data(), subtaskDoc.id);

          // Lấy danh sách subsubtasks dựa trên subtaskId
          final subsubtaskSnapshot = await firestore
              .collection('projects')
              .doc(event.projectId)
              .collection('tasks')
              .doc(doc.id)
              .collection('subtasks')
              .doc(subtaskDoc.id)
              .collection('subsubtasks')
              .get();

          final subsubtasks = subsubtaskSnapshot.docs
              .map((subsubtaskDoc) =>
                  Task.fromFirestore(subsubtaskDoc.data(), subsubtaskDoc.id))
              .toList();

          return subtask.copyWith(subtasks: subsubtasks);
        }).toList());

        return task.copyWith(subtasks: subtasks);
      }).toList());

      // In ra log để kiểm tra dữ liệu
      for (var task in tasks) {
        print('Task: ${task.title}, Subtasks: ${task.subtasks.length}');
        for (var subtask in task.subtasks) {
          print(
              '  Subtask: ${subtask.title}, Subsubtasks: ${subtask.subtasks.length}');
        }
      }

      emit(TaskLoaded(tasks)); // Phát trạng thái thành công với danh sách tasks
      return true;
    } catch (e) {
      emit(TaskError(e.toString())); // Phát trạng thái lỗi nếu có exception
      return false;
    }
  }

  Future<bool> _onFetchTasksByDate(
      FetchTasksByDate event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final userEmail = await userRepository.getUserEmail();
      if (userEmail == null) {
        emit(TaskError('User email is null'));
        return false;
      }
      final taskMaps = await taskRepository.fetchTasksByDate(
          event.date, event.showCompletedTasks, userEmail);
      final tasks = taskMaps.map((taskMap) => Task.copyTasks(taskMap)).toList();
      emit(TaskLoaded(tasks));
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      return false;
    }
  }

  Future<bool> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.addTask(event.thisTaskId, event.type, event.task,
          event.taskId, event.projectId);
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      return false;
    }
  }

  Future<bool> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(
          event.taskId, event.updatedTask, event.type);
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      return false;
    }
  }

  Future<bool> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId, event.type);
      emit(TaskInitial()); // Reset state after deletion
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      return false;
    }
  }

  Future<void> _onDetailTaskLoaded(
      DetailsTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading()); // Start with loading state
    try {
      final detailTask =
          await taskRepository.fetchDataFromFirestore(event.type, event.id);
      emit(DetailTaskLoaded(detailTask)); // Phát trạng thái mới
    } catch (e) {
      emit(TaskError('Failed to load task details: ${e.toString()}'));
    }
  }

  Future<void> _onLogTaskActivity(
      logTaskActivity event, Emitter<TaskState> emit) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      User? user = firebaseAuth.currentUser;

      final taskActivity = await taskRepository.logTaskActivity(
          event.projectId,
          event.taskId,
          event.action,
          event.changedFields,
          user?.email ?? '',
          event.type);
    } catch (e) {
      emit(TaskError('Failed to load task details: ${e.toString()}'));
    }
  }
}
