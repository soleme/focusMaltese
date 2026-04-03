import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF7F1E7);
  static const glow = Color(0xFFF2E2C9);
  static const surface = Color(0xFFFFFBF5);
  static const textPrimary = Color(0xFF49362A);
  static const textSecondary = Color(0xFF7D6A59);
  static const idle = Color(0xFF97BF8F);
  static const focusing = Color(0xFF8FC3E8);
  static const paused = Color(0xFFA8B0B7);
  static const success = Color(0xFFE6BD5C);
  static const fail = Color(0xFFD58C87);
  static const neutralButton = Color(0xFF8E857C);
  static const shadow = Color(0x1A6F543A);

  static Color accentForStatus(String status) {
    switch (status) {
      case 'focusing':
        return focusing;
      case 'paused':
        return paused;
      case 'success':
        return success;
      case 'fail':
        return fail;
      case 'idle':
      default:
        return idle;
    }
  }
}
