import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/sign_up_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.put<SignUpController>(
      SignUpController(),
    );

    return Scaffold(
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                _buildEmailField(context, controller),
                SizedBox(height: 20.h),
                _buildPasswordField(context, controller),
                SizedBox(height: 20.h),
                _buildUsernameField(context, controller),
                SizedBox(height: 20.h),
                _buildGenderField(context, controller),
                SizedBox(height: 20.h),
                _buildDateOfBirthFields(context, controller),
                SizedBox(height: 24.h),
                _buildTermsCheckbox(context, controller),
                SizedBox(height: 40.h),
                _buildContinueButton(controller),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: AppBar
  // ─────────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    SignUpController controller,
  ) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.blackColor,
          size: 24.r,
        ),
        onPressed: controller.onBackTapped,
      ),
      centerTitle: true,
      title: Obx(
        () => Text(
          controller.appBarTitle.value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Email Field
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEmailField(BuildContext context, SignUpController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: Icons.mail_outline_rounded,
          label: controller.emailLabel.value,
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.emailController,
          validator: controller.validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 15.sp, color: AppColors.blackColor),
          decoration: _buildInputDecoration(
            context,
            hintText: 'exampleemail@gmail.com',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Password Field
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildPasswordField(
    BuildContext context,
    SignUpController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: Icons.lock_outline_rounded,
          label: controller.passwordLabel.value,
        ),
        SizedBox(height: 8.h),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            validator: controller.validatePassword,
            obscureText: controller.isPasswordObscured.value,
            textInputAction: TextInputAction.next,
            style: TextStyle(fontSize: 15.sp, color: AppColors.blackColor),
            decoration: _buildInputDecoration(
              context,
              hintText: '********',
              suffixIcon: GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: Icon(
                  controller.isPasswordObscured.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20.r,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Username Field
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildUsernameField(
    BuildContext context,
    SignUpController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: Icons.person_outline_rounded,
          label: controller.usernameLabel.value,
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.usernameController,
          validator: controller.validateUsername,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 15.sp, color: AppColors.blackColor),
          decoration: _buildInputDecoration(context, hintText: 'tahmiddipu'),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Gender Selection
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildGenderField(BuildContext context, SignUpController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: Icons.person_outline_rounded,
          label: controller.genderLabel.value,
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildGenderButton(
                  context,
                  label: 'Male',
                  isSelected: controller.selectedGender.value == 'Male',
                  onTap: () => controller.setGender('Male'),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(
                () => _buildGenderButton(
                  context,
                  label: 'Female',
                  isSelected: controller.selectedGender.value == 'Female',
                  onTap: () => controller.setGender('Female'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).dividerColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : AppColors.blackColor,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Date of Birth Fields
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildDateOfBirthFields(
    BuildContext context,
    SignUpController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: Icons.calendar_today_outlined,
          label: controller.dobLabel.value,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // ── Month ──────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.monthLabel.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: controller.monthController,
                    validator: controller.validateMonth,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.blackColor,
                    ),
                    decoration: _buildInputDecoration(context, hintText: '03'),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // ── Date ───────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.dateLabel.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: controller.dateController,
                    validator: controller.validateDate,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.blackColor,
                    ),
                    decoration: _buildInputDecoration(context, hintText: '17'),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // ── Year ───────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.yearLabel.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: controller.yearController,
                    validator: controller.validateYear,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.blackColor,
                    ),
                    decoration: _buildInputDecoration(
                      context,
                      hintText: '2000',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Terms Checkbox
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildTermsCheckbox(
    BuildContext context,
    SignUpController controller,
  ) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: Checkbox(
              value: controller.isTermsAccepted.value,
              onChanged: controller.toggleTermsAccepted,
              activeColor: AppColors.primaryColor,
              side: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1.5.w,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              controller.termsText.value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Continue Button
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildContinueButton(SignUpController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: controller.buttonText.value,
        isLoading: controller.isLoading.value,
        onTap: controller.onContinueTapped,
      ),
    );
  }
  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER: Field Label
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFieldLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.blackColor),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER: Input Decoration
  // ─────────────────────────────────────────────────────────────────────────────

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 15.sp,
        color: const Color(0xFF9CA3AF),
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: suffixIcon,
            )
          : null,
      suffixIconConstraints: BoxConstraints(minWidth: 44.w),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.red, width: 1.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
      ),
      errorStyle: TextStyle(fontSize: 12.sp, color: AppColors.red),
    );
  }
}
