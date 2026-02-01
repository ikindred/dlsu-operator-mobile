import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController {
  final StorageService _storageService = StorageService();

  final RxString userEmail = ''.obs;
  final RxString displayName = 'Kindred'.obs;

  // Dashboard stats (placeholder – wire to API later)
  final RxInt studentsCount = 15482.obs;
  final RxInt studentNotUploadedCount = 500.obs;
  final RxInt visitorsCount = 20000.obs;

  final RxString lastSync = 'Jan 2 2024 - 09:25:48 AM'.obs;
  final RxString lastUpload = 'Jan 2 2024 - 09:25:48 AM'.obs;
  final RxString lastUpdate = 'Jan 2 2024 - 09:25:48 AM'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final account = _storageService.getCachedAccount();
    userEmail.value = account['email'] ?? '';
    // Use name from account if available, else derive from email or default
    final name = account['name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      displayName.value = name.toString().trim();
    } else if (userEmail.value.isNotEmpty) {
      final part = userEmail.value.split('@').first;
      if (part.isNotEmpty) {
        displayName.value = part[0].toUpperCase() + part.substring(1).toLowerCase();
      }
    }
  }

  void refreshStudents() {
    // TODO: call API to sync students
  }

  void uploadStudents() {
    // TODO: call API to upload students
  }

  Future<void> logout() async {
    await _storageService.clearAccount();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
