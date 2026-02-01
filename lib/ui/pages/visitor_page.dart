import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../widgets/svg_icon.dart';

class VisitorPage extends StatelessWidget {
  const VisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SvgIcon(AppSvgIcons.heart, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Visitor',
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
