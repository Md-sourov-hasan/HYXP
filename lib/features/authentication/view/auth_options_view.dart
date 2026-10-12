import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/auth_options_controller.dart';

class AuthOptionsView extends StatelessWidget {
  const AuthOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthOptionsController controller = Get.put<AuthOptionsController>(
      AuthOptionsController(),
    );
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildHeader(context, controller)),
            _buildAuthButtons(context, controller),
            SizedBox(height: 24.h),
            _buildFooter(context, controller),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthOptionsController controller) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 220.w,
          height: 120.h,
          child: ClipRect(
            child: Transform.scale(
              scale: 1.95,
              child: Image.asset(
                'assets/icons/app_icon.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      controller.logoText.value,
                      style: TextStyle(
                        fontSize: 64.sp,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? Colors.white : Colors.black,
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 0.h),
        Obx(
          () => Text(
            controller.tagline.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? Colors.white : Colors.black,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons(
    BuildContext context,
    AuthOptionsController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          _buildAppleButton(context, controller),
          SizedBox(height: 14.h),
          _buildGoogleButton(context, controller),
          SizedBox(height: 14.h),
          _buildEmailButton(context, controller),
        ],
      ),
    );
  }

  Widget _buttonContainer(
    BuildContext context, {
    required Widget child,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildAppleButton(
    BuildContext context,
    AuthOptionsController controller,
  ) {
    final foregroundColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);

    return Obx(
      () => _buttonContainer(
        context,
        onTap: controller.isAppleLoading.value
            ? null
            : controller.onAppleSignUpTapped,
        child: controller.isAppleLoading.value
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apple_rounded,
                    size: 24.r,
                    color: foregroundColor,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    controller.appleButtonText.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleButton(
    BuildContext context,
    AuthOptionsController controller,
  ) {
    final foregroundColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);

    return Obx(
      () => _buttonContainer(
        context,
        onTap: controller.isGoogleLoading.value
            ? null
            : controller.onGoogleSignUpTapped,
        child: controller.isGoogleLoading.value
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/google.png',
                    width: 24.r,
                    height: 24.r,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.g_mobiledata_rounded,
                      size: 24.r,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    controller.googleButtonText.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmailButton(
    BuildContext context,
    AuthOptionsController controller,
  ) {
    final foregroundColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);

    return Obx(
      () => _buttonContainer(
        context,
        onTap: controller.isEmailLoading.value
            ? null
            : controller.onEmailSignUpTapped,
        child: controller.isEmailLoading.value
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 24.r,
                    color: foregroundColor,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    controller.emailButtonText.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AuthOptionsController controller) {
    final Color footerTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.blackColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(
          () => Text(
            controller.footerText.value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: footerTextColor,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: controller.onLogInTapped,
          child: Obx(
            () => Text(
              controller.loginLinkText.value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00D9FF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
