import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AuthService {
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
  
  String get _baseUrl => dotenv.env['BASE_URL'] ?? 'http://139.135.147.181:10580';

  String _normalizeAccessToken(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    final lower = t.toLowerCase();
    if (lower.startsWith('bearer ')) return t.substring('bearer '.length).trim();
    return t;
  }

  /// Login with username and password.
  /// Returns auth payload on success, throws exception on failure.
  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    _logger.d('🔐 Login request for username: $username');
    try {
      final url = Uri.parse('$_baseUrl/auth/employee');
      _logger.d('📤 POST request to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      _logger.d('📥 Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is! Map<String, dynamic>) {
          throw Exception('Unexpected login response format');
        }

        final accessToken =
            _normalizeAccessToken((data['access_token'] ?? '').toString());
        final user = (data['user'] is Map)
            ? Map<String, dynamic>.from(data['user'] as Map)
            : <String, dynamic>{};

        if (accessToken.isEmpty) {
          throw Exception('Login response missing access_token');
        }

        _logger.i('✅ Login successful, access token received');
        return AuthLoginResult(
          accessToken: accessToken,
          userId: (user['id'] ?? '').toString(),
          username: (user['username'] ?? '').toString(),
          email: (user['email'] ?? '').toString(),
        );
      } else {
        String serverMessage = '';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            serverMessage = body['message'].toString();
          }
        } catch (_) {}
        _logger.e('❌ Login failed with status: ${response.statusCode}');
        throw Exception(
          serverMessage.isNotEmpty
              ? serverMessage
              : 'Login failed: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('❌ Login error occurred', error: e, stackTrace: stackTrace);
      throw Exception('Login error: $e');
    }
  }

  /// Validate token (optional, for checking if cached token is still valid)
  Future<bool> validateToken(String token) async {
    _logger.d('🔍 Validating token...');
    try {
      final trimmed = token.trim();
      final authHeaderValue = trimmed.toLowerCase().startsWith('bearer ')
          ? trimmed
          : 'Bearer $trimmed';
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/validate'),
        headers: {'Authorization': authHeaderValue},
      );

      final isValid = response.statusCode == 200;
      _logger.d('${isValid ? '✅' : '❌'} Token validation result: $isValid');
      return isValid;
    } catch (e, stackTrace) {
      _logger.e('❌ Token validation error', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}

class AuthLoginResult {
  const AuthLoginResult({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.email,
  });

  final String accessToken;
  final String userId;
  final String username;
  final String email;
}
