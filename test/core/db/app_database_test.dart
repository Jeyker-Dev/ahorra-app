import 'package:ahorra_app/core/db/app_database.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opens in-memory database and executes SELECT 1', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final row = await database.customSelect('SELECT 1').getSingle();

    expect(row.data.values.single, 1);
  });

  test('upserts exchange rate by id idempotently and preserves Decimal precision', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final firstFetchedAt = DateTime.utc(2026, 11, 25, 12, 0);
    await database.into(database.exchangeRates).insertOnConflictUpdate(
          ExchangeRatesCompanion.insert(
            id: 'rate-1',
            kind: 'bcv',
            value: Decimal.parse('220.12345678'),
            valueDate: '2026-11-25',
            origin: 'dolarapi',
            status: 'in_review',
            fetchedAt: firstFetchedAt,
          ),
        );

    final updatedFetchedAt = DateTime.utc(2026, 11, 25, 13, 0);
    await database.into(database.exchangeRates).insertOnConflictUpdate(
          ExchangeRatesCompanion.insert(
            id: 'rate-1',
            kind: 'bcv',
            value: Decimal.parse('220.50000000'),
            valueDate: '2026-11-25',
            origin: 'bcv_html',
            status: 'confirmed',
            fetchedAt: updatedFetchedAt,
          ),
        );

    final rows = await database.select(database.exchangeRates).get();
    expect(rows, hasLength(1));
    expect(rows.single.value, Decimal.parse('220.5'));
    expect(rows.single.origin, 'bcv_html');
    expect(rows.single.status, 'confirmed');
    expect(rows.single.fetchedAt.toUtc(), updatedFetchedAt);
  });

  test('migrates schema from v1 to v2 creating exchange_rates table', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (rawDb) {
          rawDb.execute('PRAGMA user_version = 1;');
        },
      ),
    );
    addTearDown(database.close);

    await database.into(database.exchangeRates).insert(
          ExchangeRatesCompanion(
            id: const Value('rate-migrated'),
            kind: const Value('usdt'),
            value: Value(Decimal.parse('300.25')),
            valueDate: const Value('2026-11-25'),
            origin: const Value('binance_p2p'),
            status: const Value('confirmed'),
            fetchedAt: Value(DateTime.utc(2026, 11, 25, 14, 0)),
          ),
        );

    final rows = await database.select(database.exchangeRates).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'rate-migrated');
    expect(rows.single.value, Decimal.parse('300.25'));
  });
}
