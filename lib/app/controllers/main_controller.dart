import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  static const int homeIndex = 0;
  static const int studentIndex = 1;
  static const int fabIndex = 2;
  static const int visitorIndex = 3;
  static const int profileIndex = 4;

  void goTo(int index) {
    if (index >= 0 && index <= 4) {
      currentIndex.value = index;
    }
  }
}
