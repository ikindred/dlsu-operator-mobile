import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../widgets/svg_icon.dart';
import '../../app/controllers/home_controller.dart';
import '../../app/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SvgIcon(AppSvgIcons.user, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                controller.userEmail.value.isNotEmpty
                    ? controller.userEmail.value
                    : 'No email',
                style: const TextStyle(fontSize: 16, color: AppColors.subTitle),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(LineAwesomeIcons.sign_out_alt_solid),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.negative,
                side: const BorderSide(color: AppColors.negative),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
