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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The largest share of differing pixels a golden comparison accepts,
/// absorbing anti-aliasing differences between machines.
const double goldenTolerance = 0.005;

/// Loads JetBrains Mono, Inter and the Lucide icons, so goldens show real
/// glyphs instead of the test font's boxes.
Future<void> loadGoldenFonts() async {
  Future<ByteData> file(String path) async =>
      ByteData.sublistView(await File(path).readAsBytes());

  await (FontLoader('packages/oito2_ui_syntax/JetBrains Mono')
        ..addFont(
          file('assets/fonts/jetbrains_mono/JetBrainsMono-Variable.ttf'),
        )
        ..addFont(
          file('assets/fonts/jetbrains_mono/JetBrainsMono-Italic-Variable.ttf'),
        ))
      .load();
  await (FontLoader('packages/oito2_ui/Inter')..addFont(
        rootBundle.load(
          'packages/oito2_ui/assets/fonts/inter/InterVariable.ttf',
        ),
      ))
      .load();
  await (FontLoader('packages/flutter_lucide/lucide')..addFont(
        rootBundle.load('packages/flutter_lucide/lib/fonts/lucide.ttf'),
      ))
      .load();
}

/// Replaces the golden comparator with one that accepts up to
/// [goldenTolerance] of differing pixels.
void installGoldenComparator() {
  final current = goldenFileComparator;
  if (current is! LocalFileComparator) return;
  goldenFileComparator = _TolerantComparator(current.basedir);
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
