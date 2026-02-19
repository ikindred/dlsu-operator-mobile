import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../services/nfc_service.dart';

/// Uses only the device's built-in NFC (nfc_manager). No SDK required.
class ScannerController extends GetxController {
  final NfcService _nfc = NfcService();
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
  final Rx<String?> scanError = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _logger.i('📱 ScannerController initialized (built-in NFC only)');
  }

  @override
  void onClose() {
    _logger.d('🛑 ScannerController closing');
    _nfc.stopSession();
    super.onClose();
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
    _startScanning();
  }

  void stopScanning() {
    _nfc.stopSession();
    isScanning.value = false;
  }

  void startScanning() {
    _startScanning();
  }

  Future<void> disposeReader() async {
    await _nfc.stopSession();
    isScanning.value = false;
  }
}
