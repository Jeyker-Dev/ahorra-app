import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:ahorra_app/features/auth/domain/auth_errors.dart';
import 'package:ahorra_app/features/auth/domain/auth_repository.dart';
import 'package:ahorra_app/features/auth/domain/auth_tokens.dart';
import 'package:ahorra_app/features/auth/presentation/auth_providers.dart';
import 'package:ahorra_app/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.onLogin});

  final Future<AuthTokens> Function(String email, String password)? onLogin;

  @override
  Future<bool> hasTokens() async => false;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) {
    if (onLogin != null) {
      return onLogin!(email, password);
    }
    return Future.value(
      const AuthTokens(
        accessToken: 'acc',
        refreshToken: 'ref',
        tokenType: 'bearer',
        expiresIn: 900,
      ),
    );
  }

  @override
  Future<void> logout() async {}
}

Widget buildLoginTestApp(AuthRepository repo) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      theme: AhorraTheme.dark(),
      home: const LoginScreen(),
    ),
  );
}

void main() {
  testWidgets('login shows inline message on wrong credentials', (tester) async {
    final repo = FakeAuthRepository(
      onLogin: (_, _) async => throw const InvalidCredentialsException(),
    );
    await tester.pumpWidget(buildLoginTestApp(repo));

    await tester.enterText(find.byKey(LoginScreen.emailFieldKey), 'user@example.com');
    await tester.enterText(find.byKey(LoginScreen.passwordFieldKey), 'badpass');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Wrong email or password.'), findsOneWidget);
  });

  testWidgets('login shows inline message on network failure', (tester) async {
    final repo = FakeAuthRepository(
      onLogin: (_, _) async => throw const AuthNetworkException(),
    );
    await tester.pumpWidget(buildLoginTestApp(repo));

    await tester.enterText(find.byKey(LoginScreen.emailFieldKey), 'user@example.com');
    await tester.enterText(find.byKey(LoginScreen.passwordFieldKey), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('No connection. Try again.'), findsOneWidget);
  });

  testWidgets('login shows a generic message and reports unexpected errors', (tester) async {
    final repo = FakeAuthRepository(
      onLogin: (_, _) async => throw StateError('unexpected payload'),
    );
    await tester.pumpWidget(buildLoginTestApp(repo));

    await tester.enterText(find.byKey(LoginScreen.emailFieldKey), 'user@example.com');
    await tester.enterText(find.byKey(LoginScreen.passwordFieldKey), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong. Try again.'), findsOneWidget);
    expect(find.text('No connection. Try again.'), findsNothing);
    expect(tester.takeException(), isA<StateError>());
  });

  testWidgets('password visibility toggle keeps 48x48 dp touch target', (tester) async {
    await tester.pumpWidget(buildLoginTestApp(FakeAuthRepository()));

    final toggle = find.byKey(LoginScreen.passwordToggleKey);
    expect(toggle, findsOneWidget);
    final size = tester.getSize(toggle);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
