import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/main_controller.dart';
import '../../app/theme/app_colors.dart';
import '../widgets/svg_icon.dart';
import 'home_page.dart';
import 'student_page.dart';
import 'add_page.dart';
import 'visitor_page.dart';
import 'profile_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomePage(),
            StudentPage(),
            AddPage(),
            VisitorPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: _BottomNavBar(controller: controller),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.controller});

  final MainController controller;

  static const double _barHeight = 82;
  static const double _fabSize = 64;
  static const double _fabOverlap = 20;

  @override
  Widget build(BuildContext context) {
    final i = controller.currentIndex.value;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const inactiveColor = Color(0xFF9E9E9E);

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: _barHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    assetPath: AppSvgIcons.home,
                    label: 'Home',
                    isSelected: i == MainController.homeIndex,
                    onTap: () => controller.goTo(MainController.homeIndex),
                    selectedColor: AppColors.primary,
                    inactiveColor: inactiveColor,
                  ),
                  _NavItem(
                    assetPath: AppSvgIcons.graduationCap,
                    label: 'Student',
                    isSelected: i == MainController.studentIndex,
                    onTap: () => controller.goTo(MainController.studentIndex),
                    selectedColor: AppColors.primary,
                    inactiveColor: inactiveColor,
                  ),
                  SizedBox(width: _fabSize + 8),
                  _NavItem(
                    assetPath: AppSvgIcons.heart,
                    label: 'Visitor',
                    isSelected: i == MainController.visitorIndex,
                    onTap: () => controller.goTo(MainController.visitorIndex),
                    selectedColor: AppColors.primary,
                    inactiveColor: inactiveColor,
                  ),
                  _NavItem(
                    assetPath: AppSvgIcons.user,
                    label: 'Profile',
                    isSelected: i == MainController.profileIndex,
                    onTap: () => controller.goTo(MainController.profileIndex),
                    selectedColor: AppColors.primary,
                    inactiveColor: inactiveColor,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -_fabOverlap,
              child: Center(
                child: _FabItem(
                  onTap: () => controller.goTo(MainController.fabIndex),
                  size: _fabSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.inactiveColor,
  });

  final String assetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : inactiveColor;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(assetPath, size: 26, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FabItem extends StatelessWidget {
  const _FabItem({required this.onTap, required this.size});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: AppColors.primary.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: SvgIcon(
              AppSvgIcons.scan,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
