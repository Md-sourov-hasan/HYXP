import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/model/signup_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/signup_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class SignUpController extends GetxController {
  final SignupService _signupService = SignupService();

  // ─── Text Editing Controllers ───────────────────────────────────────────────
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  // ─── Form Key ───────────────────────────────────────────────────────────────
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ─── Observable State ───────────────────────────────────────────────────────
  final RxBool isPasswordObscured = true.obs;
  final RxBool isTermsAccepted = true.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedGender = 'Male'.obs;

  // ─── Screen Content ─────────────────────────────────────────────────────────
  final RxString appBarTitle = 'Sign up'.obs;
  final RxString emailLabel = 'Email'.obs;
  final RxString passwordLabel = 'Password'.obs;
  final RxString usernameLabel = 'Username'.obs;
  final RxString genderLabel = 'Gender'.obs;
  final RxString dobLabel = 'Date of birth'.obs;
  final RxString monthLabel = 'Month'.obs;
  final RxString dateLabel = 'Date'.obs;
  final RxString yearLabel = 'Year'.obs;
  final RxString termsText =
      "By creating an account, you agree to HYKX's terms & condition and privacy policy."
          .obs;
  final RxString buttonText = 'Continue'.obs;

  // ─── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    monthController.dispose();
    dateController.dispose();
    yearController.dispose();
    super.onClose();
  }

  // ─── Methods ────────────────────────────────────────────────────────────────

  /// Toggles password visibility
  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  /// Toggles terms acceptance checkbox
  void toggleTermsAccepted(bool? value) {
    isTermsAccepted.value = value ?? false;
  }

  /// Sets selected gender
  void setGender(String gender) {
    selectedGender.value = gender;
  }

  /// Handles back button tap
  void onBackTapped() {
    Get.back();
  }

  /// Handles Continue button tap
  Future<void> onContinueTapped() async {
    if (!formKey.currentState!.validate()) return;

    if (!isTermsAccepted.value) {
      AppLoadingService.showError(
        'Terms Required',
        'Please accept the terms and conditions to continue.',
      );

      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    debugPrint(
      'Signup continue tapped: email=${emailController.text.trim()}, '
      'username=${usernameController.text.trim()}, '
      'gender=${selectedGender.value.toLowerCase()}, dob=$formattedDob',
    );

    try {
      final response = await _signupService.signup(
        SignupRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
          username: usernameController.text.trim(),
          gender: selectedGender.value.toLowerCase(),
          dateOfBirth: formattedDob,
        ),
      );
      debugPrint(
        'Signup request successful: email=${emailController.text.trim()}, '
        'message=${response.message}',
      );

      Get.toNamed(
        AppRoute.getVerificationScreen(),
        arguments: <String, dynamic>{
          'flow': 'signup',
          'purpose': 'signup',
          'email': emailController.text.trim(),
          'username': usernameController.text.trim(),
          'password': passwordController.text,
          'gender': selectedGender.value.toLowerCase(),
          'dob': formattedDob,
        },
      );

      AppLoadingService.showSuccess(
        'OTP Sent',
        response.message.isNotEmpty
            ? response.message
            : 'Verification code sent to your email.',
      );
    } on AuthException catch (error) {
      debugPrint('Signup failed: ${error.message}');
      AppLoadingService.showError('Signup Failed', error.message);
    } catch (_) {
      debugPrint('Signup failed: unexpected error');
      AppLoadingService.showError(
        'Signup Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Validators ─────────────────────────────────────────────────────────────

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validateMonth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final month = int.tryParse(value.trim());
    if (month == null || month < 1 || month > 12) {
      return '1-12';
    }
    return null;
  }

  String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final date = int.tryParse(value.trim());
    if (date == null || date < 1 || date > 31) {
      return '1-31';
    }
    return null;
  }

  String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final yearStr = value.trim();
    if (yearStr.length != 4) {
      return '4 digits';
    }
    final year = int.tryParse(yearStr);
    if (year == null || year < 1900 || year > DateTime.now().year) {
      return 'Invalid';
    }
    return null;
  }

  String get formattedDob {
    final rawMonth = int.tryParse(monthController.text.trim());
    final rawDate = int.tryParse(dateController.text.trim());
    final rawYear = int.tryParse(yearController.text.trim());

    if (rawMonth == null || rawDate == null || rawYear == null) {
      return '';
    }

    final monthStr = rawMonth.toString().padLeft(2, '0');
    final dateStr = rawDate.toString().padLeft(2, '0');
    final yearStr = rawYear.toString().padLeft(4, '0');

    return '$yearStr-$monthStr-$dateStr';
  }
}
