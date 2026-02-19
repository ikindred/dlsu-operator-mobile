import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/main_controller.dart';
import '../../app/controllers/scanner_controller.dart';
import '../../app/controllers/student_controller.dart';
import '../../app/theme/app_colors.dart';
import '../widgets/profile_image_from_data.dart';
import '../widgets/svg_icon.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScannerController>();
    final mainController = Get.find<MainController>();
    final onScannerTab = mainController.currentIndex.value == MainController.fabIndex;
    if (kDebugMode) {
      if (onScannerTab) {
        debugPrint('[ScannerPage] ► visible (current tab = Scanner)');
      } else {
        debugPrint('[ScannerPage] build: not visible (current tab index=${mainController.currentIndex.value}), scheduling stopScanning');
      }
    }
    if (!onScannerTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<ScannerController>()) {
          Get.find<ScannerController>().stopScanning();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Obx(() {
            final record = controller.scannedRecord.value;
            final uid = controller.lastScannedUid.value;
            final error = controller.scanError.value;

            // Valid card: has a record with id or card_no (display info)
            final hasValidRecord = record != null &&
                record.isNotEmpty &&
                (record['id'] != null || record['card_no'] != null);
            if (hasValidRecord) {
              return _ScannedResultCard(
                record: record,
                onClearAndScanAgain: controller.clearAndScanAgain,
              );
            }
            // Invalid card: we got a UID but no matching record (display invalid + card no)
            if (uid != null && uid.isNotEmpty) {
              final displayNumber = ScannerController.hexUidToDecimal(uid) ?? uid;
              return _CardNotFoundState(
                displayNumber: displayNumber,
                onClearAndScanAgain: controller.clearAndScanAgain,
              );
            }
            return _ScanningState(scanError: error);
          }),
        ),
      ),
    );
  }
}

class _ScanningState extends StatelessWidget {
  const _ScanningState({this.scanError});

  final String? scanError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date time at top (dark green), centered
        Obx(() {
          final controller = Get.find<ScannerController>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: Text(
                ScannerController.formatDateTime(controller.currentTime.value),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.title,
                ),
              ),
            ),
          );
        }),
        // Center: scanner image + Tap and Hold to Read
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/png/scanner.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SvgIcon(
                      AppSvgIcons.scan,
                      size: 120,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tap and Hold to Read',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Result card when a record was found in stu_emp_list (green / yellow / red by status).
class _ScannedResultCard extends StatelessWidget {
  const _ScannedResultCard({
    required this.record,
    required this.onClearAndScanAgain,
  });

  final Map<String, dynamic> record;
  final VoidCallback onClearAndScanAgain;

  static Color _statusColor(Map<String, dynamic> r) {
    final status = (r['status'] as String?)?.toLowerCase() ?? '';
    final remarks = r['remarks'] as String?;
    final hasRemarks = remarks != null && remarks.trim().isNotEmpty;
    if (status == 'not_allowed') return AppColors.notAllowed;
    if (status == 'allowed' && hasRemarks) return AppColors.allowedWithRemarks;
    return AppColors.allowed;
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = StudentController.displayStatus(record);
    final borderColor = _statusColor(record);
    final type = (record['type'] as String?)?.toLowerCase() ?? 'student';
    final typeLabel = type == 'employee' ? 'Employee' : 'Student';
    final id = record['id'] as String? ?? record['card_no'] as String? ?? '—';
    final remarks = record['remarks'] as String? ?? '';
    final remarksDisplay = remarks.trim().isEmpty ? 'No Remarks' : remarks.trim();
    final profile = record['profile'] as String?;

    return Column(
      children: [
        Obx(() {
          final controller = Get.find<ScannerController>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: Text(
                ScannerController.formatDateTime(controller.currentTime.value),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.title,
                ),
              ),
            ),
          );
        }),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            typeLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.title,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusLabel == 'With Remarks'
                                    ? AppColors.title
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ProfileImageFromData(
                          profile: profile,
                          fallbackId: id,
                          size: 100,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ID: $id',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.title,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Remarks:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.title,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          remarksDisplay,
                          style: TextStyle(
                            fontSize: 13,
                            color: remarks.trim().isEmpty
                                ? Colors.grey.shade500
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown when card was scanned but not found in stu_emp_list (Invalid Card).
class _CardNotFoundState extends StatelessWidget {
  const _CardNotFoundState({
    required this.displayNumber,
    required this.onClearAndScanAgain,
  });

  final String displayNumber;
  final VoidCallback onClearAndScanAgain;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          final controller = Get.find<ScannerController>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: Text(
                ScannerController.formatDateTime(controller.currentTime.value),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.title,
                ),
              ),
            ),
          );
        }),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.notAllowed,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.notAllowed.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: SvgIcon(
                      AppSvgIcons.crossCircle,
                      size: 80,
                      color: AppColors.notAllowed,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Invalid Card',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.notAllowed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This card is not enrolled',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    displayNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                      fontFamily: 'monospace',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
