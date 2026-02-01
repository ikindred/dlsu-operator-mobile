import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/svg_icon.dart';
import '../../app/controllers/home_controller.dart';
import '../../app/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Obx(
                () => Text(
                  'Hi, ${controller.displayName.value}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Students card
              Obx(
                () => _DashboardCard(
                  leftColor: AppColors.primary,
                  iconPath: AppSvgIcons.graduationCap,
                  label: 'Students',
                  count: controller.studentsCount.value,
                  trailingIconPath: AppSvgIcons.refresh,
                  onTrailingTap: controller.refreshStudents,
                  subtitle: 'Last Sync: ${controller.lastSync.value}',
                ),
              ),
              const SizedBox(height: 20),

              // Student not Uploaded card
              Obx(
                () => _DashboardCard(
                  leftColor: AppColors.negative,
                  iconPath: AppSvgIcons.graduationCap,
                  label: 'Student not Uploaded',
                  count: controller.studentNotUploadedCount.value,
                  trailingIconPath: AppSvgIcons.upload,
                  onTrailingTap: controller.uploadStudents,
                  subtitle: 'Last Upload: ${controller.lastUpload.value}',
                ),
              ),
              const SizedBox(height: 30),

              //add divider
              const Divider(
                color: Color.fromARGB(87, 112, 128, 144),
                height: 1,
              ),
              const SizedBox(height: 30),

              // Visitors card
              Obx(
                () => _DashboardCard(
                  leftColor: AppColors.primary,
                  iconPath: AppSvgIcons.heart,
                  label: 'Visitors',
                  count: controller.visitorsCount.value,
                  subtitle: 'Last update: ${controller.lastUpdate.value}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.leftColor,
    required this.iconPath,
    required this.label,
    required this.count,
    required this.subtitle,
    this.trailingIconPath,
    this.onTrailingTap,
  });

  final Color leftColor;
  final String iconPath;
  final String label;
  final int count;
  final String subtitle;
  final String? trailingIconPath;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left colored section
                  Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    color: leftColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgIcon(iconPath, color: Colors.white, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right white section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatCount(count),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.title,
                            ),
                          ),
                          if (trailingIconPath != null)
                            GestureDetector(
                              onTap: onTrailingTap,
                              child: SvgIcon(
                                trailingIconPath!,
                                size: 22,
                                color: AppColors.subTitle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.subTitle),
        ),
      ],
    );
  }

  String _formatCount(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
