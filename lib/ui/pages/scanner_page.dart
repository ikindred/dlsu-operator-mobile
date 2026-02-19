import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/scanner_controller.dart';
import '../../app/theme/app_colors.dart';
import '../widgets/svg_icon.dart';

/// Converts a hex card UID string to decimal (e.g. "04A1B2C3" → "78123456").
String? hexUidToDecimal(String hex) {
  final cleaned = hex.trim().replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
  if (cleaned.isEmpty) return null;
  try {
    return BigInt.parse(cleaned, radix: 16).toString();
  } catch (_) {
    return null;
  }
}

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
            final error = controller.scanError.value;

            if (uid != null && uid.isNotEmpty) {
              final displayNumber = hexUidToDecimal(uid) ?? uid;
              return _ScannedState(
                uid: uid,
                displayNumber: displayNumber,
                onClearAndScanAgain: controller.clearAndScanAgain,
              );
            }
            return _ScanningState(
              isScanning: isScanning,
              scanError: error,
            );
          }),
        ),
      ),
    );
  }
}

class _ScanningState extends StatelessWidget {
  const _ScanningState({
    required this.isScanning,
    this.scanError,
  });

  final bool isScanning;
  final String? scanError;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScannerController>();

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SvgIcon(AppSvgIcons.scan, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              isScanning
                  ? 'Hold card on the back of the device'
                  : 'Ready to scan (built-in NFC)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
              textAlign: TextAlign.center,
            ),
            if (scanError != null && scanError!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        scanError!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isScanning) ...[
              const SizedBox(height: 16),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => controller.stopScanning(),
                icon: const Icon(Icons.stop, size: 20),
                label: const Text('Stop'),
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
      ),
    );
  }
}

class _ScannedState extends StatelessWidget {
  const _ScannedState({
    required this.uid,
    required this.displayNumber,
    required this.onClearAndScanAgain,
  });

  final String uid;
  /// Card number in decimal (converted from hex UID for display).
  final String displayNumber;
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
              displayNumber,
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
