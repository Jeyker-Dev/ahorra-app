import 'package:ahorra_app/core/network/api_config.dart';
import 'package:ahorra_app/core/network/auth_token_delegate.dart';
import 'package:ahorra_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overridden in the composition root (`app/`) so `core/network` stays decoupled
/// from `features/auth`.
final authTokenDelegateProvider = Provider<AuthTokenDelegate>((ref) {
  throw UnimplementedError('authTokenDelegateProvider must be overridden');
});

/// Authenticated [Dio] client shared by feature repositories.
final apiDioProvider = Provider<Dio>((ref) {
  return buildAuthenticatedDio(
    baseUrl: ref.watch(apiBaseUrlProvider),
    tokenDelegate: ref.watch(authTokenDelegateProvider),
  );
});
