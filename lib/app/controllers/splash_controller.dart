import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAccountAndNavigate();
  }

  Future<void> _checkAccountAndNavigate() async {
    await Future.delayed(const Duration(seconds: 1)); // Minimum splash display

    final cachedAccount = _storageService.getCachedAccount();

    if (!_storageService.hasCachedAccount()) {
      // No cached account -> go to login
      isLoading.value = false;
      //todo: uncomment this when login is implemented
      // Get.offAllNamed(AppRoutes.LOGIN);
      Get.offAllNamed(AppRoutes.HOME);
      return;
    }

    // Has cached account -> call login API
    try {
      final email = cachedAccount['email']!;
      final password = cachedAccount['password']!;

      final token = await _authService.login(email: email, password: password);

      // Update token in storage
      await _storageService.saveAccount(
        email: email,
        password: password,
        token: token,
      );

      // Navigate to home
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      // Login failed -> clear cache and go to login
      await _storageService.clearAccount();
      isLoading.value = false;
      //todo: uncomment this when login is implemented
      // Get.offAllNamed(AppRoutes.LOGIN);
      Get.offAllNamed(AppRoutes.HOME);
    }
  }
}
