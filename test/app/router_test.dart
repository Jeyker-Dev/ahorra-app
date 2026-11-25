import 'package:ahorra_app/app/app.dart';
import 'package:ahorra_app/features/auth/domain/auth_repository.dart';
import 'package:ahorra_app/features/auth/domain/auth_tokens.dart';
import 'package:ahorra_app/features/auth/presentation/auth_providers.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rates_repository.dart';
import 'package:ahorra_app/features/rates/presentation/rates_providers.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _RouterFakeAuthRepository implements AuthRepository {
  _RouterFakeAuthRepository(this._hasTokens);

  bool _hasTokens;

  @override
  Future<bool> hasTokens() async => _hasTokens;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    _hasTokens = true;
    return const AuthTokens(
      accessToken: 'acc',
      refreshToken: 'ref',
      tokenType: 'bearer',
      expiresIn: 900,
    );
  }

  @override
  Future<void> logout() async {
    _hasTokens = false;
  }
}

class _RouterFakeRatesRepository implements RatesRepository {
  @override
  Stream<CurrentRatesSnapshot> watchCurrentRates({
    required DateTime todayCaracas,
  }) {
    final now = DateTime.utc(2026, 11, 25, 16, 0);
    return Stream.value(
      CurrentRatesSnapshot(
        bcv: ExchangeRate(
          id: 'bcv-1',
          kind: RateKind.bcv,
          value: Decimal.parse('220.00'),
          valueDate: DateTime.utc(2026, 11, 25),
          origin: RateOrigin.bcvHtml,
          status: RateStatus.confirmed,
          fetchedAt: now,
        ),
        usdt: ExchangeRate(
          id: 'usdt-1',
          kind: RateKind.usdt,
          value: Decimal.parse('300.00'),
          valueDate: DateTime.utc(2026, 11, 25),
          origin: RateOrigin.binanceP2p,
          status: RateStatus.confirmed,
          fetchedAt: now,
        ),
      ),
    );
  }

  @override
  Stream<List<ExchangeRate>> watchHistory({
    required RateKind kind,
    required DateTime fromDate,
    required DateTime toDate,
  }) =>
      Stream.value(const []);

  @override
  Stream<List<ExchangeRate>> watchRecentUpdates({int limit = 20}) =>
      Stream.value(const []);

  @override
  Future<void> refresh({int days = 30}) async {}
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_VE');
  });

  testWidgets('redirects to login when no tokens are stored', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_RouterFakeAuthRepository(false)),
          ratesRepositoryProvider.overrideWithValue(_RouterFakeRatesRepository()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 25, 17, 0)),
        ],
        child: const AhorraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('authenticated startup opens Home shell with 5 tabs and navigates to /rates full-screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_RouterFakeAuthRepository(true)),
          ratesRepositoryProvider.overrideWithValue(_RouterFakeRatesRepository()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 25, 17, 0)),
        ],
        child: const AhorraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Home', 'Income', 'Shopping', 'Expenses', 'Goals']) {
      expect(find.text(label), findsWidgets);
    }

    await tester.tap(find.textContaining('BCV 220,00'));
    await tester.pumpAndSettle();

    expect(find.text('Rates'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
