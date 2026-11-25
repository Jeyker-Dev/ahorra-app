import 'package:ahorra_app/core/network/auth_token_delegate.dart';
import 'package:ahorra_app/features/auth/data/remote_auth_repository.dart';
import 'package:ahorra_app/features/auth/domain/token_store.dart';

/// Bridges [TokenStore] and [RemoteAuthRepository] into `core/network`'s [AuthTokenDelegate].
class AuthSessionDelegate implements AuthTokenDelegate {
  AuthSessionDelegate({
    required TokenStore tokenStore,
    required RemoteAuthRepository authRepository,
    required Future<void> Function() onExpired,
  })  : _tokenStore = tokenStore,
        _authRepository = authRepository,
        _onExpired = onExpired;

  final TokenStore _tokenStore;
  final RemoteAuthRepository _authRepository;
  final Future<void> Function() _onExpired;

  @override
  Future<String?> readAccessToken() async {
    final tokens = await _tokenStore.read();
    return tokens?.accessToken;
  }

  @override
  Future<String?> refreshAccessToken() async {
    final tokens = await _authRepository.refreshTokens();
    return tokens.accessToken;
  }

  @override
  Future<void> onSessionExpired() async {
    await _tokenStore.clear();
    await _onExpired();
  }
}
