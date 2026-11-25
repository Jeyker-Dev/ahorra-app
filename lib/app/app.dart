import 'package:ahorra_app/app/router.dart';
import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AhorraApp extends ConsumerWidget {
  const AhorraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Ahorra',
      theme: AhorraTheme.light(),
      darkTheme: AhorraTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
