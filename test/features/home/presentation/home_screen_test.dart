import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:ahorra_app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen displays RateChip, stale warning banner, and triggers callbacks', (tester) async {
    var openRatesCalled = false;
    var signOutCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AhorraTheme.dark(),
        home: HomeScreen(
          rates: const HomeRatesSummary(
            bcvText: '220,00',
            usdtText: '300,00',
            ageText: '14 h ago',
            isStale: true,
            isOfflineFallback: false,
          ),
          onOpenRates: () => openRatesCalled = true,
          onRefreshRates: () async {},
          onSignOut: () => signOutCalled = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BCV 220,00 · USDT/Bs 300,00 · 14 h ago'), findsOneWidget);
    expect(find.text('Outdated rate · last: 14 h ago'), findsOneWidget);

    await tester.tap(find.text('BCV 220,00 · USDT/Bs 300,00 · 14 h ago'));
    expect(openRatesCalled, isTrue);

    await tester.tap(find.byTooltip('Account menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(signOutCalled, isTrue);
  });
}
