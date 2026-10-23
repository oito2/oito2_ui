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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

Future<void> _pump(WidgetTester tester, Widget child, {ThemeData? theme}) =>
    pumpOito2(
      tester,
      Center(child: child),
      theme: theme ?? Oito2Theme.dark(platform: testPlatform),
    );

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
    final colors = Oito2ColorTheme.dark();
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

  testWidgets('highlights again only when the code changes', (tester) async {
    final highlighter = _CountingHighlighter();
    Widget block(String code) =>
        Oito2CodeBlock(code: code, language: 'dart', highlighter: highlighter);
    await _pump(tester, block('final x = 1;'));
    await _pump(tester, block('final x = 1;'));
    expect(highlighter.calls, 1);
    await _pump(tester, block('final y = 2;'));
    expect(highlighter.calls, 2);
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

  test('the default text style uses the bundled JetBrains Mono', () {
    expect(
      Oito2CodeBlock.defaultTextStyle.fontFamily,
      'packages/oito2_ui_syntax/JetBrains Mono',
    );
    expect(
      Oito2CodeBlock.defaultTextStyle.fontFamilyFallback,
      Oito2CodeBlock.monospaceFallback,
    );
  });

  test(
    'JetBrains Mono is bundled with a fixed advance for every weight',
    () async {
      final data = rootBundle.load(
        'packages/oito2_ui_syntax/assets/fonts/jetbrains_mono/JetBrainsMono-Variable.ttf',
      );
      await (FontLoader('MonoAssetTest')..addFont(data)).load();
      double width(String text, FontWeight weight) {
        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'MonoAssetTest',
              fontSize: 20,
              fontWeight: weight,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        return painter.width;
      }

      expect(width('iiii', FontWeight.w400), width('MMMM', FontWeight.w400));
      expect(width('iiii', FontWeight.w700), width('iiii', FontWeight.w400));
    },
  );
}

/// Counts its highlight calls.
class _CountingHighlighter extends Oito2Highlighter {
  int calls = 0;

  @override
  TextSpan highlight(
    String code, {
    required Oito2SyntaxPalette palette,
    String? language,
    TextStyle? style,
    bool autoDetect = false,
  }) {
    calls++;
    return super.highlight(
      code,
      palette: palette,
      language: language,
      style: style,
      autoDetect: autoDetect,
    );
  }
}
