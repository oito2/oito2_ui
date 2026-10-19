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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';

const _linux = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);

Future<void> _pump(WidgetTester tester, Widget child, {ThemeData? theme}) {
  return tester.pumpWidget(
    MaterialApp(
      theme:
          theme ??
          Oito2Theme.fromPreset(Oito2ThemePreset.nordDark, platform: _linux),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

TextSpan _codeSpan(WidgetTester tester) {
  final text = tester.widget<SelectableText>(find.byType(SelectableText));
  return text.textSpan!;
}

void main() {
  testWidgets('uses the theme syntax palette and the container surface', (
    tester,
  ) async {
    await _pump(
      tester,
      const Oito2CodeBlock(code: 'final x = 1;', language: 'dart'),
    );
    final colors = Oito2ColorTheme.fromPreset(Oito2ThemePreset.nordDark);
    expect(_codeSpan(tester).style!.color, colors.syntax.foreground);
    expect(_codeSpan(tester).toPlainText(), 'final x = 1;');
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(Oito2BorderContainer),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, colors.colorScheme.surfaceContainer);
  });

  testWidgets('falls back to the base scheme without a syntax theme', (
    tester,
  ) async {
    await _pump(
      tester,
      const Oito2CodeBlock(code: 'x', language: 'dart'),
      theme: ThemeData(brightness: Brightness.dark),
    );
    expect(
      _codeSpan(tester).style!.color,
      Oito2ColorTheme.dark().syntax.foreground,
    );
  });

  testWidgets('shows line numbers outside the semantics tree', (tester) async {
    await _pump(
      tester,
      const Oito2CodeBlock(code: 'a\nb\nc', showLineNumbers: true),
    );
    expect(find.text('1\n2\n3'), findsOneWidget);
  });

  testWidgets('copies the code to the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pump(tester, const Oito2CodeBlock(code: 'print(1);'));
    await tester.tap(find.byTooltip('Copy'));
    await tester.pump();
    expect(copied, 'print(1);');
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byIcon(LucideIcons.copy), findsOneWidget);
  });

  testWidgets('the copy button can be hidden', (tester) async {
    await _pump(tester, const Oito2CodeBlock(code: 'x', showCopyButton: false));
    expect(find.byType(IconButton), findsNothing);
  });

  test('the default text style is monospace', () {
    expect(Oito2CodeBlock.defaultTextStyle.fontFamily, 'monospace');
    expect(
      Oito2CodeBlock.defaultTextStyle.fontFamilyFallback,
      Oito2CodeBlock.monospaceFallback,
    );
  });
}
