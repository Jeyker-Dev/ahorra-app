import 'package:flutter_riverpod/flutter_riverpod.dart';

const _rawApiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// Reads and validates the API base URL passed via `--dart-define=API_BASE_URL=...`.
String readRequiredApiBaseUrl({String? override}) {
  final raw = (override ?? _rawApiBaseUrl).trim();
  if (raw.isEmpty) {
    throw StateError(
      'Missing API_BASE_URL. Pass --dart-define=API_BASE_URL=https://your-api.example.com',
    );
  }
  return raw.replaceFirst(RegExp(r'/+$'), '');
}

/// Provides the validated API base URL for the app.
final apiBaseUrlProvider = Provider<String>((ref) => readRequiredApiBaseUrl());
