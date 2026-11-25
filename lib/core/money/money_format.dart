import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

const _veLocale = 'es_VE';
const _defaultAmountDecimals = 2;
const _percentDecimals = 1;

/// Formats [value] in Venezuelan Spanish (`es_VE`) with dot thousands and comma decimals.
String formatVeDecimal(
  Decimal value, {
  int decimals = _defaultAmountDecimals,
}) {
  final rounded = value.round(scale: decimals);
  final formatter = DecimalFormatter(
    NumberFormat.decimalPatternDigits(
      locale: _veLocale,
      decimalDigits: decimals,
    ),
  );
  return formatter.format(rounded);
}

/// Formats a percentage [value] with one decimal and a space before `%` (`12,3 %`).
String formatVePercent(Decimal value) {
  return '${formatVeDecimal(value, decimals: _percentDecimals)} %';
}

/// Formats a signed percentage [value] (`+7,3 %`, `-1,3 %`, or `0,0 %`).
String formatVeSignedPercent(Decimal value) {
  final rounded = value.round(scale: _percentDecimals);
  final prefix = rounded > Decimal.zero ? '+' : '';
  return '$prefix${formatVePercent(rounded)}';
}
