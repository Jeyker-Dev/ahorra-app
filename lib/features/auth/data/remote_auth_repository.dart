import 'dart:io';

import 'package:ahorra_app/core/network/auth_token_delegate.dart';
import 'package:ahorra_app/features/auth/data/token_response_dto.dart';
import 'package:ahorra_app/features/auth/domain/auth_errors.dart';
import 'package:ahorra_app/features/auth/domain/auth_repository.dart';
import 'package:ahorra_app/features/auth/domain/auth_tokens.dart';
import 'package:ahorra_app/features/auth/domain/token_store.dart';
import 'package:dio/dio.dart';

/// HTTP-backed [AuthRepository] using an unintercepted [Dio] client for `/auth/*`.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({
    required Dio dio,
    required TokenStore tokenStore,
  })  : _dio = dio,
        _tokenStore = tokenStore;

  final Dio _dio;
  final TokenStore _tokenStore;

  @override
  Future<bool> hasTokens() async {
    final tokens = await _tokenStore.read();
    return tokens != null;
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/token',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final tokens = parseTokenResponse(response.data ?? const {});
      await _tokenStore.save(tokens);
      return tokens;
    } on DioException catch (error) {
      if (error.response?.statusCode == HttpStatus.unauthorized) {
        throw const InvalidCredentialsException();
      }
      if (_isConnectionFailure(error)) {
        throw const AuthNetworkException();
      }
      rethrow;
    }
  }

  /// Rotates the stored refresh token and persists the returned pair.
  Future<AuthTokens> refreshTokens() async {
    final current = await _tokenStore.read();
    if (current == null || current.refreshToken.isEmpty) {
      throw const RefreshUnauthorizedException();
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': current.refreshToken},
      );
      final rotated = parseTokenResponse(response.data ?? const {});
      await _tokenStore.save(rotated);
      return rotated;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == HttpStatus.unauthorized ||
          statusCode == HttpStatus.forbidden) {
        throw const RefreshUnauthorizedException();
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    final current = await _tokenStore.read();
    try {
      if (current != null && current.refreshToken.isNotEmpty) {
        await _dio.post<void>(
          '/auth/logout',
          data: {'refresh_token': current.refreshToken},
        );
      }
    } on DioException {
      // Logout is best-effort remotely; local tokens are always cleared.
    } finally {
      await _tokenStore.clear();
    }
  }

  bool _isConnectionFailure(DioException error) {
    return error.response == null &&
        (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.error is SocketException);
  }
}
