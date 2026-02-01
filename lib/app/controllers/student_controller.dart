import 'package:get/get.dart';
import '../database/database_helper.dart';

/// Controller for the Student (scanned students / stu_emp_logs) list.
class StudentController extends GetxController {
  final RxList<Map<String, dynamic>> logs = <Map<String, dynamic>>[].obs;

  @override
  void onReady() {
    loadLogs();
    super.onReady();
  }

  Future<void> loadLogs() async {
    final list = await DatabaseHelper.instance.getAllStuEmpLogs();
    logs.assignAll(list);
  }

  Future<void> refresh() async {
    await loadLogs();
  }

  /// Upload scanned student logs (e.g. to server). Override or call API as needed.
  Future<void> upload() async {
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
