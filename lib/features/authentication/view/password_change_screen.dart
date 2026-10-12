import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/password_change_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildChangePasswordHeader(context, controller),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 32.h),
                      Obx(
                        () => controller.isProfileChangeFlow
                            ? Column(
                                children: [
                                  _buildOldPasswordField(context, controller),
                                  SizedBox(height: 24.h),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      _buildPasswordField(context, controller),
                      SizedBox(height: 24.h),
                      _buildConfirmPasswordField(context, controller),
                    ],
                  ),
                ),
              ),
            ),
            _buildChangePasswordButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordHeader(
    BuildContext context,
    ChangePasswordController controller,
  ) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.chevron_left,
                  size: 28.sp,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            Obx(
              () => Text(
                controller.isProfileChangeFlow
                    ? 'Change password'
                    : 'Reset password',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Divider(color: Theme.of(context).dividerColor, thickness: 1),
      ],
    );
  }

  Widget _buildOldPasswordField(
    BuildContext context,
    ChangePasswordController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label: 'Current Password'),
        SizedBox(height: 10.h),
        Obx(
          () => _buildPasswordTextField(
            context,
            textController: controller.oldPasswordController,
            isVisible: controller.isOldPasswordVisible.value,
            onToggle: controller.toggleOldPasswordVisibility,
            validator: controller.validateOldPassword,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    ChangePasswordController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => _buildFieldLabel(
            label: controller.isProfileChangeFlow
                ? 'New Password'
                : 'Password',
          ),
        ),
        SizedBox(height: 10.h),
        Obx(
          () => _buildPasswordTextField(
            context,
            textController: controller.passwordController,
            isVisible: controller.isPasswordVisible.value,
            onToggle: controller.togglePasswordVisibility,
            validator: controller.validatePassword,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(
    BuildContext context,
    ChangePasswordController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label: 'Confirm Password'),
        SizedBox(height: 10.h),
        Obx(
          () => _buildPasswordTextField(
            context,
            textController: controller.confirmPasswordController,
            isVisible: controller.isConfirmPasswordVisible.value,
            onToggle: controller.toggleConfirmPasswordVisibility,
            validator: controller.validateConfirmPassword,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel({required String label}) {
    return Row(
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 20.sp,
          color: AppColors.blackColor,
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTextField(
    BuildContext context, {
    required TextEditingController textController,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: textController,
      obscureText: !isVisible,
      validator: validator,
      style: TextStyle(fontSize: 14.sp, color: AppColors.blackColor),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20.sp,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildChangePasswordButton(ChangePasswordController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: controller.isProfileChangeFlow
            ? 'Change password'
            : 'Reset password',
        onTap: controller.onChangePassword,
        isLoading: controller.isLoading.value,
        borderRadius: 16,
        margin: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      ),
    );
  }
}
