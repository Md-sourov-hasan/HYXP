import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/logout_service.dart';
import 'package:hawiisaac/features/profile/model/current_user.dart';
import 'package:hawiisaac/features/profile/services/current_user_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class ProfileController extends GetxController {
  final CurrentUserService _currentUserService = CurrentUserService();
  final LogoutService _logoutService = LogoutService();

  late final RxBool isDarkMode = _initialDarkMode.obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeletingAccount = false.obs;
  final RxString userName = ''.obs;
  final RxString email = ''.obs;
  final RxString photo = ''.obs;
  final Rxn<CurrentUser> currentUser = Rxn<CurrentUser>();

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    final themeMode = value ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode);
    StorageService.saveThemeMode(themeMode);
  }

  Future<void> fetchCurrentUser() async {
    isLoading.value = true;

    try {
      final user = await _currentUserService.getProfile();
      currentUser.value = user;
      userName.value = user.displayName;
      email.value = user.email;
      photo.value = user.effectivePhoto;
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void onProfileTap() {
    Get.toNamed(AppRoute.editProfileScreen);
  }

  void onAccountTap() {
    Get.toNamed(
      AppRoute.getChangepasswordScreen(),
      arguments: <String, dynamic>{'flow': 'profile_change'},
    );
  }

  void onPrivacyTap() {
    Get.toNamed(AppRoute.getPrivacyPolicyScreen());
  }

  void onThemeTap() {
    // TODO: Navigate to theme screen
  }

  void onGetPremiumTap() {
    Get.toNamed(AppRoute.getPremiumScreen());
  }

  void onBack() {
    Get.back();
  }

  Future<void> onLogout() async {
    isLoading.value = true;
    try {
      final response = await _logoutService.logout();
      debugPrint('Logout API successful: ${response.message}');
    } catch (error) {
      debugPrint('Logout API error (proceeding with local session cleanup): $error');
    } finally {
      await StorageService.clearAuthSession();
      isLoading.value = false;
      Get.offAllNamed(AppRoute.getLoginScreen());
      AppLoadingService.showSuccess('Log Out', 'Logged out successfully.');
    }
  }

  Future<void> onDeleteAccount() async {
    if (isDeletingAccount.value) return;

    final userId = currentUser.value?.id ?? '';
    if (userId.isEmpty) {
      AppLoadingService.showError(
        'Delete Account Failed',
        'Profile is not ready yet. Please try again.',
      );
      return;
    }

    isDeletingAccount.value = true;
    try {
      final message = await _currentUserService.deleteUser(userId);
      await StorageService.clearAuthSession();
      AppLoadingService.showSuccess('Delete Account', message);
      Get.offAllNamed(AppRoute.getLoginScreen());
    } on AuthException catch (error) {
      AppLoadingService.showError('Delete Account Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Delete Account Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

  void _showError(String message) {
    AppLoadingService.showError('Profile Failed', message);
  }

  bool get _initialDarkMode {
    return switch (StorageService.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => Get.isDarkMode,
    };
  }
}
