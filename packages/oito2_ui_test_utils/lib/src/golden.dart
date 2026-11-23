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

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The largest share of differing pixels a golden comparison accepts,
/// absorbing anti-aliasing differences between machines.
const double goldenTolerance = 0.005;

/// The environment variable that, set to `1`, makes [installGoldenComparator]
/// rewrite only the goldens that are missing or differ beyond
/// [goldenTolerance], instead of failing on them.
const String updateFailedGoldensVariable = 'OITO2_UPDATE_FAILED_GOLDENS';

/// A font family to load for golden tests from [files] of [package].
///
/// A `required` font that is missing from the test bundle fails the load;
/// an optional one is skipped.
typedef _GoldenFont = ({
  String family,
  String package,
  List<String> files,
  bool required,
});

/// The font families loaded by [loadGoldenFonts], in load order.
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

/// Replaces the golden comparator with a [TolerantGoldenComparator] that
/// accepts up to [goldenTolerance] of differing pixels.
///
/// When the [updateFailedGoldensVariable] environment variable is `1`, the
/// comparator rewrites the goldens that are missing or differ beyond the
/// tolerance and leaves the others untouched. Does nothing when the current
/// comparator isn't a [LocalFileComparator].
void installGoldenComparator() {
  final current = goldenFileComparator;
  if (current is! LocalFileComparator) return;
  goldenFileComparator = TolerantGoldenComparator(
    current.basedir,
    updateFailed: Platform.environment[updateFailedGoldensVariable] == '1',
  );
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

/// A [LocalFileComparator] that passes when at most [goldenTolerance] of
/// the pixels differ.
///
/// A comparison beyond the tolerance, or against a missing golden, throws
/// a [FlutterError] with the failure output, unless [updateFailed] is true:
/// then it writes [compare]'s image as the new golden, prints its name and
/// passes.
class TolerantGoldenComparator extends LocalFileComparator {
  /// Creates a comparator that resolves goldens against [basedir], a
  /// directory URI.
  TolerantGoldenComparator(Uri basedir, {this.updateFailed = false})
    : super(basedir.resolve('golden_test.dart'));

  /// Whether a missing golden, or one that differs beyond [goldenTolerance],
  /// is rewritten instead of failing the comparison.
  final bool updateFailed;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    if (updateFailed &&
        !File.fromUri(basedir.resolveUri(golden)).existsSync()) {
      return _rewrite(imageBytes, golden, 'missing');
    }
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= goldenTolerance) {
      result.dispose();
      return true;
    }
    if (updateFailed) {
      final percent = (result.diffPercent * 100).toStringAsFixed(2);
      result.dispose();
      return _rewrite(imageBytes, golden, '$percent% diff');
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }

  /// Writes [imageBytes] as [golden], prints its name with [reason] and
  /// returns true.
  Future<bool> _rewrite(Uint8List imageBytes, Uri golden, String reason) async {
    await update(golden, imageBytes);
    debugPrint('Updated golden $golden ($reason).');
    return true;
  }
}
