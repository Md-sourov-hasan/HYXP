import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/widgets/app_shimmer.dart';
import 'package:hawiisaac/features/profile/controller/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        toolbarHeight: 58,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSummary(context, controller),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader(context, 'Account'),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    svgIcon: 'assets/icons/profile.svg',
                    label: 'Profile',
                    onTap: controller.onProfileTap,
                  ),
                  _buildDivider(context),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.lock_outline_rounded,
                    svgIcon: 'assets/icons/lock.svg',
                    label: 'Change Password',
                    onTap: controller.onAccountTap,
                  ),
                  _buildSectionHeader(context, 'Settings'),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.security_rounded,
                    svgIcon: 'assets/icons/privacy_tip.svg',
                    label: 'Privacy',
                    onTap: controller.onPrivacyTap,
                  ),
                  _buildDivider(context),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.nightlight_round,
                    svgIcon: 'assets/icons/moon.svg',
                    label: 'Theme',
                    onTap: () =>
                        controller.toggleTheme(!controller.isDarkMode.value),
                    suffix: Obx(
                      () => Switch(
                        value: controller.isDarkMode.value,
                        onChanged: controller.toggleTheme,
                        activeThumbColor: const Color(0xff00E5FF),
                      ),
                    ),
                  ),
                  _buildDivider(context),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.diamond_outlined,
                    svgIcon: 'assets/icons/diamond-02.svg',
                    label: 'Get premium',
                    onTap: controller.onGetPremiumTap,
                  ),
                  _buildDivider(context),
                  _buildDangerSectionHeader(context, 'Danger zone'),
                  _buildDangerMenuItem(
                    icon: Icons.logout_rounded,
                    svgIcon: 'assets/icons/logout.svg',
                    color: const Color(0xFF00464F),
                    label: 'Log out',
                    onTap: controller.onLogout,
                  ),
                  _buildDivider(context),
                  _buildDangerMenuItem(
                    icon: Icons.delete_outline_rounded,
                    assetIcon: 'assets/icons/delete-01.png',
                    label: 'Delete Account',
                    onTap: controller.onDeleteAccount,
                    suffix: Obx(
                      () => controller.isDeletingAccount.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD32F2F),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  _buildDivider(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile Summary ────────────────────────────────────────────────

  Widget _buildProfileSummary(
    BuildContext context,
    ProfileController controller,
  ) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).cardColor,
              backgroundImage: controller.photo.value.isNotEmpty
                  ? NetworkImage(controller.photo.value)
                  : null,
              child: controller.photo.value.isEmpty
                  ? const Icon(Icons.person_outline_rounded, size: 30)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.value.isNotEmpty
                        ? controller.userName.value
                        : 'Profile',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (controller.email.value.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      controller.email.value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (controller.isLoading.value)
              const ShimmerBox(
                width: 20,
                height: 20,
                radius: 10,
                shape: BoxShape.circle,
              ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF9E9E9E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Menu Item ──────────────────────────────────────────────────────

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    String? svgIcon,
    required String label,
    required VoidCallback onTap,
    Widget? suffix,
  }) {
    final iconColor = IconTheme.of(context).color;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            svgIcon != null
                ? SvgPicture.asset(
                    svgIcon,
                    width: 23,
                    height: 23,
                    colorFilter: iconColor != null
                        ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                        : null,
                  )
                : Icon(icon, size: 23),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ?suffix,
          ],
        ),
      ),
    );
  }

  // ── Divider ────────────────────────────────────────────────────────

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 0,
      color: Theme.of(context).dividerColor,
    );
  }

  // ── Danger Section Header ──────────────────────────────────────────

  Widget _buildDangerSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.red.withValues(alpha: 0.2)
          : const Color(0xFFFFC5B2),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFFD32F2F),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Danger Menu Item ───────────────────────────────────────────────

  Widget _buildDangerMenuItem({
    required IconData icon,
    String? svgIcon,
    String? assetIcon,
    Color color = const Color(0xFFD32F2F),
    required String label,
    required VoidCallback onTap,
    Widget? suffix,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            svgIcon != null
                ? SvgPicture.asset(
                    svgIcon,
                    width: 23,
                    height: 23,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  )
                : assetIcon != null
                ? Image.asset(assetIcon, width: 23, height: 23, color: color)
                : Icon(icon, size: 23, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ).copyWith(color: color),
            ),
            const Spacer(),
            ?suffix,
          ],
        ),
      ),
    );
  }
}
