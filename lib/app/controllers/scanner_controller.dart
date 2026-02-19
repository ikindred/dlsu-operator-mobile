import 'dart:async';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../database/database_helper.dart';
import '../services/nfc_service.dart';

/// Uses only the device's built-in NFC (nfc_manager). No SDK required.
class ScannerController extends GetxController {
  final NfcService _nfc = NfcService();
  Timer? _timeTimer;
  final Rx<DateTime> currentTime = DateTime.now().obs;
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

  final Rx<String?> lastScannedUid = Rx<String?>(null);
  /// Record from stu_emp_list after lookup by card_no; null if not found or not yet scanned.
  final Rx<Map<String, dynamic>?> scannedRecord = Rx<Map<String, dynamic>?>(null);
  final RxBool isScanning = false.obs;
  final Rx<String?> scanError = Rx<String?>(null);

  /// Converts hex UID to decimal string for lookup (e.g. "04A1B2C3" → "78123456").
  static String? hexUidToDecimal(String hex) {
    final cleaned = hex.trim().replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    if (cleaned.isEmpty) return null;
    try {
      return BigInt.parse(cleaned, radix: 16).toString();
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    currentTime.value = DateTime.now();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      currentTime.value = DateTime.now();
    });
    _logger.i('📱 ScannerController initialized (built-in NFC only)');
  }

  @override
  void onClose() {
    _timeTimer?.cancel();
    _logger.d('🛑 ScannerController closing');
    _nfc.stopSession();
    super.onClose();
  }

  /// Format: "Jan 2 2024 - 09:25:48 AM"
  static String formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour;
    final am = h < 12;
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day} ${dt.year} - ${h12.toString().padLeft(2, '0')}:$m:$s ${am ? 'AM' : 'PM'}';
  }

  Future<void> _startScanning() async {
    if (isScanning.value) {
      _logger.w('⚠️ Already scanning');
      return;
    }
    _logger.i('🔍 Starting NFC scan...');
    lastScannedUid.value = null;
    scanError.value = null;
    isScanning.value = true;

    try {
      final available = await _nfc.isAvailable;
      if (!available) {
        scanError.value = 'NFC is off or not supported. Turn on NFC in Settings.';
        _logger.w(scanError.value);
        return;
      }
      final result = await _nfc.readTag();
      if (result != null && result.uid.isNotEmpty) {
        _logger.i('✅ Card scanned. UID: ${result.uid}');
        lastScannedUid.value = result.uid;
        await _nfc.stopSession();
        // Look up by card_no (try hex UID then decimal)
        Map<String, dynamic>? record =
            await DatabaseHelper.instance.getStuEmpListByCardNo(result.uid);
        if (record == null) {
          final decimal = hexUidToDecimal(result.uid);
          if (decimal != null && decimal != result.uid) {
            record =
                await DatabaseHelper.instance.getStuEmpListByCardNo(decimal);
          }
        }
        scannedRecord.value = record;
        // Save valid card scan to stu_emp_logs
        if (record != null) {
          final now = DateTime.now().toIso8601String();
          final logRow = <String, dynamic>{
            'id': record['id'],
            'card_no': record['card_no'],
            'type': record['type'] ?? 'student',
            'remarks': record['remarks'] ?? '',
            'status': record['status'] ?? 'allowed',
            'profile': record['profile'],
            'created_at': now,
          };
          await DatabaseHelper.instance.insertStuEmpLog(logRow);
          _logger.i('📝 Saved valid scan to stu_emp_logs');
        }
        // Ensure reader is fully off after showing result (redundant stop)
        scheduleMicrotask(() async {
          await _nfc.stopSession();
          _logger.d('🔒 NFC session stopped after result');
        });
      } else {
        scanError.value = 'No card read. Hold the card steady on the back of the device.';
      }
    } catch (e, st) {
      _logger.e('Scan error', error: e, stackTrace: st);
      scanError.value = 'Scan failed: $e';
    } finally {
      isScanning.value = false;
    }
  }

  void clearAndScanAgain() {
    scanError.value = null;
    lastScannedUid.value = null;
    scannedRecord.value = null;
    _startScanning();
  }

  /// Stops the NFC reader. Call when leaving the scanner tab or after showing result.
  Future<void> stopScanning() async {
    await _nfc.stopSession();
    isScanning.value = false;
    _logger.d('🔒 NFC reader disabled (stopScanning)');
  }

  void startScanning() {
    _startScanning();
  }

  Future<void> disposeReader() async {
    await _nfc.stopSession();
    isScanning.value = false;
  }
}
