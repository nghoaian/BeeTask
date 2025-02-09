import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
    on<RemoveProjectMember>(_onRemoveProjectMember);
    on<LoadProjectPermissions>(_onLoadProjectPermissions);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    // _listenToProjectChanges();
  }

  // void _listenToProjectChanges() {
  //   firestore.collection('projects').snapshots().listen((snapshot) {
  //     add(LoadProjectsEvent());
  //   });
  // }

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

      // Lưu trữ quyền cho từng dự án
      Map<String, bool> projectPermissions = {};
      for (var project in projects) {
        final permissions = await _getProjectPermissions(project["id"]);
        projectPermissions[project["id"]] = permissions;
      }

      emit(ProjectLoaded(projects, projectPermissions: projectPermissions));
    } catch (e) {
      emit(ProjectError("Failed to load projects: $e"));
    }
  }

  Future<bool> _getProjectPermissions(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final projectDoc =
          await firestore.collection('projects').doc(projectId).get();
      final permissions =
          projectDoc.data()?['permissions'] as List<dynamic>? ?? [];
      return permissions.contains(user?.email ?? '');
    } catch (e) {
      return false;
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
            'userColor': user['userColor'],
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

  Future<void> _onRemoveProjectMember(
      RemoveProjectMember event, Emitter<ProjectState> emit) async {
    try {
      final projectRef = firestore.collection('projects').doc(event.projectId);

      await projectRef.update({
        'members': FieldValue.arrayRemove([event.userEmail]),
        'permissions': FieldValue.arrayRemove([event.userEmail]),
      });
      final user = FirebaseAuth.instance.currentUser;

      logProjectActivity(
          event.projectId, 'remove', user?.email ?? '', event.userEmail);

      final tasksSnapshot = await projectRef.collection('tasks').get();
      for (var taskDoc in tasksSnapshot.docs) {
        final taskData = taskDoc.data();
        if (taskData['assignee'] == event.userEmail) {
          await taskDoc.reference.update({'assignee': ""});
        }

        final subtasksSnapshot =
            await taskDoc.reference.collection('subtasks').get();
        for (var subtaskDoc in subtasksSnapshot.docs) {
          final subtaskData = subtaskDoc.data();
          if (subtaskData['assignee'] == event.userEmail) {
            await subtaskDoc.reference.update({'assignee': ""});
          }

          final subsubtasksSnapshot =
              await subtaskDoc.reference.collection('subsubtasks').get();
          for (var subsubtaskDoc in subsubtasksSnapshot.docs) {
            final subsubtaskData = subsubtaskDoc.data();
            if (subsubtaskData['assignee'] == event.userEmail) {
              await subsubtaskDoc.reference.update({'assignee': ""});
            }
          }
        }
      }

      add(LoadProjectMembers(event.projectId));
    } catch (e) {
      emit(ProjectError("Failed to remove project member: $e"));
    }
  }

  Future<void> _onLoadProjectPermissions(
      LoadProjectPermissions event, Emitter<ProjectState> emit) async {
    try {
      final projectDoc =
          await firestore.collection('projects').doc(event.projectId).get();
      final permissions =
          projectDoc.data()?['permissions'] as List<dynamic>? ?? [];

      if (permissions.contains(event.userEmail)) {
        emit(ProjectPermissionLoaded(canEdit: true));
      } else {
        emit(ProjectPermissionLoaded(canEdit: false));
      }
    } catch (e) {
      emit(ProjectError('Failed to load project permissions: $e'));
    }
  }

  Future<void> _onUpdateProject(
      UpdateProject event, Emitter<ProjectState> emit) async {
    try {
      await firestore
          .collection('projects')
          .doc(event.projectId)
          .update({'name': event.projectName});
      emit(ProjectUpdated(event.projectId, event.projectName));
      add(LoadProjectsEvent());
    } catch (e) {
      emit(ProjectError("Failed to update project: $e"));
    }
  }

  Future<void> _onDeleteProject(
      DeleteProject event, Emitter<ProjectState> emit) async {
    try {
      await firestore.collection('projects').doc(event.projectId).delete();
      emit(ProjectDeleted(event.projectId));
      add(LoadProjectsEvent());
    } catch (e) {
      emit(ProjectError("Failed to delete project: $e"));
    }
  }

  Future<void> logProjectActivity(
      String projectId, String action, String actor, String target) async {
    final projectActivitiesCollection =
        FirebaseFirestore.instance.collection('project_activities');

    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('HH:mm, dd-MM-yyyy').format(now);

      await projectActivitiesCollection.add({
        'projectId': projectId,
        'action': action,
        'actor': actor,
        'target': target,
        'timestamp': formattedDate,
      });
    } catch (e) {
      print('Failed to log activity: $e');
    }
  }
}
