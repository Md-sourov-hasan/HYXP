import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/scan/model/scan_result.dart';
import 'package:hawiisaac/features/scan/services/equipment_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanEquipmentController extends GetxController {
  final EquipmentApiService _equipmentApiService = EquipmentApiService();

  // ── Detection Modes ────────────────────────────────────────────
  final List<String> detectionModes = [
    'Auto detect',
    'Barbell',
    'Dumbbell',
    'Kettlebell',
    'Cable',
  ];

  final RxInt selectedModeIndex = 0.obs;

  // ── Scanner State ──────────────────────────────────────────────
  final RxBool isScanning = true.obs;
  final RxBool isProcessingScan = false.obs;

  CameraController? cameraController;
  final RxBool isCameraInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        AppLoadingService.showError(
          'Permission Denied',
          'Camera permission is required',
        );
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        AppLoadingService.showError(
          'Camera Error',
          'No cameras available on this device',
        );
        return;
      }

      final firstCamera = cameras.first;
      cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      AppLoadingService.showError('Camera Error', 'Failed to initialize: $e');
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  void onModeSelected(int index) {
    selectedModeIndex.value = index;
  }

  void onChooseManually() {
    Get.toNamed(AppRoute.getEquipmentView());
    AppLoadingService.showInfo('Manual Selection', 'Opening equipment list...');
  }

  void onBackTapped() {
    Get.back();
  }

  Future<void> onScanNow() async {
    if (isProcessingScan.value) return;
    if (!isCameraInitialized.value || cameraController == null) {
      AppLoadingService.showError(
        'Camera Not Ready',
        'Please wait for the camera to finish loading.',
      );
      return;
    }

    isProcessingScan.value = true;
    try {
      final image = await cameraController!.takePicture();
      if (selectedModeIndex.value == 0) {
        final result = await _equipmentApiService.scanEquipmentUpload(
          image.path,
        );
        _handleAutoDetectResult(result, image.path);
      } else {
        final equipmentName = detectionModes[selectedModeIndex.value];
        final result = await _equipmentApiService.verifyEquipment(
          equipmentName: equipmentName,
          imagePath: image.path,
        );
        _handleVerificationResult(result, image.path, equipmentName);
      }
    } on AuthException catch (error) {
      AppLoadingService.showError('Scan Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Scan Failed',
        'Something went wrong while scanning. Please try again.',
      );
    } finally {
      isProcessingScan.value = false;
    }
  }

  // Description text based on selected mode
  String get modeTitle {
    switch (selectedModeIndex.value) {
      case 1:
        return 'Point at a Barbell';
      case 2:
        return 'Point at a Dumbbell';
      case 3:
        return 'Point at a Kettlebell';
      case 4:
        return 'Point at a Cable machine';
      default:
        return 'Point at any equipment';
    }
  }

  String get modeSubtitle {
    switch (selectedModeIndex.value) {
      case 1:
        return 'The scanner identifies barbells and loads barbell exercises automatically';
      case 2:
        return 'The scanner identifies dumbbells and loads dumbbell exercises automatically';
      case 3:
        return 'The scanner identifies kettlebells and loads kettlebell exercises automatically';
      case 4:
        return 'The scanner identifies cable machines and loads cable exercises automatically';
      default:
        return 'The scanner identifies gym equipment and loads exercise automatically';
    }
  }

  String get scanButtonText {
    return selectedModeIndex.value == 0
        ? 'Auto detect equipment'
        : 'Verify equipment';
  }

  void _handleAutoDetectResult(EquipmentScanResult result, String imagePath) {
    if (!result.hasMatch) {
      AppLoadingService.showError(
        'Equipment Not Found',
        result.errorMessage.isNotEmpty
            ? result.errorMessage
            : 'This equipment is not found in this gym.',
      );
      return;
    }

    Get.toNamed(
      AppRoute.getMatchedEquipmentScreen(),
      arguments: <String, dynamic>{
        'showMismatchPrompt': true,
        'equipmentId': result.primaryEquipmentId,
        'equipmentName': result.primaryEquipment,
        'matchText': result.primaryEquipment.trim().isNotEmpty
            ? 'Detected ${result.primaryEquipment}'
            : 'Equipment detected successfully',
        'recommendedWorkoutIds': result.recommendedWorkoutIds,
        'detectedEquipment': result.equipmentDetected,
        'scanImagePath': imagePath,
      },
    );
  }

  void _handleVerificationResult(
    EquipmentVerificationResult result,
    String imagePath,
    String equipmentName,
  ) {
    if (!result.success || !result.isMatch) {
      AppLoadingService.showError(
        'Equipment Not Matched',
        result.message.isNotEmpty
            ? result.message
            : 'The scanned image did not match $equipmentName.',
      );
      return;
    }

    Get.toNamed(
      AppRoute.getMatchedEquipmentScreen(),
      arguments: <String, dynamic>{
        'showMismatchPrompt': true,
        'equipmentName': equipmentName,
        'matchText': result.message.isNotEmpty
            ? result.message
            : 'Yes, this is $equipmentName',
        'confidence': result.confidence,
        'scanImagePath': imagePath,
      },
    );
  }
}
