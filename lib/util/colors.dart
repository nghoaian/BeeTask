import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4254FE);
  static const secondary = Color(0xFF691FDC);
  static const accent = Color(0xff281537);
  static const white = Colors.white;
  static const black = Colors.black;
  static const grey = Colors.grey;
  static const error = Colors.red;
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
