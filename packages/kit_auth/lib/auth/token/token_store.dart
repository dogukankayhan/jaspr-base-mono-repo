import '../domain/entity/auth_entity.dart';

/// Persistence contract for auth tokens. Platform implementations:
/// `SecureTokenStore` (flutter_secure_storage) in `flutter_kit_auth`, and a
/// browser-storage store in the web app.
abstract class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
  Future<String?> readAccess();
  Future<String?> readRefresh();
}
