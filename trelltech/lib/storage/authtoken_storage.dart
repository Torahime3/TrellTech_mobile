import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  static const String _keyAuthToken = 'auth_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> setAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: _keyAuthToken);
  }
}
