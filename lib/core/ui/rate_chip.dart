import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:flutter/material.dart';

/// Compact pill chip displaying BCV and USDT/Bs values plus age, tapping to `/rates`.
class RateChip extends StatelessWidget {
  const RateChip({
    super.key,
    required this.bcvText,
    required this.usdtText,
    required this.ageText,
    required this.isStale,
    required this.onTap,
  });

  final String bcvText;
  final String usdtText;
  final String ageText;
  final bool isStale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ahorraColors;
    final accentColor = isStale ? colors.warning : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: 'Exchange rates: BCV $bcvText, USDT/Bs $usdtText, $ageText. Open rate history.',
      child: Material(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AhorraTheme.pillRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AhorraTheme.pillRadius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isStale ? Icons.warning_amber_rounded : Icons.sync,
                    size: 16,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'BCV $bcvText · USDT/Bs $usdtText · $ageText',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isStale
                            ? colors.warning
                            : theme.colorScheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: accentColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
