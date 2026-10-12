import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/splash_screen_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SplashScreenController>()
        ? Get.find<SplashScreenController>()
        : Get.put(SplashScreenController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1300),
                curve: Curves.easeInOutQuart,
                onEnd: controller.onAnimationComplete,
                builder: (context, value, child) {
                  final screenWidth = MediaQuery.sizeOf(context).width;
                  final imageSize = 170.w;
                  final exitDistance = (screenWidth / 2) + (imageSize / 2);

                  return Transform.translate(
                    offset: Offset(exitDistance * value, 0),
                    child: child,
                  );
                },
                child: RepaintBoundary(
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 170.w,
                    height: 170.w,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Text
          Positioned(
            left: 0,
            right: 0,
            bottom: 50.h,
            child: Center(
              child: Text(
                'by Ventyy Company',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
