import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/controller/selectunit_controller.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';

class SelectUnitsView extends StatelessWidget {
  const SelectUnitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelectUnitsController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),
                    _buildWeightSection(controller),
                    SizedBox(height: 28.h),
                    _buildDistanceSection(controller),
                    SizedBox(height: 28.h),
                    _buildBodyMeasurementSection(controller),
                  ],
                ),
              ),
            ),
            _buildGetStartedButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Text(
          'Select Units',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 16.h),
        Divider(color: const Color(0xFF2C2C2C), thickness: 1),
      ],
    );
  }

  Widget _buildWeightSection(SelectUnitsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(icon: 'assets/icons/weight.png', label: 'Weight'),
        SizedBox(height: 12.h),
        Obx(
          () => _buildToggleButtonRow(
            options: controller.weightOptions,
            selected: controller.selectedWeight.value,
            onSelect: controller.selectWeight,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceSection(SelectUnitsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: 'assets/icons/distance.png',
          label: 'Distance',
        ),
        SizedBox(height: 12.h),
        Obx(
          () => _buildToggleButtonRow(
            options: controller.distanceOptions,
            selected: controller.selectedDistance.value,
            onSelect: controller.selectDistance,
          ),
        ),
      ],
    );
  }

  Widget _buildBodyMeasurementSection(SelectUnitsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: 'assets/icons/body_mesurments.png',
          label: 'Body Measurements',
        ),
        SizedBox(height: 12.h),
        Obx(
          () => _buildToggleButtonRow(
            options: controller.bodyMeasurementOptions,
            selected: controller.selectedBodyMeasurement.value,
            onSelect: controller.selectBodyMeasurement,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel({required dynamic icon, required String label}) {
    return Row(
      children: [
        icon is String
            ? Image.asset(
                icon,
                width: 22.w,
                height: 22.w,
                color: AppColors.blackColor,
              )
            : Icon(icon as IconData, size: 22.sp, color: AppColors.blackColor),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtonRow({
    required List<String> options,
    required String selected,
    required void Function(String) onSelect,
  }) {
    return Row(
      children: options
          .map(
            (option) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: option == options.last ? 0 : 12.w,
                ),
                child: _buildToggleButton(
                  label: option,
                  isSelected: selected == option,
                  onTap: () => onSelect(option),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final unselectedTextColor = Get.isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : const Color(0xFfEAEAEA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFF9E9E9E),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.black : unselectedTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(SelectUnitsController controller) {
    return Obx(
      () => CustomPrimaryButton(
        text: 'Get Started',
        onTap: controller.onGetStarted,
        isLoading: controller.isLoading.value,
        borderRadius: 16,
        margin: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      ),
    );
  }
}
