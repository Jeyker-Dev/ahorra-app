import 'package:ahorra_app/core/errors/business_rule_exception.dart';
import 'package:decimal/decimal.dart';

/// Supported exchange rate kinds matching `ahorra-api`.
enum RateKind {
  bcv('bcv'),
  usdt('usdt');

  const RateKind(this.wireValue);

  final String wireValue;

  static RateKind fromWire(String raw) {
    for (final kind in values) {
      if (kind.wireValue == raw) return kind;
    }
    throw InvalidRatePayloadException('Unknown rate kind: $raw');
  }
}

/// Source that produced an exchange rate snapshot.
enum RateOrigin {
  bcvHtml('bcv_html'),
  dolarApi('dolarapi'),
  binanceP2p('binance_p2p'),
  manual('manual');

  const RateOrigin(this.wireValue);

  final String wireValue;

  static RateOrigin fromWire(String raw) {
    for (final origin in values) {
      if (origin.wireValue == raw) return origin;
    }
    throw InvalidRatePayloadException('Unknown rate origin: $raw');
  }
}

/// Verification status of an exchange rate record.
enum RateStatus {
  confirmed('confirmed'),
  inReview('in_review');

  const RateStatus(this.wireValue);

  final String wireValue;

  static RateStatus fromWire(String raw) {
    for (final status in values) {
      if (status.wireValue == raw) return status;
    }
    throw InvalidRatePayloadException('Unknown rate status: $raw');
  }
}

/// Pure-Dart domain entity representing an exchange rate snapshot.
class ExchangeRate {
  const ExchangeRate({
    required this.id,
    required this.kind,
    required this.value,
    required this.valueDate,
    required this.origin,
    required this.status,
    required this.fetchedAt,
  });

  final String id;
  final RateKind kind;
  final Decimal value;
  final DateTime valueDate;
  final RateOrigin origin;
  final RateStatus status;
  final DateTime fetchedAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExchangeRate &&
            id == other.id &&
            kind == other.kind &&
            value == other.value &&
            valueDate == other.valueDate &&
            origin == other.origin &&
            status == other.status &&
            fetchedAt == other.fetchedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, value, valueDate, origin, status, fetchedAt);
}

/// Current BCV (in force today in Caracas) and latest USDT rates.
class CurrentRatesSnapshot {
  const CurrentRatesSnapshot({
    required this.bcv,
    required this.usdt,
  });

  final ExchangeRate? bcv;
  final ExchangeRate? usdt;
}

/// Thrown when an API rate payload contains an unexpected value or enum.
final class InvalidRatePayloadException extends BusinessRuleException {
  const InvalidRatePayloadException(super.message);
}

/// Thrown when refreshing rates fails because the device is offline or unreachable.
final class RatesNetworkException extends BusinessRuleException {
  const RatesNetworkException()
      : super('No connection · using the last known rate');
}
