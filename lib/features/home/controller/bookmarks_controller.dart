import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';
import 'package:hawiisaac/features/home/services/content_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class BookmarksController extends GetxController {
  final ContentApiService _contentApiService = ContentApiService();
  final RxList<ContentItem> bookmarks = <ContentItem>[].obs;
  final RxnInt bookmarkingContentId = RxnInt();
  Worker? _bookmarkSyncWorker;

  @override
  void onInit() {
    super.onInit();
    _loadBookmarks();
  }

  @override
  void onClose() {
    _bookmarkSyncWorker?.dispose();
    super.onClose();
  }

  void onBackTap() => Get.back();

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

  Future<void> removeBookmark(ContentItem content) async {
    if (bookmarkingContentId.value != null) return;

    bookmarkingContentId.value = content.id;
    try {
      final result = await _contentApiService.removeBookmark(content.id);
      _removeBookmarkFromList(result.contentId);

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().applyBookmarkResult(result);
      }

      AppLoadingService.showSuccess(
        'Removed',
        '"${content.title}" removed from bookmarks',
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

  void _loadBookmarks() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      _syncFromHome(homeController);
      _bookmarkSyncWorker ??= everAll([
        homeController.featuredContents,
        homeController.moreContents,
      ], (_) => _syncFromHome(homeController));
      return;
    }

    final args = Get.arguments;
    if (args is List<ContentItem>) {
      bookmarks.assignAll(_uniqueBookmarked(args));
      _refreshBookmarkCounts();
    }
  }

  void _syncFromHome(HomeController homeController) {
    bookmarks.assignAll(
      _uniqueBookmarked([
        ...homeController.featuredContents,
        ...homeController.moreContents,
      ]),
    );
    _refreshBookmarkCounts();
  }

  Future<void> _refreshBookmarkCounts() async {
    final snapshot = List<ContentItem>.from(bookmarks);
    if (snapshot.isEmpty) return;

    for (final item in snapshot) {
      try {
        final result = await _contentApiService.getBookmarkCount(item.id);
        _updateBookmarkCount(item.id, result.bookmarkCount);
      } on AuthException catch (error) {
        AppLoadingService.showError('Bookmark Count Failed', error.message);
        break;
      } catch (_) {
        AppLoadingService.showError(
          'Bookmark Count Failed',
          'Something went wrong. Please try again.',
        );
        break;
      }
    }
  }

  void _updateBookmarkCount(int contentId, int bookmarkCount) {
    final index = bookmarks.indexWhere((item) => item.id == contentId);
    if (index == -1) return;

    final item = bookmarks[index];
    bookmarks[index] = item.copyWith(bookmarkCount: bookmarkCount);

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().applyBookmarkResult(
        ContentBookmarkResult(
          contentId: contentId,
          isBookmarked: item.isBookmarked,
          bookmarkCount: bookmarkCount,
          myReaction: item.myReaction,
        ),
      );
    }
  }

  void _removeBookmarkFromList(int contentId) {
    bookmarks.removeWhere((item) => item.id == contentId);
  }

  List<ContentItem> _uniqueBookmarked(List<ContentItem> items) {
    final uniqueItems = <int, ContentItem>{};

    for (final item in items) {
      if (item.isBookmarked) {
        uniqueItems[item.id] = item;
      }
    }

    return uniqueItems.values.toList(growable: false);
  }
}
