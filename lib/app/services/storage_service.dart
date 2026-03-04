import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

class StorageService {
  static final GetStorage _storage = GetStorage();
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

  // Keys
  static const String _keyEmail = 'cached_email';
  static const String _keyUsername = 'cached_username';
  static const String _keyName = 'cached_name';
  static const String _keyPassword = 'cached_password';
  static const String _keyToken = 'cached_token';
  static const String _keyOfflineMode = 'offline_mode';

  /// Whether the user chose to use the app without signing in (no sync/upload).
  bool isOfflineMode() {
    return _storage.read(_keyOfflineMode) == true;
  }

  Future<void> setOfflineMode(bool value) async {
    await _storage.write(_keyOfflineMode, value);
  }

  // Save account data
  Future<void> saveAccount({
    required String username,
    String? email,
    String? name,
    required String password,
    required String token,
  }) async {
    _logger.d('💾 Saving account data for username: $username');
    await _storage.write(_keyUsername, username);
    await _storage.write(_keyEmail, (email ?? '').trim());
    await _storage.write(_keyName, (name ?? '').trim());
    await _storage.write(_keyPassword, password);
    await _storage.write(_keyToken, token);
    await setOfflineMode(false); // User is signed in, no longer offline mode
    _logger.i('✅ Account data saved successfully');
  }

  // Get cached account
  Map<String, String?> getCachedAccount() {
    _logger.d('📖 Reading cached account data');
    final account = <String, String?>{
      'username': _storage.read(_keyUsername) as String?,
      'name': _storage.read(_keyName) as String?,
      'email': _storage.read(_keyEmail) as String?,
      'password': _storage.read(_keyPassword) as String?,
      'token': _storage.read(_keyToken) as String?,
    };
    final hasAccount = (account['username'] ?? account['email']) != null;
    _logger.d('${hasAccount ? '✅' : '📭'} Cached account ${hasAccount ? 'found' : 'not found'}');
    return account;
  }

  // Check if account exists
  bool hasCachedAccount() {
    final account = getCachedAccount();
    final loginId = account['username'] ?? account['email'];
    final exists = loginId != null &&
        account['password'] != null &&
        account['token'] != null;
    _logger.d('${exists ? '✅' : '📭'} Account cache check: ${exists ? 'exists' : 'does not exist'}');
    return exists;
  }

  // Clear cached account
  Future<void> clearAccount() async {
    _logger.d('🗑️ Clearing cached account data');
    await _storage.remove(_keyEmail);
    await _storage.remove(_keyUsername);
    await _storage.remove(_keyName);
    await _storage.remove(_keyPassword);
    await _storage.remove(_keyToken);
    await setOfflineMode(false);
    _logger.i('✅ Account data cleared');
  }

  // Initialize storage
  static Future<void> init() async {
    _logger.d('🔧 Initializing GetStorage...');
    await GetStorage.init();
    _logger.i('✅ GetStorage initialized');
  }
}
