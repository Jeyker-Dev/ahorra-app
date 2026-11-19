import 'package:ahorra_app/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opens in-memory database and executes SELECT 1', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final row = await database.customSelect('SELECT 1').getSingle();

    expect(row.data.values.single, 1);
  });
}
