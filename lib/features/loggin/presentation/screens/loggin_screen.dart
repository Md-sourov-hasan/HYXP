import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_secondary_button.dart';
import 'package:hawiisaac/features/loggin/controller/logging_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class LoggingView extends StatelessWidget {
  const LoggingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoggingController());

    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 132.h),
                  child: Column(
                    children: [
                      _loggingHeader(context, controller),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            _exerciseTitle(controller),
                            SizedBox(height: 20.h),
                            _setTableHeader(),
                            SizedBox(height: 10.h),
                            _setList(context, controller),
                            SizedBox(height: 16.h),
                            _addSetButton(controller),
                            SizedBox(height: 20.h),
                            _noteField(controller),
                            Obx(() {
                              if (!controller.isCardioWorkout.value) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                children: [
                                  SizedBox(height: 20.h),
                                  _cardioSection(context, controller),
                                ],
                              );
                            }),
                            SizedBox(height: 24.h),
                            _finishWorkoutButton(controller),
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

  // ─── Header ───────────────────────────────────────────────────────

  Widget _loggingHeader(BuildContext context, LoggingController controller) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.chevron_left,
                  size: 28.sp,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            Text(
              'Logging',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: _timerBadge(controller),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Divider(color: Theme.of(context).dividerColor, thickness: 1),
      ],
    );
  }

  // ─── Timer Badge ──────────────────────────────────────────────────

  Widget _timerBadge(LoggingController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 16.sp,
              color: AppColors.primaryColor,
            ),
            SizedBox(width: 5.w),
            Text(
              controller.formattedTime,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Exercise Title ───────────────────────────────────────────────

  Widget _exerciseTitle(LoggingController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.exerciseName.value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          if (controller.workoutTags.value.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              controller.workoutTags.value.replaceAll(',', ' .'),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Set Table Header ─────────────────────────────────────────────

  Widget _setTableHeader() {
    return Row(
      children: [
        SizedBox(
          width: 40.w,
          child: Text('SET', style: _headerStyle()),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Center(child: Text('KG', style: _headerStyle())),
        ),
        Expanded(
          child: Center(child: Text('REPS', style: _headerStyle())),
        ),
        SizedBox(width: 32.w),
      ],
    );
  }

  TextStyle _headerStyle() => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade400,
    letterSpacing: 1.2,
  );

  // ─── Set List ─────────────────────────────────────────────────────

  Widget _setList(BuildContext context, LoggingController controller) {
    return Obx(
      () => Column(
        children: controller.sets.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: _setRow(
              index: entry.key,
              set: entry.value,
              context: context,
              controller: controller,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Set Row ──────────────────────────────────────────────────────

  Widget _setRow({
    required int index,
    required WorkoutSet set,
    required BuildContext context,
    required LoggingController controller,
  }) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Set number circle
          _setNumberBadge(
            context,
            number: index + 1,
            isCompleted: set.isCompleted.value,
          ),
          SizedBox(width: 16.w),
          // KG stepper
          Expanded(
            child: _stepper(
              context: context,
              value: set.kg.value,
              isEnabled: !set.isCompleted.value,
              onDecrement: () => controller.decrementKg(index),
              onIncrement: () => controller.incrementKg(index),
            ),
          ),
          SizedBox(width: 10.w),
          // REPS stepper
          Expanded(
            child: _stepper(
              context: context,
              value: set.reps.value,
              isEnabled: !set.isCompleted.value,
              onDecrement: () => controller.decrementReps(index),
              onIncrement: () => controller.incrementReps(index),
            ),
          ),
          SizedBox(width: 12.w),
          // Completed checkbox
          _completedCheckbox(
            controller: controller,
            index: index,
            isCompleted: set.isCompleted.value,
            onTap: () => controller.toggleCompleted(index),
          ),
        ],
      ),
    );
  }

  // ─── Set Number Badge ─────────────────────────────────────────────

  Widget _setNumberBadge(
    BuildContext context, {
    required int number,
    required bool isCompleted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.primaryColor
            : Theme.of(context).cardColor,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: isCompleted ? AppColors.blackColor : Colors.grey.shade600,
        ),
      ),
    );
  }

  // ─── Stepper ──────────────────────────────────────────────────────

  Widget _stepper({
    required BuildContext context,
    required int value,
    required bool isEnabled,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepperButton(
          context: context,
          icon: Icons.remove,
          onTap: isEnabled ? onDecrement : null,
          isEnabled: isEnabled,
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 32.w,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isEnabled
                  ? AppColors.blackColor
                  : isDark
                  ? Colors.white54
                  : Colors.grey.shade500,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        _stepperButton(
          context: context,
          icon: Icons.add,
          onTap: isEnabled ? onIncrement : null,
          isEnabled: isEnabled,
        ),
      ],
    );
  }

  // ─── Stepper Button ───────────────────────────────────────────────

  Widget _stepperButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isEnabled
        ? (isDark ? Theme.of(context).cardColor : Colors.white)
        : (isDark
              ? Theme.of(context).cardColor.withValues(alpha: 0.7)
              : Colors.grey.shade100);
    final borderColor = isEnabled
        ? (isDark ? Colors.white.withValues(alpha: 0.22) : Colors.grey.shade300)
        : (isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.grey.shade200);
    final iconColor = isEnabled
        ? AppColors.blackColor
        : (isDark ? Colors.white54 : Colors.grey.shade400);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: borderColor, width: 1.5),
          color: backgroundColor,
        ),
        child: Icon(icon, size: 14.sp, color: iconColor),
      ),
    );
  }

  // ─── Completed Checkbox ───────────────────────────────────────────

  Widget _completedCheckbox({
    required LoggingController controller,
    required int index,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final isLoading = controller.savingSetIndexes.contains(index);

      return GestureDetector(
        onTap: isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 26.w,
          height: 26.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            color: isCompleted ? AppColors.primaryColor : Colors.transparent,
            border: Border.all(
              color: isCompleted
                  ? AppColors.primaryColor
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: isLoading
              ? Padding(
                  padding: EdgeInsets.all(4.w),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? AppColors.blackColor
                          : AppColors.primaryColor,
                    ),
                  ),
                )
              : isCompleted
              ? Icon(Icons.check, size: 16.sp, color: AppColors.blackColor)
              : null,
        ),
      );
    });
  }

  // ─── Add Set Button ───────────────────────────────────────────────

  Widget _addSetButton(LoggingController controller) {
    return CustomSecondaryButton(
      text: 'Add set',
      onTap: controller.addSet,
      height: 52.h,
      borderRadius: 14,
    );
  }

  // ─── Note Field ───────────────────────────────────────────────────

  Widget _noteField(LoggingController controller) {
    return TextField(
      controller: controller.noteController,
      maxLines: 4,
      style: TextStyle(fontSize: 14.sp, color: AppColors.blackColor),
      decoration: InputDecoration(
        hintText: 'Add a note about this exercise...',
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
        filled: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _cardioSection(BuildContext context, LoggingController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${controller.exerciseName.value} workout',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _cardioField(
                  context,
                  label: 'Time',
                  icon: Icons.timer_outlined,
                  controller: controller.timeController,
                  hintText: '10 min',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _cardioField(
                  context,
                  label: 'Distance',
                  icon: Icons.social_distance_outlined,
                  controller: controller.distanceController,
                  hintText: '4 km',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _cardioField(
                  context,
                  label: 'Speed',
                  icon: Icons.speed_outlined,
                  controller: controller.speedController,
                  hintText: '24 km/h',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(child: _inclineField(context, controller)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardioField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: AppColors.blackColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inclineField(BuildContext context, LoggingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 18.sp,
              color: AppColors.blackColor,
            ),
            SizedBox(width: 6.w),
            Text(
              'Incline',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
          ),
          child: Row(
            children: [
              _stepperButton(
                context: context,
                icon: Icons.remove,
                onTap: controller.decrementIncline,
                isEnabled: true,
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    '${controller.inclineValue.value}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ),
              _stepperButton(
                context: context,
                icon: Icons.add,
                onTap: controller.incrementIncline,
                isEnabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Finish Workout Button ────────────────────────────────────────

  Widget _finishWorkoutButton(LoggingController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: controller.isSaving.value ? 'Saving...' : 'Finish workout',
        onTap: controller.onFinishWorkout,
        isLoading: controller.isSaving.value,
        borderRadius: 16,
      ),
    );
  }
}
