import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/password_change_complete.dart';

class PasswordChangeCompleteScreen extends StatelessWidget {
  const PasswordChangeCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PasswordChangeCompleteController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _buildSuccessCard(context),
            SizedBox(height: 40.h),
            _buildBackToLoginButton(controller),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 52.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _CheckCircle(),
            SizedBox(height: 28.h),
            _buildSuccessTitle(),
            SizedBox(height: 10.h),
            _buildSuccessSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessTitle() {
    return Text(
      'Password Changed !',
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.blackColor,
      ),
    );
  }

  Widget _buildSuccessSubtitle() {
    return Text(
      'Your password has been changed successfully .',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        color: Colors.grey.shade500,
        height: 1.5,
      ),
    );
  }

  Widget _buildBackToLoginButton(PasswordChangeCompleteController controller) {
    return GestureDetector(
      onTap: controller.onBackToLogin,
      child: Text(
        'Back to Login',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

class _CheckCircle extends StatefulWidget {
  const _CheckCircle();

  @override
  State<_CheckCircle> createState() => _CheckCircleState();
}

class _CheckCircleState extends State<_CheckCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  static const _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 110.w,
        height: 110.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _green, width: 2.5),
          color: Theme.of(context).cardColor,
        ),
        child: Center(
          child: Icon(Icons.check, color: _green, size: 48.sp),
        ),
      ),
    );
  }
}
