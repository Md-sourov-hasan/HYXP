import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/google_auth_debug_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class AuthOptionsController extends GetxController {
  final GoogleAuthDebugService _googleAuthDebugService =
      GoogleAuthDebugService();

  // ─── Observable State ───────────────────────────────────────────────────────
  final RxBool isAppleLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isEmailLoading = false.obs;

  // ─── Screen Content ─────────────────────────────────────────────────────────
  final RxString logoText = 'HYKX'.obs;
  final RxString tagline = 'Scan. Learn. Train. Track Your Progress.'.obs;
  final RxString appleButtonText = 'Sign up with Apple'.obs;
  final RxString googleButtonText = 'Sign up with Google'.obs;
  final RxString emailButtonText = 'Sign up with Email'.obs;
  final RxString footerText = 'Already have an account?'.obs;
  final RxString loginLinkText = 'Log in'.obs;

  // ─── Methods ────────────────────────────────────────────────────────────────

  /// Handles Apple sign up
  Future<void> onAppleSignUpTapped() async {
    isAppleLoading.value = true;

    // Simulated API call
    await Future.delayed(const Duration(milliseconds: 1200));

    isAppleLoading.value = false;

    AppLoadingService.showInfo(
      'Apple Sign Up',
      'Apple authentication initiated.',
    );

    // TODO: Navigate to next screen or handle Apple auth
  }

  /// Handles Google sign up
  Future<void> onGoogleSignUpTapped() async {
    isGoogleLoading.value = true;
    try {
      final result = await _googleAuthDebugService.signInAndLoginToBackend();
      final saved = await StorageService.saveAuthSession(result.authSession);
      if (!saved) {
        throw const AuthException(
          message: 'Google login response did not include valid tokens.',
          statusCode: 0,
        );
      }

      if (StorageService.hasSelectedUnits) {
        Get.offAllNamed(AppRoute.getBottomNavigationScreen());
      } else {
        Get.offAllNamed(AppRoute.getSelectUnitsScreen());
      }
      AppLoadingService.showSuccess(
        'Google Sign In',
        'Signed in successfully for ${result.email}',
      );
    } on AuthException catch (error) {
      debugPrint('Google Sign Up Failed [AuthException]: ${error.message}');
      AppLoadingService.showError('Google Sign Up Failed', error.message);
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Google Sign Up Failed [FirebaseAuthException]: '
        '${error.code} ${error.message}',
      );
      AppLoadingService.showError(
        'Google Sign Up Failed',
        error.message ?? 'Firebase auth failed.',
      );
    } on GoogleSignInException catch (error) {
      debugPrint(
        'Google Sign Up Failed [GoogleSignInException]: '
        '${error.code.name} ${error.description}',
      );
      AppLoadingService.showError(
        'Google Sign Up Failed',
        error.description ?? error.code.name,
      );
    } catch (error) {
      debugPrint('Google Sign Up Failed [Unknown]: $error');
      AppLoadingService.showError('Google Sign Up Failed', error.toString());
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// Handles Email sign up
  Future<void> onEmailSignUpTapped() async {
    isEmailLoading.value = true;

    // Simulated delay
    await Future.delayed(const Duration(milliseconds: 800));

    isEmailLoading.value = false;

    Get.toNamed(AppRoute.getSignupScreen());
  }

  /// Handles Log in tap
  void onLogInTapped() {
    Get.toNamed(AppRoute.getLoginScreen());
  }
}
