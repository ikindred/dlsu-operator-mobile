import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../database/database_helper.dart';
import 'home_controller.dart';

/// Controller for the Visitor (scanned visitors / visitor_logs) list.
class VisitorController extends GetxController {
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
    _logger.i('👥 VisitorController ready');
    loadLogs();
    super.onReady();
  }

  Future<void> loadLogs() async {
    _logger.d('📖 Loading visitor logs...');
    final list = await DatabaseHelper.instance.getAllVisitorLogs();
    logs.assignAll(list);
    _logger.i('✅ Loaded ${list.length} visitor log entries');
  }

  Future<void> refresh() async {
    _logger.d('🔄 Refreshing visitor logs...');
    await loadLogs();
  }

  /// Export visitor logs to CSV (same as Home "Visitor Logs" export). Saves to Downloads on Android or share sheet on iOS.
  Future<void> download() async {
    _logger.i('📥 Export visitor logs (CSV) requested');
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().downloadVisitorLogs();
      await refresh();
    }
  }

  /// Clear all visitor logs from the database and refresh the list.
  Future<void> clearLogs() async {
    _logger.i('🗑️ Clearing visitor logs...');
    await DatabaseHelper.instance.clearVisitorLogs();
    await loadLogs();
    _logger.i('✅ Visitor logs cleared');
  }
}
