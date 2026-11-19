import 'package:ahorra_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Ahorra placeholder home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AhorraApp()));

    expect(find.text('Ahorra'), findsOneWidget);
  });
}
