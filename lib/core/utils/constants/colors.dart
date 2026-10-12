import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primaryColor = Color(0xff00E5FF);

  static Color get secondaryColor =>
      Get.isDarkMode ? const Color(0xffEAEAEA) : const Color(0xff1A1A1A);
  static Color get blackColor =>
      Get.isDarkMode ? const Color(0xffFFFFFF) : const Color(0xff1A1A1A);
  static Color get whiteColor =>
      Get.isDarkMode ? const Color(0xff1A1A1A) : const Color(0xffFFFFFF);

  // Background/Surface Colors
  static const Color greyColor = Color(0xffF5F5F5);
  static const Color darkButtonColor = Color(0xFF00464F);

  // Static Constants (for const themes)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color red = Color(0xFFF44336);
  static const Color orange = Color(0xFFFF9800);
}
