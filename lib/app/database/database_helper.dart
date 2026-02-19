import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// Local SQLite database helper.
/// Tables: stu_emp_list, stu_emp_logs, visitor_list, visitor_logs
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;
  static const String _dbName = 'operator_app.db';
  static const int _dbVersion = 1;

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

  // Table names
  static const String tableStuEmpList = 'stu_emp_list';
  static const String tableStuEmpLogs = 'stu_emp_logs';
  static const String tableVisitorList = 'visitor_list';
  static const String tableVisitorLogs = 'visitor_logs';

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $tableStuEmpList (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT UNIQUE,
        card_no TEXT,
        type TEXT,
        remarks TEXT,
        status TEXT,
        profile TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await database.execute('''
      CREATE TABLE $tableStuEmpLogs (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT,
        card_no TEXT,
        type TEXT,
        remarks TEXT,
        status TEXT,
        profile TEXT,
        created_at TEXT
      )
    ''');

    await database.execute('''
      CREATE TABLE $tableVisitorList (
        card_no TEXT PRIMARY KEY,
        vis_card TEXT,
        created_at TEXT
      )
    ''');

    await database.execute('''
      CREATE TABLE $tableVisitorLogs (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_no TEXT,
        vis_card TEXT,
        created_at TEXT
      )
    ''');
  }

  /// Close the database (call when app terminates if needed)
  Future<void> close() async {
    final database = _db;
    if (database != null) {
      await database.close();
      _db = null;
    }
  }

  // ---------- stu_emp_list ----------

  Future<int> insertStuEmpList(Map<String, dynamic> row) async {
    final database = await db;
    final id = row['id']?.toString() ?? '';
    final data = <String, dynamic>{
      'id': id,
      'card_no': row['card_no']?.toString(),
      'type': row['type']?.toString() ?? 'student',
      'remarks': row['remarks'],
      'status': row['status'],
      'profile': row['profile'],
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
    };
    return database.insert(
      tableStuEmpList,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllStuEmpList() async {
    final database = await db;
    return database.query(tableStuEmpList, orderBy: 'created_at DESC');
  }

  Future<int> getStuEmpListCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as c FROM $tableStuEmpList',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<Map<String, dynamic>?> getStuEmpListById(String id) async {
    final database = await db;
    final list = await database.query(
      tableStuEmpList,
      where: 'id = ?',
      whereArgs: [id],
    );
    return list.isNotEmpty ? list.first : null;
  }

  /// Look up a row in stu_emp_list by card_no (e.g. NFC UID in hex or decimal).
  Future<Map<String, dynamic>?> getStuEmpListByCardNo(String cardNo) async {
    if (cardNo.trim().isEmpty) return null;
    final database = await db;
    final list = await database.query(
      tableStuEmpList,
      where: 'card_no = ?',
      whereArgs: [cardNo.trim()],
    );
    return list.isNotEmpty ? list.first : null;
  }

  Future<int> updateStuEmpList(String id, Map<String, dynamic> row) async {
    final database = await db;
    final data = Map<String, dynamic>.from(row)
      ..remove('_id')
      ..remove('id');
    if (data.isEmpty) return 0;
    return database.update(
      tableStuEmpList,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStuEmpList(String id) async {
    final database = await db;
    return database.delete(tableStuEmpList, where: 'id = ?', whereArgs: [id]);
  }

  /// Saves a scanned card to stu_emp_list (upsert) and adds an entry to stu_emp_logs.
  /// DISABLED: Scanned cards are only looked up, not saved. Re-enable by uncommenting the body.
  Future<void> saveScannedCard(String cardId) async {
    // final now = DateTime.now().toIso8601String();
    // final profileJson =
    //     '{"name":"Scanned Card","type":"student","uid":"$cardId"}';
    // final listRow = <String, dynamic>{
    //   'id': cardId,
    //   'card_no': cardId,
    //   'type': 'student',
    //   'remarks': 'Scanned via NFC',
    //   'status': 'allowed',
    //   'profile': profileJson,
    //   'created_at': now,
    //   'updated_at': now,
    // };
    // await insertStuEmpList(listRow);
    // final logRow = <String, dynamic>{
    //   'id': cardId,
    //   'card_no': cardId,
    //   'type': 'student',
    //   'remarks': '',
    //   'status': 'allowed',
    //   'profile': profileJson,
    //   'created_at': now,
    // };
    // await insertStuEmpLog(logRow);
  }

  // ---------- stu_emp_logs ----------

  Future<int> insertStuEmpLog(Map<String, dynamic> row) async {
    final database = await db;
    final data = Map<String, dynamic>.from(row);
    data.putIfAbsent('type', () => 'student');
    return database.insert(tableStuEmpLogs, data);
  }

  Future<List<Map<String, dynamic>>> getAllStuEmpLogs() async {
    final database = await db;
    return database.query(tableStuEmpLogs, orderBy: 'created_at DESC');
  }

  Future<int> getStuEmpLogsCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as c FROM $tableStuEmpLogs',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getStuEmpLogsById(String id) async {
    final database = await db;
    return database.query(
      tableStuEmpLogs,
      where: 'id = ?',
      whereArgs: [id],
      orderBy: 'created_at DESC',
    );
  }

  // ---------- visitor_list ----------

  Future<int> insertVisitorList(Map<String, dynamic> row) async {
    final database = await db;
    return database.insert(
      tableVisitorList,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllVisitorList() async {
    final database = await db;
    return database.query(tableVisitorList, orderBy: 'created_at DESC');
  }

  Future<int> getVisitorListCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as c FROM $tableVisitorList',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<Map<String, dynamic>?> getVisitorListByCardNo(String cardNo) async {
    final database = await db;
    final list = await database.query(
      tableVisitorList,
      where: 'card_no = ?',
      whereArgs: [cardNo],
    );
    return list.isNotEmpty ? list.first : null;
  }

  Future<int> updateVisitorList(String cardNo, Map<String, dynamic> row) async {
    final database = await db;
    return database.update(
      tableVisitorList,
      row,
      where: 'card_no = ?',
      whereArgs: [cardNo],
    );
  }

  Future<int> deleteVisitorList(String cardNo) async {
    final database = await db;
    return database.delete(
      tableVisitorList,
      where: 'card_no = ?',
      whereArgs: [cardNo],
    );
  }

  /// Clear all visitor list records
  Future<void> clearVisitorList() async {
    final database = await db;
    await database.delete(tableVisitorList);
  }

  /// Batch insert visitor list records. Replaces all existing data with new data.
  /// Returns the number of successfully inserted records.
  Future<int> batchInsertVisitorList(List<Map<String, dynamic>> rows) async {
    _logger.i('💾 Starting batch insert. Input rows: ${rows.length}');

    final database = await db;
    final now = DateTime.now().toIso8601String();
    int insertedCount = 0;

    // Prepare valid rows first (deduplicate by card_no, reject invalid values)
    _logger.d('🔄 Preparing valid rows for insertion...');
    final List<Map<String, dynamic>> validRows = [];
    final Set<String> seenCardNos = {};
    for (final row in rows) {
      final rawCardNo = row['card_no'] == null
          ? ''
          : (row['card_no'] is num)
          ? (row['card_no'] as num).isFinite
                ? (row['card_no'] as num).toString()
                : ''
          : (row['card_no'] as Object).toString().trim();
      final visCard = row['vis_card']?.toString().trim() ?? '';

      // Skip empty or invalid card_no (e.g. Infinity, NaN from CSV/number parsing)
      if (rawCardNo.isEmpty ||
          rawCardNo.toLowerCase() == 'infinity' ||
          rawCardNo.toLowerCase() == 'nan') {
        _logger.w('⚠️ Skipping row with invalid card_no: "$rawCardNo"');
        continue;
      }
      if (visCard.isEmpty) {
        _logger.w('⚠️ Skipping row with empty vis_card');
        continue;
      }
      // Deduplicate: keep first occurrence of each card_no
      if (seenCardNos.contains(rawCardNo)) {
        _logger.d('⚠️ Skipping duplicate card_no: $rawCardNo');
        continue;
      }
      seenCardNos.add(rawCardNo);

      validRows.add({
        'card_no': rawCardNo,
        'vis_card': visCard,
        'created_at': row['created_at'] ?? now,
      });
      insertedCount++;
    }

    _logger.i(
      '✅ Prepared $insertedCount valid rows out of ${rows.length} total',
    );

    // Use a transaction to ensure atomicity: clear table, then insert all records
    _logger.d('🔄 Starting database transaction (clear + insert)...');
    final transactionStartTime = DateTime.now();

    await database.transaction((txn) async {
      // First, clear all existing records
      _logger.d('🗑️ Clearing existing records from visitor_list table...');
      final deletedCount = await txn.delete(tableVisitorList);
      _logger.i('🗑️ Deleted $deletedCount existing records');

      // Then, insert all new records using batch for efficiency
      _logger.d('📦 Preparing batch insert for ${validRows.length} records...');
      final batch = txn.batch();
      for (final data in validRows) {
        batch.insert(tableVisitorList, data);
      }

      // Commit the batch - this will execute all inserts
      _logger.d('💾 Committing batch insert...');
      await batch.commit();
      _logger.d('✅ Batch commit completed');
      // Transaction will auto-commit when this function completes successfully
    });

    final transactionDuration = DateTime.now().difference(transactionStartTime);
    _logger.i(
      '✅ Transaction completed successfully. Inserted $insertedCount records in ${transactionDuration.inMilliseconds}ms',
    );

    return insertedCount;
  }

  // ---------- visitor_logs ----------

  Future<int> insertVisitorLog(Map<String, dynamic> row) async {
    final database = await db;
    return database.insert(tableVisitorLogs, row);
  }

  Future<List<Map<String, dynamic>>> getAllVisitorLogs() async {
    final database = await db;
    return database.query(tableVisitorLogs, orderBy: 'created_at DESC');
  }

  Future<int> getVisitorLogsCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as c FROM $tableVisitorLogs',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getVisitorLogsByCardNo(
    String cardNo,
  ) async {
    final database = await db;
    return database.query(
      tableVisitorLogs,
      where: 'card_no = ?',
      whereArgs: [cardNo],
      orderBy: 'created_at DESC',
    );
  }
}
