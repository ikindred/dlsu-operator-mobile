import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'storage_service.dart';

class UploadLogsResult {
  const UploadLogsResult._({
    required this.ok,
    this.sentCount = 0,
    this.statusCode,
    this.error,
  });

  final bool ok;
  final int sentCount;
  final int? statusCode;
  final String? error;

  factory UploadLogsResult.success(int sentCount) =>
      UploadLogsResult._(ok: true, sentCount: sentCount);

  factory UploadLogsResult.failure({
    required String error,
    int? statusCode,
  }) =>
      UploadLogsResult._(ok: false, error: error, statusCode: statusCode);
}

class ReportService {
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

  Future<UploadLogsResult> uploadStuEmpLogs(
    List<Map<String, dynamic>> logs,
  ) async {
    final baseUrlRaw = (dotenv.env['BASE_URL'] ?? '').trim();
    if (baseUrlRaw.isEmpty) {
      return UploadLogsResult.failure(error: 'Missing BASE_URL in .env');
    }
    final baseUrl = baseUrlRaw.endsWith('/')
        ? baseUrlRaw.substring(0, baseUrlRaw.length - 1)
        : baseUrlRaw;

    final token = (_storage.getCachedAccount()['token'] ?? '').trim();
    final uri = Uri.parse('$baseUrl/reports');
    _logger.i('📤 Upload student logs POST: $uri');

    final payload = <Map<String, dynamic>>[];
    for (final log in logs) {
      final id = (log['id'] ?? '').toString().trim();
      final createdAt = (log['created_at'] ?? '').toString().trim();
      if (id.isEmpty || createdAt.isEmpty) continue;

      final remarks = (log['remarks'] ?? '').toString();
      final status = _mapStatusToApi(log['status']?.toString(), remarks);

      payload.add({
        'datetime': createdAt,
        'type': '1',
        'user_id': id,
        // ! TODO: include student name once available in stu_emp_logs
        'remarks': remarks,
        'status': status,
        'device': 'Mobile App',
      });
    }

    if (payload.isEmpty) {
      return UploadLogsResult.failure(error: 'No valid logs to upload');
    }

    try {
      final authHeaderValue = _toAuthHeaderValue(token);
      final headers = <String, String>{
        'accept': '*/*',
        'Content-Type': 'application/json',
        if (authHeaderValue.isNotEmpty) 'Authorization': authHeaderValue,
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      _logger.i('📥 Upload logs status: ${response.statusCode}');

      if (response.statusCode == 401) {
        return UploadLogsResult.failure(
          error: 'Unauthorized (missing/invalid token)',
          statusCode: 401,
        );
      }

      if (response.statusCode == 201) {
        return UploadLogsResult.success(payload.length);
      }

      String serverMessage = '';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          serverMessage = body['message'].toString();
        }
      } catch (_) {}

      return UploadLogsResult.failure(
        error: serverMessage.isNotEmpty
            ? serverMessage
            : 'Upload failed: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } catch (e, st) {
      _logger.e('❌ Upload logs error', error: e, stackTrace: st);
      return UploadLogsResult.failure(error: 'Upload error: $e');
    }
  }

  /// API status strings:
  /// - GREEN;allowed: status is Y/allowed, no remarks
  /// - YELLOW;pending: status is Y/allowed, has remarks
  /// - RED;cannot enter with or without remarks: status is N/not_allowed
  static String _mapStatusToApi(String? status, String? remarks) {
    final s = (status ?? '').toString().trim().toUpperCase();
    final r = (remarks ?? '').trim();
    final hasRemarks = r.isNotEmpty;

    final isDenied = s == 'N' || s == 'NOT_ALLOWED';
    final isAllowed = s == 'Y' || s == 'ALLOWED' || s.isEmpty;

    if (isDenied) return 'RED;cannot enter with or without remarks';
    if (isAllowed && hasRemarks) return 'YELLOW;pending';
    return 'GREEN;allowed';
  }
}

