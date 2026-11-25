import 'package:ahorra_app/app/app_shell.dart';
import 'package:ahorra_app/core/money/money_format.dart';
import 'package:ahorra_app/features/auth/presentation/auth_providers.dart';
import 'package:ahorra_app/features/auth/presentation/login_screen.dart';
import 'package:ahorra_app/features/expenses/presentation/expenses_screen.dart';
import 'package:ahorra_app/features/goals/presentation/goals_screen.dart';
import 'package:ahorra_app/features/home/presentation/home_screen.dart';
import 'package:ahorra_app/features/income/presentation/income_screen.dart';
import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rate_calculations.dart';
import 'package:ahorra_app/features/rates/presentation/rates_providers.dart';
import 'package:ahorra_app/features/rates/presentation/rates_screen.dart';
import 'package:ahorra_app/features/shopping/presentation/shopping_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const income = '/income';
  static const shopping = '/shopping';
  static const expenses = '/expenses';
  static const goals = '/goals';
  static const rates = '/rates';
}

class _AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier();
  ref.listen<AsyncValue<AuthStatus>>(authStateProvider, (_, _) {
    refreshNotifier.notify();
  });
  ref.onDispose(refreshNotifier.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.matchedLocation;

      if (authState.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final status = authState.value ?? AuthStatus.unauthenticated;
      if (status == AuthStatus.unauthenticated) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }

      if (location == AppRoutes.login || location == AppRoutes.splash) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const _HomeContainer(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.income,
                builder: (context, state) => const IncomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shopping,
                builder: (context, state) => const ShoppingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expenses,
                builder: (context, state) => const ExpensesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.goals,
                builder: (context, state) => const GoalsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.rates,
        builder: (context, state) => const RatesScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class _HomeContainer extends ConsumerWidget {
  const _HomeContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(currentTimeProvider);
    final current = ref.watch(currentRatesProvider).value ??
        const CurrentRatesSnapshot(bcv: null, usdt: null);
    final refreshState = ref.watch(ratesRefreshControllerProvider);

    final oldestFetched = oldestCurrentFetchedAt(current);
    final isStale = isRateStale(oldestFetchedAt: oldestFetched, now: now);

    return HomeScreen(
      rates: HomeRatesSummary(
        bcvText: current.bcv == null ? '—' : formatVeDecimal(current.bcv!.value),
        usdtText:
            current.usdt == null ? '—' : formatVeDecimal(current.usdt!.value),
        ageText: oldestFetched == null
            ? 'No data'
            : formatRateAge(oldestFetched, now),
        isStale: isStale,
        isOfflineFallback: refreshState.isOfflineFallback,
      ),
      onOpenRates: () => context.push(AppRoutes.rates),
      onRefreshRates: () =>
          ref.read(ratesRefreshControllerProvider.notifier).refresh(),
      onSignOut: () => ref.read(authStateProvider.notifier).signOut(),
    );
  }
}
