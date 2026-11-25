import 'package:ahorra_app/features/rates/domain/exchange_rate.dart';

/// Persistence & sync port for exchange rates. UI reads only Drift streams.
abstract interface class RatesRepository {
  Stream<CurrentRatesSnapshot> watchCurrentRates({
    required DateTime todayCaracas,
  });

  Stream<List<ExchangeRate>> watchHistory({
    required RateKind kind,
    required DateTime fromDate,
    required DateTime toDate,
  });

  Stream<List<ExchangeRate>> watchRecentUpdates({int limit = 20});

  Future<void> refresh({int days = 30});
}
