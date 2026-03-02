import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'storage_service.dart';

class SyncStudentsResult {
  const SyncStudentsResult._({
    required this.ok,
    this.rows = const [],
    this.statusCode,
    this.error,
  });

  final bool ok;
  final List<Map<String, dynamic>> rows;
  final int? statusCode;
  final String? error;

  factory SyncStudentsResult.success(List<Map<String, dynamic>> rows) =>
      SyncStudentsResult._(ok: true, rows: rows);

  factory SyncStudentsResult.failure({
    required String error,
    int? statusCode,
  }) =>
      SyncStudentsResult._(ok: false, error: error, statusCode: statusCode);
}

class SyncService {
  final StorageService _storage = StorageService();
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

  static String _toAuthHeaderValue(String token) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.toLowerCase().startsWith('bearer ') ? trimmed : 'Bearer $trimmed';
  }

  Future<SyncStudentsResult> syncStudents() async {
    final baseUrlRaw = (dotenv.env['BASE_URL'] ?? '').trim();
    if (baseUrlRaw.isEmpty) {
      return SyncStudentsResult.failure(
        error: 'Missing BASE_URL in .env',
      );
    }
    final baseUrl =
        baseUrlRaw.endsWith('/') ? baseUrlRaw.substring(0, baseUrlRaw.length - 1) : baseUrlRaw;

    final token = _storage.getCachedAccount()['token'] ?? '';
    final uri = Uri.parse('$baseUrl/sync/students');
    _logger.i('🔄 Sync students GET: $uri');

    try {
      final authHeaderValue = _toAuthHeaderValue(token);
      final headers = <String, String>{
        'accept': 'application/json',
        if (authHeaderValue.isNotEmpty) 'Authorization': authHeaderValue,
      };

      final response = await http.get(uri, headers: headers);
      _logger.i('📥 Sync students status: ${response.statusCode}');

      if (response.statusCode == 401) {
        return SyncStudentsResult.failure(
          error: 'Unauthorized (missing/invalid token)',
          statusCode: 401,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return SyncStudentsResult.failure(
          error: 'Sync failed: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return SyncStudentsResult.failure(
          error: 'Unexpected response format (expected object)',
          statusCode: response.statusCode,
        );
      }

      final rawStudents = decoded['students'];
      if (rawStudents is! List) {
        return SyncStudentsResult.failure(
          error: 'Unexpected response format (missing students array)',
          statusCode: response.statusCode,
        );
      }

      final rows = <Map<String, dynamic>>[];
      var skippedArchived = 0;
      var skippedInvalid = 0;

      for (final item in rawStudents) {
        if (item is! Map) {
          skippedInvalid++;
          continue;
        }
        final s = Map<String, dynamic>.from(item);

        final isArchived = s['isArchived'];
        if (isArchived == true) {
          skippedArchived++;
          continue;
        }

        final idNumber = (s['ID_Number'] ?? '').toString().trim();
        final uniqueId = (s['Unique_ID'] ?? '').toString().trim();
        final cardNo = uniqueId.isNotEmpty ? uniqueId : idNumber;
        if (idNumber.isEmpty) {
          skippedInvalid++;
          continue;
        }

        final campusEntry = (s['Campus_Entry'] ?? '').toString().trim().toUpperCase();
        final status = campusEntry == 'Y'
            ? 'allowed'
            : campusEntry == 'N'
                ? 'not_allowed'
                : 'not_allowed';

        final group = (s['group'] ?? '').toString().trim().toUpperCase();
        final type = group == 'EMPLOYEE' ? 'employee' : 'student';

        rows.add({
          // Option A mapping: keep existing local column names
          'id': idNumber,
          'card_no': cardNo,
          'name': s['Name']?.toString(),
          'type': type,
          'remarks': s['Remarks']?.toString(),
          'status': status,
          'profile': s['Photo']?.toString(),
          'created_at': s['createdAt']?.toString(),
          'updated_at': s['updatedAt']?.toString(),
        });
      }

      _logger.i(
        '✅ Sync students parsed: ${rows.length} rows (skipped archived=$skippedArchived, invalid=$skippedInvalid)',
      );
      return SyncStudentsResult.success(rows);
    } catch (e, st) {
      _logger.e('❌ Sync students error', error: e, stackTrace: st);
      return SyncStudentsResult.failure(error: 'Sync error: $e');
    }
  }
}

