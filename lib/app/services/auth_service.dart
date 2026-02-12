import 'package:http/http.dart' as http;
import 'dart:convert';
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
  
  // TODO: Replace with actual API endpoint
  static const String _baseUrl = 'https://api.example.com';

  /// Login with email and password
  /// Returns token on success, throws exception on failure
  Future<String> login({
    required String email,
    required String password,
  }) async {
    _logger.d('🔐 Login request for email: $email');
    try {
      // TODO: Replace with actual API endpoint
      final url = Uri.parse('$_baseUrl/auth/login');
      _logger.d('📤 POST request to: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      _logger.d('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        _logger.i('✅ Login successful, token received');
        return token;
      } else {
        _logger.e('❌ Login failed with status: ${response.statusCode}');
        throw Exception('Login failed: ${response.statusCode}');
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
      // TODO: Replace with actual API endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/validate'),
        headers: {'Authorization': 'Bearer $token'},
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
