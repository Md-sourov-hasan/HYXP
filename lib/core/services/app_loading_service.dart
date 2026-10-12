import 'package:flutter_easyloading/flutter_easyloading.dart';

class AppLoadingService {
  AppLoadingService._();

  static void showSuccess(String title, String message) {
    EasyLoading.showSuccess(_formatMessage(title, message));
  }

  static void showError(String title, String message) {
    EasyLoading.showError(_formatMessage(title, message));
  }

  static void showInfo(String title, String message) {
    EasyLoading.showToast(_formatMessage(title, message));
  }

  static String _formatMessage(String title, String message) {
    final cleanTitle = title.trim();
    final cleanMessage = message.trim();

    if (cleanTitle.isEmpty) return cleanMessage;
    if (cleanMessage.isEmpty) return cleanTitle;

    return '$cleanTitle\n$cleanMessage';
  }
}
