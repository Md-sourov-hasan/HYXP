import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigationController extends GetxController {
  final RxInt _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  void changeTab(int index) {
    if (_currentIndex.value != index) {
      _currentIndex.value = index;
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('BottomNavigationController initialized');
  }

  @override
  void onClose() {
    super.onClose();
    debugPrint('BottomNavigationController disposed');
  }
}
