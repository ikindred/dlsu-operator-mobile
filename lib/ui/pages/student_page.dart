import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/student_controller.dart';
import '../../app/theme/app_colors.dart';
import '../widgets/profile_image_from_data.dart';
import '../widgets/svg_icon.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentController>();

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: title + upload
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      'Scanned Students: ${controller.logs.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.title,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.upload,
                    icon: const SvgIcon(
                      AppSvgIcons.upload,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Upload',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  final logs = controller.logs;
                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SvgIcon(
                            AppSvgIcons.graduationCap,
                            size: 64,
                            color: AppColors.subTitle,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No scanned students yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return _StudentLogCard(log: log);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentLogCard extends StatelessWidget {
  const _StudentLogCard({required this.log});

  final Map<String, dynamic> log;

  static Color _statusColor(Map<String, dynamic> log) {
    final status = (log['status'] as String?)?.toLowerCase() ?? '';
    final remarks = log['remarks'] as String?;
    final hasRemarks = remarks != null && remarks.trim().isNotEmpty;
    if (status == 'not_allowed') return AppColors.notAllowed;
    if (status == 'allowed' && hasRemarks) return AppColors.allowedWithRemarks;
    return AppColors.allowed;
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = StudentController.displayStatus(log);
    final borderColor = _statusColor(log);
    final id = log['id'] as String? ?? '—';
    final remarks = log['remarks'] as String? ?? '';
    final profile = log['profile'] as String?;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileImageFromData(
              profile: profile,
              fallbackId: id,
              size: 56,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'ID: ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.title,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          id,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.title,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  const SizedBox(height: 12),
                  const Text(
                    'Remarks:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        remarks.isEmpty ? '' : remarks,
                        style: TextStyle(
                          fontSize: 13,
                          color: remarks.isEmpty ? Colors.grey.shade500 : Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
