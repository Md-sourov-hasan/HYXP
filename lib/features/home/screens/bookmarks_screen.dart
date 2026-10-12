import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/home/controller/bookmarks_controller.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookmarksController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 18.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SizedBox(
                height: 44.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24.r),
                        onTap: controller.onBackTap,
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 22.sp,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Bookmarks',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: const Color(0xFFE7E7E7),
            ),
            Expanded(
              child: Obx(() {
                if (controller.bookmarks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        'No bookmarks yet.',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: controller.bookmarks.length,
                  itemBuilder: (context, index) {
                    final content = controller.bookmarks[index];
                    return _BookmarkCard(
                      content: content,
                      controller: controller,
                      onTap: () => controller.onContentTap(content),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.content,
    required this.controller,
    required this.onTap,
  });

  final ContentItem content;
  final BookmarksController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              content.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 36.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.35, 1],
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${content.bookmarkCount}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Obx(() {
                final isRemoving = controller.isBookmarkingContent(content.id);

                return Material(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isRemoving
                        ? null
                        : () => _showRemoveOption(context, content),
                    child: SizedBox(
                      width: 36.w,
                      height: 36.w,
                      child: Center(
                        child: isRemoving
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.bookmark,
                                size: 18.sp,
                                color: AppColors.primaryColor,
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Positioned(
              left: 10.w,
              right: 10.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.8.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    content.summary.trim().isNotEmpty
                        ? content.summary
                        : content.feedLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.2.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemoveOption(BuildContext context, ContentItem content) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
                SizedBox(height: 18.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade600,
                    ),
                  ),
                  title: Text(
                    'Remove bookmark',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                  subtitle: Text(
                    'This will remove it from your bookmarks list.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.removeBookmark(content);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
