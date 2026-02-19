import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'home_controller.dart';
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

  static const List<String> _pageNames = ['Home', 'Student', 'Scanner', 'Visitor', 'Profile'];

  @override
  void onReady() {
    super.onReady();
    _logger.i('[Nav] ► Current page: ${_pageNames[currentIndex.value]} (initial)');
    _logger.d('[Nav] MainController onReady — ensuring scanner off (start on Home)');
    if (Get.isRegistered<ScannerController>()) {
      Get.find<ScannerController>().stopScanning();
    }
  }

  static const int homeIndex = 0;
  static const int studentIndex = 1;
  static const int fabIndex = 2;
  static const int visitorIndex = 3;
  static const int profileIndex = 4;

  Future<void> goTo(int index) async {
    if (index < 0 || index > 4) {
      _logger.w('[Nav] Invalid index: $index');
      return;
    }
    final wasOnScanner = currentIndex.value == fabIndex;
    final nowOnScanner = index == fabIndex;
    _logger.d('[Nav] goTo($index)=${_pageNames[index]} — wasOnScanner=$wasOnScanner nowOnScanner=$nowOnScanner');

    if (Get.isRegistered<ScannerController>()) {
      final scanner = Get.find<ScannerController>();
      if (wasOnScanner && !nowOnScanner) {
        _logger.d('[Nav] Leaving Scanner tab → stopping NFC');
        await scanner.stopScanning();
        _logger.d('[Nav] NFC stopped after leaving Scanner');
      }
    }

    currentIndex.value = index;
    _logger.i('[Nav] ► Current page: ${_pageNames[index]}');

    if (Get.isRegistered<ScannerController>()) {
      final scanner = Get.find<ScannerController>();
      if (nowOnScanner) {
        _logger.d('[Nav] Entering Scanner tab → startScanning()');
        scanner.startScanning();
      }
    }

    // Refetch dashboard counts when entering Home so Student List, Student Logs, Visitor List, Visitor Logs are up to date.
    if (index == homeIndex && Get.isRegistered<HomeController>()) {
      _logger.d('[Nav] Entering Home → refetching dashboard counts');
      Get.find<HomeController>().loadDashboardCounts();
    }
  }
}
