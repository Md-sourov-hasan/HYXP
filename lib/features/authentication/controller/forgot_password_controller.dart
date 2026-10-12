import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/forgot_password_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class ForgetPasswordController extends GetxController {
  final ForgotPasswordService _forgotPasswordService = ForgotPasswordService();

  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> onNext() async {
    if (!formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final response = await _forgotPasswordService.sendForgotPasswordCode(
        emailController.text.trim(),
      );

      Get.toNamed(
        AppRoute.verificationScreen,
        arguments: <String, dynamic>{
          'flow': 'forgot_password',
          'purpose': 'forgot_password',
          'email': emailController.text.trim(),
        },
      );
      AppLoadingService.showSuccess(
        'Code Sent',
        response.message.isNotEmpty
            ? response.message
            : 'If this email exists, a code has been sent.',
      );
    } on AuthException catch (error) {
      AppLoadingService.showError('Request Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Request Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
