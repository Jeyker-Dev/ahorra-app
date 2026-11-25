import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rate_calculations.dart';
import 'package:decimal/decimal.dart';

/// Parses a single `RateOut` JSON object from `ahorra-api`.
ExchangeRate parseRateOut(Map<String, dynamic> json) {
  final id = json['id'];
  final kind = json['kind'];
  final value = json['value'];
  final valueDate = json['value_date'];
  final origin = json['origin'];
  final status = json['status'];
  final fetchedAt = json['fetched_at'];

  if (id is! String ||
      kind is! String ||
      value is! String ||
      valueDate is! String ||
      origin is! String ||
      status is! String ||
      fetchedAt is! String) {
    throw const InvalidRatePayloadException('Malformed RateOut payload.');
  }

  return ExchangeRate(
    id: id,
    kind: RateKind.fromWire(kind),
    value: Decimal.parse(value),
    valueDate: parseIsoDate(valueDate),
    origin: RateOrigin.fromWire(origin),
    status: RateStatus.fromWire(status),
    fetchedAt: DateTime.parse(fetchedAt).toUtc(),
  );
}

/// Parses `GET /rates/latest` (`{"bcv": RateOut | null, "usdt": RateOut | null}`).
CurrentRatesSnapshot parseLatestRatesOut(Map<String, dynamic> json) {
  final rawBcv = json['bcv'];
  final rawUsdt = json['usdt'];

  return CurrentRatesSnapshot(
    bcv: rawBcv is Map<String, dynamic> ? parseRateOut(rawBcv) : null,
    usdt: rawUsdt is Map<String, dynamic> ? parseRateOut(rawUsdt) : null,
  );
}
