import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../widgets/svg_icon.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SvgIcon(AppSvgIcons.graduationCap, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Student',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
