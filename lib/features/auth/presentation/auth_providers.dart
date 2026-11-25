import 'package:ahorra_app/core/network/api_config.dart';
import 'package:ahorra_app/core/network/dio_client.dart';
import 'package:ahorra_app/features/auth/data/remote_auth_repository.dart';
import 'package:ahorra_app/features/auth/data/secure_storage_token_store.dart';
import 'package:ahorra_app/features/auth/domain/auth_repository.dart';
import 'package:ahorra_app/features/auth/domain/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication state resolved at startup and updated on login/logout/expiry.
enum AuthStatus {
  authenticated,
  unauthenticated,
}

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return SecureStorageTokenStore();
});

final authDioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return buildBaseDio(baseUrl: baseUrl);
});

final remoteAuthRepositoryProvider = Provider<RemoteAuthRepository>((ref) {
  return RemoteAuthRepository(
    dio: ref.watch(authDioProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(remoteAuthRepositoryProvider);
});

/// Holds the current [AuthStatus] and drives router redirects.
class AuthStateNotifier extends AsyncNotifier<AuthStatus> {
  @override
  Future<AuthStatus> build() async {
    final hasTokens = await ref.read(authRepositoryProvider).hasTokens();
    return hasTokens ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await ref.read(authRepositoryProvider).login(
          email: email,
          password: password,
        );
    state = const AsyncData(AuthStatus.authenticated);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthStatus.unauthenticated);
  }

  void markUnauthenticated() {
    state = const AsyncData(AuthStatus.unauthenticated);
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, AuthStatus>(AuthStateNotifier.new);
