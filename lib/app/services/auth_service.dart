import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // TODO: Replace with actual API endpoint
  static const String _baseUrl = 'https://api.example.com';

  /// Login with email and password
  /// Returns token on success, throws exception on failure
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with actual API endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Validate token (optional, for checking if cached token is still valid)
  Future<bool> validateToken(String token) async {
    try {
      // TODO: Replace with actual API endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/validate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
