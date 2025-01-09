import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    on<LoadProjectsEvent>((event, emit) async {
      emit(ProjectLoading());
      try {
        // Lấy danh sách projects từ Firestore
        final querySnapshot =
            await FirebaseFirestore.instance.collection('projects').get();

        final projects = querySnapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "name": doc["name"],
            "description": doc["description"],
          };
        }).toList();

        emit(ProjectLoaded(projects));
      } catch (e) {
        emit(ProjectError("Failed to load projects: $e"));
      }
    });
  }
}
