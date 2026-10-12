import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';

class CustomSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? margin;

  const CustomSecondaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.height,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = backgroundColor ?? (isDark ? AppColors.darkButtonColor : AppColors.secondaryColor);
    final buttonTextColor = textColor ?? Colors.white;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: double.infinity,
          height: height ?? 56.h,
          decoration: BoxDecoration(
            color: isLoading ? buttonColor.withValues(alpha: 0.5) : buttonColor,
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: buttonTextColor,
                  ),
                ),
        ),
      ),
    );
  }
}
