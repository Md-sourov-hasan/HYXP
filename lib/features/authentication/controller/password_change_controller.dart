import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/model/change_password_request.dart';
import 'package:hawiisaac/features/authentication/model/forgot_password_reset_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/change_password_service.dart';
import 'package:hawiisaac/features/authentication/services/reset_password_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class ChangePasswordController extends GetxController {
  final ResetPasswordService _resetPasswordService = ResetPasswordService();
  final ChangePasswordService _changePasswordService = ChangePasswordService();

  final oldPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxString flow = 'forgot_password'.obs;
  final RxString email = ''.obs;
  final RxString code = ''.obs;

  final RxBool isOldPasswordVisible = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  bool get isProfileChangeFlow => flow.value == 'profile_change';

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      flow.value = arguments['flow']?.toString() ?? 'forgot_password';
      email.value = arguments['email']?.toString() ?? '';
      code.value =
          arguments['code']?.toString() ??
          arguments['sessionKey']?.toString() ??
          '';
      debugPrint(
        'ChangePasswordController init: flow=${flow.value}, email=${email.value}, code=${code.value}',
      );
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleOldPasswordVisibility() =>
      isOldPasswordVisible.value = !isOldPasswordVisible.value;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateOldPassword(String? value) {
    if (!isProfileChangeFlow) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> onChangePassword() async {
    if (!formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      if (isProfileChangeFlow) {
        final response = await _changePasswordService.changePassword(
          ChangePasswordRequest(
            oldPassword: oldPasswordController.text,
            newPassword: passwordController.text,
            confirmPassword: confirmPasswordController.text,
          ),
        );

        Get.back();
        AppLoadingService.showSuccess(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'Password changed successfully.',
        );
      } else {
        final response = await _resetPasswordService.resetPasswordWithCode(
          ForgotPasswordResetRequest(
            email: email.value,
            code: code.value,
            password: passwordController.text,
            confirmPassword: confirmPasswordController.text,
          ),
        );

        Get.offAllNamed(AppRoute.changepasswordCompleteScreen);
        AppLoadingService.showSuccess(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'Password reset successfully.',
        );
      }
    } on AuthException catch (error) {
      AppLoadingService.showError('Password Update Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Password Update Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
