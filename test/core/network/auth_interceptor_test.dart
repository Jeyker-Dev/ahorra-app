import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ahorra_app/core/network/auth_interceptor.dart';
import 'package:ahorra_app/core/network/auth_token_delegate.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef FakeHandler = Future<ResponseBody> Function(RequestOptions options);

class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this._onFetch);

  final FakeHandler _onFetch;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object payload, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class FakeTokenDelegate implements AuthTokenDelegate {
  FakeTokenDelegate({
    this.accessToken,
    required this.onRefresh,
  });

  String? accessToken;
  final Future<String?> Function() onRefresh;
  int refreshCalls = 0;
  int sessionExpiredCalls = 0;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> refreshAccessToken() async {
    refreshCalls += 1;
    final nextToken = await onRefresh();
    if (nextToken != null) {
      accessToken = nextToken;
    }
    return nextToken;
  }

  @override
  Future<void> onSessionExpired() async {
    sessionExpiredCalls += 1;
    accessToken = null;
  }
}

Dio buildTestDio(FakeTokenDelegate delegate, FakeHttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  dio.httpClientAdapter = adapter;
  final retryDio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  retryDio.httpClientAdapter = adapter;
  dio.interceptors.add(AuthInterceptor(delegate: delegate, retryDio: retryDio));
  return dio;
}

void main() {
  test('adds Bearer token to protected requests and skips auth endpoints', () async {
    final delegate = FakeTokenDelegate(
      accessToken: 'token-1',
      onRefresh: () async => null,
    );
    final adapter = FakeHttpClientAdapter((options) async => jsonBody({'ok': true}));
    final dio = buildTestDio(delegate, adapter);

    await dio.get<Map<String, dynamic>>('/rates/latest');
    await dio.post<Map<String, dynamic>>('/auth/token');

    expect(adapter.requests[0].headers['Authorization'], 'Bearer token-1');
    expect(adapter.requests[1].headers['Authorization'], isNull);
  });

  test('refreshes once on 401 and retries the original request with the new token', () async {
    final delegate = FakeTokenDelegate(
      accessToken: 'expired-token',
      onRefresh: () async => 'fresh-token',
    );
    final adapter = FakeHttpClientAdapter((options) async {
      if (options.headers['Authorization'] == 'Bearer expired-token') {
        return jsonBody({'detail': 'expired'}, statusCode: 401);
      }
      return jsonBody({'bcv': null, 'usdt': null});
    });
    final dio = buildTestDio(delegate, adapter);

    final response = await dio.get<Map<String, dynamic>>('/rates/latest');

    expect(response.statusCode, 200);
    expect(delegate.refreshCalls, 1);
    expect(adapter.requests, hasLength(2));
    expect(adapter.requests[1].headers['Authorization'], 'Bearer fresh-token');
  });

  test('shares a single refresh call across concurrent 401 responses', () async {
    final refreshCompleter = Completer<String?>();
    final delegate = FakeTokenDelegate(
      accessToken: 'expired-token',
      onRefresh: () => refreshCompleter.future,
    );
    final adapter = FakeHttpClientAdapter((options) async {
      if (options.headers['Authorization'] == 'Bearer expired-token') {
        return jsonBody({'detail': 'expired'}, statusCode: 401);
      }
      return jsonBody({'path': options.path});
    });
    final dio = buildTestDio(delegate, adapter);

    final futures = [
      dio.get<Map<String, dynamic>>('/rates/latest'),
      dio.get<Map<String, dynamic>>('/rates?kind=bcv'),
      dio.get<Map<String, dynamic>>('/rates?kind=usdt'),
    ];

    while (delegate.refreshCalls == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(delegate.refreshCalls, 1);

    refreshCompleter.complete('shared-fresh-token');
    final responses = await Future.wait(futures);

    expect(responses.every((r) => r.statusCode == 200), isTrue);
    expect(delegate.refreshCalls, 1);
    expect(delegate.sessionExpiredCalls, 0);
  });

  test('clears session when refresh fails with 401', () async {
    final delegate = FakeTokenDelegate(
      accessToken: 'expired-token',
      onRefresh: () async => throw const RefreshUnauthorizedException(),
    );
    final adapter = FakeHttpClientAdapter(
      (options) async => jsonBody({'detail': 'unauthorized'}, statusCode: 401),
    );
    final dio = buildTestDio(delegate, adapter);

    await expectLater(
      dio.get<Map<String, dynamic>>('/rates/latest'),
      throwsA(isA<DioException>()),
    );

    expect(delegate.refreshCalls, 1);
    expect(delegate.sessionExpiredCalls, 1);
    expect(delegate.accessToken, isNull);
  });

  test('keeps tokens when refresh fails due to a network error', () async {
    final delegate = FakeTokenDelegate(
      accessToken: 'expired-token',
      onRefresh: () async => throw DioException.connectionError(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        reason: 'offline',
      ),
    );
    final adapter = FakeHttpClientAdapter(
      (options) async => jsonBody({'detail': 'unauthorized'}, statusCode: 401),
    );
    final dio = buildTestDio(delegate, adapter);

    await expectLater(
      dio.get<Map<String, dynamic>>('/rates/latest'),
      throwsA(isA<DioException>()),
    );

    expect(delegate.refreshCalls, 1);
    expect(delegate.sessionExpiredCalls, 0);
    expect(delegate.accessToken, 'expired-token');
  });
}
