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
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

const _code = '''
// Greets [name] a number of times.
String greet(String name, {int times = 2}) {
  final text = 'Hello, \$name!';
  return List.filled(times, text).join(' ');
}''';

/// A window with the title bar, sidebar and mainbar chrome, a few
/// controls and a code block.
class _PresetScene extends StatelessWidget {
  const _PresetScene(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final chrome = Oito2ChromeColors.maybeOf(context)!;
    return Scaffold(
      body: Column(
        children: [
          Oito2TitleBar(title: Text(name)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 48, color: chrome.sidebar),
                const VerticalDivider(width: 1),
                Container(width: 120, color: chrome.mainbar),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Oito2Spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Oito2Spacing.md,
                      children: [
                        Row(
                          spacing: Oito2Spacing.sm,
                          children: [
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Save'),
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Cancel'),
                            ),
                            Switch(value: true, onChanged: (_) {}),
                            Checkbox(value: true, onChanged: (_) {}),
                          ],
                        ),
                        const TextField(
                          decoration: InputDecoration(
                            hintText: 'Name',
                            errorText: 'Required',
                          ),
                        ),
                        const Oito2CodeBlock(code: _code, language: 'dart'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  for (final preset in Oito2ThemePreset.values) {
    testWidgets('${preset.name} preset', (tester) async {
      tester.view.physicalSize = const Size(720, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: preset.theme(
            platform: const Oito2Platform(
              targetPlatform: TargetPlatform.linux,
              isWeb: false,
            ),
          ),
          home: RepaintBoundary(child: _PresetScene(preset.name)),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/${preset.name}.png'),
      );
    });
  }
}
