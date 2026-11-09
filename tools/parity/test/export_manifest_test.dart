// Copyright (C) 2026  OITO2
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Writes the versions the fixtures were generated with: the Flutter
// framework, every oito2_ui package and the third-party packages whose
// values the fixtures carry.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// The oito2_ui packages the exporters read.
const packages = [
  'oito2_ui',
  'oito2_ui_themes',
  'oito2_ui_syntax',
  'oito2_ui_extras',
];

/// The third-party packages whose data reaches the fixtures.
const dependencies = [
  'catppuccin_flutter',
  'flutter_lucide',
  'intl',
  'material_ui',
  'qr',
  're_highlight',
];

/// The `version:` line of the pubspec at [path].
String versionOf(String path) {
  final match = RegExp(
    r'^version:\s*(\S+)',
    multiLine: true,
  ).firstMatch(File(path).readAsStringSync());
  return match!.group(1)!;
}

/// The resolved version of [package] in the workspace lock file.
String lockedVersion(String lock, String package) {
  final match = RegExp(
    '^  $package:\\n(?:    .*\\n)*?    version: "([^"]+)"',
    multiLine: true,
  ).firstMatch(lock);
  return match!.group(1)!;
}

/// The Flutter framework version, from the SDK the tests run with.
String flutterVersion() {
  final root = Platform.environment['FLUTTER_ROOT']!;
  final json = File('$root/bin/cache/flutter.version.json').readAsStringSync();
  return (jsonDecode(json) as Map<String, Object?>)['frameworkVersion']!
      as String;
}

void main() {
  test('exports the manifest', () {
    final lock = File('../../pubspec.lock').readAsStringSync();
    final file = writeFixture('manifest.json', {
      'flutter': flutterVersion(),
      'packages': {
        for (final package in packages)
          package: versionOf('../../packages/$package/pubspec.yaml'),
      },
      'dependencies': {
        for (final package in dependencies)
          package: lockedVersion(lock, package),
      },
    });
    expect(file.existsSync(), isTrue);
  });
}
