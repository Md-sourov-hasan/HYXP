import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/warm_up_details_controller.dart';

class WarmUpDetailsScreen extends StatelessWidget {
  const WarmUpDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WarmUpDetailsController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
        ),
        centerTitle: true,
        title: Text(
          controller.appBarTitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                debugPrint(
                  'WarmUpDetailsScreen rebuild: '
                  'loading=${controller.isLoading.value}, '
                  'isContentDetail=${controller.isContentDetail}, '
                  'title=${controller.workoutTitle}, '
                  'exercises=${controller.todayExercises.length}',
                );

                return controller.isLoading.value
                    ? _loadingSkeleton(context)
                    : Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.coverImageUrl.trim().isNotEmpty) ...[
                              _coverImage(context, controller),
                              SizedBox(height: 18.h),
                            ],
                            _header(controller),
                            SizedBox(height: 18.h),
                            if (controller.isContentDetail) ...[
                              _contentInfoChips(context, controller),
                              SizedBox(height: 18.h),
                            ],
                            if (controller.isContentDetail &&
                                controller.contentStats.isNotEmpty) ...[
                              _contentStats(context, controller),
                              SizedBox(height: 22.h),
                            ],
                            if (!controller.isContentDetail) ...[
                              _statsRow(context, controller),
                              SizedBox(height: 22.h),
                            ],
                            if (controller.overviewText.trim().isNotEmpty) ...[
                              Text(
                                'Overview',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                controller.overviewText,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.6,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 22.h),
                            ],
                            Text(
                              controller.sectionTitle,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blackColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ...controller.todayExercises.asMap().entries.map(
                              (entry) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _exerciseTile(
                                  context,
                                  index: entry.key + 1,
                                  item: entry.value,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
              }),
              SizedBox(height: 90.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Obx(
          () => Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
            child: SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: controller.isStartingExercise.value
                    ? null
                    : () => controller.onStartExercise(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  disabledBackgroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: controller.isStartingExercise.value
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Start Exercise',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(WarmUpDetailsController controller) {
    final content = controller.contentDetail.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: content.isFree
                  ? AppColors.primaryColor.withValues(alpha: 0.18)
                  : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              content.isFree ? 'Free Content' : 'Premium Content',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: content.isFree ? AppColors.blackColor : Colors.white,
              ),
            ),
          ),
          SizedBox(height: 14.h),
        ],
        Text(
          controller.workoutTitle,
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          controller.workoutMeta,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _coverImage(BuildContext context, WarmUpDetailsController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              controller.coverImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint(
                  'WarmUpDetails image load failed: '
                  'title=${controller.workoutTitle}, '
                  'image=${controller.coverImageUrl}, '
                  'error=$error',
                );
                return Container(
                  color: Theme.of(context).cardColor,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 42.sp,
                    color: Colors.grey.shade500,
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 14.h,
              child: Row(
                children: [
                  if (controller.contentFeedLabel.isNotEmpty)
                    _overlayBadge(controller.contentFeedLabel),
                  if (controller.contentTypeLabel.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    _overlayBadge(controller.contentTypeLabel),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overlayBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _contentInfoChips(
    BuildContext context,
    WarmUpDetailsController controller,
  ) {
    final chips = <String>[
      if (controller.contentFeedLabel.isNotEmpty) controller.contentFeedLabel,
      if (controller.contentTypeLabel.isNotEmpty) controller.contentTypeLabel,
      if (controller.hasContentVideo) 'Video available',
    ];

    debugPrint('WarmUpDetails info chips: $chips');

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: chips
          .map(
            (chip) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                chip,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _contentStats(
    BuildContext context,
    WarmUpDetailsController controller,
  ) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: controller.contentStats
          .map((stat) => _contentStatChip(context, stat: stat))
          .toList(growable: false),
    );
  }

  Widget _contentStatChip(
    BuildContext context, {
    required WarmUpDetailStat stat,
  }) {
    return Container(
      constraints: BoxConstraints(minWidth: 88.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: 10.sp,
              letterSpacing: 0.4,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context, WarmUpDetailsController controller) {
    return Row(
      children: [
        Expanded(
          child: _statChip(context, value: controller.setsValue, label: 'SETS'),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _statChip(context, value: controller.repsValue, label: 'REPS'),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _statChip(context, value: controller.restValue, label: 'REST'),
        ),
      ],
    );
  }

  Widget _statChip(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              letterSpacing: 0.4,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseTile(
    BuildContext context, {
    required int index,
    required WarmUpExerciseItem item,
  }) {
    debugPrint(
      'WarmUpDetails exercise tile: '
      'index=$index, name=${item.name}, metric=${item.metric}, details=${item.details}',
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.tags,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (item.details.trim().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item.details,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.isFree)
                Container(
                  margin: EdgeInsets.only(
                    bottom: item.metric.trim().isNotEmpty ? 8.h : 0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Free',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              if (item.metric.trim().isNotEmpty)
                Text(
                  item.metric,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadingSkeleton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 220, height: 30, radius: 8),
          SizedBox(height: 8.h),
          const ShimmerBox(width: 180, height: 12, radius: 8),
          SizedBox(height: 18.h),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 2 ? 0 : 10.w),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 68.h,
                    radius: 12,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 22.h),
          const ShimmerBox(width: 130, height: 14, radius: 8),
          SizedBox(height: 12.h),
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ShimmerBox(
                width: double.infinity,
                height: 64.h,
                radius: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
