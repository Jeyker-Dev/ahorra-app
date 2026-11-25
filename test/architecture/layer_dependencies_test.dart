import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final libDir = Directory('lib');

  List<File> dartFilesUnder(String relativePath) {
    final dir = Directory('${libDir.path}/$relativePath');
    if (!dir.existsSync()) return const [];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
        .toList();
  }

  test('domain layers remain pure Dart without Flutter, Drift, or HTTP imports', () {
    const forbidden = [
      'package:flutter/',
      'package:drift/',
      'package:dio/',
      'package:go_router/',
      'package:flutter_secure_storage/',
      'package:flutter_riverpod/',
    ];

    final featuresDir = Directory('${libDir.path}/features');
    for (final feature in featuresDir.listSync().whereType<Directory>()) {
      final featureName = feature.uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .last;
      for (final file in dartFilesUnder('features/$featureName/domain')) {
        final content = file.readAsStringSync();
        for (final prefix in forbidden) {
          expect(
            content.contains(prefix),
            isFalse,
            reason: '${file.path} must not import $prefix',
          );
        }
        expect(
          RegExp(r'\bdouble\b').hasMatch(content),
          isFalse,
          reason: '${file.path} must not use double',
        );
      }
    }
  });

  test('features do not import other features or app/', () {
    final featuresDir = Directory('${libDir.path}/features');
    final importPattern = RegExp(r"import\s+'package:ahorra_app/([^']+)'");

    for (final feature in featuresDir.listSync().whereType<Directory>()) {
      final featureName = feature.uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .last;
      for (final file in dartFilesUnder('features/$featureName')) {
        final content = file.readAsStringSync();
        for (final match in importPattern.allMatches(content)) {
          final target = match.group(1)!;
          expect(
            target.startsWith('app/'),
            isFalse,
            reason: '${file.path} must not import app/ ($target)',
          );
          if (target.startsWith('features/')) {
            expect(
              target.startsWith('features/$featureName/'),
              isTrue,
              reason: '${file.path} must not import another feature ($target)',
            );
          }
        }
      }
    }
  });

  test('core/ never imports features/ or app/', () {
    final importPattern = RegExp(r"import\s+'package:ahorra_app/(features|app)/");
    for (final file in dartFilesUnder('core')) {
      final content = file.readAsStringSync();
      expect(
        importPattern.hasMatch(content),
        isFalse,
        reason: '${file.path} must not import features/ or app/',
      );
    }
  });

  test('core/money never uses double', () {
    for (final file in dartFilesUnder('core/money')) {
      final content = file.readAsStringSync();
      expect(
        RegExp(r'\bdouble\b').hasMatch(content),
        isFalse,
        reason: '${file.path} must not use double',
      );
    }
  });
}
