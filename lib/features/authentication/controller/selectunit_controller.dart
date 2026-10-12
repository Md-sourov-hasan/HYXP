import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/user_preference_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/authentication/services/user_preference_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class SelectUnitsController extends GetxController {
  final UserPreferenceService _preferenceService = UserPreferenceService();

  // Weight
  final RxString selectedWeight = 'lbs'.obs;

  // Distance
  final RxString selectedDistance = 'miles'.obs;

  // Body Measurements
  final RxString selectedBodyMeasurement = 'in'.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasPreference = false.obs;

  // Weight options
  final List<String> weightOptions = ['lbs', 'kg'];

  // Distance options
  final List<String> distanceOptions = ['miles', 'km'];

  // Body measurement options
  final List<String> bodyMeasurementOptions = ['in', 'cm'];

  @override
  void onInit() {
    super.onInit();
    getPreference(showError: false);
  }

  void selectWeight(String value) => selectedWeight.value = value;

  void selectDistance(String value) => selectedDistance.value = value;

  void selectBodyMeasurement(String value) =>
      selectedBodyMeasurement.value = value;

  Future<void> onGetStarted() async {
    await updatePreference();
  }

  Future<void> createPreference() async {
    await _savePreference(
      request: _selectedPreferenceRequest,
      saveRequest: _preferenceService.createPreference,
      successMessage: 'Units saved successfully',
    );
  }

  Future<void> getPreference({bool showError = true}) async {
    isLoading.value = true;

    try {
      final preference = await _preferenceService.getPreference();
      hasPreference.value = true;
      if (preference.weight.isNotEmpty) {
        selectedWeight.value = preference.weight;
      }
      if (preference.distance.isNotEmpty) {
        selectedDistance.value = preference.distance;
      }
      if (preference.bodyMeasurements.isNotEmpty) {
        selectedBodyMeasurement.value = preference.bodyMeasurements;
      }
    } on AuthException catch (error) {
      if (showError && error.statusCode != 404) {
        _showError(error.message);
      }
    } catch (_) {
      if (showError) {
        _showError('Something went wrong. Please try again.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePreference() async {
    await _savePreference(
      request: _selectedPreferenceRequest,
      saveRequest: _preferenceService.updatePreference,
      successMessage: 'Units saved successfully',
    );
  }

  Future<void> deletePreference() async {
    isLoading.value = true;

    try {
      final response = await _preferenceService.deletePreference();
      AppLoadingService.showSuccess(
        'Preference Deleted',
        response.message.isNotEmpty ? response.message : 'Preference deleted',
      );
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _savePreference({
    required UserPreferenceRequest request,
    required Future<Object?> Function(UserPreferenceRequest request)
    saveRequest,
    required String successMessage,
  }) async {
    isLoading.value = true;

    try {
      await saveRequest(request);
      await StorageService.setHasSelectedUnits(true);
      Get.offAllNamed(AppRoute.getBottomNavigationScreen());
      AppLoadingService.showSuccess('Success', successMessage);
    } on AuthException catch (error) {
      if (!hasPreference.value &&
          (error.statusCode == 400 || error.statusCode == 409)) {
        hasPreference.value = true;
        await updatePreference();
      } else {
        _showError(error.message);
      }
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  UserPreferenceRequest get _selectedPreferenceRequest {
    return UserPreferenceRequest(
      weight: selectedWeight.value,
      distance: selectedDistance.value,
      bodyMeasurements: selectedBodyMeasurement.value,
    );
  }

  void _showError(String message) {
    AppLoadingService.showError('Preference Failed', message);
  }
}
