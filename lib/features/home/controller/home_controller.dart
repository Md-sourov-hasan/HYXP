import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';
import 'package:hawiisaac/features/home/services/content_api_service.dart';
import 'package:hawiisaac/features/profile/model/current_user.dart';
import 'package:hawiisaac/features/profile/services/current_user_service.dart';
import 'package:hawiisaac/features/sessions/model/session_models.dart';
import 'package:hawiisaac/features/sessions/services/session_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class HomeController extends GetxController {
  final ContentApiService _contentApiService = ContentApiService();
  final CurrentUserService _currentUserService = CurrentUserService();
  final SessionApiService _sessionApiService = SessionApiService();

  // ── User Info ──────────────────────────────────────────────────
  final RxString userName = 'User'.obs;
  final RxString userInitials = 'U'.obs;
  final RxString greeting = ''.obs;
  final RxString userPhoto = ''.obs;
  final Rxn<CurrentUser> currentUser = Rxn<CurrentUser>();

  // ── Stats ──────────────────────────────────────────────────────
  final RxString daysStreak = '0'.obs;
  final RxString thisWeek = '0'.obs;
  final RxString caloriesBurned = '0'.obs;
  final RxBool isHighlightsLoading = false.obs;

  // ── Recent Activities ──────────────────────────────────────────
  final RxBool isSessionsLoading = false.obs;
  final RxList<Map<String, String>> recentActivities =
      <Map<String, String>>[].obs;

  // ── Content Tabs ───────────────────────────────────────────────
  final List<HomeContentTab> workoutTabs = const [
    HomeContentTab(label: 'For you', feed: 'for_you'),
    HomeContentTab(label: 'Browse', feed: 'browse'),
    HomeContentTab(label: 'Expert Tips', feed: 'expert_tips'),
    HomeContentTab(label: 'Trending', feed: 'trending'),
  ];
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isContentLoading = false.obs;
  final RxnInt bookmarkingContentId = RxnInt();
  final RxString contentErrorMessage = ''.obs;

  final RxList<ContentItem> featuredContents = <ContentItem>[].obs;
  final RxList<ContentItem> moreContents = <ContentItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    greeting.value = _currentGreeting();
    fetchCurrentUser();
    fetchProgressHighlights();
    fetchRecentSessions();
    fetchContents();
  }

  String get selectedTabLabel => workoutTabs[selectedTabIndex.value].label;

  String get selectedFeed => workoutTabs[selectedTabIndex.value].feed;

  void onTabSelected(int index) {
    if (selectedTabIndex.value == index) return;

    selectedTabIndex.value = index;
    fetchContents();
  }

  // ── Content Cards ──────────────────────────────────────────────
  Future<void> fetchContents() async {
    isContentLoading.value = true;
    contentErrorMessage.value = '';

    try {
      final contents = await _contentApiService.getContents(
        feed: selectedFeed,
        limit: 20,
      );
      final normalizedSelectedFeed = selectedFeed.trim().toLowerCase();
      final filteredContents = normalizedSelectedFeed.isEmpty
          ? contents
          : contents
                .where(
                  (item) => item.feedType.trim().toLowerCase() ==
                      normalizedSelectedFeed,
                )
                .toList(growable: false);
      final splitIndex = filteredContents.length > 1
          ? (filteredContents.length / 2).ceil()
          : filteredContents.length;

      featuredContents.assignAll(filteredContents.take(splitIndex));
      moreContents.assignAll(filteredContents.skip(splitIndex));
    } on AuthException catch (error) {
      contentErrorMessage.value = error.message;
      _showContentError(error.message);
    } catch (_) {
      contentErrorMessage.value = 'Something went wrong. Please try again.';
      _showContentError(contentErrorMessage.value);
    } finally {
      isContentLoading.value = false;
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await _currentUserService.getProfile();
      currentUser.value = user;
      userName.value = user.displayName;
      userInitials.value = _initialsFor(user);
      userPhoto.value = user.effectivePhoto;
    } on AuthException catch (error) {
      AppLoadingService.showError('Profile Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Profile Failed',
        'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> fetchRecentSessions() async {
    isSessionsLoading.value = true;

    try {
      final sessions = await _sessionApiService.getProgressRecentActivity(
        limit: 3,
      );
      recentActivities.assignAll(
        sessions.asMap().entries.map(
          (entry) => _recentProgressToActivity(entry.value, entry.key),
        ),
      );
    } on AuthException catch (error) {
      AppLoadingService.showError('Sessions Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Sessions Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isSessionsLoading.value = false;
    }
  }

  Future<void> fetchProgressHighlights() async {
    isHighlightsLoading.value = true;

    try {
      final highlights = await _sessionApiService.getProgressHighlights();
      daysStreak.value = highlights.daysStreak.toString();
      thisWeek.value = highlights.workoutsThisWeek.toString();
      caloriesBurned.value = _formatHighlightNumber(highlights.caloriesBurned);
    } on AuthException catch (error) {
      AppLoadingService.showError('Highlights Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Highlights Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isHighlightsLoading.value = false;
    }
  }

  // ── Actions ────────────────────────────────────────────────────
  void onBookmarkTap() {
    final bookmarkedContents = <ContentItem>[
      ...featuredContents,
      ...moreContents,
    ].where((item) => item.isBookmarked).toList(growable: false);

    Get.toNamed(AppRoute.getBookmarksScreen(), arguments: bookmarkedContents);
  }

  void onMessageTap() => Get.toNamed(AppRoute.getNotificationsScreen());

  Future<void> onContentBookmark(ContentItem content) async {
    if (bookmarkingContentId.value != null) return;

    bookmarkingContentId.value = content.id;
    try {
      final result = content.isBookmarked
          ? await _contentApiService.removeBookmark(content.id)
          : await _contentApiService.addBookmark(content.id);

      applyBookmarkResult(result);
      AppLoadingService.showSuccess(
        result.isBookmarked ? 'Saved' : 'Removed',
        result.isBookmarked
            ? '"${content.title}" added to bookmarks'
            : '"${content.title}" removed from bookmarks',
      );
    } on AuthException catch (error) {
      AppLoadingService.showError('Bookmark Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Bookmark Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      bookmarkingContentId.value = null;
    }
  }

  bool isBookmarkingContent(int contentId) {
    return bookmarkingContentId.value == contentId;
  }

  void applyBookmarkResult(ContentBookmarkResult result) {
    _updateContentBookmark(result);
  }

  void onContentTap(ContentItem content) {
    Get.toNamed(
      AppRoute.getWarmUpDetailsScreen(),
      arguments: {
        'content_id': content.id.toString(),
        'title': content.title,
        'description': content.body,
        'meta': content.summary,
        'image': content.image,
        'tags': content.feedLabel,
        'sets': '-',
        'reps': '-',
        'rest': '-',
        'video': content.video,
      },
    );
  }

  void _updateContentBookmark(ContentBookmarkResult result) {
    _updateBookmarkInList(featuredContents, result);
    _updateBookmarkInList(moreContents, result);
  }

  void _updateBookmarkInList(
    RxList<ContentItem> items,
    ContentBookmarkResult result,
  ) {
    final index = items.indexWhere((item) => item.id == result.contentId);
    if (index == -1) return;

    items[index] = items[index].copyWith(
      isBookmarked: result.isBookmarked,
      bookmarkCount: result.bookmarkCount,
      myReaction: result.myReaction,
    );
  }

  void _showContentError(String message) {
    AppLoadingService.showError('Content Failed', message);
  }

  Map<String, String> _recentProgressToActivity(
    ProgressRecentActivity activity,
    int index,
  ) {
    final fallback = _activityFallback(index);
    final dayLabel = activity.dayLabel.isNotEmpty
        ? activity.dayLabel
        : _formatActivityDate(activity.date);

    return <String, String>{
      'title': activity.title.isNotEmpty ? activity.title : fallback['title']!,
      'time': '$dayLabel . ${activity.durationMinutes} min',
      'sets': activity.setCount.toString(),
      'icon': fallback['icon']!,
    };
  }

  Map<String, String> _activityFallback(int index) {
    const fallbacks = <Map<String, String>>[
      {'title': 'Upper Body', 'icon': 'upper'},
      {'title': 'Leg Day', 'icon': 'leg'},
      {'title': 'Pull Day', 'icon': 'pull'},
    ];

    return fallbacks[index % fallbacks.length];
  }

  String _formatActivityDate(DateTime? value) {
    if (value == null) return 'No date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(value.year, value.month, value.day);
    final difference = today.difference(sessionDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';

    const months = <String>[
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

  String _currentGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatHighlightNumber(double value) {
    if (value % 1 == 0) return value.toInt().toString();

    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _initialsFor(CurrentUser user) {
    final parts = user.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class HomeContentTab {
  const HomeContentTab({required this.label, required this.feed});

  final String label;
  final String feed;
}
