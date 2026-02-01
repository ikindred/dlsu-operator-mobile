import 'package:get/get.dart';
import 'app_routes.dart';
import '../bindings/splash_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/main_binding.dart';
import '../../ui/pages/splash_page.dart';
import '../../ui/pages/login_page.dart';
import '../../ui/pages/main_page.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
  ];
}
