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
      case 'Cao':
        return Colors.red;
      case 'Trung bình':
        return Colors.orange;
      case 'Thấp':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
