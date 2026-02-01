import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/database/database.dart';
import 'app/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_colors.dart';

/// Set to true to seed the database with sample data on app start (e.g. for dev/demo).
const bool _kSeedDatabaseOnStart = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await StorageService.init();

  // Initialize SQLite database (creates DB and tables on first access)
  await DatabaseHelper.instance.db;

  if (_kSeedDatabaseOnStart) {
    await DatabaseSeeder.seed(clearFirst: true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DLSU Operator Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
    );
  }
}
