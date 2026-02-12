import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/visitor_controller.dart';
import '../controllers/scanner_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<StudentController>(() => StudentController());
    Get.lazyPut<VisitorController>(() => VisitorController());
    Get.lazyPut<ScannerController>(() => ScannerController());
  }
}
