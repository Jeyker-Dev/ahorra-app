import 'package:ahorra_app/features/auth/domain/auth_tokens.dart';

/// Port handling login, token refresh, logout, and local token checks.
abstract interface class AuthRepository {
  Future<bool> hasTokens();

  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}
