import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:media_store_plus/media_store_plus.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';
import '../database/database_helper.dart';
import 'scanner_controller.dart';

class HomeController extends GetxController {
  final StorageService _storageService = StorageService();
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
    studentNotUploadedCount.value = await DatabaseHelper.instance
        .getStuEmpLogsCount();
    visitorsCount.value = await DatabaseHelper.instance.getVisitorListCount();
    visitorLogsCount.value = await DatabaseHelper.instance
        .getVisitorLogsCount();
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
        displayName.value =
            part[0].toUpperCase() + part.substring(1).toLowerCase();
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
    _logger.i('🚀 Starting CSV upload process');

    try {
      // Pick CSV file
      _logger.d('📂 Opening file picker for CSV selection');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        _logger.w('⚠️ File selection cancelled or no file selected');
        Get.snackbar(
          'Upload Cancelled',
          'No file selected',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final filePath = result.files.single.path!;
      final file = File(filePath);
      _logger.i('✅ File selected: $filePath');

      // Read file content
      _logger.d('📖 Reading file content...');
      final fileContent = await file.readAsString();
      final fileSizeBytes = fileContent.length;
      _logger.i(
        '📄 File read successfully. Size: $fileSizeBytes bytes (${(fileSizeBytes / 1024).toStringAsFixed(2)} KB)',
      );

      // Parse CSV
      _logger.d('🔍 Parsing CSV data...');
      final csvData = const CsvToListConverter().convert(
        fileContent,
        eol: '\n',
      );
      _logger.i('📊 CSV parsed. Total rows: ${csvData.length}');

      if (csvData.isEmpty) {
        _logger.e('❌ CSV file is empty');
        Get.snackbar(
          'Error',
          'CSV file is empty',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get header row (first row)
      _logger.d('🔎 Analyzing CSV header row...');
      final headerRow = csvData[0];
      _logger.d('📋 Header row: $headerRow');

      final cardNoIndex = headerRow.indexWhere(
        (cell) => cell.toString().toLowerCase().trim() == 'card no',
      );
      final visCardIndex = headerRow.indexWhere(
        (cell) => cell.toString().toLowerCase().trim() == 'vis card',
      );

      _logger.i(
        '📍 Column indices - Card No: $cardNoIndex, Vis Card: $visCardIndex',
      );

      if (cardNoIndex == -1 || visCardIndex == -1) {
        _logger.e('❌ Required columns not found in CSV');
        Get.snackbar(
          'Error',
          'CSV must contain "Card No" and "Vis Card" columns',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Parse and validate data rows
      _logger.d('🔄 Processing data rows (excluding header)...');
      final List<Map<String, dynamic>> validRows = [];
      int skippedRows = 0;

      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length <= cardNoIndex || row.length <= visCardIndex) {
          skippedRows++;
          if (i <= 5) {
            _logger.w(
              '⚠️ Row $i skipped: insufficient columns (has ${row.length}, needs ${cardNoIndex > visCardIndex ? cardNoIndex + 1 : visCardIndex + 1})',
            );
          }
          continue;
        }

        final cardNo = row[cardNoIndex]?.toString().trim() ?? '';
        final visCard = row[visCardIndex]?.toString().trim() ?? '';

        // Validate that both fields are not empty
        if (cardNo.isEmpty || visCard.isEmpty) {
          skippedRows++;
          if (i <= 5) {
            _logger.w('⚠️ Row $i skipped: empty card_no or vis_card');
          }
          continue;
        }

        validRows.add({'card_no': cardNo, 'vis_card': visCard});
      }

      _logger.i(
        '✅ Data validation complete. Valid rows: ${validRows.length}, Skipped: $skippedRows',
      );

      if (validRows.isEmpty) {
        _logger.e('❌ No valid data rows found after validation');
        Get.snackbar(
          'Error',
          'No valid data found in CSV file',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get current count before insertion
      final countBefore = await DatabaseHelper.instance.getVisitorListCount();
      _logger.i('📊 Current visitor count in database: $countBefore');

      // Show loading indicator
      Get.dialog(
        const Material(
          color: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        ),
        barrierDismissible: false,
      );

      // Insert into database
      _logger.d(
        '💾 Starting database insertion for ${validRows.length} rows...',
      );
      final startTime = DateTime.now();

      final insertedCount = await DatabaseHelper.instance
          .batchInsertVisitorList(validRows);

      final duration = DateTime.now().difference(startTime);
      _logger.i(
        '✅ Database insertion completed. Inserted: $insertedCount rows in ${duration.inMilliseconds}ms',
      );

      // Close loading dialog
      Get.back();

      // Update counts
      _logger.d('🔄 Refreshing dashboard counts...');
      await loadDashboardCounts();
      final countAfter = await DatabaseHelper.instance.getVisitorListCount();
      _logger.i(
        '📊 Visitor count after insertion: $countAfter (was $countBefore)',
      );

      // Show success message
      _logger.i('🎉 Upload completed successfully');
      Get.snackbar(
        'Upload Successful',
        'Imported $insertedCount visitor${insertedCount != 1 ? 's' : ''}${skippedRows > 0 ? ' ($skippedRows row${skippedRows != 1 ? 's' : ''} skipped)' : ''}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e, stackTrace) {
      _logger.e('❌ Upload failed with error', error: e, stackTrace: stackTrace);
      Get.back(); // Close loading dialog if open
      Get.snackbar(
        'Upload Failed',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> downloadVisitorLogs() async {
    try {
      _logger.i('📥 Exporting visitor logs to CSV...');
      final logs = await DatabaseHelper.instance.getAllVisitorLogs();
      if (logs.isEmpty) {
        Get.snackbar(
          'No data',
          'There are no visitor logs to export.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      // Export only visitor_logs columns: card_no, vis_card, entry_timestamp (created_at)
      final rows = <List<dynamic>>[
        ['Card No', 'Visitor Card', 'Entry Timestamp'],
        ...logs.map((row) => [
              row['card_no']?.toString() ?? '',
              row['vis_card']?.toString() ?? '',
              row['created_at']?.toString() ?? '',
            ]),
      ];
      final csvString = const ListToCsvConverter().convert(rows);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final fileName = 'visitor_logs_$timestamp.csv';
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsString(csvString);
      _logger.i('✅ Visitor logs prepared: ${file.path}');

      if (Platform.isAndroid) {
        // Save directly to device Downloads folder (visible in Files/Downloads app)
        final saveInfo = await MediaStore().saveFile(
          tempFilePath: file.path,
          dirType: DirType.download,
          dirName: DirName.download,
          relativePath: FilePath.root,
        );
        if (saveInfo != null) {
          Get.snackbar(
            'Saved to Downloads',
            '$fileName is in your Download folder.',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Export ready',
            'Use the share menu to save to Downloads.',
            snackPosition: SnackPosition.BOTTOM,
          );
          await Share.shareXFiles([XFile(file.path)], subject: 'Visitor logs export', text: fileName);
        }
      } else {
        // iOS / other: use share sheet so user can save to Files
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Visitor logs export',
          text: 'Save to Files to keep a copy.',
        );
        Get.snackbar(
          'Export ready',
          'Use the share menu to save to Files.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      await loadDashboardCounts();
    } catch (e, stackTrace) {
      _logger.e('❌ Export failed', error: e, stackTrace: stackTrace);
      Get.snackbar(
        'Export Failed',
        'Could not export visitor logs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> logout() async {
    try {
      await Get.find<ScannerController>().disposeReader();
    } catch (_) {}
    await _storageService.clearAccount();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
