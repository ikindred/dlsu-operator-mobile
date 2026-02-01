import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _storage = GetStorage();

  // Keys
  static const String _keyEmail = 'cached_email';
  static const String _keyPassword = 'cached_password';
  static const String _keyToken = 'cached_token';

  // Save account data
  Future<void> saveAccount({
    required String email,
    required String password,
    required String token,
  }) async {
    await _storage.write(_keyEmail, email);
    await _storage.write(_keyPassword, password);
    await _storage.write(_keyToken, token);
  }

  // Get cached account
  Map<String, String?> getCachedAccount() {
    return {
      'email': _storage.read(_keyEmail),
      'password': _storage.read(_keyPassword),
      'token': _storage.read(_keyToken),
    };
  }

  // Check if account exists
  bool hasCachedAccount() {
    final account = getCachedAccount();
    return account['email'] != null &&
        account['password'] != null &&
        account['token'] != null;
  }

  // Clear cached account
  Future<void> clearAccount() async {
    await _storage.remove(_keyEmail);
    await _storage.remove(_keyPassword);
    await _storage.remove(_keyToken);
  }

  // Initialize storage
  static Future<void> init() async {
    await GetStorage.init();
  }
}
