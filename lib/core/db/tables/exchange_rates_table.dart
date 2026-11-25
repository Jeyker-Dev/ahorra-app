import 'package:ahorra_app/core/db/converters/decimal_text_converter.dart';
import 'package:drift/drift.dart';

/// Drift table mirroring the backend `exchange_rates` schema.
@DataClassName('ExchangeRateRow')
@TableIndex(
  name: 'ix_exchange_rates_kind_fetched_at',
  columns: {#kind, #fetchedAt},
)
@TableIndex(
  name: 'ix_exchange_rates_kind_value_date',
  columns: {#kind, #valueDate},
)
class ExchangeRates extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get value => text().map(const DecimalTextConverter())();
  TextColumn get valueDate => text()();
  TextColumn get origin => text()();
  TextColumn get status => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
