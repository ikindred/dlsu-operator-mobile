import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../services/mifare_reader_service.dart';

class ScannerController extends GetxController {
  final MifareReaderService _reader = MifareReaderService();
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
  final RxBool isScanning = false.obs;

  bool _stopPolling = false;

  @override
  void onInit() {
    super.onInit();
    _logger.i('📱 ScannerController initialized');
    // Don't start scanning automatically - wait for explicit user action
  }

  @override
  void onClose() {
    _logger.d('🛑 ScannerController closing');
    _stopPolling = true;
    _reader.disposeReader();
    super.onClose();
  }

  /// Start the reader and poll until a card is read.
  Future<void> _startScanning() async {
    if (isScanning.value) {
      _logger.w('⚠️ Already scanning, skipping start');
      return;
    }
    _logger.i('🔍 Starting card scanning...');
    lastScannedUid.value = null;
    _stopPolling = false;
    isScanning.value = true;

    _logger.d('🔧 Initializing MIFARE reader...');
    final ok = await _reader.initialize();
    if (!ok) {
      _logger.e('❌ Failed to initialize MIFARE reader');
      isScanning.value = false;
      return;
    }
    _logger.i('✅ MIFARE reader initialized successfully');

    _pollForCard();
  }

  Future<void> _pollForCard() async {
    _logger.d('🔄 Starting card polling loop...');
    while (!_stopPolling && lastScannedUid.value == null) {
      final result = await _reader.readCard();
      if (_stopPolling) {
        _logger.d('🛑 Polling stopped by user');
        break;
      }
      if (result != null && result.uid.isNotEmpty) {
        _logger.i('✅ Card scanned successfully. UID: ${result.uid}');
        lastScannedUid.value = result.uid;
        isScanning.value = false;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1500));
    }
    if (_stopPolling) {
      _logger.d('🛑 Polling stopped');
      isScanning.value = false;
    }
  }

  /// Clear the last result and start scanning again.
  void clearAndScanAgain() {
    _logger.i('🔄 Clearing result and starting scan again');
    lastScannedUid.value = null;
    _startScanning();
  }

  /// Stop polling when user leaves the scanner page.
  void stopScanning() {
    _logger.i('🛑 Stopping scanning');
    _stopPolling = true;
    isScanning.value = false;
  }

  /// Resume polling when user returns to the scanner page (if no result is shown).
  void resumeScanningIfNeeded() {
    if (lastScannedUid.value != null) return;
    if (isScanning.value) return;
    // Don't auto-start - require explicit user action
  }

  /// Public method to start scanning - call this when user explicitly wants to scan
  void startScanning() {
    _logger.i('▶️ Start scanning requested by user');
    _startScanning();
  }

  /// Call from logout to release the reader.
  Future<void> disposeReader() async {
    _logger.i('🗑️ Disposing reader');
    _stopPolling = true;
    await _reader.disposeReader();
    isScanning.value = false;
  }
}
