import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rate_calculations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

ExchangeRate _rate({
  required String id,
  required RateKind kind,
  required String value,
  required DateTime valueDate,
  required DateTime fetchedAt,
}) {
  return ExchangeRate(
    id: id,
    kind: kind,
    value: Decimal.parse(value),
    valueDate: valueDate,
    origin: kind == RateKind.bcv ? RateOrigin.bcvHtml : RateOrigin.binanceP2p,
    status: RateStatus.confirmed,
    fetchedAt: fetchedAt,
  );
}

void main() {
  test('calculates gap percentage with Decimal and returns null if a rate is missing', () {
    final bcv = _rate(
      id: 'bcv-1',
      kind: RateKind.bcv,
      value: '220.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: DateTime.utc(2026, 11, 25, 12),
    );
    final usdt = _rate(
      id: 'usdt-1',
      kind: RateKind.usdt,
      value: '300.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: DateTime.utc(2026, 11, 25, 12),
    );

    expect(
      calculateRateGapPercent(bcv: bcv, usdt: usdt),
      Decimal.parse('36.4'),
    );
    expect(calculateRateGapPercent(bcv: null, usdt: usdt), isNull);
    expect(calculateRateGapPercent(bcv: bcv, usdt: null), isNull);
  });

  test('calculates period variation with Decimal and returns null with fewer than two points', () {
    final oldest = _rate(
      id: 'r1',
      kind: RateKind.bcv,
      value: '205.00',
      valueDate: DateTime.utc(2026, 10, 26),
      fetchedAt: DateTime.utc(2026, 10, 26, 12),
    );
    final latest = _rate(
      id: 'r2',
      kind: RateKind.bcv,
      value: '220.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: DateTime.utc(2026, 11, 25, 12),
    );

    expect(calculateVariationPercent([latest, oldest]), Decimal.parse('7.3'));
    expect(calculateVariationPercent([latest]), isNull);
    expect(calculateVariationPercent(const []), isNull);
  });

  test('detects staleness strictly after 12 hours using the oldest current rate fetchedAt', () {
    final now = DateTime.utc(2026, 11, 25, 18, 0, 0);
    final exactTwelveHours = now.subtract(const Duration(hours: 12));
    final overTwelveHours = now.subtract(const Duration(hours: 12, seconds: 1));
    final recent = now.subtract(const Duration(hours: 1));

    expect(
      isRateStale(oldestFetchedAt: exactTwelveHours, now: now),
      isFalse,
    );
    expect(
      isRateStale(oldestFetchedAt: overTwelveHours, now: now),
      isTrue,
    );

    final bcvOld = _rate(
      id: 'bcv-old',
      kind: RateKind.bcv,
      value: '220.00',
      valueDate: DateTime.utc(2026, 11, 24),
      fetchedAt: overTwelveHours,
    );
    final usdtRecent = _rate(
      id: 'usdt-new',
      kind: RateKind.usdt,
      value: '300.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: recent,
    );

    final oldest = oldestCurrentFetchedAt(
      CurrentRatesSnapshot(bcv: bcvOld, usdt: usdtRecent),
    );
    expect(oldest, overTwelveHours);
    expect(isRateStale(oldestFetchedAt: oldest, now: now), isTrue);
  });
}
