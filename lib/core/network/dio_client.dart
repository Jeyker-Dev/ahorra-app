import 'package:ahorra_app/core/network/auth_interceptor.dart';
import 'package:ahorra_app/core/network/auth_token_delegate.dart';
import 'package:dio/dio.dart';

const _connectTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 15);

/// Creates a plain [Dio] client without auth interception (used for auth/refresh calls).
Dio buildBaseDio({
  required String baseUrl,
  HttpClientAdapter? adapter,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: const {
        Headers.acceptHeader: Headers.jsonContentType,
      },
    ),
  );
  if (adapter != null) {
    dio.httpClientAdapter = adapter;
  }
  return dio;
}

/// Creates an authenticated [Dio] client with [AuthInterceptor].
Dio buildAuthenticatedDio({
  required String baseUrl,
  required AuthTokenDelegate tokenDelegate,
  HttpClientAdapter? adapter,
}) {
  final dio = buildBaseDio(baseUrl: baseUrl, adapter: adapter);
  final retryDio = buildBaseDio(baseUrl: baseUrl, adapter: dio.httpClientAdapter);
  dio.interceptors.add(
    AuthInterceptor(
      delegate: tokenDelegate,
      retryDio: retryDio,
    ),
  );
  return dio;
}
