import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/model/verify_email_request.dart';
import 'package:hawiisaac/features/authentication/model/verify_reset_otp_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/verify_email_service.dart';
import 'package:hawiisaac/features/authentication/services/verify_reset_otp_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class VerificationController extends GetxController {
  static const int otpLength = 6;

  final VerifyEmailService _verifyEmailService = VerifyEmailService();
  final VerifyResetOtpService _verifyResetOtpService = VerifyResetOtpService();

  // One controller + focusNode per OTP box
  final List<TextEditingController> controllers = List.generate(
    otpLength,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(
    otpLength,
    (_) => FocusNode(),
  );

  final RxBool isLoading = false.obs;
  final RxString flow = 'forgot_password'.obs;
  final RxString purpose = 'forgot_password'.obs;
  final RxString email = ''.obs;
  final RxString username = ''.obs;
  final RxString password = ''.obs;
  final RxString gender = ''.obs;
  final RxString dob = ''.obs;
  final RxString sessionKey = ''.obs;

  // Reactive list to track each digit for border color
  final RxList<String> otpDigits = List.generate(otpLength, (_) => '').obs;

  bool get isSignupFlow => flow.value == 'signup';

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      flow.value = arguments['flow']?.toString() ?? 'forgot_password';
      purpose.value = arguments['purpose']?.toString() ?? 'forgot_password';
      email.value = arguments['email']?.toString() ?? '';
      username.value = arguments['username']?.toString() ?? '';
      password.value = arguments['password']?.toString() ?? '';
      gender.value = arguments['gender']?.toString() ?? '';
      dob.value = arguments['dob']?.toString() ?? '';
      debugPrint(
        'Verification init: flow=${flow.value}, email=${email.value}, '
        'username=${username.value}, gender=${gender.value}, dob=${dob.value}',
      );
    }
  }

  @override
  void onClose() {
    for (int i = 0; i < otpLength; i++) {
      controllers[i].dispose();
      focusNodes[i].dispose();
    }
    super.onClose();
  }

  void onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      otpDigits[index] = value;
      // Move forward
      if (index < otpLength - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    } else {
      otpDigits[index] = '';
    }
  }

  void onKeyboardTap(String value, int index) {
    // Handle backspace — move back
    if (value.isEmpty && index > 0) {
      controllers[index].clear();
      otpDigits[index] = '';
      focusNodes[index - 1].requestFocus();
    }
  }

  bool get isOtpComplete => otpDigits.every((digit) => digit.isNotEmpty);

  String get fullOtp => otpDigits.join();

  Future<void> onVerify() async {
    if (!isOtpComplete) {
      AppLoadingService.showError('Incomplete', 'Please enter all 6 digits');
      return;
    }

    isLoading.value = true;

    try {
      if (isSignupFlow) {
        debugPrint(
          'Signup email verification started: email=${email.value}, code=$fullOtp',
        );
        final response = await _verifyEmailService.verifyEmail(
          VerifyEmailRequest(email: email.value, code: fullOtp),
        );

        Get.offAllNamed(AppRoute.getLoginScreen());
        AppLoadingService.showSuccess(
          'Verified',
          response.message.isNotEmpty
              ? response.message
              : 'Email verified successfully.',
        );
      } else {
        debugPrint(
          'Password reset OTP verification started: email=${email.value}, code=$fullOtp',
        );
        final response = await _verifyResetOtpService.verifyResetOtp(
          VerifyResetOtpRequest(
            email: email.value,
            code: fullOtp,
          ),
        );

        Get.toNamed(
          AppRoute.changepasswordScreen,
          arguments: <String, dynamic>{
            'flow': 'forgot_password',
            'email': email.value,
            'code': fullOtp,
          },
        );
        AppLoadingService.showSuccess(
          'Verified',
          response.message.isNotEmpty
              ? response.message
              : 'OTP verified successfully.',
        );
      }
    } on AuthException catch (error) {
      debugPrint('Verification failed: ${error.message}');
      AppLoadingService.showError('Verification Failed', error.message);
    } catch (_) {
      debugPrint('Verification failed: unexpected error');
      AppLoadingService.showError(
        'Verification Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
