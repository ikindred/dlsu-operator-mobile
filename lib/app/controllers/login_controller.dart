import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class LoginController extends GetxController {
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

  final RxString employeeId = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final Rxn<String> errorMessage = Rxn<String>();

  void updateEmployeeId(String value) => employeeId.value = value;
  void updatePassword(String value) => password.value = value;
  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  Future<void> login() async {
    _logger.i('🔐 Login attempt started');
    
    if (employeeId.value.isEmpty || password.value.isEmpty) {
      _logger.w('⚠️ Login validation failed: empty fields');
      errorMessage.value = 'Please enter Employee ID and password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    _logger.d('📤 Attempting login for employee: ${employeeId.value}');

    try {
      final result = await _authService.login(
        username: employeeId.value,
        password: password.value,
      );

      _logger.i('✅ Login successful, saving account data');

      await _storageService.saveAccount(
        username: employeeId.value,
        email: result.email.isNotEmpty ? result.email : null,
        name: result.username.isNotEmpty ? result.username : employeeId.value,
        password: password.value,
        token: result.accessToken,
      );

      // Navigate to home
      isLoading.value = false;
      _logger.i('🏠 Navigating to home');
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e, stackTrace) {
      _logger.e('❌ Login failed', error: e, stackTrace: stackTrace);
      isLoading.value = false;
      errorMessage.value = 'Login failed: ${e.toString()}';
    }
  }
}
