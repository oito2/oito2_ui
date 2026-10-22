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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

import '../support/sample_roles.dart';

/// The Linux desktop platform the golden scenes are rendered for.
const goldenPlatform = testPlatform;

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

/// Pumps [child] at [size] under the oito2 theme of [colors], with the
/// app localizations and real shadows, and compares it with the golden
/// file `goldens/<name>.png`.
///
/// With [wholeApp], the capture includes the routes above [child], such
/// as dialogs.
Future<void> expectGoldenScene(
  WidgetTester tester,
  Widget child, {
  required String name,
  required Oito2ColorTheme colors,
  Size size = const Size(640, 480),
  bool wholeApp = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  debugDisableShadows = false;
  try {
    const appKey = ValueKey('golden-app');
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Oito2Theme.fromColors(colors, platform: goldenPlatform),
      localizationsDelegates: const [
        Oito2Localizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: wholeApp ? child : RepaintBoundary(child: child),
    );
    await tester.pumpWidget(
      wholeApp ? RepaintBoundary(key: appKey, child: app) : app,
    );
    await tester.pumpAndSettle();
    await expectLater(
      wholeApp ? find.byKey(appKey) : find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/$name.png'),
    );
  } finally {
    debugDisableShadows = true;
  }
}
