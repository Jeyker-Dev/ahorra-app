import 'dart:io';

import 'package:ahorra_app/core/db/app_database.dart';
import 'package:ahorra_app/features/rates/data/rate_dto.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rate_calculations.dart';
import 'package:ahorra_app/features/rates/domain/rates_repository.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

/// Drift + Dio implementation of [RatesRepository].
///
/// Writes go exclusively from API responses into Drift; all read streams
/// observe Drift tables directly.
class DriftRatesRepository implements RatesRepository {
  DriftRatesRepository({
    required AppDatabase database,
    required Dio dio,
    DateTime Function()? now,
  })  : _database = database,
        _dio = dio,
        _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Dio _dio;
  final DateTime Function() _now;

  @override
  Stream<CurrentRatesSnapshot> watchCurrentRates({
    required DateTime todayCaracas,
  }) {
    final todayIso = formatIsoDate(todayCaracas);
    return (_database.select(_database.exchangeRates)..limit(1))
        .watch()
        .asyncMap((_) => _readCurrentRates(todayIso));
  }

  @override
  Stream<List<ExchangeRate>> watchHistory({
    required RateKind kind,
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    final fromIso = formatIsoDate(fromDate);
    final toIso = formatIsoDate(toDate);

    final query = _database.select(_database.exchangeRates)
      ..where(
        (table) =>
            table.kind.equals(kind.wireValue) &
            table.valueDate.isBiggerOrEqualValue(fromIso) &
            table.valueDate.isSmallerOrEqualValue(toIso),
      )
      ..orderBy([
        (table) => OrderingTerm.asc(table.valueDate),
        (table) => OrderingTerm.asc(table.fetchedAt),
      ]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<ExchangeRate>> watchRecentUpdates({int limit = 20}) {
    final query = _database.select(_database.exchangeRates)
      ..orderBy([
        (table) => OrderingTerm.desc(table.fetchedAt),
        (table) => OrderingTerm.desc(table.valueDate),
      ])
      ..limit(limit);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<void> refresh({int days = 30}) async {
    final today = caracasDate(_now());
    final fromDate = today.subtract(Duration(days: days));
    final fromIso = formatIsoDate(fromDate);
    final toIso = formatIsoDate(today);

    try {
      final responses = await Future.wait([
        _dio.get<Map<String, dynamic>>('/rates/latest'),
        _dio.get<List<dynamic>>(
          '/rates',
          queryParameters: {
            'kind': RateKind.bcv.wireValue,
            'from': fromIso,
            'to': toIso,
          },
        ),
        _dio.get<List<dynamic>>(
          '/rates',
          queryParameters: {
            'kind': RateKind.usdt.wireValue,
            'from': fromIso,
            'to': toIso,
          },
        ),
      ]);

      final latest = parseLatestRatesOut(
        (responses[0].data as Map<String, dynamic>?) ?? const {},
      );
      final bcvHistory = _parseRateList(responses[1].data);
      final usdtHistory = _parseRateList(responses[2].data);

      final byId = <String, ExchangeRate>{};
      for (final rate in [
        if (latest.bcv != null) latest.bcv!,
        if (latest.usdt != null) latest.usdt!,
        ...bcvHistory,
        ...usdtHistory,
      ]) {
        byId[rate.id] = rate;
      }

      if (byId.isEmpty) return;

      await _database.transaction(() async {
        await _database.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _database.exchangeRates,
            byId.values.map(_toCompanion).toList(),
          );
        });
      });
    } on DioException catch (error) {
      if (_isConnectionFailure(error)) {
        throw const RatesNetworkException();
      }
      rethrow;
    }
  }

  Future<CurrentRatesSnapshot> _readCurrentRates(String todayIso) async {
    final bcvQuery = _database.select(_database.exchangeRates)
      ..where(
        (table) =>
            table.kind.equals(RateKind.bcv.wireValue) &
            table.valueDate.isSmallerOrEqualValue(todayIso),
      )
      ..orderBy([
        (table) => OrderingTerm.desc(table.valueDate),
        (table) => OrderingTerm.desc(table.fetchedAt),
      ])
      ..limit(1);

    final usdtQuery = _database.select(_database.exchangeRates)
      ..where((table) => table.kind.equals(RateKind.usdt.wireValue))
      ..orderBy([
        (table) => OrderingTerm.desc(table.fetchedAt),
        (table) => OrderingTerm.desc(table.valueDate),
      ])
      ..limit(1);

    final results = await Future.wait([
      bcvQuery.getSingleOrNull(),
      usdtQuery.getSingleOrNull(),
    ]);

    return CurrentRatesSnapshot(
      bcv: results[0] == null ? null : _toDomain(results[0]!),
      usdt: results[1] == null ? null : _toDomain(results[1]!),
    );
  }

  List<ExchangeRate> _parseRateList(Object? rawList) {
    if (rawList is! List<dynamic>) {
      throw const InvalidRatePayloadException('Expected rate list payload.');
    }
    return rawList.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const InvalidRatePayloadException('Malformed rate list item.');
      }
      return parseRateOut(item);
    }).toList();
  }

  ExchangeRate _toDomain(ExchangeRateRow row) {
    return ExchangeRate(
      id: row.id,
      kind: RateKind.fromWire(row.kind),
      value: row.value,
      valueDate: parseIsoDate(row.valueDate),
      origin: RateOrigin.fromWire(row.origin),
      status: RateStatus.fromWire(row.status),
      fetchedAt: row.fetchedAt.toUtc(),
    );
  }

  ExchangeRatesCompanion _toCompanion(ExchangeRate rate) {
    return ExchangeRatesCompanion.insert(
      id: rate.id,
      kind: rate.kind.wireValue,
      value: rate.value,
      valueDate: formatIsoDate(rate.valueDate),
      origin: rate.origin.wireValue,
      status: rate.status.wireValue,
      fetchedAt: rate.fetchedAt.toUtc(),
    );
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
