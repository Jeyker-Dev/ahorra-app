import 'dart:convert';
import 'dart:typed_data';

import 'package:ahorra_app/core/network/auth_token_delegate.dart';
import 'package:ahorra_app/features/auth/data/remote_auth_repository.dart';
import 'package:ahorra_app/features/auth/domain/auth_errors.dart';
import 'package:ahorra_app/features/auth/domain/auth_tokens.dart';
import 'package:ahorra_app/features/auth/domain/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class InMemoryTokenStore implements TokenStore {
  InMemoryTokenStore([this._tokens]);

  AuthTokens? _tokens;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> save(AuthTokens tokens) async {
    _tokens = tokens;
  }

  @override
  Future<void> clear() async {
    _tokens = null;
  }
}

class StubHttpAdapter implements HttpClientAdapter {
  StubHttpAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  test('login posts form-urlencoded credentials and stores returned tokens', () async {
    final store = InMemoryTokenStore();
    final adapter = StubHttpAdapter((options) async {
      return _json({
        'access_token': 'acc-1',
        'refresh_token': 'ref-1',
        'token_type': 'bearer',
        'expires_in': 900,
      });
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter;
    final repo = RemoteAuthRepository(dio: dio, tokenStore: store);

    final tokens = await repo.login(email: 'jeyker@example.com', password: 'secret');

    expect(tokens.accessToken, 'acc-1');
    expect(tokens.refreshToken, 'ref-1');
    expect(await store.read(), tokens);
    expect(adapter.requests.single.path, '/auth/token');
    expect(
      adapter.requests.single.contentType,
      Headers.formUrlEncodedContentType,
    );
    expect(adapter.requests.single.data, {
      'username': 'jeyker@example.com',
      'password': 'secret',
    });
  });

  test('login throws InvalidCredentialsException on 401', () async {
    final store = InMemoryTokenStore();
    final adapter = StubHttpAdapter(
      (_) async => _json({'detail': 'Incorrect email or password'}, statusCode: 401),
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter;
    final repo = RemoteAuthRepository(dio: dio, tokenStore: store);

    await expectLater(
      repo.login(email: 'jeyker@example.com', password: 'wrong'),
      throwsA(
        isA<InvalidCredentialsException>().having(
          (e) => e.message,
          'message',
          'Wrong email or password.',
        ),
      ),
    );
  });

  test('login throws AuthNetworkException when connection fails', () async {
    final store = InMemoryTokenStore();
    final adapter = StubHttpAdapter((options) async {
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter;
    final repo = RemoteAuthRepository(dio: dio, tokenStore: store);

    await expectLater(
      repo.login(email: 'jeyker@example.com', password: 'secret'),
      throwsA(
        isA<AuthNetworkException>().having(
          (e) => e.message,
          'message',
          'No connection. Try again.',
        ),
      ),
    );
  });

  test('refreshTokens rotates refresh token and throws RefreshUnauthorizedException on 401', () async {
    final store = InMemoryTokenStore(
      const AuthTokens(
        accessToken: 'old-acc',
        refreshToken: 'old-ref',
        tokenType: 'bearer',
        expiresIn: 900,
      ),
    );
    var failNext = false;
    final adapter = StubHttpAdapter((options) async {
      if (failNext) {
        return _json({'detail': 'Invalid refresh token'}, statusCode: 401);
      }
      return _json({
        'access_token': 'new-acc',
        'refresh_token': 'new-ref',
        'token_type': 'bearer',
        'expires_in': 900,
      });
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter;
    final repo = RemoteAuthRepository(dio: dio, tokenStore: store);

    final rotated = await repo.refreshTokens();
    expect(rotated.refreshToken, 'new-ref');
    expect((await store.read())?.refreshToken, 'new-ref');

    failNext = true;
    await expectLater(
      repo.refreshTokens(),
      throwsA(isA<RefreshUnauthorizedException>()),
    );
  });

  test('logout calls /auth/logout best-effort and always clears local tokens', () async {
    final store = InMemoryTokenStore(
      const AuthTokens(
        accessToken: 'acc',
        refreshToken: 'ref',
        tokenType: 'bearer',
        expiresIn: 900,
      ),
    );
    final adapter = StubHttpAdapter((options) async {
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter;
    final repo = RemoteAuthRepository(dio: dio, tokenStore: store);

    await repo.logout();

    expect(adapter.requests.single.path, '/auth/logout');
    expect(await store.read(), isNull);
  });
}
