import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/core/utils/logging/logger.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/scan/controller/exercise_detail_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────
class ExerciseDetailView extends StatelessWidget {
  const ExerciseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExerciseDetailController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _heroImage(controller),
                            SizedBox(height: 4.h),
                            _exerciseInfo(controller),
                            SizedBox(height: 16.h),
                            _muscleTags(controller),
                            SizedBox(height: 20.h),
                            _statCards(controller),
                            SizedBox(height: 28.h),
                            _howToSection(controller),
                            SizedBox(height: 28.h),
                          ],
                        ),
                      ),
                    ),
                    _addToWorkoutButton(controller),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────────────────────────────────────────

  /// Hero illustration
  Widget _heroImage(ExerciseDetailController controller) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
      child: ExerciseHeroMedia(
        imageUrl: controller.imageUrl,
        videoUrl: controller.videoUrl,
      ),
    );
  }

  /// Exercise name + category
  Widget _exerciseInfo(ExerciseDetailController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.exerciseName,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.blackColor,
              height: 1.15,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${controller.category} . ${controller.muscleGroup}',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryColor.withValues(alpha: 0.45),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontally scrollable muscle chips
  Widget _muscleTags(ExerciseDetailController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: controller.muscleTags.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: _muscleChip(label: entry.key, isPrimary: entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _muscleChip({required String label, required bool isPrimary}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        // primary chips: light cyan tint; secondary: white-ish
        color: isPrimary
            ? AppColors.primaryColor.withValues(alpha: 0.15)
            : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(
          color: isPrimary
              ? AppColors.primaryColor
              : AppColors.secondaryColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: isPrimary
              ? AppColors.primaryColor
              : AppColors.secondaryColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Sets / Reps / Rest row
  Widget _statCards(ExerciseDetailController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _statCard(value: controller.sets, label: 'SETS'),
          SizedBox(width: 12.w),
          _statCard(value: controller.reps, label: 'REPS'),
          SizedBox(width: 12.w),
          _statCard(value: controller.rest, label: 'REST(s)'),
        ],
      ),
    );
  }

  Widget _statCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.secondaryColor.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryColor.withValues(alpha: 0.4),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "How to use" section
  Widget _howToSection(ExerciseDetailController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to use',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.secondaryColor.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: List.generate(controller.steps.length, (index) {
                return _stepItem(
                  number: index + 1,
                  text: controller.steps[index],
                  showDivider: index != controller.steps.length - 1,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepItem({
    required int number,
    required String text,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cyan numbered circle
              Container(
                width: 28.w,
                height: 28.w,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.secondaryColor.withValues(alpha: 0.07),
            indent: 58.w,
          ),
      ],
    );
  }

  /// Primary CTA button
  Widget _addToWorkoutButton(ExerciseDetailController controller) {
    return Obx(
      () => CustomPrimaryButton(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        text: controller.isStartingWorkout.value
            ? 'Starting...'
            : 'Add to workout',
        onTap: controller.addToWorkout,
        isLoading: controller.isStartingWorkout.value,
        backgroundColor: AppColors.blackColor,
        textColor: AppColors.whiteColor,
        height: 54.h,
        borderRadius: 14,
      ),
    );
  }
}

class ExerciseHeroMedia extends StatefulWidget {
  const ExerciseHeroMedia({
    super.key,
    required this.imageUrl,
    required this.videoUrl,
  });

  final String imageUrl;
  final String videoUrl;

  @override
  State<ExerciseHeroMedia> createState() => _ExerciseHeroMediaState();
}

class _ExerciseHeroMediaState extends State<ExerciseHeroMedia> {
  VideoPlayerController? _videoController;
  bool _hasVideoError = false;
  int _loadToken = 0;

  bool get _shouldShowVideo =>
      widget.videoUrl.trim().isNotEmpty && !_hasVideoError;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant ExerciseHeroMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeVideoController();
      _hasVideoError = false;
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    final videoUrl = widget.videoUrl.trim();
    if (videoUrl.isEmpty) return;
    final loadToken = ++_loadToken;

    try {
      final cachedVideo = await _getCachedVideoFile(videoUrl);
      if (!mounted || loadToken != _loadToken) return;

      final controller = VideoPlayerController.file(cachedVideo);
      _videoController = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (mounted) setState(() {});
    } catch (error) {
      AppLoggerHelper.warning('Exercise video failed to load: $error');
      if (mounted) {
        setState(() {
          _videoController = null;
          _hasVideoError = true;
        });
      }
    }
  }

  Future<File> _getCachedVideoFile(String videoUrl) async {
    final uri = Uri.parse(videoUrl);
    final cacheDirectory = Directory(
      '${(await getTemporaryDirectory()).path}/exercise_video_cache',
    );
    if (!await cacheDirectory.exists()) {
      await cacheDirectory.create(recursive: true);
    }

    final extension = _videoExtension(uri);
    final cacheKey = sha1.convert(utf8.encode(videoUrl)).toString();
    final cachedFile = File('${cacheDirectory.path}/$cacheKey$extension');

    if (await cachedFile.exists() && await cachedFile.length() > 0) {
      return cachedFile;
    }

    final tempFile = File('${cachedFile.path}.download');
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Failed to download video: ${response.statusCode}',
          uri: uri,
        );
      }

      final sink = tempFile.openWrite();
      await response.pipe(sink);
      await tempFile.rename(cachedFile.path);
      return cachedFile;
    } finally {
      client.close(force: true);
    }
  }

  String _videoExtension(Uri uri) {
    final path = uri.path.toLowerCase();
    final extensionStart = path.lastIndexOf('.');
    if (extensionStart == -1 || extensionStart == path.length - 1) {
      return '.mp4';
    }

    final extension = path.substring(extensionStart);
    return extension.length <= 6 ? extension : '.mp4';
  }

  void _disposeVideoController() {
    _loadToken++;
    final controller = _videoController;
    _videoController = null;
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldShowVideo) {
      return _videoPlayer();
    }

    return _fallbackImage();
  }

  Widget _videoPlayer() {
    final isReady = _videoController?.value.isInitialized ?? false;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        child: ColoredBox(
          color: AppColors.blackColor,
          child: isReady
              ? _initializedVideoPlayer(_videoController!)
              : Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _initializedVideoPlayer(VideoPlayerController controller) {
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          ),
          if (!controller.value.isPlaying)
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.blackColor.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.whiteColor,
                size: 34.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: widget.imageUrl.startsWith('http')
          ? Image.network(
              widget.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.asset(
              widget.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }
}
