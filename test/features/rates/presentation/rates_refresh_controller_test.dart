import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';
import 'package:ahorra_app/features/rates/domain/rates_repository.dart';
import 'package:ahorra_app/features/rates/presentation/rates_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingRatesRepository implements RatesRepository {
  _ThrowingRatesRepository(this.error);

  final Object error;

  @override
  Future<void> refresh({int days = 30}) async => throw error;

  @override
  Stream<CurrentRatesSnapshot> watchCurrentRates({
    required DateTime todayCaracas,
  }) =>
      const Stream.empty();

  @override
  Stream<List<ExchangeRate>> watchHistory({
    required RateKind kind,
    required DateTime fromDate,
    required DateTime toDate,
  }) =>
      const Stream.empty();

  @override
  Stream<List<ExchangeRate>> watchRecentUpdates({int limit = 20}) =>
      const Stream.empty();
}

ProviderContainer _containerThrowing(Object error) {
  final container = ProviderContainer(
    overrides: [
      ratesRepositoryProvider.overrideWithValue(_ThrowingRatesRepository(error)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('refresh marks offline fallback on a network error without rethrowing', () async {
    final container = _containerThrowing(const RatesNetworkException());

    await container.read(ratesRefreshControllerProvider.notifier).refresh();

    final state = container.read(ratesRefreshControllerProvider);
    expect(state.isRefreshing, isFalse);
    expect(state.isOfflineFallback, isTrue);
    expect(state.hasAttempted, isTrue);
  });

  test('refresh rethrows unexpected errors after leaving the refreshing state', () async {
    final container = _containerThrowing(StateError('unexpected payload'));

    await expectLater(
      container.read(ratesRefreshControllerProvider.notifier).refresh(),
      throwsA(isA<StateError>()),
    );

    final state = container.read(ratesRefreshControllerProvider);
    expect(state.isRefreshing, isFalse);
    expect(state.isOfflineFallback, isFalse);
    expect(state.hasAttempted, isTrue);
  });
}
