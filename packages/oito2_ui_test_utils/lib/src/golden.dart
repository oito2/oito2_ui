// Copyright (C) 2026  oito2
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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The largest share of differing pixels a golden comparison accepts,
/// absorbing anti-aliasing differences between machines.
const double goldenTolerance = 0.005;

/// A font family to load for golden tests, from files of [package].
typedef _GoldenFont = ({
  String family,
  String package,
  List<String> files,
  bool required,
});

const List<_GoldenFont> _fonts = [
  (
    family: 'packages/oito2_ui/Inter',
    package: 'oito2_ui',
    files: [
      'assets/fonts/inter/InterVariable.ttf',
      'assets/fonts/inter/InterVariable-Italic.ttf',
    ],
    required: true,
  ),
  (
    family: 'packages/flutter_lucide/lucide',
    package: 'flutter_lucide',
    files: ['lib/fonts/lucide.ttf'],
    required: true,
  ),
  (
    family: 'packages/oito2_ui_syntax/JetBrains Mono',
    package: 'oito2_ui_syntax',
    files: [
      'assets/fonts/jetbrains_mono/JetBrainsMono-Variable.ttf',
      'assets/fonts/jetbrains_mono/JetBrainsMono-Italic-Variable.ttf',
    ],
    required: false,
  ),
  (
    family: 'MaterialIcons',
    package: '',
    files: ['fonts/MaterialIcons-Regular.otf'],
    required: false,
  ),
];

/// Reads [file] of [package] from the test asset bundle: as a dependency's
/// asset, or as one of the package under test, which has no prefix.
Future<ByteData?> _asset(String package, String file) async {
  for (final key in [if (package.isNotEmpty) 'packages/$package/$file', file]) {
    try {
      return await rootBundle.load(key);
    } on Object {
      continue;
    }
  }
  return null;
}

/// Loads Inter, the Lucide icons and, when the package under test bundles
/// them, JetBrains Mono and the Material icons, so goldens show real
/// glyphs instead of the test font's boxes.
///
/// Throws a [StateError] when Inter or the Lucide icons are missing.
Future<void> loadGoldenFonts() async {
  for (final font in _fonts) {
    final data = [
      for (final file in font.files) await _asset(font.package, file),
    ];
    if (data.contains(null)) {
      if (font.required) {
        throw StateError('The ${font.family} font is not in the test bundle.');
      }
      continue;
    }
    final loader = FontLoader(font.family);
    for (final bytes in data) {
      loader.addFont(Future.value(bytes!));
    }
    await loader.load();
  }
}

/// Replaces the golden comparator with one that accepts up to
/// [goldenTolerance] of differing pixels.
void installGoldenComparator() {
  final current = goldenFileComparator;
  if (current is! LocalFileComparator) return;
  goldenFileComparator = _TolerantComparator(current.basedir);
}

/// Runs [testMain] after loading the golden fonts and installing the
/// tolerant comparator: the body of a golden directory's
/// `flutter_test_config.dart`.
Future<void> runGoldenTests(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadGoldenFonts();
  installGoldenComparator();
  await testMain();
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(Uri basedir) : super(basedir.resolve('golden_test.dart'));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= goldenTolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
