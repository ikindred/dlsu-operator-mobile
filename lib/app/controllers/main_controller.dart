import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'scanner_controller.dart';

class MainController extends GetxController {
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
  final RxInt currentIndex = 0.obs;

  static const int homeIndex = 0;
  static const int studentIndex = 1;
  static const int fabIndex = 2;
  static const int visitorIndex = 3;
  static const int profileIndex = 4;

  void goTo(int index) {
    if (index < 0 || index > 4) {
      _logger.w('⚠️ Invalid navigation index: $index');
      return;
    }
    final wasOnScanner = currentIndex.value == fabIndex;
    final pageNames = ['Home', 'Student', 'Scanner', 'Visitor', 'Profile'];
    _logger.d('🧭 Navigating to ${pageNames[index]} (from ${pageNames[currentIndex.value]})');
    
    currentIndex.value = index;
    final nowOnScanner = index == fabIndex;
    if (Get.isRegistered<ScannerController>()) {
      final scanner = Get.find<ScannerController>();
      // Stop scanning when leaving scanner page
      if (wasOnScanner && !nowOnScanner) {
        _logger.d('🛑 Leaving scanner page, stopping scan');
        scanner.stopScanning();
      }
      // Don't auto-start scanning when entering scanner page
      // User must explicitly press "Start Scanning" button
    }
  }
}
