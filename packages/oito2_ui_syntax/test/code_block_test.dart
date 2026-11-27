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

import 'package:flutter/rendering.dart';
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

  testWidgets('highlightedLines tints those lines behind the code', (
    tester,
  ) async {
    await _pump(
      tester,
      const SizedBox(
        width: 300,
        child: Oito2CodeBlock(
          code: 'a\nb\nc',
          showLineNumbers: true,
          highlightedLines: {2, 9},
        ),
      ),
    );
    final painter = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter.runtimeType.toString() == 'FixedLineHighlightPainter',
    );
    expect(painter, findsOneWidget);
    final numbers = find.text('1\n2\n3');
    final lineHeight = tester.getSize(numbers).height / 3;
    final top = tester.getTopLeft(numbers).dy - tester.getTopLeft(painter).dy;
    final width = tester.getSize(painter).width;
    final scheme = Theme.of(tester.element(painter)).colorScheme;
    expect(
      tester.renderObject(painter),
      paints..rect(
        rect: Rect.fromLTWH(0, top + lineHeight, width, lineHeight),
        color: scheme.primary.withValues(alpha: 0.14),
      ),
    );
    // Line 9 doesn't exist: only line 2's tint and bar are painted.
    expect(
      tester.renderObject(painter),
      isNot(
        paints
          ..rect()
          ..rect()
          ..rect(),
      ),
    );
  });

  testWidgets('no highlight painter without highlightedLines', (tester) async {
    await _pump(tester, const Oito2CodeBlock(code: 'a'));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint &&
            widget.painter.runtimeType.toString() ==
                'FixedLineHighlightPainter',
      ),
      findsNothing,
    );
  });

  testWidgets('code longer than maxHighlightLength shows as plain text', (
    tester,
  ) async {
    final highlighter = _CountingHighlighter();
    const code = 'final x = 1;';
    await _pump(
      tester,
      Oito2CodeBlock(
        code: code,
        language: 'dart',
        highlighter: highlighter,
        maxHighlightLength: code.length - 1,
      ),
    );
    final span = _codeSpan(tester);
    expect(highlighter.calls, 0);
    expect(span.children, isNull);
    expect(span.text, code);
    expect(span.style!.color, Oito2ColorTheme.dark().syntax.foreground);

    await _pump(
      tester,
      Oito2CodeBlock(
        code: code,
        language: 'dart',
        highlighter: highlighter,
        maxHighlightLength: code.length,
      ),
    );
    expect(highlighter.calls, 1);
    expect(_codeSpan(tester).children, isNotEmpty);
  });

  testWidgets('the default limit leaves longer code unhighlighted', (
    tester,
  ) async {
    final highlighter = _CountingHighlighter();
    final code = 'x' * (Oito2CodeBlock.defaultMaxHighlightLength + 1);
    await _pump(
      tester,
      Oito2CodeBlock(code: code, language: 'dart', highlighter: highlighter),
    );
    expect(highlighter.calls, 0);
    expect(_codeSpan(tester).text, code);
  });

  group('background highlighting', () {
    const notice = 'Applying syntax highlighting…';
    final dark = Oito2ColorTheme.dark().syntax;
    late _FakeTokenizer tokenizer;

    setUp(() {
      tokenizer = _FakeTokenizer();
      Oito2CodeBlock.debugBackgroundTokenizer = tokenizer.call;
    });
    tearDown(() => Oito2CodeBlock.debugBackgroundTokenizer = null);

    /// Dart code of about [length] code units, longer than the default
    /// background threshold when [length] is.
    String longCode(int length, [String name = 'x']) {
      final line = 'final $name = 1; // c\n';
      return line * (length ~/ line.length + 1);
    }

    bool isPlain(TextSpan span, String code) =>
        span.children == null && span.text == code;

    testWidgets('shows plain text and the notice, then the colors', (
      tester,
    ) async {
      final code = longCode(6000);
      await _pump(tester, Oito2CodeBlock(code: code, language: 'dart'));
      expect(tokenizer.requests, hasLength(1));
      expect(tokenizer.requests.single.code, code);
      expect(tokenizer.requests.single.language, 'dart');
      expect(isPlain(_codeSpan(tester), code), isTrue);
      expect(_codeSpan(tester).style!.color, dark.foreground);
      expect(find.text(notice), findsOneWidget);
      final pendingSize = tester.getSize(find.byType(Oito2CodeBlock));

      tokenizer.completeAll();
      await tester.pump();
      expect(find.text(notice), findsNothing);
      final span = _codeSpan(tester);
      expect(span.toPlainText(), code);
      expect(
        span.children!.cast<TextSpan>().map((s) => s.style?.color),
        contains(dark.keyword),
      );
      expect(tester.getSize(find.byType(Oito2CodeBlock)), pendingSize);
    });

    testWidgets('discards a result for code that changed meanwhile', (
      tester,
    ) async {
      final first = longCode(6000);
      final second = longCode(6000, 'y');
      await _pump(tester, Oito2CodeBlock(code: first, language: 'dart'));
      await _pump(tester, Oito2CodeBlock(code: second, language: 'dart'));
      expect(tokenizer.requests, hasLength(2));

      tokenizer.complete(0);
      await tester.pump();
      expect(isPlain(_codeSpan(tester), second), isTrue);
      expect(find.text(notice), findsOneWidget);

      tokenizer.complete(1);
      await tester.pump();
      expect(find.text(notice), findsNothing);
      expect(_codeSpan(tester).toPlainText(), second);
      expect(_codeSpan(tester).children, isNotEmpty);
    });

    testWidgets('discards a result when the language changed meanwhile', (
      tester,
    ) async {
      final code = longCode(6000);
      await _pump(tester, Oito2CodeBlock(code: code, language: 'dart'));
      await _pump(tester, Oito2CodeBlock(code: code, language: 'rust'));
      expect(tokenizer.requests.map((r) => r.language), ['dart', 'rust']);
      tokenizer.complete(0);
      await tester.pump();
      expect(find.text(notice), findsOneWidget);
      tokenizer.complete(1);
      await tester.pump();
      expect(find.text(notice), findsNothing);
    });

    testWidgets('a theme change reuses the tokens', (tester) async {
      final code = longCode(6000);
      final block = Oito2CodeBlock(code: code, language: 'dart');
      await _pump(tester, block);
      tokenizer.completeAll();
      await tester.pump();
      final light = Oito2ColorTheme.light();
      await _pump(
        tester,
        block,
        theme: Oito2Theme.fromColors(light, platform: testPlatform),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tokenizer.requests, hasLength(1));
      expect(find.text(notice), findsNothing);
      expect(
        _codeSpan(tester).children!.cast<TextSpan>().map((s) => s.style?.color),
        contains(light.syntax.keyword),
      );
    });

    testWidgets('a theme change while pending keeps the request', (
      tester,
    ) async {
      final code = longCode(6000);
      final block = Oito2CodeBlock(code: code, language: 'dart');
      await _pump(tester, block);
      final light = Oito2ColorTheme.light();
      await _pump(
        tester,
        block,
        theme: Oito2Theme.fromColors(light, platform: testPlatform),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tokenizer.requests, hasLength(1));
      tokenizer.completeAll();
      await tester.pump();
      expect(
        _codeSpan(tester).children!.cast<TextSpan>().map((s) => s.style?.color),
        contains(light.syntax.keyword),
      );
    });

    testWidgets('a result after dispose is ignored', (tester) async {
      await _pump(
        tester,
        Oito2CodeBlock(code: longCode(6000), language: 'dart'),
      );
      await _pump(tester, const SizedBox());
      tokenizer.completeAll();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failure keeps the plain text without the notice', (
      tester,
    ) async {
      final code = longCode(6000);
      await _pump(tester, Oito2CodeBlock(code: code, language: 'dart'));
      tokenizer.fail(0);
      await tester.pump();
      expect(tester.takeException(), isA<StateError>());
      expect(find.text(notice), findsNothing);
      expect(isPlain(_codeSpan(tester), code), isTrue);
    });

    testWidgets('code up to the threshold is highlighted synchronously', (
      tester,
    ) async {
      final code = 'x' * Oito2CodeBlock.defaultBackgroundHighlightLength;
      final highlighter = _CountingHighlighter();
      await _pump(
        tester,
        Oito2CodeBlock(code: code, language: 'dart', highlighter: highlighter),
      );
      expect(tokenizer.requests, isEmpty);
      expect(highlighter.calls, 1);
      expect(find.text(notice), findsNothing);
    });

    testWidgets('code over the limit stays plain without the notice', (
      tester,
    ) async {
      final code = longCode(6000);
      await _pump(
        tester,
        Oito2CodeBlock(
          code: code,
          language: 'dart',
          maxHighlightLength: code.length - 1,
        ),
      );
      expect(tokenizer.requests, isEmpty);
      expect(find.text(notice), findsNothing);
      expect(isPlain(_codeSpan(tester), code), isTrue);
    });

    testWidgets('plain or unregistered languages skip the background', (
      tester,
    ) async {
      final code = longCode(6000);
      await _pump(tester, Oito2CodeBlock(code: code));
      await _pump(tester, Oito2CodeBlock(code: code, language: 'cobol'));
      expect(tokenizer.requests, isEmpty);
      expect(find.text(notice), findsNothing);
    });

    testWidgets('backgroundHighlightLength sets the threshold', (tester) async {
      const code = 'final x = 1;';
      await _pump(
        tester,
        Oito2CodeBlock(
          code: code,
          language: 'dart',
          backgroundHighlightLength: code.length - 1,
        ),
      );
      expect(tokenizer.requests, hasLength(1));
      expect(find.text(notice), findsOneWidget);
    });

    testWidgets('the notice is a polite status that takes no focus', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pump(
        tester,
        Oito2CodeBlock(code: longCode(6000), language: 'dart'),
      );
      expect(
        tester.getSemantics(find.text(notice)),
        matchesSemantics(label: notice, isLiveRegion: true, isFocusable: false),
      );
      expect(
        find.ancestor(
          of: find.text(notice),
          matching: find.byType(IgnorePointer),
        ),
        findsWidgets,
      );
      semantics.dispose();
    });

    testWidgets('the plain text stays selectable under the notice', (
      tester,
    ) async {
      final code = longCode(6000);
      await _pump(tester, Oito2CodeBlock(code: code, language: 'dart'));
      final center = tester.getCenter(find.text(notice));
      final hits = tester.hitTestOnBinding(center).path.map((e) => e.target);
      expect(hits.whereType<RenderEditable>(), isNotEmpty);
    });

    testWidgets('the indicator is still when animations are disabled', (
      tester,
    ) async {
      final code = longCode(6000);
      await _pump(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Oito2CodeBlock(code: code, language: 'dart'),
        ),
      );
      await tester.pump();
      expect(find.text(notice), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('the indicator spins when animations are enabled', (
      tester,
    ) async {
      await _pump(
        tester,
        Oito2CodeBlock(code: longCode(6000), language: 'dart'),
      );
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isTrue);
    });
  });

  test('the background thresholds default to 5 000 and 20 000', () {
    expect(Oito2CodeBlock.defaultBackgroundHighlightLength, 5000);
    expect(Oito2CodeBlock.defaultMaxHighlightLength, 20000);
    const block = Oito2CodeBlock(code: '');
    expect(block.backgroundHighlightLength, 5000);
  });

  test('negative thresholds throw an AssertionError', () {
    expect(
      () => Oito2CodeBlock(code: '', backgroundHighlightLength: -1),
      throwsAssertionError,
    );
    expect(
      () => Oito2CodeBlock(code: '', maxHighlightLength: -1),
      throwsAssertionError,
    );
  });

  testWidgets('the default runner tokenizes in another isolate', (
    tester,
  ) async {
    final line = 'final x = 1; // c\n';
    final code = line * 300;
    await _pump(tester, Oito2CodeBlock(code: code, language: 'dart'));
    expect(find.text('Applying syntax highlighting…'), findsOneWidget);
    for (var i = 0; i < 100 && _codeSpan(tester).children == null; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(_codeSpan(tester).children, isNotEmpty);
    expect(find.text('Applying syntax highlighting…'), findsNothing);
  });
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

/// A background tokenizer completed by the test.
class _FakeTokenizer {
  final requests = <({String code, String language, Oito2Highlighter h})>[];
  final _completers = <Completer<Oito2HighlightTokens?>>[];

  Future<Oito2HighlightTokens?> call(
    Oito2Highlighter highlighter,
    String code,
    String language,
  ) {
    requests.add((code: code, language: language, h: highlighter));
    final completer = Completer<Oito2HighlightTokens?>();
    _completers.add(completer);
    return completer.future;
  }

  /// Completes request [index] with the real tokens.
  void complete(int index) {
    final request = requests[index];
    _completers[index].complete(
      request.h.tokenize(request.code, language: request.language),
    );
  }

  /// Fails request [index].
  void fail(int index) =>
      _completers[index].completeError(StateError('tokenizer failed'));

  /// Completes every pending request.
  void completeAll() {
    for (var i = 0; i < requests.length; i++) {
      if (!_completers[i].isCompleted) complete(i);
    }
  }
}
