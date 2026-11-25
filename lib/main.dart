import 'package:ahorra_app/app/app.dart';
import 'package:ahorra_app/app/app_providers.dart';
import 'package:ahorra_app/core/network/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  readRequiredApiBaseUrl();
  await initializeDateFormatting('es_VE');

  runApp(
    ProviderScope(
      overrides: appProviderOverrides,
      child: const AhorraApp(),
    ),
  );
}
