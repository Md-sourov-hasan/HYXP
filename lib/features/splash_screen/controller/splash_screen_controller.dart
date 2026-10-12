import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_session_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class SplashScreenController extends GetxController {
  final AuthSessionService _authSessionService = AuthSessionService();
  bool _isCompletingStartup = false;

  @override
  void onInit() {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void onAnimationComplete() {
    if (_isCompletingStartup) return;
    _isCompletingStartup = true;
    debugPrint('Splash animation complete: starting auto-login check');

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _completeStartup();
  }

  Future<void> _completeStartup() async {
    if (!StorageService.hasRefreshToken) {
      debugPrint(
        'Auto login: no saved refresh token, navigating to auth options',
      );
      Get.offAllNamed(AppRoute.getAuthOptionsScreen());
      return;
    }

    debugPrint('Auto login: refresh token found, navigating directly to home');
    Get.offAllNamed(AppRoute.getBottomNavigationScreen());
    unawaited(_refreshSessionInBackground());
  }

  Future<void> _refreshSessionInBackground() async {
    try {
      debugPrint('Auto login: refreshing session silently with verify-token');
      final tokens = await _authSessionService.verifyToken();
      final saved = await StorageService.saveAuthSession(tokens);
      if (!saved) {
        throw StateError('Verify token response did not include valid tokens');
      }
      debugPrint('Auto login: background token refresh completed');
    } catch (error) {
      debugPrint('Auto login background refresh failed: $error');
    }
  }

  @override
  void onClose() {
    // Ensure system UI is restored if the controller is disposed
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.onClose();
  }
}
