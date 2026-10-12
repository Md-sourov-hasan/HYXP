import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/progress/controller/progress_controller.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProgressController());

    return Scaffold(
      body: Obx(
        () => SafeArea(
          child: controller.isLoading.value
              ? _loadingSkeleton(context)
              : SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 132.h),
                  child: Column(
                    children: [
                      _progressHeader(context, controller),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            _filterTabs(context, controller),
                            SizedBox(height: 20.h),
                            _volumeCard(context, controller),
                            SizedBox(height: 16.h),
                            _chartCard(context, controller),
                            SizedBox(height: 16.h),
                            _statsGrid(context, controller),
                            SizedBox(height: 28.h),
                            _personalBestSection(context, controller),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _loadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: ShimmerBox(width: 120, height: 22, radius: 8)),
          SizedBox(height: 8.h),
          const Center(child: ShimmerBox(width: 100, height: 12, radius: 8)),
          SizedBox(height: 26.h),
          Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : 10.w),
                child: ShimmerBox(width: 54.w, height: 34.h, radius: 22),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ShimmerBox(width: double.infinity, height: 150.h, radius: 16),
          SizedBox(height: 16.h),
          ShimmerBox(width: double.infinity, height: 220.h, radius: 16),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 110.h, radius: 14)),
              SizedBox(width: 12.w),
              Expanded(child: ShimmerBox(height: 110.h, radius: 14)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 110.h, radius: 14)),
              SizedBox(width: 12.w),
              Expanded(child: ShimmerBox(height: 110.h, radius: 14)),
            ],
          ),
          SizedBox(height: 28.h),
          const ShimmerBox(width: 150, height: 20, radius: 8),
          SizedBox(height: 14.h),
          ...List.generate(
            2,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ShimmerBox(
                width: double.infinity,
                height: 92.h,
                radius: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────

  Widget _progressHeader(BuildContext context, ProgressController controller) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Obx(
                    () => Text(
                      controller.dateRange.value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: controller.onShare,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share_outlined,
                          size: 14.sp,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Divider(color: Theme.of(context).dividerColor, thickness: 1),
      ],
    );
  }

  // ─── Filter Tabs ──────────────────────────────────────────────────

  Widget _filterTabs(BuildContext context, ProgressController controller) {
    return Obx(
      () => Row(
        children: controller.filterTabs.asMap().entries.map((entry) {
          final isSelected = entry.key == controller.selectedFilterIndex.value;
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: GestureDetector(
              onTap: () => controller.onFilterSelected(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.blackColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Volume Card ──────────────────────────────────────────────────

  Widget _volumeCard(BuildContext context, ProgressController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              controller.volumeLabel.value,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(
                () => Text(
                  controller.totalVolume.value,
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(
                  controller.volumeUnit,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 14.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 4.w),
              Obx(
                () => Text(
                  controller.volumeLabel.value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Chart Card ───────────────────────────────────────────────────

  Widget _chartCard(BuildContext context, ProgressController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Volume Lifted',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 140.h,
            child: Obx(() {
              final points = controller.chartPoints.toList();

              return CustomPaint(
                size: Size(double.infinity, 140.h),
                painter: _LineChartPainter(
                  points: points,
                  lineColor: AppColors.primaryColor,
                  fillColor: AppColors.primaryColor.withValues(alpha: 0.15),
                  dotColor: AppColors.primaryColor,
                  dotBorderColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  controller.chartStartLabel.value,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              Obx(
                () => Text(
                  controller.chartEndLabel.value,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats Grid ───────────────────────────────────────────────────

  Widget _statsGrid(BuildContext context, ProgressController controller) {
    return Obx(() {
      final cards = controller.statCards;
      if (cards.length < 4) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard(context, data: cards[0])),
              SizedBox(width: 12.w),
              Expanded(child: _statCard(context, data: cards[1])),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _statCard(context, data: cards[2])),
              SizedBox(width: 12.w),
              Expanded(child: _statCard(context, data: cards[3])),
            ],
          ),
        ],
      );
    });
  }

  // ─── Stat Card ────────────────────────────────────────────────────

  Widget _statCard(BuildContext context, {required Map<String, String> data}) {
    final isPositive = data['isPositive'] == 'true';
    final isNeutral = data['isPositive'] == 'neutral';
    final changeColor = isNeutral
        ? Colors.grey.shade500
        : isPositive
        ? AppColors.primaryColor
        : Colors.red;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['label']!,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 6.h),
          Text(
            data['value']!,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            data['change']!,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Personal Best Section ────────────────────────────────────────

  Widget _personalBestSection(
    BuildContext context,
    ProgressController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Best',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 14.h),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              children: controller.personalBests.asMap().entries.map((entry) {
                return _personalBestTile(
                  context,
                  pb: entry.value,
                  showDivider: entry.key < controller.personalBests.length - 1,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Personal Best Tile ───────────────────────────────────────────

  IconData _resolveIcon(String type) {
    switch (type) {
      case 'squat':
        return Icons.directions_run_rounded;
      case 'deadlift':
        return Icons.fitness_center_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  Widget _personalBestTile(
    BuildContext context, {
    required PersonalBest pb,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _resolveIcon(pb.iconType),
                  size: 20.sp,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(width: 12.w),
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pb.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      pb.subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              // Value & change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: pb.value,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ),
                        TextSpan(
                          text: ' ${pb.unit}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    pb.change,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
            indent: 14.w,
            endIndent: 14.w,
          ),
      ],
    );
  }
}

// ─── Line Chart Painter ───────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color dotColor;
  final Color dotBorderColor;

  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
    required this.dotBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = dotBorderColor
      ..style = PaintingStyle.fill;

    // Convert normalized points to canvas coordinates
    List<Offset> offsets = points.map((p) {
      return Offset(p.x * size.width, (1 - p.y) * size.height);
    }).toList();

    // Build smooth path
    final linePath = Path();
    final fillPath = Path();

    linePath.moveTo(offsets[0].dx, offsets[0].dy);
    fillPath.moveTo(offsets[0].dx, size.height);
    fillPath.lineTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final curr = offsets[i];
      final next = offsets[i + 1];
      final cp1 = Offset((curr.dx + next.dx) / 2, curr.dy);
      final cp2 = Offset((curr.dx + next.dx) / 2, next.dy);

      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
    }

    fillPath.lineTo(offsets.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    for (final offset in offsets) {
      canvas.drawCircle(offset, 5, dotBorderPaint);
      canvas.drawCircle(offset, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    if (oldDelegate.points.length != points.length ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.dotBorderColor != dotBorderColor) {
      return true;
    }

    for (var i = 0; i < points.length; i++) {
      final oldPoint = oldDelegate.points[i];
      final point = points[i];
      if (oldPoint.x != point.x || oldPoint.y != point.y) {
        return true;
      }
    }

    return false;
  }
}
