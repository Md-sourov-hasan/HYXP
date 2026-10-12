import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/controller/home_controller.dart';
import 'package:hawiisaac/features/profile/model/current_user.dart';
import 'package:hawiisaac/features/profile/controller/profile_controller.dart';
import 'package:hawiisaac/features/profile/services/current_user_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final CurrentUserService _currentUserService = CurrentUserService();

  final RxString name = ''.obs;
  final RxString username = ''.obs;
  final RxString bio = ''.obs;
  final RxString sex = ''.obs;
  final RxString birthday = ''.obs;
  final Rxn<DateTime> selectedDob = Rxn<DateTime>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rxn<CurrentUser> currentUser = Rxn<CurrentUser>();

  final RxString profileImagePath = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }

  Future<void> fetchCurrentUser() async {
    isLoading.value = true;

    try {
      final user = await _currentUserService.getProfile();
      currentUser.value = user;
      name.value = user.name.isNotEmpty ? user.name : user.displayName;
      username.value = user.username;
      bio.value = user.bio;
      sex.value = _capitalize(user.gender);
      selectedDob.value = user.dob;
      birthday.value = _formatDate(user.dob);
      profileImageUrl.value = user.effectivePhoto;

      nameController.text = name.value;
      usernameController.text = username.value;
      bioController.text = bio.value;
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      AppLoadingService.showError('Error', 'Failed to pick image: $e');
    }
  }

  void onChangePicture() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void onSexTap() {
    final current = sex.value.trim().toLowerCase();
    final next = current == 'female' ? 'Male' : 'Female';
    sex.value = next;
  }

  Future<void> onDone() async {
    if (isSaving.value) return;

    final nextName = nameController.text.trim();
    final nextUsername = usernameController.text.trim();
    final nextBio = bioController.text.trim();
    final nextGender = sex.value.trim().toLowerCase();

    if (nextUsername.isEmpty) {
      _showError('Username is required.');
      return;
    }

    isSaving.value = true;
    try {
      await _currentUserService.updateProfile(
        username: nextUsername,
        name: nextName,
        bio: nextBio,
        gender: nextGender,
        dob: selectedDob.value,
        photoPath: profileImagePath.value,
      );

      final freshUser = await _currentUserService.getProfile();

      currentUser.value = freshUser;
      name.value = freshUser.name.isNotEmpty ? freshUser.name : freshUser.displayName;
      username.value = freshUser.username;
      bio.value = freshUser.bio;
      sex.value = _capitalize(freshUser.gender);
      selectedDob.value = freshUser.dob;
      birthday.value = _formatDate(freshUser.dob);
      profileImageUrl.value = freshUser.effectivePhoto;
      profileImagePath.value = '';

      nameController.text = name.value;
      usernameController.text = username.value;
      bioController.text = bio.value;

      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().fetchCurrentUser();
      }
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchCurrentUser();
      }

      AppLoadingService.showSuccess(
        'Profile Updated',
        'Profile updated successfully',
      );
      Get.back();
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> onBirthdayTap(BuildContext context) async {
    final now = DateTime.now();
    final initialDate =
        selectedDob.value ??
        DateTime(now.year - 18, now.month, now.day > 28 ? 28 : now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate == null) return;

    selectedDob.value = pickedDate;
    birthday.value = _formatDate(pickedDate);
  }

  void onBack() {
    Get.back();
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';

    final monthNames = <String>[
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

    return '${value.day} ${monthNames[value.month - 1]}, ${value.year}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return '';

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  void _showError(String message) {
    AppLoadingService.showError('Profile Failed', message);
  }
}
