import 'package:ai4bmi/config/api_config.dart';

/// Token + email du lien « réinitialiser mot de passe » (rempli par main / splash / listener).
class PendingResetLink {
  PendingResetLink._();

  static String? _token;
  static String? _email;

  static void set(String token, String email) {
    _token = token;
    _email = email;
  }

  static String? get token => _token;
  static String? get email => _email;

  static bool get hasData =>
      _token != null &&
      _token!.isNotEmpty &&
      _email != null &&
      _email!.isNotEmpty;

  static void clear() {
    _token = null;
    _email = null;
  }

  static bool isResetPasswordUri(Uri uri) {
    if (uri.scheme == 'bmi' && uri.host == 'reset-password') return true;
    if (uri.scheme != 'https' || uri.host != ApiConfig.resetPasswordHost) {
      return false;
    }
    final path = uri.path;
    return path == ApiConfig.resetPasswordPath ||
        path == '${ApiConfig.resetPasswordPath}/' ||
        path.startsWith('${ApiConfig.resetPasswordPath}/');
  }

  static void trySetFromUri(Uri uri) {
    if (!isResetPasswordUri(uri)) return;
    final token = _extractToken(uri);
    final email = uri.queryParameters['email'] ?? '';
    if (token.isNotEmpty && email.isNotEmpty) set(token, email);
  }

  static String _extractToken(Uri uri) {
    final fromQuery =
        uri.queryParameters['token'] ??
        uri.queryParameters['reset_token'] ??
        uri.queryParameters['key'] ??
        '';
    if (fromQuery.isNotEmpty) return fromQuery;
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'reset-password') {
      return segments[1];
    }
    return '';
  }
}
