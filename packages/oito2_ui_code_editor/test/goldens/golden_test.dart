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

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_code_editor/oito2_ui_code_editor.dart';

const _rules = r'''
# Build output
/build/
*.log
!important.log
**/temp?/[a-z]*.tmp
\#not-a-comment''';

/// Pumps [child] on a [size] view in [colors], inside a repaint boundary.
Future<void> _pumpGolden(
  WidgetTester tester,
  Oito2ColorTheme colors,
  Size size,
  Widget child,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Oito2Theme.fromColors(colors, platform: _linux),
      home: RepaintBoundary(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(Oito2Spacing.lg),
            child: child,
          ),
        ),
      ),
    ),
  );
}

const _linux = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);

void main() {
  final schemes = {
    'light': Oito2ColorTheme.light(),
    'dark': Oito2ColorTheme.dark(),
  };
  for (final MapEntry(key: name, value: colors) in schemes.entries) {
    testWidgets('code editor in $name', (tester) async {
      final controller = CodeLineEditingController.fromText(_rules);
      addTearDown(controller.dispose);
      await _pumpGolden(
        tester,
        colors,
        const Size(480, 200),
        Oito2CodeEditor(
          controller: controller,
          language: 'gitignore',
          highlightedLines: const {4},
          lineMarkers: const {
            3: Oito2LineMarker.warning('Matches every log file'),
            5: Oito2LineMarker.error('Unclosed bracket'),
          },
        ),
      );
      // Highlighting runs in a background isolate: alternate real time,
      // for its messages, with frames, for the callbacks they schedule.
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/code_editor_$name.png'),
      );
      await tester.pumpWidget(const SizedBox());
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  }
}
