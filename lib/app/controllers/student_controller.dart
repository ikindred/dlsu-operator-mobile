import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../database/database_helper.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';
import '../utils/offline_dialog.dart';

/// Controller for the Student (scanned students / stu_emp_logs) list.
class StudentController extends GetxController {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  final RxList<Map<String, dynamic>> logs = <Map<String, dynamic>>[].obs;
  final RxBool isUploading = false.obs;

  @override
  void onReady() {
    _logger.i('📚 StudentController ready');
    loadLogs();
    super.onReady();
  }

  Future<void> loadLogs() async {
    _logger.d('📖 Loading student logs...');
    final list = await DatabaseHelper.instance.getAllStuEmpLogs();
    logs.assignAll(list);
    _logger.i('✅ Loaded ${list.length} student log entries');
  }

  Future<void> refresh() async {
    _logger.d('🔄 Refreshing student logs...');
    await loadLogs();
  }

  /// Upload scanned student logs (e.g. to server). Override or call API as needed.
  Future<void> upload() async {
    if (isUploading.value) return;
    if (StorageService().isOfflineMode()) {
      showOfflineLoginRequiredDialog('upload student logs');
      return;
    }
    isUploading.value = true;
    _logger.i('📤 Upload student logs requested');

    try {
      final items = List<Map<String, dynamic>>.from(logs);
      if (items.isEmpty) {
        Get.snackbar(
          'No logs',
          'No student logs to upload.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final result = await ReportService().uploadStuEmpLogs(items);
      if (!result.ok) {
        if (result.statusCode == 401) {
          Get.snackbar(
            'Session expired',
            'Please login again to upload logs.',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Upload failed',
            result.error ?? 'Unable to upload student logs.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return;
      }

      await DatabaseHelper.instance.clearStuEmpLogs();
      await loadLogs();
      Get.snackbar(
        'Upload complete',
        'Uploaded ${result.sentCount} logs.',
        snackPosition: SnackPosition.BOTTOM,
      );
      _logger.i('✅ Uploaded ${result.sentCount} student logs, local logs cleared');
    } catch (e, st) {
      _logger.e('❌ StudentController.upload error', error: e, stackTrace: st);
      Get.snackbar(
        'Upload error',
        'Upload failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  /// Display status for a log row: "Allowed", "With Remarks", or "Not Allowed".
  static String displayStatus(Map<String, dynamic> log) {
    final status = (log['status'] as String?)?.toLowerCase() ?? '';
    final remarks = log['remarks'] as String?;
    final hasRemarks = remarks != null && remarks.trim().isNotEmpty;

    if (status == 'not_allowed') return 'Not Allowed';
    if (status == 'allowed' && hasRemarks) return 'With Remarks';
    if (status == 'allowed') return 'Allowed';
    // Fallback for legacy data (e.g. "in"/"out")
    if (hasRemarks) return 'With Remarks';
    return 'Allowed';
  }

  /// Border/status color: Green (Allowed), Yellow (With Remarks), Red (Not Allowed).
  static int statusColorValue(Map<String, dynamic> log) {
    final status = (log['status'] as String?)?.toLowerCase() ?? '';
    final remarks = log['remarks'] as String?;
    final hasRemarks = remarks != null && remarks.trim().isNotEmpty;

    if (status == 'not_allowed') return 0xFFEE5F62; // notAllowed
    if (status == 'allowed' && hasRemarks) return 0xFFCED501; // allowedWithRemarks
    return 0xFF00BC65; // allowed
  }
}
