import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Persists arbitrary-precision [Decimal] values as SQLite TEXT without floating-point loss.
class DecimalTextConverter extends TypeConverter<Decimal, String> {
  const DecimalTextConverter();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => value.toString();
}
