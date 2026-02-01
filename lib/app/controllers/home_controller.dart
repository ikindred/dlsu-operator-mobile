import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';
import '../database/database_helper.dart';

class HomeController extends GetxController {
  final StorageService _storageService = StorageService();

  final RxString userEmail = ''.obs;
  final RxString displayName = 'Kindred'.obs;

  // Dashboard counts from database
  final RxInt studentsCount = 0.obs;
  final RxInt studentNotUploadedCount = 0.obs;
  final RxInt visitorsCount = 0.obs;
  final RxInt visitorLogsCount = 0.obs;

  final RxString lastSync = 'Jan 2 2024 - 09:25:48 AM'.obs;
  final RxString lastUpload = 'Jan 2 2024 - 09:25:48 AM'.obs;
  final RxString lastUpdate = 'Jan 2 2024 - 09:25:48 AM'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  @override
  void onReady() {
    super.onReady();
    loadDashboardCounts();
  }

  Future<void> loadDashboardCounts() async {
    studentsCount.value = await DatabaseHelper.instance.getStuEmpListCount();
    studentNotUploadedCount.value =
        await DatabaseHelper.instance.getStuEmpLogsCount();
    visitorsCount.value = await DatabaseHelper.instance.getVisitorListCount();
    visitorLogsCount.value =
        await DatabaseHelper.instance.getVisitorLogsCount();
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

  Future<void> refreshStudents() async {
    // TODO: call API to sync students
    await loadDashboardCounts();
  }

  Future<void> uploadStudents() async {
    // TODO: call API to upload students
    await loadDashboardCounts();
  }

  Future<void> uploadVisitors() async {
    // TODO: call API to upload visitors
    await loadDashboardCounts();
  }

  Future<void> downloadVisitorLogs() async {
    // TODO: call API to download/export visitor logs
    await loadDashboardCounts();
  }

  Future<void> logout() async {
    await _storageService.clearAccount();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
