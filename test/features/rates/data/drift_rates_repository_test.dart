import 'dart:convert';
import 'dart:typed_data';

import 'package:ahorra_app/core/db/app_database.dart';
import 'package:ahorra_app/features/rates/data/drift_rates_repository.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRatesAdapter implements HttpClientAdapter {
  FakeRatesAdapter(this._onFetch);

  final Future<ResponseBody> Function(RequestOptions options) _onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      _onFetch(options);

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
  test('watchCurrentRates returns null for BCV when only future-dated BCV rows exist', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
    final repo = DriftRatesRepository(
      database: db,
      dio: dio,
      now: () => DateTime.utc(2026, 11, 25, 16, 0),
    );

    await db.into(db.exchangeRates).insert(
          ExchangeRatesCompanion.insert(
            id: 'future-bcv',
            kind: 'bcv',
            value: Decimal.parse('225.00'),
            valueDate: '2026-11-26',
            origin: 'bcv_html',
            status: 'confirmed',
            fetchedAt: DateTime.utc(2026, 11, 25, 15, 0),
          ),
        );
    await db.into(db.exchangeRates).insert(
          ExchangeRatesCompanion.insert(
            id: 'usdt-1',
            kind: 'usdt',
            value: Decimal.parse('300.00'),
            valueDate: '2026-11-25',
            origin: 'binance_p2p',
            status: 'confirmed',
            fetchedAt: DateTime.utc(2026, 11, 25, 15, 30),
          ),
        );

    final current = await repo
        .watchCurrentRates(todayCaracas: DateTime.utc(2026, 11, 25))
        .first;

    expect(current.bcv, isNull);
    expect(current.usdt?.id, 'usdt-1');
  });

  test('refresh upserts rates from API and preserves local Drift data if refresh fails', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    var shouldFail = false;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = FakeRatesAdapter((options) async {
        if (shouldFail) {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
          );
        }
        if (options.path == '/rates/latest') {
          return _json({
            'bcv': {
              'id': 'bcv-today',
              'kind': 'bcv',
              'value': '220.00',
              'value_date': '2026-11-25',
              'origin': 'bcv_html',
              'status': 'confirmed',
              'fetched_at': '2026-11-25T12:00:00Z',
            },
            'usdt': {
              'id': 'usdt-today',
              'kind': 'usdt',
              'value': '300.00',
              'value_date': '2026-11-25',
              'origin': 'binance_p2p',
              'status': 'confirmed',
              'fetched_at': '2026-11-25T12:05:00Z',
            },
          });
        }
        final kind = options.queryParameters['kind'];
        if (kind == 'bcv') {
          return _json([
            {
              'id': 'bcv-prev',
              'kind': 'bcv',
              'value': '210.00',
              'value_date': '2026-11-01',
              'origin': 'bcv_html',
              'status': 'confirmed',
              'fetched_at': '2026-11-01T12:00:00Z',
            },
          ]);
        }
        return _json([
          {
            'id': 'usdt-prev',
            'kind': 'usdt',
            'value': '290.00',
            'value_date': '2026-11-01',
            'origin': 'binance_p2p',
            'status': 'confirmed',
            'fetched_at': '2026-11-01T12:00:00Z',
          },
        ]);
      });

    final repo = DriftRatesRepository(
      database: db,
      dio: dio,
      now: () => DateTime.utc(2026, 11, 25, 16, 0),
    );

    await repo.refresh(days: 30);

    final afterRefresh = await repo
        .watchCurrentRates(todayCaracas: DateTime.utc(2026, 11, 25))
        .first;
    expect(afterRefresh.bcv?.value, Decimal.parse('220.00'));
    expect(afterRefresh.usdt?.value, Decimal.parse('300.00'));

    final history = await repo
        .watchHistory(
          kind: RateKind.bcv,
          fromDate: DateTime.utc(2026, 10, 26),
          toDate: DateTime.utc(2026, 11, 25),
        )
        .first;
    expect(history.map((e) => e.id), ['bcv-prev', 'bcv-today']);

    shouldFail = true;
    await expectLater(repo.refresh(days: 30), throwsA(isA<Exception>()));

    final afterFailedRefresh = await repo
        .watchCurrentRates(todayCaracas: DateTime.utc(2026, 11, 25))
        .first;
    expect(afterFailedRefresh.bcv?.value, Decimal.parse('220.00'));
    expect(afterFailedRefresh.usdt?.value, Decimal.parse('300.00'));
  });
}
