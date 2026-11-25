import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:flutter/material.dart';

/// Pill tag displaying currency/rate source (`BCV` or `USDT`) at 15% tint.
class CurrencyTag extends StatelessWidget {
  const CurrencyTag.bcv({super.key})
      : label = 'BCV',
        _isBcv = true;

  const CurrencyTag.usdt({super.key})
      : label = 'USDT',
        _isBcv = false;

  final String label;
  final bool _isBcv;

  @override
  Widget build(BuildContext context) {
    final colors = context.ahorraColors;
    final tint = _isBcv ? colors.tagBcv : colors.tagUsdt;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AhorraTheme.pillRadius),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tint,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
