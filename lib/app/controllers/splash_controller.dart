import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
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

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _logger.i('🚀 SplashController initialized');
    _checkAccountAndNavigate();
  }

  Future<void> _checkAccountAndNavigate() async {
    _logger.d('⏳ Showing splash screen (1 second delay)');
    await Future.delayed(const Duration(seconds: 1)); // Minimum splash display

    _logger.d('🔍 Checking for cached account...');
    final cachedAccount = _storageService.getCachedAccount();

    if (!_storageService.hasCachedAccount()) {
      // No cached account -> go to login
      _logger.i('📭 No cached account found, navigating to home');
      isLoading.value = false;
      //todo: uncomment this when login is implemented
      // Get.offAllNamed(AppRoutes.LOGIN);
      Get.offAllNamed(AppRoutes.HOME);
      return;
    }

    // Has cached account -> call login API
    _logger.i('✅ Cached account found, attempting auto-login');
    try {
      final email = cachedAccount['email']!;
      final password = cachedAccount['password']!;

      _logger.d('🔐 Attempting login with cached credentials');
      final token = await _authService.login(email: email, password: password);

      _logger.i('✅ Auto-login successful, updating token');
      // Update token in storage
      await _storageService.saveAccount(
        email: email,
        password: password,
        token: token,
      );

      // Navigate to home
      isLoading.value = false;
      _logger.i('🏠 Navigating to home');
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e, stackTrace) {
      // Login failed -> clear cache and go to login
      _logger.e('❌ Auto-login failed, clearing cache', error: e, stackTrace: stackTrace);
      await _storageService.clearAccount();
      isLoading.value = false;
      //todo: uncomment this when login is implemented
      // Get.offAllNamed(AppRoutes.LOGIN);
      _logger.i('🏠 Navigating to home (fallback)');
      Get.offAllNamed(AppRoutes.HOME);
    }
  }
}
