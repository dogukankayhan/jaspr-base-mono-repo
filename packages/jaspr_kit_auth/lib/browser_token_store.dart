import 'package:kit_auth/auth/domain/entity/auth_entity.dart';
import 'package:kit_auth/auth/token/token_store.dart';
import 'package:web/web.dart' as web;

export 'package:kit_auth/auth/token/token_store.dart';

/// [TokenStore] over the browser's Web Storage. Web twin of flutter_kit_auth's
/// `SecureTokenStore`.
///
/// ⚠️ Web Storage is readable by any script on the page, so a successful XSS
/// can steal tokens — there is no browser equivalent of the iOS Keychain /
/// Android Keystore. For production prefer having the backend set the refresh
/// token as an `HttpOnly; Secure; SameSite` cookie and keep only the
/// short-lived access token here (or in memory). Pass `window.sessionStorage`
/// to limit exposure to the current tab.
class BrowserTokenStore implements TokenStore {
  BrowserTokenStore({web.Storage? storage})
    : _s = storage ?? web.window.localStorage;

  static const _kA = 'access_token';
  static const _kR = 'refresh_token';
  final web.Storage _s;

  @override
  Future<void> clear() async {
    _s.removeItem(_kA);
    _s.removeItem(_kR);
  }

  @override
  Future<AuthTokens?> read() async {
    final a = _s.getItem(_kA);
    if (a == null || a.isEmpty) return null;
    return AuthTokens(accessToken: a, refreshToken: _s.getItem(_kR));
  }

  @override
  Future<String?> readAccess() async => _s.getItem(_kA);

  @override
  Future<String?> readRefresh() async => _s.getItem(_kR);

  @override
  Future<void> write(AuthTokens tokens) async {
    _s.setItem(_kA, tokens.accessToken);
    final refresh = tokens.refreshToken;
    if (refresh != null) _s.setItem(_kR, refresh);
  }
}
