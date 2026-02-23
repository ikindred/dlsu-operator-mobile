import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'app/database/database.dart';
import 'app/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_colors.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

/// Set to true to seed the database with sample data on app start (e.g. for dev/demo).
/// When true, existing data is cleared every launch—set to false so imports persist across restarts.
const bool _kSeedDatabaseOnStart = false;

void main() async {
  logger.i('🚀 App starting...');
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: '.env');

  // Initialize GetStorage
  logger.d('💾 Initializing storage...');
  await StorageService.init();

  // Initialize SQLite database (creates DB and tables on first access)
  logger.d('🗄️ Initializing database...');
  await DatabaseHelper.instance.db;
  logger.i('✅ Database initialized');

  // Initialize MediaStore for saving exports to Downloads (Android)
  if (Platform.isAndroid) {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = 'OperatorApp';
  }

  // Lock screen orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (_kSeedDatabaseOnStart) {
    logger.i('🌱 Seeding database...');
    await DatabaseSeeder.seed(clearFirst: true);
    logger.i('✅ Database seeded');
  }

  logger.i('🎨 Launching app...');
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
