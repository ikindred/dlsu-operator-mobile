import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// Local SQLite database helper.
/// Tables: stu_emp_list, stu_emp_logs, visitor_list, visitor_logs
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;
  static const String _dbName = 'operator_app.db';
  static const int _dbVersion = 1;

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
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $tableStuEmpList (
        id TEXT PRIMARY KEY,
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
    return database.insert(tableStuEmpList, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllStuEmpList() async {
    final database = await db;
    return database.query(tableStuEmpList, orderBy: 'created_at DESC');
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

  Future<int> updateStuEmpList(String id, Map<String, dynamic> row) async {
    final database = await db;
    return database.update(
      tableStuEmpList,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStuEmpList(String id) async {
    final database = await db;
    return database.delete(
      tableStuEmpList,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- stu_emp_logs ----------

  Future<int> insertStuEmpLog(Map<String, dynamic> row) async {
    final database = await db;
    return database.insert(tableStuEmpLogs, row);
  }

  Future<List<Map<String, dynamic>>> getAllStuEmpLogs() async {
    final database = await db;
    return database.query(tableStuEmpLogs, orderBy: 'created_at DESC');
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
    return database.insert(tableVisitorList, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllVisitorList() async {
    final database = await db;
    return database.query(tableVisitorList, orderBy: 'created_at DESC');
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

  // ---------- visitor_logs ----------

  Future<int> insertVisitorLog(Map<String, dynamic> row) async {
    final database = await db;
    return database.insert(tableVisitorLogs, row);
  }

  Future<List<Map<String, dynamic>>> getAllVisitorLogs() async {
    final database = await db;
    return database.query(tableVisitorLogs, orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getVisitorLogsByCardNo(String cardNo) async {
    final database = await db;
    return database.query(
      tableVisitorLogs,
      where: 'card_no = ?',
      whereArgs: [cardNo],
      orderBy: 'created_at DESC',
    );
  }
}
