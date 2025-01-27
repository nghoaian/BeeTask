import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final FirebaseFirestore firestore;

  ProjectBloc(
    this.firestore,
  ) : super(ProjectInitial()) {
    on<LoadProjectsEvent>(_onLoadProjects);
    on<AddProjectEvent>(_onAddProject);
    on<GetColorForProjectEvent>(_getColorForProject);
    on<LoadProjectMembers>(_onLoadProjectMembers);
  }

  Future<void> _onLoadProjects(
      LoadProjectsEvent event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Lấy danh sách projects từ Firestore
      final querySnapshot = await firestore
          .collection('projects')
          .where('members', arrayContains: user?.email)
          .get();

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

  Future<void> _onAddProject(
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

  Future<void> _onLoadProjectMembers(
      LoadProjectMembers event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final projectDoc =
          await firestore.collection('projects').doc(event.projectId).get();
      final members = projectDoc.data()?['members'] as List<dynamic>? ?? [];

      final memberDetails = await Future.wait(members.map((email) async {
        final userDoc = await firestore
            .collection('users')
            .where('userEmail', isEqualTo: email)
            .get();
        if (userDoc.docs.isNotEmpty) {
          final user = userDoc.docs.first.data();
          return {
            'userName': user['userName'],
            'userEmail': user['userEmail'],
          };
        }
        return null;
      }).toList());

      final filteredMemberDetails = memberDetails
          .where((user) => user != null)
          .cast<Map<String, dynamic>>()
          .toList();

      emit(ProjectMemberLoaded(filteredMemberDetails));
    } catch (e) {
      emit(ProjectError('Failed to load project members: $e'));
    }
  }
}
