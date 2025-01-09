import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/bloc/task/task_state.dart';
import 'package:bee_task/data/model/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseFirestore firestore;

  TaskBloc(this.firestore) : super(TaskInitial()) {
    on<LoadTasks>(_loadTasks);
  }

  /// Hàm xử lý sự kiện LoadTasks
  Future<void> _loadTasks(LoadTasks event, Emitter<TaskState> emit) async {
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

        final subtasks = await Future.wait(subtaskSnapshot.docs.map((subtaskDoc) async {
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
              .map((subsubtaskDoc) => Task.fromFirestore(subsubtaskDoc.data(), subsubtaskDoc.id))
              .toList();

          return subtask.copyWith(subtasks: subsubtasks);
        }).toList());

        return task.copyWith(subtasks: subtasks);
      }).toList());

      // In ra log để kiểm tra dữ liệu
      for (var task in tasks) {
        print('Task: ${task.title}, Subtasks: ${task.subtasks.length}');
        for (var subtask in task.subtasks) {
          print('  Subtask: ${subtask.title}, Subsubtasks: ${subtask.subtasks.length}');
        }
      }

      emit(TaskLoaded(tasks)); // Phát trạng thái thành công với danh sách tasks
    } catch (e) {
      emit(TaskError(e.toString())); // Phát trạng thái lỗi nếu có exception
    }
  }
}