import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  static const String _keyAuthToken = 'auth_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final List<Function(String?)> _listeners = [];

  static void addListener(Function(String?) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(String?) listener) {
    _listeners.remove(listener);
  }

  static void notifyListeners(String? token) {
    for (var listener in _listeners) {
      listener(token);
    }
  }

  static void setAuthToken(String token) {
    _storage.write(key: _keyAuthToken, value: token);
    notifyListeners(token);
  }

  static Future<String?> getAuthToken() {
    return _storage.read(key: _keyAuthToken);
  }

  static void deleteAuthToken() {
    _storage.delete(key: _keyAuthToken);
  }
}
