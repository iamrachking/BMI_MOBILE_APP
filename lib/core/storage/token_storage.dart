import 'package:get_storage/get_storage.dart';

/// Persistance du token Bearer qui est generer par le backend Laravel Sanctum.
class TokenStorage {
  TokenStorage._();

  static final _box = GetStorage();
  static const _keyToken = 'auth_token';

  static String? get token => _box.read<String>(_keyToken);

  static Future<void> saveToken(String token) async {
    await _box.write(_keyToken, token);
  }

  static Future<void> clearToken() async {
    await _box.remove(_keyToken);
  }

  static bool get isLoggedIn => token != null && token!.isNotEmpty;
}
