import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/profile/controller/edit_profile_controller.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              _buildHeader(context, controller),
              Expanded(
                child: controller.isLoading.value
                    ? _buildLoadingContent(context)
                    : _buildContent(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EditProfileController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildAvatar(controller),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: controller.onChangePicture,
            child: Text(
              'Change Picture',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildSectionHeader(context, 'Public profile data'),
          _buildTextField(
            context,
            label: 'Username',
            controller: controller.usernameController,
            hintText: 'Username',
          ),
          _buildDivider(context),
          _buildTextField(
            context,
            label: 'Name',
            controller: controller.nameController,
            hintText: 'Name',
          ),
          _buildDivider(context),
          _buildTextField(
            context,
            label: 'Bio',
            controller: controller.bioController,
            hintText: 'Bio',
          ),
          _buildDivider(context),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Private information'),
          Obx(
            () => _buildInfoRow(
              context,
              label: 'Sex',
              value: controller.sex.value.isEmpty
                  ? 'Select sex'
                  : controller.sex.value,
              onTap: controller.onSexTap,
              showChevron: true,
            ),
          ),
          _buildDivider(context),
          Obx(
            () => _buildInfoRow(
              context,
              label: 'Birthday',
              value: controller.birthday.value.isEmpty
                  ? 'Select date'
                  : controller.birthday.value,
              onTap: () => controller.onBirthdayTap(context),
              showChevron: true,
            ),
          ),
          _buildDivider(context),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          const ShimmerBox(width: 100, height: 100, shape: BoxShape.circle),
          const SizedBox(height: 12),
          const ShimmerBox(width: 110, height: 16, radius: 8),
          const SizedBox(height: 28),
          _buildSectionHeader(context, 'Public profile data'),
          _buildLoadingRow(context),
          _buildDivider(context),
          _buildLoadingRow(context),
          _buildDivider(context),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Private information'),
          _buildLoadingRow(context, showChevron: false),
          _buildDivider(context),
          _buildLoadingRow(context, showChevron: true),
          _buildDivider(context),
        ],
      ),
    );
  }

  Widget _buildLoadingRow(BuildContext context, {bool showChevron = false}) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const ShimmerBox(width: 86, height: 16, radius: 8),
          const Spacer(),
          const ShimmerBox(width: 140, height: 16, radius: 8),
          if (showChevron) ...[
            const SizedBox(width: 12),
            const ShimmerBox(width: 14, height: 14, radius: 7),
          ],
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, EditProfileController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: controller.onBack,
              icon: Icon(
                Icons.chevron_left,
                size: 28,
                color: AppColors.blackColor,
              ),
            ),
          ),
          Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Obx(
                () => controller.isLoading.value
                    ? const ShimmerBox(width: 72, height: 34, radius: 24)
                    : GestureDetector(
                        onTap: controller.isSaving.value
                            ? null
                            : controller.onDone,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (controller.isSaving.value) ...[
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.blackColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                controller.isSaving.value
                                    ? 'Saving...'
                                    : 'Done',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar ─────────────────────────────────────────────────────────

  Widget _buildAvatar(EditProfileController controller) {
    return GestureDetector(
      onTap: controller.onChangePicture,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE8DDD2),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Obx(() {
            if (controller.profileImagePath.value.isNotEmpty) {
              return Image.file(
                File(controller.profileImagePath.value),
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              );
            } else if (controller.profileImageUrl.value.isNotEmpty) {
              return Image.network(
                controller.profileImageUrl.value,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF8B7355),
                  );
                },
              );
            } else {
              return const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF8B7355),
              );
            }
          }),
        ),
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF9E9E9E),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ── Editable Text Field Row ────────────────────────────────────────

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(fontSize: 15, color: AppColors.blackColor),

              decoration: InputDecoration(
                hintText: hintText ?? label,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFFBDBDBD),
                ),
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Read-only Info Row (Private info) ──────────────────────────────

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (showChevron) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Theme.of(context).hintColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Divider ────────────────────────────────────────────────────────

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 0,
      color: Theme.of(context).dividerColor,
    );
  }
}
