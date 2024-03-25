import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  static const String _keyAuthToken = 'auth_token';
  final FlutterSecureStorage _storage;
  static final List<Function(String?)> _listeners = [];

  AuthTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

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

  Future<void> setAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
    notifyListeners(token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _keyAuthToken);
  }
}
