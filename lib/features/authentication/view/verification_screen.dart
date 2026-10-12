import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/verification_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class VerificationView extends StatelessWidget {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerificationController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _verificationHeader(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),
                    _otpSectionLabel(),
                    SizedBox(height: 20.h),
                    _otpInputRow(controller),
                  ],
                ),
              ),
            ),
            _verifyButton(controller),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────

  Widget _verificationHeader(BuildContext context) {
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
              'Verification',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
        Divider(color: Theme.of(context).dividerColor, thickness: 1),
      ],
    );
  }

  // ─── OTP Section Label ────────────────────────────────────────────

  Widget _otpSectionLabel() {
    return Row(
      children: [
        Image.asset(
          'assets/icons/finger-print-scan.png',
          width: 22.w,
          height: 22.w,
          color: AppColors.blackColor,
        ),
        SizedBox(width: 8.w),
        Text(
          'Enter Verification code',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  // ─── OTP Input Row ────────────────────────────────────────────────

  Widget _otpInputRow(VerificationController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        VerificationController.otpLength,
        (index) => Obx(
          () => _otpBox(
            textController: controller.controllers[index],
            focusNode: controller.focusNodes[index],
            isFilled: controller.otpDigits[index].isNotEmpty,
            onChanged: (val) => controller.onDigitChanged(val, index),
            onBackspace: (val) => controller.onKeyboardTap(val, index),
          ),
        ),
      ),
    );
  }

  // ─── OTP Single Box ───────────────────────────────────────────────

  Widget _otpBox({
    required TextEditingController textController,
    required FocusNode focusNode,
    required bool isFilled,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onBackspace,
  }) {
    return SizedBox(
      width: 52.w,
      height: 60.h,
      child: TextField(
        controller: textController,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.blackColor,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        // Detect backspace on empty field
        onTapOutside: (_) => focusNode.unfocus(),
        decoration: InputDecoration(
          counterText: '',
          filled: false,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color: isFilled ? AppColors.primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  // ─── Verify Button ────────────────────────────────────────────────

  Widget _verifyButton(VerificationController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: 'Verify',
        onTap: controller.onVerify,
        isLoading: controller.isLoading.value,
        borderRadius: 16,
        margin: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      ),
    );
  }
}
