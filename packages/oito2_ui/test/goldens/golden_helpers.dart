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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../support/sample_roles.dart';

/// The largest share of differing pixels a golden comparison accepts,
/// absorbing anti-aliasing differences between machines.
const double goldenTolerance = 0.005;

/// The Linux desktop platform the golden scenes are rendered for.
const goldenPlatform = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);

/// The color schemes every golden scene is rendered in.
final Map<String, Oito2ColorTheme> goldenSchemes = {
  'light': Oito2ColorTheme.light(),
  'dark': Oito2ColorTheme.dark(),
  'light_high_contrast': Oito2ColorTheme.light(highContrast: true),
  'roles_light_dim': Oito2ColorTheme.fromRoles(sampleRoles['roles light dim']!),
  'roles_dark_lifted': Oito2ColorTheme.fromRoles(
    sampleRoles['roles dark lifted']!,
  ),
};

/// Loads Inter, the Lucide icons and the Material icons, so goldens show
/// real glyphs instead of the test font's boxes.
Future<void> loadGoldenFonts() async {
  Future<ByteData> file(String path) async =>
      ByteData.sublistView(await File(path).readAsBytes());

  await (FontLoader('packages/oito2_ui/Inter')
        ..addFont(file('assets/fonts/inter/InterVariable.ttf'))
        ..addFont(file('assets/fonts/inter/InterVariable-Italic.ttf')))
      .load();
  await (FontLoader('packages/flutter_lucide/lucide')..addFont(
        rootBundle.load('packages/flutter_lucide/lib/fonts/lucide.ttf'),
      ))
      .load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
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

/// Pumps [child] at [size] under the oito2 theme of [colors], with the
/// app localizations and real shadows, and compares it with the golden
/// file `goldens/<name>.png`.
Future<void> expectGoldenScene(
  WidgetTester tester,
  Widget child, {
  required String name,
  required Oito2ColorTheme colors,
  Size size = const Size(640, 480),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  debugDisableShadows = false;
  try {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Oito2Theme.fromColors(colors, platform: goldenPlatform),
        localizationsDelegates: const [
          Oito2Localizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: RepaintBoundary(child: child),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/$name.png'),
    );
  } finally {
    debugDisableShadows = true;
  }
}
