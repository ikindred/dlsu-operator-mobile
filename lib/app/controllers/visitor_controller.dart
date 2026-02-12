import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../database/database_helper.dart';

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

  /// Download visitor logs (e.g. export or sync). Override or call API as needed.
  Future<void> download() async {
    _logger.i('📥 Download visitor logs requested');
    // TODO: implement download/export of logs
    await loadLogs();
  }
}
