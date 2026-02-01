import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class LoginController extends GetxController {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

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
    if (employeeId.value.isEmpty || password.value.isEmpty) {
      errorMessage.value = 'Please enter Employee ID and password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Using employeeId as email for API (update AuthService if API uses different field)
      final token = await _authService.login(
        email: employeeId.value,
        password: password.value,
      );

      // Save account data (using employeeId as email identifier)
      await _storageService.saveAccount(
        email: employeeId.value,
        password: password.value,
        token: token,
      );

      // Navigate to home
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Login failed: ${e.toString()}';
    }
  }
}
