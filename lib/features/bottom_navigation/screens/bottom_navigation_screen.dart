import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/common/styles/global_text_style.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/bottom_navigation/controllers/bottom_navigation_controller.dart';
import 'package:hawiisaac/features/home/presentation/screens/home_screen.dart';
import 'package:hawiisaac/features/loggin/presentation/screens/main_loggin_screen.dart';
import 'package:hawiisaac/features/progress/presentation/screens/progress_screen.dart';
import 'package:hawiisaac/features/profile/screens/profile_view.dart';
import 'package:hawiisaac/features/scan/presentation/screens/scan_equipment_view.dart';

class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavigationController controller = Get.put(
      BottomNavigationController(),
    );

    // Initialize TransferController

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => _getPage(controller.currentIndex)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Center(
                  child: Obx(
                    () => _CustomNavBar(
                      currentIndex: controller.currentIndex,
                      onTabSelected: (i) {
                        HapticFeedback.selectionClick();
                        controller.changeTab(i);
                      },
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

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return const ScanEquipmentView();
      case 2:
        return const MainLogginScreen();
      case 3:
        return const ProgressView();
      case 4:
        return const ProfileView();
      default:
        return const HomeView();
    }
  }
}

// ── Tab data ────────────────────────────────────────────────────────────────

class _NavTab {
  final String labelKey;
  final String activeIcon;
  final String inactiveIcon;

  const _NavTab({
    required this.labelKey,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

const _tabs = [
  _NavTab(
    labelKey: 'Home',
    activeIcon: 'assets/icons/home_active.png',
    inactiveIcon: 'assets/icons/home_inactive.png',
  ),
  _NavTab(
    labelKey: 'Scanner',
    activeIcon: 'assets/icons/scanner_active.png',
    inactiveIcon: 'assets/icons/scanner_inactive.png',
  ),
  _NavTab(
    labelKey: 'Log',
    activeIcon: 'assets/icons/log_active.png',
    inactiveIcon: 'assets/icons/log_inactive.png',
  ),
  _NavTab(
    labelKey: 'Progress',
    activeIcon: 'assets/icons/progress_active.png',
    inactiveIcon: 'assets/icons/progress_inactive.png',
  ),
  _NavTab(
    labelKey: 'Profile',
    activeIcon: 'assets/icons/profile_inactive.png',
    inactiveIcon: 'assets/icons/profile_active.png',
  ),
];

class _CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const _CustomNavBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Container margin: ~6.4% of screen width  (≈ 24px on 375pt design)
    final sideMargin = screenW * 0.064;
    // Container padding: ~2.1% of screen width (≈ 8px on 375pt design)
    final containerPad = screenW * 0.021;

    return Container(
      height: screenW * 0.213, // ~80px on 375pt
      margin: EdgeInsets.symmetric(horizontal: sideMargin),
      padding: EdgeInsets.all(containerPad),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryColor : Colors.white,
        border: Border.all(
          color: isDarkMode ? Colors.transparent : const Color(0xFFD9D9D9),
        ),
        borderRadius: BorderRadius.circular(screenW * 0.187), // ~70px on 375pt
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // LayoutBuilder provides the exact inner width after padding
      child: LayoutBuilder(
        builder: (context, constraints) {
          final innerW = constraints.maxWidth;

          // Gap between items: ~1.3% of inner width (≈ 4px when innerW ≈ 318px)
          final itemGap = innerW * 0.013;

          final inactiveCount = _tabs.length - 1;

          // We want the active pill to be ~1.85 times the width of an inactive circle
          const activeRatio = 1.85;
          final totalUnits = inactiveCount + activeRatio;

          // available width for tabs (excluding gaps)
          final widthWithoutGaps = innerW - (_tabs.length * itemGap);

          final inactiveSize = widthWithoutGaps / totalUnits;

          // -0.5 safety buffer for floating-point precision
          final activeWidth =
              (widthWithoutGaps - (inactiveCount * inactiveSize) - 0.5).clamp(
                innerW * 0.18,
                innerW * 0.45,
              );

          return Row(
            children: List.generate(
              _tabs.length,
              (i) => _NavItem(
                tab: _tabs[i],
                isActive: currentIndex == i,
                activeWidth: activeWidth,
                inactiveSize: inactiveSize,
                itemGap: itemGap,
                onTap: () => onTabSelected(i),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Single Nav Item ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final double activeWidth;
  final double inactiveSize;
  final double itemGap;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.activeWidth,
    required this.inactiveSize,
    required this.itemGap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Derive internal sizes from inactiveSize (already MediaQuery-derived)
    final iconSize = inactiveSize * 0.387; // ~24px when inactiveSize ≈ 62px
    final hPad = inactiveSize * 0.129; // ~8px when inactiveSize ≈ 62px
    final labelGap = inactiveSize * 0.081; // ~5px when inactiveSize ≈ 62px
    final radius = inactiveSize * 0.613; // ~38px when inactiveSize ≈ 62px
    final fontSize = inactiveSize * 0.21; // ~13px when inactiveSize ≈ 62px

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: isActive ? activeWidth : inactiveSize,
        height: inactiveSize,
        margin: EdgeInsets.symmetric(horizontal: itemGap / 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xff1A1A1A) : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
        ),
        // ClipRRect prevents visual overflow during width animation
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon — always visible
                Image.asset(
                  isActive ? tab.activeIcon : tab.inactiveIcon,
                  width: iconSize,
                  height: iconSize,
                  color: isActive ? Colors.lightBlueAccent : null,
                  errorBuilder: (context, e, s) => Icon(
                    Icons.circle,
                    size: iconSize,
                    color: isActive ? Colors.white : const Color(0xFF11674E),
                  ),
                ),

                // Label — fades in with active pill
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isActive
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: labelGap),
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeIn,
                              child: Text(
                                tab.labelKey.tr,
                                style: getTextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
