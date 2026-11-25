import 'package:ahorra_app/features/rates/data/rate_dto.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses RateOut JSON with decimal string value and snake_case enums', () {
    final rate = parseRateOut({
      'id': '11111111-1111-1111-1111-111111111111',
      'kind': 'bcv',
      'value': '220.12345678',
      'value_date': '2026-11-25',
      'origin': 'bcv_html',
      'status': 'in_review',
      'fetched_at': '2026-11-25T12:30:00Z',
    });

    expect(rate.id, '11111111-1111-1111-1111-111111111111');
    expect(rate.kind, RateKind.bcv);
    expect(rate.value, Decimal.parse('220.12345678'));
    expect(rate.valueDate, DateTime.utc(2026, 11, 25));
    expect(rate.origin, RateOrigin.bcvHtml);
    expect(rate.status, RateStatus.inReview);
    expect(rate.fetchedAt, DateTime.utc(2026, 11, 25, 12, 30));
  });

  test('parses LatestRatesOut when bcv or usdt is null', () {
    final latest = parseLatestRatesOut({
      'bcv': null,
      'usdt': {
        'id': '22222222-2222-2222-2222-222222222222',
        'kind': 'usdt',
        'value': '300.50',
        'value_date': '2026-11-25',
        'origin': 'binance_p2p',
        'status': 'confirmed',
        'fetched_at': '2026-11-25T13:00:00Z',
      },
    });

    expect(latest.bcv, isNull);
    expect(latest.usdt, isNotNull);
    expect(latest.usdt!.value, Decimal.parse('300.5'));
  });
}
