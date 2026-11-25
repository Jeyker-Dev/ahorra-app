import 'package:ahorra_app/features/auth/domain/auth_tokens.dart';

/// Persistence port for session tokens stored securely on the device.
abstract interface class TokenStore {
  Future<AuthTokens?> read();

  Future<void> save(AuthTokens tokens);

  Future<void> clear();
}
