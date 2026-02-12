import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../database/database_helper.dart';

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
    _logger.i('📤 Upload student logs requested');
    // TODO: implement upload of logs
    await loadLogs();
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
