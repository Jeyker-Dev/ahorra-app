import 'dart:math' as math;

import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:ahorra_app/core/money/money_format.dart';
import 'package:ahorra_app/core/ui/currency_tag.dart';
import 'package:ahorra_app/core/ui/skeleton_box.dart';
import 'package:ahorra_app/core/ui/stale_rate_banner.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rate_calculations.dart';
import 'package:ahorra_app/features/rates/presentation/rate_history_chart.dart';
import 'package:ahorra_app/features/rates/presentation/rates_providers.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _rangeOptions = [7, 30, 90];

/// Full-screen rates overview & history screen per Stitch "Tasas – Historial".
class RatesScreen extends ConsumerStatefulWidget {
  const RatesScreen({super.key});

  static const skeletonKey = Key('rates_loading_skeleton');

  @override
  ConsumerState<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends ConsumerState<RatesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final selectedDays = ref.read(selectedRangeDaysProvider);
      ref.read(ratesRefreshControllerProvider.notifier).refresh(
            days: math.max(defaultHistoryDays, selectedDays),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(currentTimeProvider);
    final currentAsync = ref.watch(currentRatesProvider);
    final refreshState = ref.watch(ratesRefreshControllerProvider);
    final selectedDays = ref.watch(selectedRangeDaysProvider);

    final bcv30d = ref
        .watch(
          rateHistoryProvider((kind: RateKind.bcv, days: defaultHistoryDays)),
        )
        .value ??
        const <ExchangeRate>[];
    final usdt30d = ref
        .watch(
          rateHistoryProvider((kind: RateKind.usdt, days: defaultHistoryDays)),
        )
        .value ??
        const <ExchangeRate>[];

    final bcvSelected = ref
        .watch(rateHistoryProvider((kind: RateKind.bcv, days: selectedDays)))
        .value ??
        const <ExchangeRate>[];
    final usdtSelected = ref
        .watch(rateHistoryProvider((kind: RateKind.usdt, days: selectedDays)))
        .value ??
        const <ExchangeRate>[];

    final recentUpdates =
        ref.watch(recentRateUpdatesProvider).value ?? const <ExchangeRate>[];

    final current = currentAsync.value ??
        const CurrentRatesSnapshot(bcv: null, usdt: null);
    final hasAnyRate =
        current.bcv != null || current.usdt != null || recentUpdates.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Rates'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(ratesRefreshControllerProvider.notifier)
            .refresh(days: math.max(defaultHistoryDays, selectedDays)),
        child: _buildBody(
          context: context,
          now: now,
          current: current,
          hasAnyRate: hasAnyRate,
          isInitialStreamLoading: currentAsync.isLoading,
          refreshState: refreshState,
          selectedDays: selectedDays,
          bcv30d: bcv30d,
          usdt30d: usdt30d,
          bcvSelected: bcvSelected,
          usdtSelected: usdtSelected,
          recentUpdates: recentUpdates,
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required DateTime now,
    required CurrentRatesSnapshot current,
    required bool hasAnyRate,
    required bool isInitialStreamLoading,
    required RatesRefreshState refreshState,
    required int selectedDays,
    required List<ExchangeRate> bcv30d,
    required List<ExchangeRate> usdt30d,
    required List<ExchangeRate> bcvSelected,
    required List<ExchangeRate> usdtSelected,
    required List<ExchangeRate> recentUpdates,
  }) {
    if (!hasAnyRate && (isInitialStreamLoading || refreshState.isRefreshing)) {
      return const _RatesSkeleton(key: RatesScreen.skeletonKey);
    }

    if (!hasAnyRate) {
      return _RatesEmptyState(
        onRetry: () => ref
            .read(ratesRefreshControllerProvider.notifier)
            .refresh(days: math.max(defaultHistoryDays, selectedDays)),
      );
    }

    final oldestFetched = oldestCurrentFetchedAt(current);
    final isStale = isRateStale(oldestFetchedAt: oldestFetched, now: now);
    final gapPercent = calculateRateGapPercent(
      bcv: current.bcv,
      usdt: current.usdt,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (refreshState.isOfflineFallback) ...[
          const StaleRateBanner.offline(),
          const SizedBox(height: 16),
        ] else if (isStale && oldestFetched != null) ...[
          StaleRateBanner.outdated(
            ageText: formatRateAge(oldestFetched, now),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CurrentRateCard(
                tag: const CurrencyTag.bcv(),
                unitLabel: 'Bs per USD',
                rate: current.bcv,
                variation30d: calculateVariationPercent(bcv30d),
                now: now,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CurrentRateCard(
                tag: const CurrencyTag.usdt(),
                unitLabel: 'Bs per USDT',
                rate: current.usdt,
                variation30d: calculateVariationPercent(usdt30d),
                now: now,
              ),
            ),
          ],
        ),
        if (gapPercent != null) ...[
          const SizedBox(height: 12),
          _GapCard(
            gapPercent: gapPercent,
            bcvValue: current.bcv!.value,
            usdtValue: current.usdt!.value,
          ),
        ],
        const SizedBox(height: 16),
        _RangeSelector(
          selectedDays: selectedDays,
          onSelect: (days) {
            ref.read(selectedRangeDaysProvider.notifier).select(days);
            ref
                .read(ratesRefreshControllerProvider.notifier)
                .refresh(days: days);
          },
        ),
        const SizedBox(height: 12),
        RateHistoryChart(
          bcvRates: bcvSelected,
          usdtRates: usdtSelected,
        ),
        const SizedBox(height: 24),
        Text(
          'Latest updates',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _LatestUpdatesCard(updates: recentUpdates),
      ],
    );
  }
}

class _CurrentRateCard extends StatelessWidget {
  const _CurrentRateCard({
    required this.tag,
    required this.unitLabel,
    required this.rate,
    required this.variation30d,
    required this.now,
  });

  final CurrencyTag tag;
  final String unitLabel;
  final ExchangeRate? rate;
  final Decimal? variation30d;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ahorraColors;

    final variationColor = switch (variation30d) {
      final v? when v > Decimal.zero => colors.negative,
      final v? when v < Decimal.zero => colors.positive,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tag,
          const SizedBox(height: 12),
          Text(
            rate == null ? '—' : formatVeDecimal(rate!.value),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'Inter',
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rate == null ? 'Not in force yet' : unitLabel,
            style: theme.textTheme.labelMedium,
          ),
          if (rate != null) ...[
            const SizedBox(height: 8),
            Text(
              '${formatIsoDate(rate!.valueDate)} · ${formatRateAge(rate!.fetchedAt, now)}',
              style: theme.textTheme.labelMedium,
            ),
          ],
          if (variation30d != null) ...[
            const SizedBox(height: 6),
            Text(
              '${formatVeSignedPercent(variation30d!)} in 30d',
              style: theme.textTheme.labelMedium?.copyWith(
                color: variationColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GapCard extends StatelessWidget {
  const _GapCard({
    required this.gapPercent,
    required this.bcvValue,
    required this.usdtValue,
  });

  final Decimal gapPercent;
  final Decimal bcvValue;
  final Decimal usdtValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ahorraColors;
    final diff = (usdtValue - bcvValue).abs();
    final relation = usdtValue >= bcvValue ? 'above' : 'below';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gap', style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  'USDT/Bs is ${formatVeDecimal(diff)} Bs $relation BCV',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatVePercent(gapPercent),
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Inter',
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selectedDays,
    required this.onSelect,
  });

  final int selectedDays;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ahorraColors;

    return Row(
      children: [
        for (var i = 0; i < _rangeOptions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _RangeChipButton(
              label: '${_rangeOptions[i]} days',
              selected: selectedDays == _rangeOptions[i],
              surfaceColor: colors.surfaceCard,
              selectedColor: colors.surfaceHigh,
              textStyle: theme.textTheme.labelLarge,
              onTap: () => onSelect(_rangeOptions[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _RangeChipButton extends StatelessWidget {
  const _RangeChipButton({
    required this.label,
    required this.selected,
    required this.surfaceColor,
    required this.selectedColor,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color surfaceColor;
  final Color selectedColor;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: selected ? selectedColor : surfaceColor,
      borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
            border: selected ? Border.all(color: primary) : null,
          ),
          child: Text(
            label,
            style: textStyle?.copyWith(color: selected ? primary : muted),
          ),
        ),
      ),
    );
  }
}

class _LatestUpdatesCard extends StatelessWidget {
  const _LatestUpdatesCard({required this.updates});

  final List<ExchangeRate> updates;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ahorraColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AhorraTheme.cardRadius),
      ),
      child: Column(
        children: [
          for (var i = 0; i < updates.length; i++) ...[
            if (i > 0) const Divider(),
            _UpdateRow(rate: updates[i], textTheme: theme.textTheme),
          ],
        ],
      ),
    );
  }
}

class _UpdateRow extends StatelessWidget {
  const _UpdateRow({
    required this.rate,
    required this.textTheme,
  });

  final ExchangeRate rate;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final caracasTime = rate.fetchedAt.toUtc().subtract(const Duration(hours: 4));
    final dateLabel = DateFormat('d MMM, HH:mm', 'en_US').format(caracasTime);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            rate.kind == RateKind.bcv
                ? const CurrencyTag.bcv()
                : const CurrencyTag.usdt(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              'Bs ${formatVeDecimal(rate.value)}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatesSkeleton extends StatelessWidget {
  const _RatesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: const [
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 132)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 132)),
          ],
        ),
        SizedBox(height: 12),
        SkeletonBox(height: 76),
        SizedBox(height: 16),
        SkeletonBox(height: 48),
        SizedBox(height: 12),
        SkeletonBox(height: 220),
        SizedBox(height: 24),
        SkeletonBox(height: 160),
      ],
    );
  }
}

class _RatesEmptyState extends StatelessWidget {
  const _RatesEmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No rates available yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your connection and try again.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 180,
                      child: FilledButton(
                        onPressed: onRetry,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
