import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/scan/model/equipment_category.dart';
import 'package:hawiisaac/features/scan/model/equipment_item.dart';
import 'package:hawiisaac/features/scan/model/muscle_group.dart';
import 'package:hawiisaac/features/scan/services/equipment_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class EquipmentController extends GetxController {
  final EquipmentApiService _equipmentApiService = EquipmentApiService();

  // ─── Text Editing Controllers ───────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();

  // ─── Observable State ───────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isDetailLoading = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt selectedEquipmentIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  // ─── Screen Content ─────────────────────────────────────────────────────────
  final RxString appBarTitle = 'Equipment'.obs;
  final RxString searchHint = 'Search equipment'.obs;
  final RxString buttonText = 'Continue'.obs;

  // ─── Category Filters ────────────────────────────────────────────────────────
  final RxList<String> categories = <String>[].obs;

  // ─── Equipment List ──────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> allEquipments =
      <Map<String, dynamic>>[].obs;
  final RxList<EquipmentCategory> apiCategories = <EquipmentCategory>[].obs;
  final RxList<EquipmentItem> apiEquipments = <EquipmentItem>[].obs;
  final RxList<MuscleGroup> muscleGroups = <MuscleGroup>[].obs;

  // ─── Computed: Filtered Equipment ────────────────────────────────────────────
  List<Map<String, dynamic>> get filteredEquipments {
    final query = searchQuery.value.toLowerCase();
    final selectedCategory = categories.isNotEmpty
        ? categories[selectedCategoryIndex.value]
        : 'All';

    return allEquipments.where((eq) {
      final matchesSearch =
          query.isEmpty || (eq['name'] as String).toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == 'All' || eq['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ─── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchEquipments();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchEquipments() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final responses = await Future.wait([
        _equipmentApiService.getCategories(),
        _equipmentApiService.getEquipments(),
        _equipmentApiService.getMuscleGroups(),
      ]);

      final fetchedCategories = responses[0] as List<EquipmentCategory>;
      final fetchedEquipments = responses[1] as List<EquipmentItem>;
      final fetchedMuscleGroups = responses[2] as List<MuscleGroup>;

      apiCategories.assignAll(fetchedCategories);
      apiEquipments.assignAll(fetchedEquipments);
      muscleGroups.assignAll(fetchedMuscleGroups);

      categories.assignAll([
        'All',
        ...fetchedCategories.map((category) => category.name),
      ]);
      allEquipments.assignAll(fetchedEquipments.map(_equipmentToMap));
      selectedCategoryIndex.value = 0;
      selectedEquipmentIndex.value = allEquipments.isEmpty ? -1 : 0;
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

  // ─── Methods ────────────────────────────────────────────────────────────────

  void onCategorySelected(int index) {
    selectedCategoryIndex.value = index;
    selectedEquipmentIndex.value = -1;
  }

  void onEquipmentSelected(int index) {
    selectedEquipmentIndex.value = index;
  }

  void onBackTapped() {
    Get.back();
  }

  Future<void> onContinueTapped() async {
    if (selectedEquipmentIndex.value < 0) {
      AppLoadingService.showError(
        'Select Equipment',
        'Please select an equipment to continue.',
      );
      return;
    }

    final selectedEquipment = filteredEquipments[selectedEquipmentIndex.value];
    final equipmentId = int.tryParse(selectedEquipment['id']?.toString() ?? '');
    final equipmentName = selectedEquipment['name']?.toString().trim() ?? '';
    final equipmentImageUrl =
        selectedEquipment['image']?.toString().trim() ?? '';

    Get.toNamed(
      AppRoute.getMatchedEquipmentScreen(),
      arguments: <String, dynamic>{
        'showMismatchPrompt': false,
        if (equipmentId != null && equipmentId > 0) 'equipmentId': equipmentId,
        if (equipmentName.isNotEmpty) 'equipmentName': equipmentName,
        if (equipmentImageUrl.isNotEmpty)
          'equipmentImageUrl': equipmentImageUrl,
        'matchText': equipmentName.isNotEmpty
            ? 'You selected $equipmentName manually.'
            : 'Equipment selected successfully',
      },
    );
  }

  Future<EquipmentItem?> fetchEquipmentDetail(int id) async {
    isDetailLoading.value = true;

    try {
      return await _equipmentApiService.getEquipmentById(id);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isDetailLoading.value = false;
    }

    return null;
  }

  Future<void> fetchCategoryDetail(int id) async {
    try {
      await _equipmentApiService.getCategoryById(id);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    }
  }

  Future<void> fetchMuscleGroupDetail(int id) async {
    try {
      await _equipmentApiService.getMuscleGroupById(id);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    }
  }

  Map<String, dynamic> _equipmentToMap(EquipmentItem equipment) {
    return <String, dynamic>{
      'id': equipment.id,
      'name': equipment.name,
      'description': equipment.description,
      'category': equipment.category.name,
      'image': equipment.image,
      'exerciseCount': 0,
    };
  }

  void _showError(String message) {
    AppLoadingService.showError('Equipment Failed', message);
  }

  void onNavHomeTapped() {}
  void onNavScanTapped() {}
  void onNavAddTapped() {}
  void onNavStatsTapped() {}
}
