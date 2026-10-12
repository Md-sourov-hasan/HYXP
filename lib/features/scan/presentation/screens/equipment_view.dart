import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/authentication/widgets/custom_primary_button.dart';
import 'package:hawiisaac/features/scan/controller/equipment_controller.dart';

class EquipmentView extends StatelessWidget {
  const EquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EquipmentController());

    return Scaffold(
      appBar: _buildAppBar(context, controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton(context);
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildSearchBar(context, controller),
                    SizedBox(height: 20.h),
                    _buildCategoryChips(context, controller),
                    SizedBox(height: 20.h),
                    _buildEquipmentGrid(context, controller),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            _buildContinueButton(controller),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: AppBar
  // ─────────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    EquipmentController controller,
  ) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.blackColor,
          size: 24.r,
        ),
        onPressed: controller.onBackTapped,
      ),
      centerTitle: true,
      title: Obx(
        () => Text(
          controller.appBarTitle.value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Divider(height: 1.h, color: Theme.of(context).dividerColor),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Search Bar
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context, EquipmentController controller) {
    return TextFormField(
      controller: controller.searchController,
      style: TextStyle(fontSize: 15.sp, color: AppColors.blackColor),
      decoration: InputDecoration(
        hintText: controller.searchHint.value,
        hintStyle: TextStyle(
          fontSize: 15.sp,
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Icon(
            Icons.search_rounded,
            size: 22.r,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 48.w),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5.w),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Category Chips
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryChips(
    BuildContext context,
    EquipmentController controller,
  ) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            controller.categories.length,
            (index) => Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: _buildCategoryChip(context, controller, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    EquipmentController controller,
    int index,
  ) {
    final bool isSelected = controller.selectedCategoryIndex.value == index;

    return GestureDetector(
      onTap: () => controller.onCategorySelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          controller.categories[index],
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.blackColor : AppColors.blackColor,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Equipment Grid
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEquipmentGrid(
    BuildContext context,
    EquipmentController controller,
  ) {
    return Obx(() {
      final items = controller.filteredEquipments;

      if (items.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text(
              'No equipment found',
              style: TextStyle(fontSize: 15.sp, color: const Color(0xFF9CA3AF)),
            ),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14.w,
          mainAxisSpacing: 14.h,
          childAspectRatio: 0.95,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildEquipmentCard(context, controller, index);
        },
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER: Equipment Card
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEquipmentCard(
    BuildContext context,
    EquipmentController controller,
    int index,
  ) {
    return Obx(() {
      final equipment = controller.filteredEquipments[index];
      final bool isSelected = controller.selectedEquipmentIndex.value == index;
      final image = equipment['image']?.toString() ?? '';
      final category = equipment['category']?.toString() ?? '';

      return GestureDetector(
        onTap: () => controller.onEquipmentSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              width: 2.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon Box ─────────────────────────────────────────────
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.darkButtonColor.withValues(alpha: 0.3)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            image,
                            width: 64.r,
                            height: 64.r,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.fitness_center_rounded,
                              size: 32.r,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.black,
                            ),
                          ),
                        )
                      : equipment['icon'] is String
                      ? Image.asset(
                          equipment['icon'] as String,
                          width: 32.r,
                          height: 32.r,
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.black,
                        )
                      : Icon(
                          equipment['icon'] as IconData,
                          size: 32.r,
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.black,
                        ),
                ),
              ),
              const Spacer(),
              // ── Name ─────────────────────────────────────────────────
              Text(
                equipment['name'] ?? '',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 4.h),
              // ── Exercise Count ───────────────────────────────────────
              Text(
                category.isNotEmpty ? category : 'Equipment',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION: Continue Button
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildContinueButton(EquipmentController controller) {
    return Obx(
      () => CustomPrimaryButton(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        text: controller.isDetailLoading.value
            ? 'Loading...'
            : controller.buttonText.value,
        onTap: controller.onContinueTapped,
        isLoading: controller.isDetailLoading.value,
        backgroundColor: AppColors.primaryColor,
        textColor: AppColors.blackColor,
        height: 56.h,
        borderRadius: 14,
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 52.h, radius: 12),
          SizedBox(height: 20.h),
          Row(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: ShimmerBox(width: 90.w, height: 40.h, radius: 30),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: 0.95,
            ),
            itemCount: 4,
            itemBuilder: (context, index) =>
                ShimmerBox(width: double.infinity, height: 170.h, radius: 16),
          ),
        ],
      ),
    );
  }
}
