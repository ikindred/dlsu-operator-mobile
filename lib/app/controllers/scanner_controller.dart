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
    _nfc.stopSession();
    isScanning.value = false;
    _logger.i('[Scanner] Controller onInit — state=idle, NFC off');
  }

  @override
  void onClose() {
    _timeTimer?.cancel();
    _logger.d('[Scanner] Controller onClose — stopping NFC');
    _nfc.stopSession();
    super.onClose();
  }

  /// Logs current scanner state so we know where we are and if scanner is on / if a card was scanned.
  void _logState({String? note}) {
    final scanning = isScanning.value ? 'ON' : 'OFF';
    final uid = lastScannedUid.value;
    final record = scannedRecord.value;
    final hasValid = record != null &&
        record.isNotEmpty &&
        (record['id'] != null || record['card_no'] != null);
    final card = uid != null && uid.isNotEmpty
        ? '${uid.length > 12 ? "${uid.substring(0, 8)}..." : uid}'
        : 'none';
    final valid = uid != null && uid.isNotEmpty
        ? (hasValid ? 'valid=yes' : 'valid=no')
        : 'valid=n/a';
    _logger.i('[Scanner] ► state: scanning=$scanning, card=$card, $valid${note != null ? ' ($note)' : ''}');
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

  /// Process: go to scanner page → start scanner → scan card → stop scanner → display valid/invalid → save in DB log.
  Future<void> _startScanning() async {
    if (isScanning.value) {
      _logger.w('[Scanner] _startScanning ignored — already scanning');
      return;
    }
    _logger.i('[Scanner] _startScanning — step 0: clearing state, isScanning=true');
    lastScannedUid.value = null;
    scannedRecord.value = null;
    scanError.value = null;
    isScanning.value = true;
    _logState(note: 'started scan');

    try {
      _logger.d('[Scanner] step 1: checking NFC availability');
      final available = await _nfc.isAvailable;
      if (!available) {
        scanError.value = 'NFC is off or not supported. Turn on NFC in Settings.';
        _logger.w('[Scanner] step 1 failed: NFC not available');
        return;
      }
      _logger.d('[Scanner] step 1 ok: NFC available');

      _logger.d('[Scanner] step 2: waiting for tag (readTag)');
      final result = await _nfc.readTag();
      if (result == null || result.uid.isEmpty) {
        scanError.value = 'No card read. Hold the card steady on the back of the device.';
        _logger.d('[Scanner] step 2: readTag returned null or empty — no card / timeout');
        return;
      }

      _logger.i('[Scanner] step 2 ok: card read UID=${result.uid}');

      _logger.d('[Scanner] step 3: stopping scanner (stopSession)');
      await _nfc.stopSession();
      _logger.d('[Scanner] step 3 ok: scanner stopped');

      // 4. Determine valid vs invalid (lookup by card_no: hex and decimal)
      final uidHex = result.uid.trim();
      Map<String, dynamic>? record =
          await DatabaseHelper.instance.getStuEmpListByCardNo(uidHex);
      if (record == null && uidHex != uidHex.toUpperCase()) {
        record = await DatabaseHelper.instance.getStuEmpListByCardNo(uidHex.toUpperCase());
      }
      if (record == null) {
        final decimal = hexUidToDecimal(result.uid);
        if (decimal != null && decimal != result.uid) {
          record = await DatabaseHelper.instance.getStuEmpListByCardNo(decimal);
        }
      }
      final bool isValid = record != null &&
          record.isNotEmpty &&
          (record['id'] != null || record['card_no'] != null);
      final Map<String, dynamic>? recordToShow = isValid ? record : null;
      _logger.d('[Scanner] step 4: lookup done — valid=$isValid');

      // Save in database log (valid cards only)
      if (isValid) {
        final r = record;
        final now = DateTime.now().toIso8601String();
        final logRow = <String, dynamic>{
          'id': r['id'],
          'card_no': r['card_no'],
          'type': r['type'] ?? 'student',
          'remarks': r['remarks'] ?? '',
          'status': r['status'] ?? 'allowed',
          'profile': r['profile'],
          'created_at': now,
        };
        await DatabaseHelper.instance.insertStuEmpLog(logRow);
        _logger.i('[Scanner] step 5: saved to stu_emp_logs');
      } else {
        _logger.d('[Scanner] step 5: no DB log (invalid/unknown card)');
      }

      _logger.d('[Scanner] step 6: updating UI (display valid/invalid)');
      lastScannedUid.value = result.uid;
      scannedRecord.value = recordToShow;
      isScanning.value = false;
    } catch (e, st) {
      _logger.e('[Scanner] _startScanning error', error: e, stackTrace: st);
      scanError.value = 'Scan failed: $e';
    } finally {
      isScanning.value = false;
      _logState(note: 'scan ended');
    }
  }

  void clearAndScanAgain() {
    _logger.d('[Scanner] clearAndScanAgain — clearing result, starting new scan');
    scanError.value = null;
    lastScannedUid.value = null;
    scannedRecord.value = null;
    _logState(note: 'cleared, starting new scan');
    _startScanning();
  }

  /// Stops the NFC reader. Call when leaving the scanner tab or after showing result.
  Future<void> stopScanning() async {
    _logger.d('[Scanner] stopScanning() called');
    await _nfc.stopSession();
    isScanning.value = false;
    _logState(note: 'stopped');
  }

  void startScanning() {
    _logger.d('[Scanner] startScanning() called (from MainController or Clear and Scan again)');
    _startScanning();
  }

  Future<void> disposeReader() async {
    await _nfc.stopSession();
    isScanning.value = false;
  }
}
