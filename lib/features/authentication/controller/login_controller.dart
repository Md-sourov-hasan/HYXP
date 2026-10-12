import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/login_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/google_auth_debug_service.dart';
import 'package:hawiisaac/features/authentication/services/login_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class LoginController extends GetxController {
  final LoginService _loginService = LoginService();
  final GoogleAuthDebugService _googleAuthDebugService =
      GoogleAuthDebugService();

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Observables
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAppleLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> onLogin() async {
    if (!formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;

    try {
      final response = await _loginService.login(
        LoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
      final saved = await StorageService.saveAuthSession(response);
      if (!saved) {
        throw const AuthException(
          message: 'Login response did not include valid tokens.',
          statusCode: 0,
        );
      }

      if (StorageService.hasSelectedUnits) {
        Get.offAllNamed(AppRoute.getBottomNavigationScreen());
      } else {
        Get.offAllNamed(AppRoute.getSelectUnitsScreen());
      }
      AppLoadingService.showSuccess(
        'Success',
        'Login successful (${response.tokenType})',
      );
    } on AuthException catch (error) {
      final message =
          error.statusCode == 400 ||
              error.statusCode == 401 ||
              error.statusCode == 403
          ? 'Email or password does not match'
          : error.message;

      AppLoadingService.showError('Login Failed', message);
    } catch (_) {
      AppLoadingService.showError(
        'Login Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onAppleLogin() async {
    isAppleLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isAppleLoading.value = false;
    AppLoadingService.showInfo('Apple Login', 'Placeholder logic');
  }

  Future<void> onGoogleLogin() async {
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
        'Google Login',
        'Login successful for ${result.email}',
      );
    } on AuthException catch (error) {
      debugPrint('Google Login Failed [AuthException]: ${error.message}');
      AppLoadingService.showError('Google Login Failed', error.message);
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Google Login Failed [FirebaseAuthException]: '
        '${error.code} ${error.message}',
      );
      AppLoadingService.showError(
        'Google Login Failed',
        error.message ?? 'Firebase auth failed.',
      );
    } on GoogleSignInException catch (error) {
      debugPrint(
        'Google Login Failed [GoogleSignInException]: '
        '${error.code.name} ${error.description}',
      );
      AppLoadingService.showError(
        'Google Login Failed',
        error.description ?? error.code.name,
      );
    } catch (error) {
      debugPrint('Google Login Failed [Unknown]: $error');
      AppLoadingService.showError('Google Login Failed', error.toString());
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void onForgotPassword() {
    // TODO: Navigate to forgot password screen
    Get.toNamed(AppRoute.getForgotPasswordScreen());
    AppLoadingService.showInfo(
      'Forgot Password',
      'Reset link will be sent to your email',
    );
  }

  void onSignUp() {
    Get.toNamed(AppRoute.getSignupScreen());
  }
}
