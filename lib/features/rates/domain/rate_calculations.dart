import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:decimal/decimal.dart';

const staleRateThreshold = Duration(hours: 12);
const _caracasOffset = Duration(hours: 4);
const _divisionScale = 10;
const _percentScale = 1;
final _hundred = Decimal.fromInt(100);

/// Returns today's calendar date in `America/Caracas` (`UTC-4`) as UTC midnight.
DateTime caracasDate(DateTime utcNow) {
  final shifted = utcNow.toUtc().subtract(_caracasOffset);
  return DateTime.utc(shifted.year, shifted.month, shifted.day);
}

/// Formats a calendar [date] as `YYYY-MM-DD`.
String formatIsoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Parses a strict `YYYY-MM-DD` string into UTC midnight.
DateTime parseIsoDate(String raw) {
  final parts = raw.split('-');
  if (parts.length != 3) {
    throw InvalidRatePayloadException('Invalid value_date: $raw');
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    throw InvalidRatePayloadException('Invalid value_date: $raw');
  }
  return DateTime.utc(year, month, day);
}

/// Returns the oldest `fetchedAt` among the current BCV and USDT rates so
/// staleness triggers if either rate has gone stale.
DateTime? oldestCurrentFetchedAt(CurrentRatesSnapshot snapshot) {
  final bcvFetched = snapshot.bcv?.fetchedAt.toUtc();
  final usdtFetched = snapshot.usdt?.fetchedAt.toUtc();
  if (bcvFetched == null) return usdtFetched;
  if (usdtFetched == null) return bcvFetched;
  return bcvFetched.isBefore(usdtFetched) ? bcvFetched : usdtFetched;
}

/// Returns `true` only when [oldestFetchedAt] is strictly older than 12 hours.
bool isRateStale({
  required DateTime? oldestFetchedAt,
  required DateTime now,
}) {
  if (oldestFetchedAt == null) return false;
  return now.toUtc().difference(oldestFetchedAt.toUtc()) > staleRateThreshold;
}

/// Computes `(usdt / bcv - 1) * 100` rounded to 1 decimal, or `null` when unavailable.
Decimal? calculateRateGapPercent({
  required ExchangeRate? bcv,
  required ExchangeRate? usdt,
}) {
  if (bcv == null || usdt == null || bcv.value <= Decimal.zero) {
    return null;
  }
  final ratio = (usdt.value / bcv.value).toDecimal(
    scaleOnInfinitePrecision: _divisionScale,
  );
  return ((ratio - Decimal.one) * _hundred).round(scale: _percentScale);
}

/// Computes `(latest - oldest) / oldest * 100` rounded to 1 decimal, or `null`
/// when fewer than two points exist.
Decimal? calculateVariationPercent(List<ExchangeRate> rates) {
  if (rates.length < 2) return null;
  final sorted = [...rates]..sort(_compareChronological);
  final oldest = sorted.first;
  final latest = sorted.last;
  if (oldest.value <= Decimal.zero) return null;

  final delta = latest.value - oldest.value;
  final ratio = (delta / oldest.value).toDecimal(
    scaleOnInfinitePrecision: _divisionScale,
  );
  return (ratio * _hundred).round(scale: _percentScale);
}

/// Formats a compact English age label like `14 h ago` or `20 min ago`.
String formatRateAge(DateTime fetchedAt, DateTime now) {
  final age = now.toUtc().difference(fetchedAt.toUtc());
  if (age.isNegative || age.inMinutes < 1) {
    return 'just now';
  }
  if (age.inHours < 1) {
    return '${age.inMinutes} min ago';
  }
  if (age.inHours < 48) {
    return '${age.inHours} h ago';
  }
  return '${age.inDays} d ago';
}

int _compareChronological(ExchangeRate a, ExchangeRate b) {
  final dateCompare = a.valueDate.compareTo(b.valueDate);
  if (dateCompare != 0) return dateCompare;
  return a.fetchedAt.compareTo(b.fetchedAt);
}
