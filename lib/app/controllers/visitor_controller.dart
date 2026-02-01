import 'package:get/get.dart';
import '../database/database_helper.dart';

/// Controller for the Visitor (scanned visitors / visitor_logs) list.
class VisitorController extends GetxController {
  final RxList<Map<String, dynamic>> logs = <Map<String, dynamic>>[].obs;

  @override
  void onReady() {
    loadLogs();
    super.onReady();
  }

  Future<void> loadLogs() async {
    final list = await DatabaseHelper.instance.getAllVisitorLogs();
    logs.assignAll(list);
  }

  Future<void> refresh() async {
    await loadLogs();
  }

  /// Download visitor logs (e.g. export or sync). Override or call API as needed.
  Future<void> download() async {
    // TODO: implement download/export of logs
    await loadLogs();
  }
}
