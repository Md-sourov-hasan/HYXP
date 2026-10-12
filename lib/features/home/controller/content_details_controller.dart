import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';
import 'package:hawiisaac/features/home/services/content_api_service.dart';

class ContentDetailsController extends GetxController {
  final ContentApiService _contentApiService = ContentApiService();

  final Rxn<ContentItem> content = Rxn<ContentItem>();
  final RxBool isLoading = false.obs;
  final RxBool isBookmarking = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is ContentItem) {
      content.value = args;
      fetchContentDetail(args.id);
      return;
    }

    if (args is int && args > 0) {
      fetchContentDetail(args);
    }
  }

  Future<void> fetchContentDetail(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      content.value = await _contentApiService.getContentById(id);
    } on AuthException catch (error) {
      errorMessage.value = error.message;
      AppLoadingService.showError('Content Failed', error.message);
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      AppLoadingService.showError('Content Failed', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onBookmarkTap() async {
    final item = content.value;
    if (item == null || isBookmarking.value) return;

    isBookmarking.value = true;
    try {
      final result = item.isBookmarked
          ? await _contentApiService.removeBookmark(item.id)
          : await _contentApiService.addBookmark(item.id);

      content.value = item.copyWith(
        isBookmarked: result.isBookmarked,
        bookmarkCount: result.bookmarkCount,
        myReaction: result.myReaction,
      );
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().applyBookmarkResult(result);
      }
      AppLoadingService.showSuccess(
        result.isBookmarked ? 'Saved' : 'Removed',
        result.isBookmarked
            ? 'Content added to bookmarks'
            : 'Content removed from bookmarks',
      );
    } on AuthException catch (error) {
      AppLoadingService.showError('Bookmark Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Bookmark Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isBookmarking.value = false;
    }
  }
}
