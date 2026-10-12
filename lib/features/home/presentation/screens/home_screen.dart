import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _topBar(context, controller),
                  SizedBox(height: 20.h),
                  _statsRow(context, controller),
                  SizedBox(height: 28.h),
                  _recentActivity(context, controller),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ContentHeaderDelegate(
                minExtentHeight: 100.h,
                maxExtentHeight: 100.h,
                child: _buildContentBar(context, controller),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 24.h, bottom: 132.h),
                child: _contentBody(context, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────────────

  Widget _topBar(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(
        () => Row(
          children: [
            _avatar(controller.userInitials.value),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.greeting.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    controller.userName.value,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: controller.onBookmarkTap,
              icon: Icon(
                Icons.bookmark_border_rounded,
                size: 24.sp,
                color: AppColors.blackColor,
              ),
            ),
            // IconButton(
            //   onPressed: controller.onMessageTap,
            //   icon: Icon(
            //     Icons.notifications_none_rounded,
            //     size: 28.sp,
            //     color: AppColors.blackColor,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ─── Avatar ───────────────────────────────────────────────────────

  Widget _avatar(String initials) {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.greyColor,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────

  Widget _statsRow(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() {
        if (controller.isHighlightsLoading.value) {
          return Row(
            children: [
              _statCardSkeleton(context),
              SizedBox(width: 10.w),
              _statCardSkeleton(context),
              SizedBox(width: 10.w),
              _statCardSkeleton(context),
            ],
          );
        }

        return Row(
          children: [
            _statCard(
              context,
              value: controller.daysStreak.value,
              label: 'Days streak',
              valueColor: AppColors.primaryColor,
            ),
            SizedBox(width: 10.w),
            _statCard(
              context,
              value: controller.thisWeek.value,
              label: 'This week',
            ),
            SizedBox(width: 10.w),
            _statCard(
              context,
              value: controller.caloriesBurned.value,
              label: 'Calories Burned',
            ),
          ],
        );
      }),
    );
  }

  // ─── Stat Card ────────────────────────────────────────────────────

  Widget _statCard(
    BuildContext context, {
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.blackColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCardSkeleton(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 38, height: 20, radius: 8),
            SizedBox(height: 8.h),
            const ShimmerBox(width: 72, height: 12, radius: 8),
          ],
        ),
      ),
    );
  }

  // ─── Recent Activity ──────────────────────────────────────────────

  Widget _recentActivity(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent activity',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Obx(() {
              if (controller.isSessionsLoading.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12.h),
                        child: _activityTileSkeleton(context),
                      ),
                    ),
                  ),
                );
              }

              if (controller.recentActivities.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'No recent sessions',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                );
              }

              return Column(
                children: controller.recentActivities
                    .asMap()
                    .entries
                    .map(
                      (entry) => _activityTile(
                        context,
                        activity: entry.value,
                        showDivider:
                            entry.key != controller.recentActivities.length - 1,
                      ),
                    )
                    .toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Activity Tile ────────────────────────────────────────────────

  IconData _resolveIcon(String key) {
    switch (key) {
      case 'leg':
        return Icons.directions_run_rounded;
      case 'pull':
        return Icons.fitness_center_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  Widget _buildActivityIcon(String key) {
    String? assetPath;
    if (key == 'upper') {
      assetPath = 'assets/icons/upperbody.png';
    } else if (key == 'leg') {
      assetPath = 'assets/icons/legday.png';
    } else if (key == 'pull') {
      assetPath = 'assets/icons/pullday.png';
    }

    if (assetPath != null) {
      return Center(
        child: Image.asset(
          assetPath,
          width: 20.sp,
          height: 20.sp,
          color: AppColors.blackColor,
        ),
      );
    }

    return Icon(_resolveIcon(key), size: 20.sp, color: AppColors.blackColor);
  }

  Widget _activityTile(
    BuildContext context, {
    required Map<String, String> activity,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: _buildActivityIcon(activity['icon']!),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      activity['time']!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    activity['sets']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Text(
                    'sets',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade400,
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

  Widget _activityTileSkeleton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          const ShimmerBox(width: 42, height: 42, radius: 10),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: double.infinity, height: 14, radius: 8),
                SizedBox(height: 6.h),
                const ShimmerBox(width: 110, height: 11, radius: 8),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              ShimmerBox(width: 20, height: 16, radius: 8),
              SizedBox(height: 6),
              ShimmerBox(width: 28, height: 10, radius: 8),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Content Section ──────────────────────────────────────────────

  Widget _buildContentBar(BuildContext context, HomeController controller) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 0, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Content',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _workoutTabs(controller),
        ],
      ),
    );
  }

  Widget _contentBody(BuildContext context, HomeController controller) {
    return Obx(() {
      if (controller.isContentLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Column(
            children: [
              _workoutGroupSkeleton(context),
              SizedBox(height: 28.h),
              _workoutGroupSkeleton(context),
            ],
          ),
        );
      }

      if (controller.featuredContents.isEmpty &&
          controller.moreContents.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              controller.contentErrorMessage.value.isEmpty
                  ? 'No content found'
                  : controller.contentErrorMessage.value,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
          ),
        );
      }

      return Column(
        children: [
          if (controller.featuredContents.isNotEmpty)
            _contentGroup(
              context,
              contents: controller.featuredContents,
              controller: controller,
            ),
          if (controller.featuredContents.isNotEmpty &&
              controller.moreContents.isNotEmpty)
            SizedBox(height: 28.h),
          if (controller.moreContents.isNotEmpty)
            _contentGroup(
              context,
              title: 'Perfect for home',
              contents: controller.moreContents,
              controller: controller,
            ),
        ],
      );
    });
  }

  // ─── Workout Tabs ─────────────────────────────────────────────────

  Widget _workoutTabs(HomeController controller) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: controller.workoutTabs.asMap().entries.map((entry) {
            final isSelected = entry.key == controller.selectedTabIndex.value;
            return GestureDetector(
              onTap: () => controller.onTabSelected(entry.key),
              child: Padding(
                padding: EdgeInsets.only(right: 24.w),
                child: Column(
                  children: [
                    Text(
                      entry.value.label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.blackColor
                            : Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2.h,
                      width: isSelected ? 24.w : 0,
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Content Group ────────────────────────────────────────────────

  Widget _contentGroup(
    BuildContext context, {
    String? title,
    required List<ContentItem> contents,
    required HomeController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
          ),
          SizedBox(height: 14.h),
        ],
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: contents.length,
            separatorBuilder: (context, index) => SizedBox(width: 14.w),
            itemBuilder: (context, index) => _contentCard(
              context,
              content: contents[index],
              controller: controller,
            ),
          ),
        ),
      ],
    );
  }

  Widget _workoutGroupSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: const ShimmerBox(width: 160, height: 18, radius: 8),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: 2,
            separatorBuilder: (context, index) => SizedBox(width: 14.w),
            itemBuilder: (context, index) =>
                ShimmerBox(width: 200.w, height: 220.h, radius: 16),
          ),
        ),
      ],
    );
  }

  // ─── Content Card ─────────────────────────────────────────────────

  Widget _contentCard(
    BuildContext context, {
    required ContentItem content,
    required HomeController controller,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.onContentTap(content),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          width: 200.w,
          height: 220.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                content.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                    size: 40.sp,
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              // Bookmark button
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Obx(() {
                  final isCurrentBookmarking = controller.isBookmarkingContent(
                    content.id,
                  );

                  return Material(
                    color: content.isBookmarked
                        ? AppColors.primaryColor.withValues(alpha: 0.18)
                        : Theme.of(context).cardColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: controller.bookmarkingContentId.value != null
                          ? null
                          : () => controller.onContentBookmark(content),
                      child: SizedBox(
                        width: 34.w,
                        height: 34.w,
                        child: Center(
                          child: isCurrentBookmarking
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      content.isBookmarked
                                          ? AppColors.primaryColor
                                          : AppColors.blackColor,
                                    ),
                                  ),
                                )
                              : Icon(
                                  content.isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border_rounded,
                                  size: 18.sp,
                                  color: content.isBookmarked
                                      ? AppColors.primaryColor
                                      : AppColors.blackColor,
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // Text overlay
              Positioned(
                bottom: 14.h,
                left: 12.w,
                right: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      content.summary.isNotEmpty
                          ? content.summary
                          : content.feedLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ContentHeaderDelegate({
    required this.minExtentHeight,
    required this.maxExtentHeight,
    required this.child,
  });

  final double minExtentHeight;
  final double maxExtentHeight;
  final Widget child;

  @override
  double get minExtent => minExtentHeight;

  @override
  double get maxExtent => maxExtentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _ContentHeaderDelegate oldDelegate) {
    return oldDelegate.minExtentHeight != minExtentHeight ||
        oldDelegate.maxExtentHeight != maxExtentHeight ||
        oldDelegate.child != child;
  }
}
