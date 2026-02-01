import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/visitor_controller.dart';
import '../../app/theme/app_colors.dart';
import '../widgets/svg_icon.dart';

/// Formats [createdAt] from visitor_logs (ISO8601 or similar) to "MM-DD-YY hh:mm AM/PM".
String _formatVisitorCreatedAt(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) return '—';
  try {
    final dt = DateTime.parse(createdAt);
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final year = (dt.year % 100).toString().padLeft(2, '0');
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month-$day-$year $hour:$minute $amPm';
  } catch (_) {
    return createdAt;
  }
}

class VisitorPage extends StatelessWidget {
  const VisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisitorController>();

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: title + download
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      'Scanned Visitor: ${controller.logs.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.title,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.download,
                    icon: const SvgIcon(
                      AppSvgIcons.download,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Download',
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
                            AppSvgIcons.heart,
                            size: 64,
                            color: AppColors.subTitle,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No scanned visitors yet',
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
                        return _VisitorLogCard(log: log);
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

class _VisitorLogCard extends StatelessWidget {
  const _VisitorLogCard({required this.log});

  final Map<String, dynamic> log;

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.title,
  );
  static const TextStyle _valueStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.title,
  );

  @override
  Widget build(BuildContext context) {
    final cardNo = log['card_no'] as String? ?? '—';
    final visCard = log['vis_card'] as String? ?? '—';
    final createdAt = log['created_at'] as String?;
    final dateTimeText = _formatVisitorCreatedAt(createdAt);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.primary, width: 2),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First line: Card No (left) | date time (right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text('Card No: ', style: _labelStyle),
                Expanded(
                  child: Text(
                    cardNo,
                    style: _valueStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(dateTimeText, style: _valueStyle),
              ],
            ),
            const SizedBox(height: 8),
            // Second line: Vis Card (left only)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text('Vis Card: ', style: _labelStyle),
                Expanded(
                  child: Text(
                    visCard,
                    style: _valueStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
