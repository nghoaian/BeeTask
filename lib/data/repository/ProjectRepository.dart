import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProjectRepository {
  Future<String?> getProjectName(String projectId);
}

class FirebaseProjectRepository implements ProjectRepository {
  final FirebaseFirestore firestore;

  FirebaseProjectRepository({required this.firestore});

  @override
  Future<String?> getProjectName(String projectId) async {
    try {
      DocumentSnapshot projectDoc = await firestore
          .collection('projects')
          .doc(projectId)
          .get();
      return projectDoc['name'] as String?;
    } catch (e) {
      print('Error fetching project name: $e');
      return null;
    }
  }
}