import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/forgot_password_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildForgetPasswordHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 32.h),
                      _buildEmailSection(context, controller),
                    ],
                  ),
                ),
              ),
            ),
            _buildNextButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildForgetPasswordHeader(BuildContext context) {
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
            Text(
              'Forget Password',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Divider(color: Theme.of(context).dividerColor, thickness: 1),
      ],
    );
  }

  Widget _buildEmailSection(BuildContext context, ForgetPasswordController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEmailLabel(),
        SizedBox(height: 4.h),
        _buildEmailSubtitle(),
        SizedBox(height: 12.h),
        _buildEmailTextField(context, controller),
      ],
    );
  }

  Widget _buildEmailLabel() {
    return Row(
      children: [
        Icon(
          Icons.mail_outline_rounded,
          size: 20.sp,
          color: AppColors.blackColor,
        ),
        SizedBox(width: 8.w),
        Text(
          'Email',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSubtitle() {
    return Text(
      'We will send a verification code in your email.',
      style: TextStyle(
        fontSize: 13.sp,
        color: Colors.grey.shade600,
        height: 1.4,
      ),
    );
  }

  Widget _buildEmailTextField(BuildContext context, ForgetPasswordController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      validator: controller.validateEmail,
      style: TextStyle(fontSize: 14.sp, color: AppColors.blackColor),
      decoration: InputDecoration(
        hintText: 'exampleemail@gmail.com',
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
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

  Widget _buildNextButton(ForgetPasswordController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: 'Next',
        onTap: controller.onNext,
        isLoading: controller.isLoading.value,
        borderRadius: 16,
        margin: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      ),
    );
  }
}
