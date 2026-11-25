import 'dart:async';

import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rates_repository.dart';
import 'package:ahorra_app/features/rates/presentation/rate_history_chart.dart';
import 'package:ahorra_app/features/rates/presentation/rates_providers.dart';
import 'package:ahorra_app/features/rates/presentation/rates_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class FakeRatesRepository implements RatesRepository {
  FakeRatesRepository({
    CurrentRatesSnapshot? initialCurrent,
    List<ExchangeRate>? initialBcvHistory,
    List<ExchangeRate>? initialUsdtHistory,
    List<ExchangeRate>? initialRecent,
    this.onRefresh,
  })  : _current = initialCurrent ??
            const CurrentRatesSnapshot(bcv: null, usdt: null),
        _bcvHistory = initialBcvHistory ?? const [],
        _usdtHistory = initialUsdtHistory ?? const [],
        _recent = initialRecent ?? const [];

  CurrentRatesSnapshot _current;
  final List<ExchangeRate> _bcvHistory;
  final List<ExchangeRate> _usdtHistory;
  final List<ExchangeRate> _recent;
  final Future<void> Function(int days)? onRefresh;
  final List<int> requestedRefreshDays = [];
  final List<DateTime> requestedTodays = [];

  final _currentController = StreamController<CurrentRatesSnapshot>.broadcast();
  final _historyController = StreamController<List<ExchangeRate>>.broadcast();
  final _recentController = StreamController<List<ExchangeRate>>.broadcast();

  void emitCurrent(CurrentRatesSnapshot next) {
    _current = next;
    _currentController.add(next);
  }

  @override
  Stream<CurrentRatesSnapshot> watchCurrentRates({
    required DateTime todayCaracas,
  }) async* {
    requestedTodays.add(todayCaracas);
    yield _current;
    yield* _currentController.stream;
  }

  @override
  Stream<List<ExchangeRate>> watchHistory({
    required RateKind kind,
    required DateTime fromDate,
    required DateTime toDate,
  }) async* {
    yield kind == RateKind.bcv ? _bcvHistory : _usdtHistory;
    yield* _historyController.stream.map(
      (_) => kind == RateKind.bcv ? _bcvHistory : _usdtHistory,
    );
  }

  @override
  Stream<List<ExchangeRate>> watchRecentUpdates({int limit = 20}) async* {
    yield _recent;
    yield* _recentController.stream;
  }

  @override
  Future<void> refresh({int days = 30}) async {
    requestedRefreshDays.add(days);
    if (onRefresh != null) {
      await onRefresh!(days);
    }
  }

  void dispose() {
    _currentController.close();
    _historyController.close();
    _recentController.close();
  }
}

ExchangeRate _rate({
  required String id,
  required RateKind kind,
  required String value,
  required DateTime valueDate,
  required DateTime fetchedAt,
}) {
  return ExchangeRate(
    id: id,
    kind: kind,
    value: Decimal.parse(value),
    valueDate: valueDate,
    origin: kind == RateKind.bcv ? RateOrigin.bcvHtml : RateOrigin.binanceP2p,
    status: RateStatus.confirmed,
    fetchedAt: fetchedAt,
  );
}

Widget _buildTestApp({
  required FakeRatesRepository repo,
  required DateTime now,
  DateTime Function()? clock,
}) {
  return ProviderScope(
    overrides: [
      ratesRepositoryProvider.overrideWithValue(repo),
      clockProvider.overrideWithValue(clock ?? () => now),
    ],
    child: MaterialApp(
      theme: AhorraTheme.dark(),
      home: const RatesScreen(),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_VE');
  });

  testWidgets('shows loading skeleton without spinner when Drift is empty and refresh runs', (tester) async {
    final refreshCompleter = Completer<void>();
    final repo = FakeRatesRepository(
      onRefresh: (_) => refreshCompleter.future,
    );
    addTearDown(repo.dispose);

    await tester.pumpWidget(
      _buildTestApp(repo: repo, now: DateTime.utc(2026, 11, 25, 16, 0)),
    );
    await tester.pump();

    expect(find.byKey(RatesScreen.skeletonKey), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    refreshCompleter.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows empty state with Retry button when Drift is empty and refresh fails', (tester) async {
    final repo = FakeRatesRepository(
      onRefresh: (_) async => throw const RatesNetworkException(),
    );
    addTearDown(repo.dispose);

    await tester.pumpWidget(
      _buildTestApp(repo: repo, now: DateTime.utc(2026, 11, 25, 16, 0)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No rates available yet'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('renders Drift rates, 30-day variations, gap, chart, and stale banner', (tester) async {
    final now = DateTime.utc(2026, 11, 25, 18, 0);
    final fourteenHoursAgo = now.subtract(const Duration(hours: 14));
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    final bcvOld = _rate(
      id: 'bcv-old',
      kind: RateKind.bcv,
      value: '205.00',
      valueDate: DateTime.utc(2026, 10, 26),
      fetchedAt: DateTime.utc(2026, 10, 26, 12, 0),
    );
    final bcvCurrent = _rate(
      id: 'bcv-now',
      kind: RateKind.bcv,
      value: '220.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: fourteenHoursAgo,
    );
    final usdtOld = _rate(
      id: 'usdt-old',
      kind: RateKind.usdt,
      value: '270.00',
      valueDate: DateTime.utc(2026, 10, 26),
      fetchedAt: DateTime.utc(2026, 10, 26, 12, 0),
    );
    final usdtCurrent = _rate(
      id: 'usdt-now',
      kind: RateKind.usdt,
      value: '300.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: oneHourAgo,
    );

    final repo = FakeRatesRepository(
      initialCurrent: CurrentRatesSnapshot(bcv: bcvCurrent, usdt: usdtCurrent),
      initialBcvHistory: [bcvOld, bcvCurrent],
      initialUsdtHistory: [usdtOld, usdtCurrent],
      initialRecent: [usdtCurrent, bcvCurrent],
    );
    addTearDown(repo.dispose);

    await tester.pumpWidget(_buildTestApp(repo: repo, now: now));
    await tester.pumpAndSettle();

    expect(find.text('Outdated rate · last: 14 h ago'), findsOneWidget);
    expect(find.text('220,00'), findsWidgets);
    expect(find.text('300,00'), findsWidgets);
    expect(find.text('36,4 %'), findsOneWidget);
    expect(find.text('+7,3 % in 30d'), findsOneWidget);
    expect(find.text('+11,1 % in 30d'), findsOneWidget);
    expect(find.byType(RateHistoryChart), findsOneWidget);

    await tester.tap(find.text('90 days'));
    await tester.pumpAndSettle();
    expect(repo.requestedRefreshDays, contains(90));
  });

  testWidgets('shows offline banner when refresh fails with network error and Drift has cached data', (tester) async {
    final now = DateTime.utc(2026, 11, 25, 18, 0);
    final recent = now.subtract(const Duration(hours: 2));
    final bcv = _rate(
      id: 'bcv-1',
      kind: RateKind.bcv,
      value: '220.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: recent,
    );
    final usdt = _rate(
      id: 'usdt-1',
      kind: RateKind.usdt,
      value: '300.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: recent,
    );

    final repo = FakeRatesRepository(
      initialCurrent: CurrentRatesSnapshot(bcv: bcv, usdt: usdt),
      initialBcvHistory: [bcv],
      initialUsdtHistory: [usdt],
      initialRecent: [usdt, bcv],
      onRefresh: (_) async => throw const RatesNetworkException(),
    );
    addTearDown(repo.dispose);

    await tester.pumpWidget(_buildTestApp(repo: repo, now: now));
    await tester.pumpAndSettle();

    expect(find.text('No connection · using the last known rate'), findsOneWidget);
    expect(find.text('220,00'), findsWidgets);
  });

  testWidgets('shows stale banner once 12 h pass while the screen stays open', (tester) async {
    final fetchedAt = DateTime.utc(2026, 11, 25, 6, 0);
    var now = fetchedAt.add(const Duration(hours: 11, minutes: 59));
    final bcv = _rate(
      id: 'bcv-1',
      kind: RateKind.bcv,
      value: '220.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: fetchedAt,
    );
    final usdt = _rate(
      id: 'usdt-1',
      kind: RateKind.usdt,
      value: '300.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: fetchedAt,
    );
    final repo = FakeRatesRepository(
      initialCurrent: CurrentRatesSnapshot(bcv: bcv, usdt: usdt),
      initialBcvHistory: [bcv],
      initialUsdtHistory: [usdt],
      initialRecent: [usdt, bcv],
    );
    addTearDown(repo.dispose);

    await tester.pumpWidget(
      _buildTestApp(repo: repo, now: now, clock: () => now),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Outdated rate'), findsNothing);

    now = now.add(const Duration(minutes: 2));
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();

    expect(find.text('Outdated rate · last: 12 h ago'), findsOneWidget);
  });

  testWidgets('re-reads current rates when the Caracas date changes', (tester) async {
    // 23:59 in Caracas (UTC-4) on Nov 25.
    var now = DateTime.utc(2026, 11, 26, 3, 59);
    final repo = FakeRatesRepository();
    addTearDown(repo.dispose);

    await tester.pumpWidget(
      _buildTestApp(repo: repo, now: now, clock: () => now),
    );
    await tester.pumpAndSettle();
    expect(repo.requestedTodays.last, DateTime.utc(2026, 11, 25));

    now = DateTime.utc(2026, 11, 26, 4, 1);
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();

    expect(repo.requestedTodays.last, DateTime.utc(2026, 11, 26));
  });

  testWidgets('hides gap card when current BCV is null', (tester) async {
    final now = DateTime.utc(2026, 11, 25, 18, 0);
    final recent = now.subtract(const Duration(hours: 2));
    final usdt = _rate(
      id: 'usdt-1',
      kind: RateKind.usdt,
      value: '300.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: recent,
    );

    final repo = FakeRatesRepository(
      initialCurrent: CurrentRatesSnapshot(bcv: null, usdt: usdt),
      initialUsdtHistory: [usdt],
      initialRecent: [usdt],
    );
    addTearDown(repo.dispose);

    await tester.pumpWidget(_buildTestApp(repo: repo, now: now));
    await tester.pumpAndSettle();

    expect(find.text('Not in force yet'), findsOneWidget);
    expect(find.text('Gap'), findsNothing);
    expect(find.text('300,00'), findsWidgets);
  });

  testWidgets('renders without overflow at 360 dp width and 2.0 text scale', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final now = DateTime.utc(2026, 11, 25, 18, 0);
    final recent = now.subtract(const Duration(hours: 2));
    final bcv = _rate(
      id: 'bcv-1',
      kind: RateKind.bcv,
      value: '220.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: recent,
    );
    final usdt = _rate(
      id: 'usdt-1',
      kind: RateKind.usdt,
      value: '300.00',
      valueDate: DateTime.utc(2026, 11, 25),
      fetchedAt: recent,
    );

    final repo = FakeRatesRepository(
      initialCurrent: CurrentRatesSnapshot(bcv: bcv, usdt: usdt),
      initialBcvHistory: [bcv],
      initialUsdtHistory: [usdt],
      initialRecent: [usdt, bcv],
    );
    addTearDown(repo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ratesRepositoryProvider.overrideWithValue(repo),
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(
          theme: AhorraTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2.0),
            ),
            child: child!,
          ),
          home: const RatesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
