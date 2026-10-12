import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/sessions/model/session_models.dart';
import 'package:hawiisaac/features/sessions/services/session_api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChartPoint {
  final double x;
  final double y;
  ChartPoint(this.x, this.y);
}

class PersonalBest {
  final String title;
  final String subtitle;
  final String value;
  final String unit;
  final String change;
  final String iconType;

  PersonalBest({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    required this.change,
    required this.iconType,
  });
}

class ProgressController extends GetxController {
  final SessionApiService _sessionApiService = SessionApiService();

  // ── Date Range ─────────────────────────────────────────────────
  final RxString dateRange = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Time Filter Tabs ───────────────────────────────────────────
  final List<String> filterTabs = ['All', '1W', '1M', '3M'];
  final RxInt selectedFilterIndex = 0.obs;

  void onFilterSelected(int index) {
    if (selectedFilterIndex.value == index) return;
    selectedFilterIndex.value = index;
    debugPrint('Progress filter selected: tab=${filterTabs[index]}');
    fetchProgress();
  }

  // ── Volume Card ────────────────────────────────────────────────
  final RxString totalVolume = '0'.obs;
  final String volumeUnit = 'kg';
  final RxString volumeLabel = 'Total Volume Lifted'.obs;

  // ── Chart Data ─────────────────────────────────────────────────
  final RxList<ChartPoint> chartPoints = <ChartPoint>[].obs;
  final RxString chartStartLabel = ''.obs;
  final RxString chartEndLabel = ''.obs;

  // ── Stat Cards ─────────────────────────────────────────────────
  final RxList<Map<String, String>> statCards = <Map<String, String>>[
    {
      'label': 'Workout',
      'value': '0',
      'change': 'Total sessions',
      'isPositive': 'neutral',
    },
    {
      'label': 'Avg Duration',
      'value': '0m',
      'change': 'Average time',
      'isPositive': 'neutral',
    },
    {
      'label': 'Total Sets',
      'value': '0',
      'change': 'Completed sets',
      'isPositive': 'true',
    },
    {
      'label': 'Total Volume',
      'value': '0',
      'change': 'kg lifted',
      'isPositive': 'true',
    },
  ].obs;

  // ── Personal Bests ─────────────────────────────────────────────
  final RxList<PersonalBest> personalBests = <PersonalBest>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    isLoading.value = true;
    errorMessage.value = '';

    final startDate = _startDateForFilter(selectedFilterIndex.value);
    final endDate = _endDate();

    debugPrint(
      'fetchProgress: tab=${filterTabs[selectedFilterIndex.value]}, '
      'startDate=${startDate ?? 'all'}, endDate=${endDate ?? 'all'}',
    );

    try {
      final responses = await Future.wait([
        _sessionApiService.getProgressSummary(
          startDate: startDate,
          endDate: endDate,
        ),
        _sessionApiService.getProgressChart(
          startDate: startDate,
          endDate: endDate,
        ),
        _sessionApiService.getProgressBests(
          limit: 3,
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      final summary = responses[0] as ProgressSummary;
      final chart = responses[1] as List<ProgressChartPoint>;
      final bests = responses[2] as List<ProgressBest>;

      debugPrint(
        'fetchProgress done: workouts=${summary.totalWorkouts}, '
        'volume=${summary.totalVolume}, chartPoints=${chart.length}, '
        'bests=${bests.length}',
      );

      _applySummary(summary);
      _applyChart(chart);
      _applyBests(bests);
      volumeLabel.value = _volumeLabelForFilter(selectedFilterIndex.value);
    } on AuthException catch (error) {
      errorMessage.value = error.message;
      _showError(error.message);
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Share ──────────────────────────────────────────────────────

  Future<void> onShare() async {
    final context = Get.overlayContext;
    if (context == null) return;

    try {
      final key = GlobalKey();
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (_) => Positioned(
          top: -9999,
          left: 0,
          width: 380,
          child: RepaintBoundary(
            key: key,
            child: ColoredBox(
              color: Colors.transparent,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: _buildShareWidget(),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(entry);

      // Two frames: first lays out, second paints
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        entry.remove();
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      entry.remove();

      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/progress_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')]);
    } catch (e) {
      debugPrint('Share failed: $e');
      AppLoadingService.showError('Share Failed', 'Could not generate image.');
    }
  }

  // ── Share Widget ───────────────────────────────────────────────

  Widget _buildShareWidget() {
    const primary = Color(0xFF00E5FF);
    const textPrimary = Color(0xFFF8FBFF);
    const textSecondary = Color(0xFFD7E0EC);

    final filter = filterTabs[selectedFilterIndex.value];
    final range = dateRange.value;
    final stats = statCards.toList();

    return Padding(
      padding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 28, right: 52),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.28),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'MY PROGRESS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: 1.0,
                          shadows: _shareTextShadow,
                        ),
                      ),
                    ],
                  ),
                  if (range.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '$filter  ·  $range',
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                        shadows: _shareTextShadow,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    volumeLabel.value,
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      shadows: _shareTextShadow,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalVolume.value,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          height: 1,
                          shadows: _shareStrongTextShadow,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          'kg',
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondary,
                            shadows: _shareTextShadow,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (stats.length >= 4) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _shareStatCard(
                            stats[0],
                            textPrimary,
                            textSecondary,
                            primary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _shareStatCard(
                            stats[1],
                            textPrimary,
                            textSecondary,
                            primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _shareStatCard(
                            stats[2],
                            textPrimary,
                            textSecondary,
                            primary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _shareStatCard(
                            stats[3],
                            textPrimary,
                            textSecondary,
                            primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Positioned(
              right: 60,
              bottom: 0,
              child: Image(
                image: AssetImage('assets/icons/app_icon.png'),
                width: 70,
                height: 70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareStatCard(
    Map<String, String> data,
    Color textDark,
    Color textGrey,
    Color primary,
  ) {
    final isPositive = data['isPositive'] == 'true';
    final isNeutral = data['isPositive'] == 'neutral';
    final changeColor = isNeutral
        ? textGrey
        : isPositive
        ? primary
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['label']!,
            style: TextStyle(
              fontSize: 11,
              color: textGrey,
              shadows: _shareTextShadow,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data['value']!,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textDark,
              shadows: _shareStrongTextShadow,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['change']!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: changeColor,
              shadows: _shareTextShadow,
            ),
          ),
        ],
      ),
    );
  }

  List<Shadow> get _shareTextShadow => const [
    Shadow(color: Color(0xA6000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  List<Shadow> get _shareStrongTextShadow => const [
    Shadow(color: Color(0xBF000000), blurRadius: 10, offset: Offset(0, 3)),
  ];

  // ── Date Helpers ───────────────────────────────────────────────

  String? _startDateForFilter(int index) {
    final days = switch (index) {
      1 => 7,
      2 => 30,
      3 => 90,
      _ => null,
    };
    if (days == null) return null;
    final start = DateTime.now().subtract(Duration(days: days - 1));
    return _formatDate(start);
  }

  String? _endDate() {
    if (selectedFilterIndex.value == 0) return null;
    return _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ── Apply Helpers ──────────────────────────────────────────────

  void _applySummary(ProgressSummary summary) {
    totalVolume.value = _formatNumber(summary.totalVolume);
    statCards.assignAll([
      {
        'label': 'Workout',
        'value': summary.totalWorkouts.toString(),
        'change': 'Total sessions',
        'isPositive': 'neutral',
      },
      {
        'label': 'Avg Duration',
        'value': '${summary.avgDuration}m',
        'change': 'Average time',
        'isPositive': 'neutral',
      },
      {
        'label': 'Total Sets',
        'value': summary.totalSets.toString(),
        'change': 'Completed sets',
        'isPositive': 'true',
      },
      {
        'label': 'Total Volume',
        'value': _formatNumber(summary.totalVolume),
        'change': 'kg lifted',
        'isPositive': 'true',
      },
    ]);
  }

  void _applyChart(List<ProgressChartPoint> chart) {
    if (chart.isEmpty) {
      chartPoints.clear();
      chartStartLabel.value = '';
      chartEndLabel.value = '';
      dateRange.value = '';
      return;
    }

    final maxVolume = chart
        .map((p) => p.volume)
        .fold<double>(0, (max, v) => v > max ? v : max);
    final denominator = chart.length > 1 ? chart.length - 1 : 1;

    chartPoints.assignAll(
      chart.asMap().entries.map((entry) {
        return ChartPoint(
          entry.key / denominator,
          maxVolume == 0 ? 0 : entry.value.volume / maxVolume,
        );
      }),
    );

    chartStartLabel.value = _formatShortDate(chart.first.date);
    chartEndLabel.value = _formatShortDate(chart.last.date);
    dateRange.value = '${chartStartLabel.value} - ${chartEndLabel.value}';
  }

  void _applyBests(List<ProgressBest> bests) {
    personalBests.assignAll(
      bests.map((best) {
        return PersonalBest(
          title: '${best.workoutName} 1RM',
          subtitle: '${_formatShortDate(best.date)} . ${best.equipmentName}',
          value: _formatNumber(best.bestOneRm),
          unit: 'kg',
          change: best.improvement > 0
              ? '↑ +${_formatNumber(best.improvement)}kg'
              : '→ Stable',
          iconType: 'bench',
        );
      }),
    );
  }

  String _volumeLabelForFilter(int index) {
    return switch (index) {
      1 => 'Total Volume Lifted (Last 7 Days)',
      2 => 'Total Volume Lifted (Last 30 Days)',
      3 => 'Total Volume Lifted (Last 90 Days)',
      _ => 'Total Volume Lifted',
    };
  }

  String _formatShortDate(DateTime? value) {
    if (value == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}';
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  void _showError(String message) {
    AppLoadingService.showError('Progress Failed', message);
  }
}
