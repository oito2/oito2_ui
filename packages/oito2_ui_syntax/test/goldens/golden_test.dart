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
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';

const _code = '''
/// Greets [name].
@override
String greet(String name, {int times = 2}) {
  final text = 'Hello, \$name!'; // 42
  return List.filled(times, text).join(' ');
}''';

void main() {
  const linux = Oito2Platform(
    targetPlatform: TargetPlatform.linux,
    isWeb: false,
  );
  final schemes = {
    'light': Oito2ColorTheme.light(),
    'dark': Oito2ColorTheme.dark(),
  };
  for (final MapEntry(key: name, value: colors) in schemes.entries) {
    testWidgets('code block in $name', (tester) async {
      tester.view.physicalSize = const Size(560, 200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Oito2Theme.fromColors(colors, platform: linux),
          home: const RepaintBoundary(
            child: Scaffold(
              body: Oito2CodeBlock(
                code: _code,
                language: 'dart',
                showLineNumbers: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/code_block_$name.png'),
      );
    });
  }
}
