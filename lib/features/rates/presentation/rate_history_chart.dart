import 'dart:math' as math;

import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:ahorra_app/core/money/money_format.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Dual-line chart comparing BCV and USDT/Bs history over the selected period.
class RateHistoryChart extends StatelessWidget {
  const RateHistoryChart({
    super.key,
    required this.bcvRates,
    required this.usdtRates,
  });

  final List<ExchangeRate> bcvRates;
  final List<ExchangeRate> usdtRates;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ahorraColors;

    final allRates = [...bcvRates, ...usdtRates];
    if (allRates.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
        ),
        child: Text(
          'No history for this period',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final originDate = allRates
        .map((r) => r.valueDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = allRates
        .map((r) => r.valueDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final bcvSpots = _toSpots(bcvRates, originDate);
    final usdtSpots = _toSpots(usdtRates, originDate);

    final allY = [
      ...bcvSpots.map((s) => s.y),
      ...usdtSpots.map((s) => s.y),
    ];
    final rawMinY = allY.reduce(math.min);
    final rawMaxY = allY.reduce(math.max);
    final paddingY = math.max((rawMaxY - rawMinY) * 0.15, 1.0);
    final maxX = math.max(maxDate.difference(originDate).inDays.toDouble(), 1.0);

    return Semantics(
      label: 'Exchange rate history chart for BCV and USDT/Bs',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _LegendItem(color: colors.tagBcv, label: 'BCV'),
                const SizedBox(width: 16),
                _LegendItem(color: colors.tagUsdt, label: 'USDT/Bs'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  minY: math.max(0, rawMinY - paddingY),
                  maxY: rawMaxY + paddingY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: colors.outlineDivider,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 56,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          final formatted = formatVeDecimal(
                            Decimal.parse(value.toStringAsFixed(0)),
                            decimals: 0,
                          );
                          return Text(
                            formatted,
                            style: theme.textTheme.labelMedium,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: math.max(maxX / 2, 1),
                        getTitlesWidget: (value, meta) {
                          final date =
                              originDate.add(Duration(days: value.round()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              DateFormat('d MMM', 'en_US').format(date),
                              style: theme.textTheme.labelMedium,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    if (bcvSpots.isNotEmpty)
                      LineChartBarData(
                        spots: bcvSpots,
                        isCurved: bcvSpots.length > 2,
                        color: colors.tagBcv,
                        barWidth: 2.5,
                        dotData: FlDotData(show: bcvSpots.length == 1),
                      ),
                    if (usdtSpots.isNotEmpty)
                      LineChartBarData(
                        spots: usdtSpots,
                        isCurved: usdtSpots.length > 2,
                        color: colors.tagUsdt,
                        barWidth: 2.5,
                        dotData: FlDotData(show: usdtSpots.length == 1),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // `fl_chart` requires `double` canvas coordinates; domain and math stay in `Decimal`.
  List<FlSpot> _toSpots(List<ExchangeRate> rates, DateTime originDate) {
    final byDay = <int, ExchangeRate>{};
    for (final rate in rates) {
      final dayOffset = rate.valueDate.difference(originDate).inDays;
      byDay[dayOffset] = rate;
    }
    final sortedDays = byDay.keys.toList()..sort();
    return [
      for (final day in sortedDays)
        FlSpot(day.toDouble(), double.parse(byDay[day]!.value.toString())),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
