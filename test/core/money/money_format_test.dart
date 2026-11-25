import 'package:ahorra_app/core/money/money_format.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats decimal values in es_VE with dot thousands and comma decimals', () {
    expect(formatVeDecimal(Decimal.parse('220.5')), '220,50');
    expect(formatVeDecimal(Decimal.parse('45067.20')), '45.067,20');
    expect(formatVeDecimal(Decimal.parse('1234567.895')), '1.234.567,90');
    expect(formatVeDecimal(Decimal.parse('-42.1')), '-42,10');
  });

  test('formats percentages with one decimal and space before percent sign', () {
    expect(formatVePercent(Decimal.parse('12.34')), '12,3 %');
    expect(formatVePercent(Decimal.parse('0')), '0,0 %');
    expect(formatVeSignedPercent(Decimal.parse('7.34')), '+7,3 %');
    expect(formatVeSignedPercent(Decimal.parse('-1.25')), '-1,3 %');
    expect(formatVeSignedPercent(Decimal.zero), '0,0 %');
  });
}
