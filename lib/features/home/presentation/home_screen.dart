import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:ahorra_app/core/ui/rate_chip.dart';
import 'package:ahorra_app/core/ui/stale_rate_banner.dart';
import 'package:flutter/material.dart';

enum _HomeMenuAction { signOut }

/// Snapshot of exchange-rate display values rendered by [HomeScreen].
class HomeRatesSummary {
  const HomeRatesSummary({
    required this.bcvText,
    required this.usdtText,
    required this.ageText,
    required this.isStale,
    required this.isOfflineFallback,
  });

  final String bcvText;
  final String usdtText;
  final String ageText;
  final bool isStale;
  final bool isOfflineFallback;
}

/// Home tab showing the latest exchange rates and account menu.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.rates,
    required this.onOpenRates,
    required this.onRefreshRates,
    required this.onSignOut,
  });

  final HomeRatesSummary rates;
  final VoidCallback onOpenRates;
  final Future<void> Function() onRefreshRates;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          PopupMenuButton<_HomeMenuAction>(
            tooltip: 'Account menu',
            onSelected: (action) {
              if (action == _HomeMenuAction.signOut) {
                onSignOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.signOut,
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefreshRates,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: RateChip(
                bcvText: rates.bcvText,
                usdtText: rates.usdtText,
                ageText: rates.ageText,
                isStale: rates.isStale,
                onTap: onOpenRates,
              ),
            ),
            if (rates.isOfflineFallback) ...[
              const SizedBox(height: 12),
              const StaleRateBanner.offline(),
            ] else if (rates.isStale) ...[
              const SizedBox(height: 12),
              StaleRateBanner.outdated(ageText: rates.ageText),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.ahorraColors.surfaceCard,
                borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
              ),
              child: Text(
                'Summary modules arrive in Phase 2. Tap the rate chip above to inspect BCV and USDT/Bs history.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
