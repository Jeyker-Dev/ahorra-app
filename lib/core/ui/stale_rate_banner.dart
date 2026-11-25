import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:flutter/material.dart';

/// Warning banner shown when rates are older than 12 hours or refresh is offline.
class StaleRateBanner extends StatelessWidget {
  const StaleRateBanner.outdated({
    super.key,
    required String ageText,
  })  : message = 'Outdated rate · last: $ageText',
        icon = Icons.warning_amber_rounded;

  const StaleRateBanner.offline({super.key})
      : message = 'No connection · using the last known rate',
        icon = Icons.wifi_off_rounded;

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ahorraColors;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.warning.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
          border: Border.all(
            color: colors.warning.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
