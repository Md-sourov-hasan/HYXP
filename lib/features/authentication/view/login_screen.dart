import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/login_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildLoginHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 32.h),
                      _buildEmailField(context, controller),
                      SizedBox(height: 24.h),
                      _buildPasswordField(context, controller),
                      SizedBox(height: 12.h),
                      _buildForgotPasswordButton(controller),
                      SizedBox(height: 32.h),
                      _buildSocialLoginSection(context, controller),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginHeader(BuildContext context) {
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
              'Log in',
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

  Widget _buildEmailField(BuildContext context, LoginController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(icon: Icons.mail_outline_rounded, label: 'Email'),
        SizedBox(height: 10.h),
        _buildAppTextField(
          context: context,
          controller: controller.emailController,
          hintText: 'exampleemail@gmail.com',
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, LoginController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(icon: Icons.lock_outline_rounded, label: 'Password'),
        SizedBox(height: 10.h),
        Obx(
          () => _buildAppTextField(
            context: context,
            controller: controller.passwordController,
            hintText: '••••••••',
            obscureText: !controller.isPasswordVisible.value,
            validator: controller.validatePassword,
            suffixIcon: GestureDetector(
              onTap: controller.togglePasswordVisibility,
              child: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton(LoginController controller) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: controller.onForgotPassword,
        child: Text(
          'Forget Password?',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF007A7A),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection(BuildContext context, LoginController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Or sign in with',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        SizedBox(height: 24.h),
        _buildSocialButton(
          context: context,
          label: 'Continue with Apple',
          icon: Icons.apple_rounded,
          isLoading: controller.isAppleLoading,
          onTap: controller.onAppleLogin,
          isIcon: true,
        ),
        SizedBox(height: 16.h),
        _buildSocialButton(
          context: context,
          label: 'Continue with Google',
          iconPath: 'assets/icons/google.png',
          isLoading: controller.isGoogleLoading,
          onTap: controller.onGoogleLogin,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String label,
    IconData? icon,
    String? iconPath,
    required RxBool isLoading,
    required VoidCallback onTap,
    bool isIcon = false,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: isLoading.value ? null : onTap,
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isLoading.value
              ? SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isIcon && icon != null)
                      Icon(icon, size: 24.r, color: AppColors.blackColor)
                    else if (iconPath != null)
                      Image.asset(
                        iconPath,
                        width: 24.r,
                        height: 24.r,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.g_mobiledata_rounded, size: 24.r),
                      ),
                    SizedBox(width: 12.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(LoginController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      child: Column(
        children: [
          _buildLoginButton(controller),
          SizedBox(height: 16.h),
          _buildSignUpRow(controller),
        ],
      ),
    );
  }

  Widget _buildLoginButton(LoginController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: 'Log in',
        onTap: controller.onLogin,
        isLoading: controller.isLoading.value,
        borderRadius: 16,
      ),
    );
  }

  Widget _buildSignUpRow(LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 14.sp, color: AppColors.blackColor),
        ),
        GestureDetector(
          onTap: controller.onSignUp,
          child: Text(
            'Sign up',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.blackColor),
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

  Widget _buildAppTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14.sp, color: AppColors.blackColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
}
