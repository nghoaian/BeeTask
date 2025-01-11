import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final FirebaseFirestore firestore;

  ProjectBloc(
    this.firestore,
  ) : super(ProjectInitial()) {
    on<LoadProjectsEvent>(_loadProjects);
    on<AddProjectEvent>(_addProject);
    on<GetColorForProjectEvent>(_getColorForProject);
  }

  Future<void> _loadProjects(
      LoadProjectsEvent event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      // Lấy danh sách projects từ Firestore
      final querySnapshot = await firestore.collection('projects').get();

      final projects = querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "name": doc["name"],
        };
      }).toList();

      emit(ProjectLoaded(projects));
    } catch (e) {
      emit(ProjectError("Failed to load projects: $e"));
    }
  }

  Future<void> _addProject(
      AddProjectEvent event, Emitter<ProjectState> emit) async {
    print(
        'Adding project: ${event.project}'); // Debug: Kiểm tra dữ liệu nhận được

    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .add(event.project);
      print(
          'Project added to Firestore successfully'); // Debug: Thành công thêm vào Firestore

      add(LoadProjectsEvent()); // Tải lại danh sách project
    } catch (e) {
      print('Failed to add project: $e'); // Debug: In lỗi
      emit(ProjectError("Failed to add project: $e"));
    }
  }

  Future<void> _getColorForProject(
      GetColorForProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      DocumentSnapshot projectSnapshot =
          await firestore.collection('projects').doc(event.projectId).get();
      
      if (projectSnapshot.exists) {
        String color = projectSnapshot['color'] ?? 'Grey'; // Giá trị mặc định
        emit(ProjectColorLoaded(color: color));
      } else {
        throw Exception('Project not found');
      }
    } catch (e) {
      emit(ProjectError("Failed to load color: $e"));
    }
  }
}
