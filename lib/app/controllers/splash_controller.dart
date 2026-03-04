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
      if (_storageService.isOfflineMode()) {
        // Offline mode -> go to home (guest)
        _logger.i('📴 Offline mode, navigating to home');
        isLoading.value = false;
        Get.offAllNamed(AppRoutes.HOME);
        return;
      }
      // No cached account -> go to login
      _logger.i('📭 No cached account found, navigating to login');
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }

    // Has cached account -> call login API
    _logger.i('✅ Cached account found, attempting auto-login');
    try {
      final username = (cachedAccount['username'] ?? cachedAccount['email'])!;
      final password = cachedAccount['password']!;

      _logger.d('🔐 Attempting login with cached credentials');
      final result = await _authService.login(
        username: username,
        password: password,
      );

      _logger.i('✅ Auto-login successful, updating token');
      // Update token in storage
      await _storageService.saveAccount(
        username: username,
        email: result.email.isNotEmpty ? result.email : cachedAccount['email'],
        name: result.username.isNotEmpty ? result.username : cachedAccount['name'],
        password: password,
        token: result.accessToken,
      );

      // Navigate to home
      isLoading.value = false;
      _logger.i('🏠 Navigating to home');
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e, stackTrace) {
      // Login failed -> clear cache and go to login
      _logger.e(
        '❌ Auto-login failed, clearing cache',
        error: e,
        stackTrace: stackTrace,
      );
      await _storageService.clearAccount();
      isLoading.value = false;
      _logger.i('🔐 Navigating to login (auto-login failed)');
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
