import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/content_details_controller.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';

class ContentDetailsScreen extends StatelessWidget {
  const ContentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContentDetailsController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
        ),
        centerTitle: true,
        title: Obx(
          () => Text(
            controller.content.value?.feedLabel ?? 'Content',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final item = controller.content.value;
          if (controller.isLoading.value && item == null) {
            return _loadingSkeleton(context);
          }

          if (item == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  controller.errorMessage.value.isEmpty
                      ? 'Content not found'
                      : controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _image(context, item),
                SizedBox(height: 20.h),
                _feedChip(context, item),
                SizedBox(height: 12.h),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: AppColors.blackColor,
                  ),
                ),
                if (item.summary.trim().isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    item.summary,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (item.body.trim().isNotEmpty) ...[
                  SizedBox(height: 22.h),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.55,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
          child: Obx(() {
            final item = controller.content.value;
            final isBookmarked = item?.isBookmarked ?? false;

            return SizedBox(
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: item == null || controller.isBookmarking.value
                    ? null
                    : controller.onBookmarkTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                label: Text(
                  isBookmarked ? 'Bookmarked' : 'Bookmark',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }



  Widget _image(BuildContext context, ContentItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          item.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).cardColor,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade500,
              size: 42.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedChip(BuildContext context, ContentItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: 15.sp,
            color: AppColors.blackColor,
          ),
          SizedBox(width: 6.w),
          Text(
            item.feedLabel.isEmpty ? 'Content' : item.feedLabel,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 220.h, radius: 18),
          SizedBox(height: 20.h),
          const ShimmerBox(width: 100, height: 28, radius: 20),
          SizedBox(height: 14.h),
          const ShimmerBox(width: double.infinity, height: 30, radius: 8),
          SizedBox(height: 8.h),
          const ShimmerBox(width: 260, height: 30, radius: 8),
          SizedBox(height: 14.h),
          const ShimmerBox(width: double.infinity, height: 14, radius: 8),
          SizedBox(height: 8.h),
          const ShimmerBox(width: double.infinity, height: 14, radius: 8),
          SizedBox(height: 8.h),
          const ShimmerBox(width: 220, height: 14, radius: 8),
        ],
      ),
    );
  }
}
