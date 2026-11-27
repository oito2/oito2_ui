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
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The largest share of differing pixels a golden comparison accepts,
/// absorbing anti-aliasing differences between machines.
///
/// A pixel differs when any of its RGBA channels changes. The comparison
/// also limits the pixels that differ strongly: see [goldenStrongDelta] and
/// [goldenStrongTolerance].
const double goldenTolerance = 0.005;

/// The change of one RGBA channel, out of 255, above which a pixel differs
/// strongly: anti-aliasing noise moves channels by less, while a recolored
/// or moved shape moves them by more.
const int goldenStrongDelta = 64;

/// The largest share of strongly differing pixels a golden comparison
/// accepts: the edge pixels of text drawn a fraction of a pixel away, which
/// reach about 0.015% of a scene, while a moved, resized or recolored
/// control, even a small one, goes beyond 0.02%.
const double goldenStrongTolerance = 0.0002;

/// The environment variable that, set to `1`, makes [installGoldenComparator]
/// rewrite only the goldens that are missing or differ beyond the
/// tolerance, instead of failing on them.
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
/// accepts up to [goldenTolerance] of differing pixels, of which up to
/// [goldenStrongTolerance] differ strongly.
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

/// How an image differs from its golden, pixel by pixel.
typedef GoldenDiff = ({
  /// The number of pixels of each image.
  int pixels,

  /// The number of pixels where any RGBA channel differs.
  int differing,

  /// The number of pixels where some RGBA channel differs by more than
  /// [goldenStrongDelta].
  int strong,

  /// The largest change of one channel, out of 255.
  int maxDelta,
});

/// Returns whether [diff] is within the tolerance of a golden comparison:
/// at most [goldenTolerance] of the pixels differ and at most
/// [goldenStrongTolerance] differ strongly.
bool isWithinGoldenTolerance(GoldenDiff diff) =>
    diff.differing <= diff.pixels * goldenTolerance &&
    diff.strong <= diff.pixels * goldenStrongTolerance;

/// Returns how the PNG image [test] differs from the PNG image [master],
/// or null when their sizes differ.
Future<GoldenDiff?> measureGoldenDiff(Uint8List test, Uint8List master) async {
  final a = await _decode(test);
  final b = await _decode(master);
  try {
    if (a.width != b.width || a.height != b.height) return null;
    final pa = (await a.toByteData())!.buffer.asUint8List();
    final pb = (await b.toByteData())!.buffer.asUint8List();
    var differing = 0;
    var strong = 0;
    var maxDelta = 0;
    for (var i = 0; i < pa.length; i += 4) {
      var delta = 0;
      for (var c = i; c < i + 4; c++) {
        final d = (pa[c] - pb[c]).abs();
        if (d > delta) delta = d;
      }
      if (delta == 0) continue;
      differing++;
      if (delta > goldenStrongDelta) strong++;
      if (delta > maxDelta) maxDelta = delta;
    }
    return (
      pixels: a.width * a.height,
      differing: differing,
      strong: strong,
      maxDelta: maxDelta,
    );
  } finally {
    a.dispose();
    b.dispose();
  }
}

/// Decodes the PNG image [bytes].
Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  try {
    return (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
}

/// Returns [diff] as text for a failure message.
String _describe(GoldenDiff diff) {
  String percent(int count) =>
      '${(count / diff.pixels * 100).toStringAsFixed(3)}%';
  return '${diff.differing} pixels differ (${percent(diff.differing)}, '
      'limit ${(goldenTolerance * 100).toStringAsFixed(3)}%), '
      '${diff.strong} by more than $goldenStrongDelta '
      '(${percent(diff.strong)}, limit '
      '${(goldenStrongTolerance * 100).toStringAsFixed(3)}%); '
      'largest channel change ${diff.maxDelta}.';
}

/// A [LocalFileComparator] that passes when at most [goldenTolerance] of
/// the pixels differ and at most [goldenStrongTolerance] differ strongly,
/// as [isWithinGoldenTolerance] tells.
///
/// A comparison beyond the tolerance throws a [FlutterError] with the
/// failure output and the measured difference, and one against a missing
/// golden fails the test with a [TestFailure], unless [updateFailed] is
/// true: then it writes [compare]'s image as the new golden, prints its
/// name and passes.
class TolerantGoldenComparator extends LocalFileComparator {
  /// Creates a comparator that resolves goldens against [basedir], a
  /// directory URI.
  TolerantGoldenComparator(Uri basedir, {this.updateFailed = false})
    : super(basedir.resolve('golden_test.dart'));

  /// Whether a missing golden, or one that differs beyond the tolerance, is
  /// rewritten instead of failing the comparison.
  final bool updateFailed;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    if (updateFailed &&
        !File.fromUri(basedir.resolveUri(golden)).existsSync()) {
      return _rewrite(imageBytes, golden, 'missing');
    }
    final master = Uint8List.fromList(await getGoldenBytes(golden));
    final result = await GoldenFileComparator.compareLists(imageBytes, master);
    if (result.passed) {
      result.dispose();
      return true;
    }
    final diff = await measureGoldenDiff(imageBytes, master);
    if (diff != null && isWithinGoldenTolerance(diff)) {
      result.dispose();
      return true;
    }
    final described = diff == null ? 'the size differs' : _describe(diff);
    if (updateFailed) {
      result.dispose();
      return _rewrite(imageBytes, golden, described);
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError('$error\n$described');
  }

  /// Writes [imageBytes] as [golden], prints its name with [reason] and
  /// returns true.
  Future<bool> _rewrite(Uint8List imageBytes, Uri golden, String reason) async {
    await update(golden, imageBytes);
    debugPrint('Updated golden $golden ($reason).');
    return true;
  }
}
