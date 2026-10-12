import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_secondary_button.dart';
import 'package:hawiisaac/features/scan/controller/scan_equipment.dart';

class ScanEquipmentView extends StatefulWidget {
  const ScanEquipmentView({super.key});

  @override
  State<ScanEquipmentView> createState() => _ScanEquipmentViewState();
}

class _ScanEquipmentViewState extends State<ScanEquipmentView>
    with SingleTickerProviderStateMixin {
  late final ScanEquipmentController controller;
  late final AnimationController _animController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ScanEquipmentController());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.08, end: 0.82).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 132.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _scanHeader(),
              _cameraViewport(),
              SizedBox(height: 20.h),
              _detectionModeChips(),
              SizedBox(height: 24.h),
              _modeDescription(),
              SizedBox(height: 28.h),
              _scanButton(),
              SizedBox(height: 14.h),
              _manualButton(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────

  Widget _scanHeader() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: controller.onBackTapped,
                icon: Icon(
                  Icons.chevron_left,
                  size: 28.sp,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            Text(
              'Scan equipment',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Camera Viewport ──────────────────────────────────────────────

  Widget _cameraViewport() {
    return Container(
      width: double.infinity,
      height: 380.h,
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          Obx(() {
            if (controller.isCameraInitialized.value &&
                controller.cameraController != null) {
              return ClipRRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width:
                        controller
                            .cameraController!
                            .value
                            .previewSize
                            ?.height ??
                        1,
                    height:
                        controller.cameraController!.value.previewSize?.width ??
                        1,
                    child: CameraPreview(controller.cameraController!),
                  ),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }),
          // Corner brackets
          _scanCorners(),
          // Scan line animation
          _scanLine(),
          // Bottom hint text
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Obx(
              () => Center(
                child: Text(
                  controller.isProcessingScan.value
                      ? 'Analyzing your equipment...'
                      : 'Hold steady and tap scan',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            if (!controller.isProcessingScan.value) {
              return const SizedBox.shrink();
            }

            return Container(
              color: Colors.black.withValues(alpha: 0.45),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 14.h),
                  Text(
                    'Scanning equipment...',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Scan Corner Brackets ─────────────────────────────────────────

  Widget _scanCorners() {
    const bracketSize = 36.0;
    const strokeWidth = 3.0;

    return Stack(
      children: [
        // Top-left
        Positioned(
          top: 32,
          left: 32,
          child: _cornerBracket(
            topLeft: true,
            size: bracketSize,
            strokeWidth: strokeWidth,
          ),
        ),
        // Top-right
        Positioned(
          top: 32,
          right: 32,
          child: _cornerBracket(
            topRight: true,
            size: bracketSize,
            strokeWidth: strokeWidth,
          ),
        ),
        // Bottom-left
        Positioned(
          bottom: 60,
          left: 32,
          child: _cornerBracket(
            bottomLeft: true,
            size: bracketSize,
            strokeWidth: strokeWidth,
          ),
        ),
        // Bottom-right
        Positioned(
          bottom: 60,
          right: 32,
          child: _cornerBracket(
            bottomRight: true,
            size: bracketSize,
            strokeWidth: strokeWidth,
          ),
        ),
      ],
    );
  }

  // ─── Single Corner Bracket ────────────────────────────────────────

  Widget _cornerBracket({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
    required double size,
    required double strokeWidth,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BracketPainter(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        color: AppColors.primaryColor,
        strokeWidth: strokeWidth,
      ),
    );
  }

  // ─── Animated Scan Line ───────────────────────────────────────────

  Widget _scanLine() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Positioned(
        top: 380.h * _animation.value,
        left: 32.w,
        right: 32.w,
        child: Container(
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primaryColor.withValues(alpha: 0.8),
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Detection Mode Chips ─────────────────────────────────────────

  Widget _detectionModeChips() {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: controller.detectionModes.asMap().entries.map((entry) {
            final isSelected = entry.key == controller.selectedModeIndex.value;
            return Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: GestureDetector(
                onTap: () => controller.onModeSelected(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 10.h,
                  ),
                  // Keep the original dark-mode treatment while using
                  // white/primary accents in light mode.
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkButtonColor
                              : AppColors.primaryColor)
                        : (Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).cardColor
                              : AppColors.white),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkButtonColor
                                : AppColors.primaryColor)
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Mode Description ─────────────────────────────────────────────

  Widget _modeDescription() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.modeTitle,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.modeSubtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Manual Button ────────────────────────────────────────────────

  Widget _manualButton() {
    return Obx(
      () => CustomSecondaryButton(
        text: 'Choose equipment manually',
        onTap: controller.isProcessingScan.value
            ? null
            : controller.onChooseManually,
        borderRadius: 16,
        margin: EdgeInsets.symmetric(horizontal: 20.w),
      ),
    );
  }

  Widget _scanButton() {
    return Obx(
      () => CustomPrimaryButton(
        text: controller.scanButtonText,
        onTap: controller.onScanNow,
        isLoading: controller.isProcessingScan.value,
        borderRadius: 16,
        margin: EdgeInsets.symmetric(horizontal: 20.w),
      ),
    );
  }
}

// ─── Bracket Painter ──────────────────────────────────────────────

class _BracketPainter extends CustomPainter {
  final bool topLeft, topRight, bottomLeft, bottomRight;
  final Color color;
  final double strokeWidth;

  _BracketPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    if (topLeft) {
      canvas.drawLine(Offset(0, h), Offset(0, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
    }
    if (topRight) {
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(w, h), Offset(0, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
