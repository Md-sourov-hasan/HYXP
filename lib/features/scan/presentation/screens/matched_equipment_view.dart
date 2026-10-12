import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_secondary_button.dart';
import 'package:hawiisaac/features/scan/controller/matched_equipment_controller.dart';

class MatchedEquipmentView extends StatelessWidget {
  const MatchedEquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MatchedEquipmentController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton(context);
        }

        return Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(context, controller),
                    _buildEquipmentHero(context, controller),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 18.h),
                          _buildMatchText(controller),
                          SizedBox(height: 14.h),
                          _buildEquipmentSummary(context, controller),
                          SizedBox(height: 24.h),
                          _buildSectionTitle(controller.sectionTitle.value),
                          SizedBox(height: 14.h),
                          _buildExerciseList(context, controller),
                          SizedBox(height: 20.h),
                          _buildContinueButton(controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.showMismatchPrompt.value)
              _buildMismatchPrompt(context, controller),
          ],
        );
      }),
    );
  }

  Widget _buildMismatchPrompt(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.30),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF171717) : Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.sentiment_dissatisfied_outlined,
                            size: 20.r,
                            color: AppColors.blackColor,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Not the right match?',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controller.dismissMismatchPrompt,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.close,
                            size: 22.r,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        'No problem. You can select the correct equipment manually or scan again for a better result.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.5,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: CustomSecondaryButton(
                            text: 'Select manually',
                            onTap: controller.onChooseManuallyTapped,
                            height: 48.h,
                            borderRadius: 14,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: controller.onScanAgainTapped,
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Scan again',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 10.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.blackColor,
                size: 24.r,
              ),
              onPressed: controller.onBackTapped,
            ),
          ),
          Text(
            controller.appBarTitle.value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentHero(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      width: double.infinity,
      height: 210.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: controller.equipmentImageUrl.value.isNotEmpty
            ? Image.network(
                controller.equipmentImageUrl.value,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildEquipmentPlaceholder(context),
              )
            : _buildEquipmentPlaceholder(context),
      ),
    );
  }

  Widget _buildEquipmentPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF252525) : const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: Icon(
        Icons.fitness_center_rounded,
        size: 52.sp,
        color: isDark ? Colors.white54 : Colors.grey.shade500,
      ),
    );
  }

  Widget _buildMatchText(MatchedEquipmentController controller) {
    return Text(
      controller.matchText.value,
      style: TextStyle(
        fontSize: 15.sp,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.blackColor,
      ),
    );
  }

  Widget _buildEquipmentSummary(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.selectedEquipmentName.value.isEmpty
                ? 'Detected equipment'
                : controller.selectedEquipmentName.value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (controller.equipmentCategory.value.isNotEmpty)
                _metaChip(context, controller.equipmentCategory.value),
              if (controller.confidence.value > 0)
                _metaChip(
                  context,
                  'Confidence ${(controller.confidence.value * 100).toStringAsFixed(0)}%',
                ),
            ],
          ),
          if (controller.equipmentDescription.value.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              controller.equipmentDescription.value,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.blackColor,
      ),
    );
  }

  Widget _buildExerciseList(
    BuildContext context,
    MatchedEquipmentController controller,
  ) {
    if (controller.exercises.isEmpty) {
      return _emptyState(context, 'No workouts found for this equipment yet.');
    }

    return Column(
      children: List.generate(
        controller.exercises.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildExerciseCard(context, controller, index),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    MatchedEquipmentController controller,
    int index,
  ) {
    final exercise = controller.exercises[index];
    final isSelected = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => controller.onExerciseSelected(index),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 2.w,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['title']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    exercise['description']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _miniChip(
                        context,
                        exercise['category']?.toString() ?? '',
                      ),
                      _miniChip(
                        context,
                        exercise['equipment']?.toString() ?? '',
                      ),
                    ].whereType<Widget>().toList(growable: false),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            _buildExerciseImage(context, exercise['imageUrl']?.toString()),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(BuildContext context, String label) {
    if (label.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999.r),
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
      ),
    );
  }

  Widget _buildExerciseImage(BuildContext context, String? imageUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 92.w,
      height: 84.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported_outlined,
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                ),
              ),
            )
          : Icon(
              Icons.image_not_supported_outlined,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
    );
  }

  Widget _emptyState(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202020) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.white70 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildContinueButton(MatchedEquipmentController controller) {
    return CustomSecondaryButton(
      text: controller.buttonText.value,
      onTap: controller.onContinueTapped,
      borderRadius: 14,
      margin: EdgeInsets.fromLTRB(0, 4.h, 0, 0),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 150, height: 18, radius: 8),
            SizedBox(height: 20.h),
            ShimmerBox(width: double.infinity, height: 210.h, radius: 22),
            SizedBox(height: 20.h),
            const ShimmerBox(width: double.infinity, height: 16, radius: 8),
            SizedBox(height: 14.h),
            ShimmerBox(width: double.infinity, height: 100.h, radius: 18),
            SizedBox(height: 22.h),
            const ShimmerBox(width: 180, height: 22, radius: 8),
            SizedBox(height: 14.h),
            ...List.generate(
              2,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: ShimmerBox(
                  width: double.infinity,
                  height: 110.h,
                  radius: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
