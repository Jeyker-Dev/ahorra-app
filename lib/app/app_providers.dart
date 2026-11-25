import 'package:ahorra_app/core/network/api_dio_provider.dart';
import 'package:ahorra_app/features/auth/data/auth_session_delegate.dart';
import 'package:ahorra_app/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/misc.dart';

/// Composition-root overrides wiring `core/` ports to `features/` adapters.
final List<Override> appProviderOverrides = [
  authTokenDelegateProvider.overrideWith((ref) {
    return AuthSessionDelegate(
      tokenStore: ref.watch(tokenStoreProvider),
      authRepository: ref.watch(remoteAuthRepositoryProvider),
      onExpired: () async {
        ref.read(authStateProvider.notifier).markUnauthenticated();
      },
    );
  }),
];
