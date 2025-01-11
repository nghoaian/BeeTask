// import 'package:cloud_firestore/cloud_firestore.dart';

// class Project {
//   final String id;
//   final String name;
//   final String description;

//   Project({required this.id, required this.name, required this.description});

//   factory Project.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return Project(
//       id: doc.id,
//       name: doc['name'] ?? '',
//       description: doc['description'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'description': description,
//     };
//   }
// }
