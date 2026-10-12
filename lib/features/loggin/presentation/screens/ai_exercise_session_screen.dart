import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/loggin/controller/ai_exercise_session_controller.dart';

class AiExerciseSessionScreen extends StatelessWidget {
  const AiExerciseSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiExerciseSessionController());

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(
            'Logging',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(child: _timerBadge(controller)),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Obx(() {
            debugPrint(
              'AiExerciseSessionScreen rebuild: '
              'loading=${controller.isLoading.value}, '
              'hasExercises=${controller.hasExercises}, '
              'sessionId=${controller.sessionIdLabel}, '
              'currentOrder=${controller.currentWorkoutOrderLabel}, '
              'source=${controller.sessionSourceLabel}',
            );

            if (controller.isLoading.value && !controller.hasExercises) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!controller.hasExercises) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    controller.errorMessage.value.isEmpty
                        ? 'No active exercises found.'
                        : controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Text(
                          controller.title.value,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _sessionSummaryCard(context, controller),
                        SizedBox(height: 14.h),
                        if (controller.completedExercises.isNotEmpty) ...[
                          ...(controller.allExercisesCompleted
                                  ? controller.completedExercises
                                  : [controller.completedExercises.last])
                              .map(
                                (exercise) => Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: _exerciseTile(
                                    context,
                                    index: exercise.order,
                                    name: exercise.name,
                                    tags: exercise.tags,
                                    details: exercise.details,
                                    durationLabel: 'Done',
                                    caloriesLabel:
                                        exercise.actualCaloriesBurned > 0
                                        ? '${_formatCalories(exercise.actualCaloriesBurned)} kcal'
                                        : '',
                                  ),
                                ),
                              ),
                          SizedBox(height: 16.h),
                        ],
                        if (!controller.allExercisesCompleted) ...[
                          Text(
                            controller.currentExercise.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            controller.currentExercise.tags,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (controller.currentExerciseNote.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.notes_rounded,
                                    size: 16.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      controller.currentExerciseNote,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        height: 1.4,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (controller.currentExercise.details
                              .trim()
                              .isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              controller.currentExercise.details,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                          SizedBox(height: 20.h),
                          Center(child: _currentExerciseTimer(controller)),
                          SizedBox(height: 20.h),
                          CustomPrimaryButton(
                            text: controller.isLastExercise ? 'Done' : 'Next',
                            onTap: () {
                              debugPrint(
                                'AiExerciseSessionScreen button tapped: '
                                'label=${controller.isLastExercise ? 'Done' : 'Next'}, '
                                'currentIndex=${controller.currentIndex.value}, '
                                'sessionId=${controller.sessionIdLabel}, '
                                'currentOrder=${controller.currentWorkoutOrderLabel}',
                              );
                              controller.nextExercise();
                            },
                            isLoading: controller.isAdvancing.value,
                            backgroundColor: const Color(0xFF1A1A1A),
                            textColor: Colors.white,
                            borderRadius: 14,
                          ),
                          SizedBox(height: 16.h),
                        ],
                        for (
                          var index = 0;
                          index < controller.pendingExercises.length;
                          index++
                        ) ...[
                          if (index > 0) SizedBox(height: 12.h),
                          _exerciseTile(
                            context,
                            index: controller.pendingExercises[index].order,
                            name: controller.pendingExercises[index].name,
                            tags: controller.pendingExercises[index].tags,
                            details: controller.pendingExercises[index].details,
                            durationLabel: _formatSeconds(
                              controller.pendingExercises[index].seconds,
                            ),
                            caloriesLabel: '',
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (controller.allExercisesCompleted) ...[
                    SizedBox(height: 12.h),
                    SafeArea(
                      top: false,
                      child: CustomPrimaryButton(
                        text: 'Finish workout',
                        onTap: () {
                          debugPrint(
                            'AiExerciseSessionScreen button tapped: '
                            'label=Finish workout, '
                            'sessionId=${controller.sessionIdLabel}, '
                            'completedExercises=${controller.completedExercises.length}, '
                            'totalExercises=${controller.totalWorkoutCount}',
                          );
                          controller.finishWorkout();
                        },
                        isLoading: controller.isFinishing.value,
                        borderRadius: 14,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _sessionSummaryCard(
    BuildContext context,
    AiExerciseSessionController controller,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _summaryPill(
                label: 'Session ${controller.sessionIdLabel}',
                color: const Color(0xFF127C91),
                background: const Color(0xFFE6F6F8),
              ),
              SizedBox(width: 8.w),
              _summaryPill(
                label: controller.sessionStatusLabel,
                color: const Color(0xFF5E5E5E),
                background: const Color(0xFFF1F1F1),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            controller.sourceContentTitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            controller.sessionSourceLabel,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _summaryMetric('Date', controller.sessionDateLabel),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _summaryMetric(
                  'Current',
                  controller.currentWorkoutOrderLabel,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _summaryMetric(
                  'Workouts',
                  '${controller.totalWorkoutCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryPill({
    required String label,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _timerBadge(AiExerciseSessionController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
              color: const Color(0xFF127C91),
            ),
            SizedBox(width: 6.w),
            Text(
              controller.formattedSessionRemainingTime,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF127C91),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currentExerciseTimer(AiExerciseSessionController controller) {
    return Obx(() {
      final seconds = controller.remainingSeconds.value;
      final left = (seconds ~/ 60).toString().padLeft(2, '0');
      final right = (seconds % 60).toString().padLeft(2, '0');

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeBox(left),
          SizedBox(width: 6.w),
          _timeBox(right),
        ],
      );
    });
  }

  Widget _timeBox(String value) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: const Color(0xFF5A5A5A),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return '0s';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}m';
    return '${m}m ${s}s';
  }

  Widget _exerciseTile(
    BuildContext context, {
    required int index,
    required String name,
    required String tags,
    required String details,
    required String durationLabel,
    required String caloriesLabel,
  }) {
    final isDone = durationLabel == 'Done';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
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
                fontWeight: FontWeight.w700,
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
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  tags,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (details.trim().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    details,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                durationLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDone
                      ? AppColors.blackColor
                      : const Color(0xFF0D6B77),
                ),
              ),
              if (caloriesLabel.trim().isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  caloriesLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D6B77),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatCalories(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }
}
