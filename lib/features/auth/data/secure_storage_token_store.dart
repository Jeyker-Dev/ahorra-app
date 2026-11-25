import 'package:ahorra_app/features/auth/domain/auth_tokens.dart';
import 'package:ahorra_app/features/auth/domain/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _accessTokenKey = 'ahorra_access_token';
const _refreshTokenKey = 'ahorra_refresh_token';
const _tokenTypeKey = 'ahorra_token_type';
const _expiresInKey = 'ahorra_expires_in';

/// Persists session tokens in Android Keystore via [FlutterSecureStorage].
class SecureStorageTokenStore implements TokenStore {
  SecureStorageTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokens?> read() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return null;
    }

    final tokenType = await _storage.read(key: _tokenTypeKey) ?? 'bearer';
    final rawExpiresIn = await _storage.read(key: _expiresInKey);
    final expiresIn = int.tryParse(rawExpiresIn ?? '') ?? 0;

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
  }

  @override
  Future<void> save(AuthTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
      _storage.write(key: _tokenTypeKey, value: tokens.tokenType),
      _storage.write(key: _expiresInKey, value: tokens.expiresIn.toString()),
    ]);
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _tokenTypeKey),
      _storage.delete(key: _expiresInKey),
    ]);
  }
}
