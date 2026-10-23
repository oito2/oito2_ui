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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

/// The Linux desktop platform used by widget and golden tests.
const testPlatform = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);

/// Pumps [child] on a [size] logical-pixel view inside the oito2 theme of
/// [colors] (the light base scheme by default), or inside [theme] when
/// given.
///
/// The child sits in a [Scaffold] unless [scaffold] is false, under
/// [textDirection].
Future<void> pumpOito2(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(1000, 800),
  Oito2ColorTheme? colors,
  ThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  bool scaffold = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme:
          theme ??
          Oito2Theme.fromColors(
            colors ?? Oito2ColorTheme.light(),
            platform: testPlatform,
          ),
      home: Directionality(
        textDirection: textDirection,
        child: scaffold ? Scaffold(body: child) : child,
      ),
    ),
  );
}
