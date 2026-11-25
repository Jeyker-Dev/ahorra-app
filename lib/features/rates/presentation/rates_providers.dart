import 'dart:async';

import 'package:ahorra_app/core/db/database_provider.dart';
import 'package:ahorra_app/core/network/api_dio_provider.dart';
import 'package:ahorra_app/features/rates/data/drift_rates_repository.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rate_calculations.dart';
import 'package:ahorra_app/features/rates/domain/rates_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const defaultHistoryDays = 30;
const _clockTickInterval = Duration(minutes: 1);

/// Injectable UTC clock for deterministic age & Caracas date calculations.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Current time, re-read from [clockProvider] every minute so rate ages,
/// staleness, and the Caracas date stay current while a screen stays open.
class CurrentTimeNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final clock = ref.watch(clockProvider);
    final timer = Timer.periodic(_clockTickInterval, (_) => state = clock());
    ref.onDispose(timer.cancel);
    return clock();
  }
}

final currentTimeProvider = NotifierProvider<CurrentTimeNotifier, DateTime>(
  CurrentTimeNotifier.new,
);

/// Today's date in `America/Caracas`; dependents rebuild only when the day changes.
final todayCaracasProvider = Provider<DateTime>(
  (ref) => caracasDate(ref.watch(currentTimeProvider)),
);

final ratesRepositoryProvider = Provider<RatesRepository>((ref) {
  return DriftRatesRepository(
    database: ref.watch(appDatabaseProvider),
    dio: ref.watch(apiDioProvider),
    now: ref.watch(clockProvider),
  );
});

/// Watches the current BCV (in force today in Caracas) and latest USDT rates from Drift.
final currentRatesProvider = StreamProvider<CurrentRatesSnapshot>((ref) {
  final todayCaracas = ref.watch(todayCaracasProvider);
  return ref
      .watch(ratesRepositoryProvider)
      .watchCurrentRates(todayCaracas: todayCaracas);
});

/// Watches historical rates from Drift for [kind] across the last [days] days.
final rateHistoryProvider =
    StreamProvider.family<List<ExchangeRate>, ({RateKind kind, int days})>(
  (ref, args) {
    final toDate = ref.watch(todayCaracasProvider);
    final fromDate = toDate.subtract(Duration(days: args.days));
    return ref.watch(ratesRepositoryProvider).watchHistory(
          kind: args.kind,
          fromDate: fromDate,
          toDate: toDate,
        );
  },
);

/// Watches recent individual rate snapshots ordered by `fetched_at DESC`.
final recentRateUpdatesProvider = StreamProvider<List<ExchangeRate>>((ref) {
  return ref.watch(ratesRepositoryProvider).watchRecentUpdates();
});

/// Selected chart range in days (`7`, `30`, or `90`).
class SelectedRangeDaysNotifier extends Notifier<int> {
  @override
  int build() => defaultHistoryDays;

  void select(int days) {
    state = days;
  }
}

final selectedRangeDaysProvider =
    NotifierProvider<SelectedRangeDaysNotifier, int>(
  SelectedRangeDaysNotifier.new,
);

/// UI-observable refresh status without surfacing raw exceptions directly.
class RatesRefreshState {
  const RatesRefreshState({
    this.isRefreshing = false,
    this.isOfflineFallback = false,
    this.hasAttempted = false,
  });

  final bool isRefreshing;
  final bool isOfflineFallback;
  final bool hasAttempted;

  RatesRefreshState copyWith({
    bool? isRefreshing,
    bool? isOfflineFallback,
    bool? hasAttempted,
  }) {
    return RatesRefreshState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
      hasAttempted: hasAttempted ?? this.hasAttempted,
    );
  }
}

/// Coordinates API-to-Drift refreshes and exposes loading/offline status.
class RatesRefreshController extends Notifier<RatesRefreshState> {
  @override
  RatesRefreshState build() => const RatesRefreshState();

  Future<void> refresh({int? days}) async {
    if (state.isRefreshing) return;
    final int targetDays = days ?? ref.read(selectedRangeDaysProvider);
    state = state.copyWith(isRefreshing: true);

    var isOfflineFallback = false;
    try {
      await ref.read(ratesRepositoryProvider).refresh(days: targetDays);
    } on RatesNetworkException {
      isOfflineFallback = true;
    } finally {
      // Unexpected errors still propagate to the global error handler.
      state = RatesRefreshState(
        isRefreshing: false,
        isOfflineFallback: isOfflineFallback,
        hasAttempted: true,
      );
    }
  }
}

final ratesRefreshControllerProvider =
    NotifierProvider<RatesRefreshController, RatesRefreshState>(
  RatesRefreshController.new,
);
