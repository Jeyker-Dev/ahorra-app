import 'dart:async';
import 'dart:io';

import 'package:ahorra_app/core/network/auth_token_delegate.dart';
import 'package:dio/dio.dart';

const _authPrefix = '/auth/';
const _retriedExtraKey = '_auth_retried';

/// Attaches the Bearer access token and coordinates single-flight token refresh on 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AuthTokenDelegate delegate,
    required Dio retryDio,
  })  : _delegate = delegate,
        _retryDio = retryDio;

  final AuthTokenDelegate _delegate;
  final Dio _retryDio;
  Future<String?>? _refreshInFlight;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    final accessToken = await _delegate.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != HttpStatus.unauthorized) {
      handler.next(err);
      return;
    }
    if (_isAuthEndpoint(err.requestOptions.path)) {
      handler.next(err);
      return;
    }
    if (err.requestOptions.extra[_retriedExtraKey] == true) {
      handler.next(err);
      return;
    }

    final String? refreshedToken;
    try {
      refreshedToken = await _awaitSingleFlightRefresh();
    } on RefreshUnauthorizedException {
      handler.next(err);
      return;
    } on DioException catch (refreshErr) {
      handler.next(refreshErr);
      return;
    }

    if (refreshedToken == null || refreshedToken.isEmpty) {
      handler.next(err);
      return;
    }

    final retryOptions = err.requestOptions;
    retryOptions.headers['Authorization'] = 'Bearer $refreshedToken';
    retryOptions.extra[_retriedExtraKey] = true;

    try {
      final response = await _retryDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  Future<String?> _awaitSingleFlightRefresh() {
    final existing = _refreshInFlight;
    if (existing != null) {
      return existing;
    }
    final refreshFuture = _runRefresh();
    _refreshInFlight = refreshFuture;
    return refreshFuture;
  }

  Future<String?> _runRefresh() async {
    try {
      return await _delegate.refreshAccessToken();
    } on RefreshUnauthorizedException {
      await _delegate.onSessionExpired();
      rethrow;
    } finally {
      _refreshInFlight = null;
    }
  }

  bool _isAuthEndpoint(String path) => path.startsWith(_authPrefix);
}
