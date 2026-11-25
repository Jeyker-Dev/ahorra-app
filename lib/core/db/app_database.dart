import 'package:ahorra_app/core/db/converters/decimal_text_converter.dart';
import 'package:ahorra_app/core/db/tables/exchange_rates_table.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ExchangeRates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(exchangeRates);
            await m.createIndex(ixExchangeRatesKindFetchedAt);
            await m.createIndex(ixExchangeRatesKindValueDate);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'ahorra');
  }
}
