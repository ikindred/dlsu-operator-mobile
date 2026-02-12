import 'package:logger/logger.dart';
import 'database_helper.dart';

/// Seeds the local SQLite database with sample data.
/// Call [DatabaseSeeder.seed] once (e.g. on first run or for dev/demo).
class DatabaseSeeder {
  DatabaseSeeder._();

  static final DatabaseHelper _db = DatabaseHelper.instance;
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Run the seeder. Set [clearFirst] to true to delete existing data before seeding (dev only).
  static Future<void> seed({bool clearFirst = false}) async {
    _logger.i('🌱 Starting database seeding (clearFirst: $clearFirst)');
    if (clearFirst) {
      await _clearAll();
    }
    await _seedStuEmpList();
    await _seedStuEmpLogs();
    await _seedVisitorList();
    await _seedVisitorLogs();
    _logger.i('✅ Database seeding completed');
  }

  static Future<void> _clearAll() async {
    _logger.d('🗑️ Clearing all existing data...');
    final database = await _db.db;
    await database.delete(DatabaseHelper.tableStuEmpLogs);
    await database.delete(DatabaseHelper.tableStuEmpList);
    await database.delete(DatabaseHelper.tableVisitorLogs);
    await database.delete(DatabaseHelper.tableVisitorList);
    _logger.i('✅ All tables cleared');
  }

  static Future<void> _seedStuEmpList() async {
    _logger.d('📚 Seeding student/employee list...');
    final now = DateTime.now();
    final base = now.subtract(const Duration(days: 30));
    // status values: "allowed", "not_allowed"
    final rows = [
      {
        'id': 'STU-001',
        'remarks': 'Enrolled - BS Computer Science',
        'status': 'allowed',
        'profile': '{"name":"Maria Santos","type":"student","course":"BSCS"}',
        'created_at': base.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'STU-002',
        'remarks': 'Enrolled - BS Information Systems',
        'status': 'allowed',
        'profile': '{"name":"Juan Dela Cruz","type":"student","course":"BSIS"}',
        'created_at': base.add(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'EMP-001',
        'remarks': 'Faculty - College of Engineering',
        'status': 'allowed',
        'profile': '{"name":"Dr. Ana Reyes","type":"employee","dept":"COE"}',
        'created_at': base.add(const Duration(days: 2)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'STU-003',
        'remarks': 'On leave - Medical',
        'status': 'not_allowed',
        'profile': '{"name":"Pedro Garcia","type":"student","course":"BSCS"}',
        'created_at': base.add(const Duration(days: 5)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];
    for (final row in rows) {
      await _db.insertStuEmpList(row);
    }
    _logger.i('✅ Seeded ${rows.length} student/employee records');
  }

  static Future<void> _seedStuEmpLogs() async {
    _logger.d('📝 Seeding student/employee logs...');
    final now = DateTime.now();
    // Green: allowed, no remarks. Yellow: allowed, with remarks. Red: not_allowed.
    final rows = [
      {
        'id': '03124824',
        'remarks': '',
        'status': 'allowed',
        'profile': null,
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': '03124825',
        'remarks': 'Late enrollment',
        'status': 'allowed',
        'profile': null,
        'created_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'id': '03124826',
        'remarks': '',
        'status': 'not_allowed',
        'profile': null,
        'created_at': now.subtract(const Duration(minutes: 30)).toIso8601String(),
      },
    ];
    for (final row in rows) {
      await _db.insertStuEmpLog(Map<String, dynamic>.from(row));
    }
    _logger.i('✅ Seeded ${rows.length} student/employee log entries');
  }

  static Future<void> _seedVisitorList() async {
    _logger.d('👥 Seeding visitor list...');
    final now = DateTime.now();
    final base = now.subtract(const Duration(days: 7));
    final rows = [
      {
        'card_no': 'V-001',
        'vis_card': 'VC-1001',
        'created_at': base.toIso8601String(),
      },
      {
        'card_no': 'V-002',
        'vis_card': 'VC-1002',
        'created_at': base.add(const Duration(days: 1)).toIso8601String(),
      },
      {
        'card_no': 'V-003',
        'vis_card': 'VC-1003',
        'created_at': base.add(const Duration(days: 2)).toIso8601String(),
      },
    ];
    for (final row in rows) {
      await _db.insertVisitorList(row);
    }
    _logger.i('✅ Seeded ${rows.length} visitor records');
  }

  static Future<void> _seedVisitorLogs() async {
    _logger.d('📋 Seeding visitor logs...');
    final now = DateTime.now();
    final rows = [
      {
        'card_no': 'V-001',
        'vis_card': 'VC-1001',
        'created_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
      },
      {
        'card_no': 'V-001',
        'vis_card': 'VC-1001',
        'created_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'card_no': 'V-002',
        'vis_card': 'VC-1002',
        'created_at': now.subtract(const Duration(minutes: 45)).toIso8601String(),
      },
    ];
    for (final row in rows) {
      await _db.insertVisitorLog(row);
    }
    _logger.i('✅ Seeded ${rows.length} visitor log entries');
  }
}
