import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/scanner_controller.dart';
import '../../app/theme/app_colors.dart';
import '../widgets/svg_icon.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScannerController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Obx(() {
            final uid = controller.lastScannedUid.value;
            final isScanning = controller.isScanning.value;

            if (uid != null && uid.isNotEmpty) {
              return _ScannedState(
                uid: uid,
                onClearAndScanAgain: controller.clearAndScanAgain,
              );
            }
            return _ScanningState(isScanning: isScanning);
          }),
        ),
      ),
    );
  }
}

class _ScanningState extends StatelessWidget {
  const _ScanningState({required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScannerController>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SvgIcon(AppSvgIcons.scan, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            isScanning ? 'Hold MIFARE card near device' : 'Ready to scan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.title,
            ),
            textAlign: TextAlign.center,
          ),
          if (isScanning) ...[
            const SizedBox(height: 8),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ] else ...[
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => controller.startScanning(),
              icon: const Icon(Icons.qr_code_scanner, size: 22),
              label: const Text('Start Scanning'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScannedState extends StatelessWidget {
  const _ScannedState({required this.uid, required this.onClearAndScanAgain});

  final String uid;
  final VoidCallback onClearAndScanAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 72, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'Card read',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              uid,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onClearAndScanAgain,
            icon: const Icon(Icons.refresh, size: 22),
            label: const Text('Clear and Scan again'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
