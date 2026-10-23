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

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// Hosts a value and rebuilds [builder] when it changes, so controlled
/// widgets behave as in an app.
class _Host<T> extends StatefulWidget {
  const _Host({required this.initial, required this.builder});

  final T initial;
  final Widget Function(T value, ValueChanged<T> set) builder;

  @override
  State<_Host<T>> createState() => _HostState<T>();
}

class _HostState<T> extends State<_Host<T>> {
  late T value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(value, (v) => setState(() => value = v));
}

/// The value currently held by the [_Host] of type [T].
T _hostValue<T>(WidgetTester tester) =>
    tester.state<_HostState<T>>(find.byType(_Host<T>)).value;

/// Presses and releases [key], holding Shift when [shift] is true and
/// Control when [control] is true, then pumps a frame.
Future<void> _key(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
  bool control = false,
}) async {
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  if (control) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  if (control) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.pump();
}

void main() {
  group('Oito2NumberEntry', () {
    Future<void> pumpEntry(WidgetTester tester, {int decimals = 0}) =>
        pumpOito2(
          tester,
          Center(
            child: SizedBox(
              width: 220,
              child: _Host<double>(
                initial: 5,
                builder: (value, set) => Oito2NumberEntry(
                  value: value,
                  onChanged: set,
                  min: 0,
                  max: 10,
                  step: decimals == 0 ? 1 : 0.5,
                  decimals: decimals,
                ),
              ),
            ),
          ),
        );

    testWidgets('a sideways scroll leaves the value alone', (tester) async {
      await pumpEntry(tester);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final center = tester.getCenter(find.byType(TextField));
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(center));
      await tester.sendEventToBinding(pointer.scroll(const Offset(40, 0)));
      await tester.pump();
      expect(_hostValue<double>(tester), 5);
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -40)));
      await tester.pump();
      expect(_hostValue<double>(tester), 6);
    });

    test('rejects more decimals than a number can show', () {
      expect(
        () => Oito2NumberEntry(value: 1, onChanged: null, decimals: 21),
        throwsAssertionError,
      );
    });

    for (final (locale, text, value) in const [
      (Locale('sv'), '\u22123', -3.0),
      (Locale('fa'), '\u06F7', 7.0),
    ]) {
      testWidgets('accepts the signs and digits of $locale', (tester) async {
        final values = <double>[];
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: [locale],
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 220,
                  child: Oito2NumberEntry(
                    value: 0,
                    min: -10,
                    max: 10,
                    onChanged: values.add,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), text);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(values.last, value);
      });
    }

    testWidgets('accepts the group separator of de_CH', (tester) async {
      final values = <double>[];
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de', 'CH'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('de', 'CH')],
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: Oito2NumberEntry(
                  value: 0,
                  max: 5000,
                  onChanged: values.add,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), "1'234");
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        "1'234",
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(values.last, 1234);
    });

    testWidgets('a locale change keeps the text being typed', (tester) async {
      Widget build(Locale locale) => MaterialApp(
        locale: locale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en'), Locale('pt')],
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              child: Oito2NumberEntry(value: 5, onChanged: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpWidget(build(const Locale('en')));
      await tester.enterText(find.byType(TextField), '12');
      await tester.pumpWidget(build(const Locale('pt')));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '12',
      );
    });

    testWidgets('the buttons step and stop at the limits', (tester) async {
      await pumpEntry(tester);
      await tester.tap(find.byTooltip('Increase'));
      await tester.pump();
      expect(_hostValue<double>(tester), 6);
      expect(find.text('6'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byTooltip('Increase'), warnIfMissed: false);
        await tester.pump();
      }
      expect(_hostValue<double>(tester), 10);
      final plus = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(LucideIcons.plus),
          matching: find.byType(IconButton),
        ),
      );
      expect(plus.onPressed, isNull);
    });

    testWidgets('keys step, page and jump to the limits', (tester) async {
      await pumpEntry(tester);
      await tester.tap(find.byType(TextField));
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(_hostValue<double>(tester), 6);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_hostValue<double>(tester), 4);
      await _key(tester, LogicalKeyboardKey.pageUp);
      expect(_hostValue<double>(tester), 10);
      await _key(tester, LogicalKeyboardKey.home);
      expect(_hostValue<double>(tester), 0);
    });

    testWidgets('typed text is rounded, clamped or replaced', (tester) async {
      await pumpEntry(tester, decimals: 1);
      await tester.enterText(find.byType(TextField), '7.26');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(_hostValue<double>(tester), 7.3);
      expect(find.text('7.3'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '42');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(_hostValue<double>(tester), 10);
      await tester.enterText(find.byType(TextField), '..');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('10.0'), findsOneWidget);
    });

    testWidgets('the wheel steps while focused', (tester) async {
      await pumpEntry(tester);
      final center = tester.getCenter(find.byType(TextField));
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(center));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -20)));
      await tester.pump();
      expect(_hostValue<double>(tester), 5);
      await tester.tap(find.byType(TextField));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -20)));
      await tester.pump();
      expect(_hostValue<double>(tester), 6);
    });
  });

  group('Oito2PasswordField', () {
    testWidgets('the eye button shows and hides the text', (tester) async {
      await pumpOito2(tester, const Oito2PasswordField(labelText: 'Password'));
      bool obscured() =>
          tester.widget<TextField>(find.byType(TextField)).obscureText;
      expect(obscured(), isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(obscured(), isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).autofillHints, [
        AutofillHints.password,
      ]);
    });

    testWidgets('warns while Caps Lock is on', (tester) async {
      await pumpOito2(tester, const Oito2PasswordField());
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(find.text('Caps Lock is on'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.capsLock);
      await tester.pump();
      expect(find.text('Caps Lock is on'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.capsLock);
      await tester.pump();
      expect(find.text('Caps Lock is on'), findsNothing);
    });

    testWidgets('warns about Caps Lock next to an error', (tester) async {
      await pumpOito2(
        tester,
        const Oito2PasswordField(errorText: 'Wrong password'),
      );
      await tester.tap(find.byType(TextField));
      await tester.sendKeyEvent(LogicalKeyboardKey.capsLock);
      await tester.pump();
      expect(find.text('Wrong password'), findsOneWidget);
      expect(find.text('Caps Lock is on'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.capsLock);
      await tester.pump();
      expect(find.text('Wrong password'), findsOneWidget);
      expect(find.text('Caps Lock is on'), findsNothing);
    });
  });

  group('Oito2PinEntry', () {
    testWidgets('fills the cells, completes and gives up the focus', (
      tester,
    ) async {
      final completed = <String>[];
      await pumpOito2(
        tester,
        Center(child: Oito2PinEntry(length: 4, onCompleted: completed.add)),
      );
      await tester.tap(find.byType(Oito2PinEntry));
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '12a34');
      await tester.pump();
      expect(completed, ['1234']);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode!.hasFocus, isFalse);
      expect(field.autofillHints, [AutofillHints.oneTimeCode]);
    });

    testWidgets('an emoji fills one cell of a text code', (tester) async {
      final completed = <String>[];
      await pumpOito2(
        tester,
        Center(
          child: Oito2PinEntry(
            length: 3,
            numeric: false,
            onCompleted: completed.add,
          ),
        ),
      );
      await tester.tap(find.byType(Oito2PinEntry));
      await tester.enterText(find.byType(TextField), 'a\u{1F600}b');
      await tester.pump();
      expect(find.text('\u{1F600}'), findsOneWidget);
      expect(completed, ['a\u{1F600}b']);
    });

    testWidgets('a pasted code fills every cell and masking hides it', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const Center(child: Oito2PinEntry(length: 4, obscure: true)),
      );
      await tester.enterText(find.byType(TextField), '987654');
      await tester.pump();
      expect(find.text('•'), findsNWidgets(4));
      expect(find.text('9'), findsNothing);
    });

    testWidgets('has its code label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, const Center(child: Oito2PinEntry()));
      expect(find.bySemanticsLabel('Code of 6 characters'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Oito2EditableLabel', () {
    Future<void> pumpLabel(WidgetTester tester) => pumpOito2(
      tester,
      Center(
        child: _Host<String>(
          initial: 'Notes',
          builder: (value, set) =>
              Oito2EditableLabel(text: value, onSubmitted: set),
        ),
      ),
    );

    testWidgets('a double click edits and Enter keeps the text', (
      tester,
    ) async {
      await pumpLabel(tester);
      await tester.tap(find.text('Notes'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Ideas');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(_hostValue<String>(tester), 'Ideas');
    });

    testWidgets('F2 edits and Escape restores the text', (tester) async {
      await pumpLabel(tester);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Other');
      await _key(tester, LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Notes'), findsOneWidget);
      expect(_hostValue<String>(tester), 'Notes');
    });
  });

  group('Oito2TagsField', () {
    Future<void> pumpTags(
      WidgetTester tester, {
      List<String> initial = const [],
      int? maxTags,
      Oito2ListCollection<String>? suggestions,
      Oito2TagsFieldStyle style = Oito2TagsFieldStyle.filled,
      bool clearable = false,
    }) => pumpOito2(
      tester,
      Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 400,
          child: _Host<List<String>>(
            initial: initial,
            builder: (value, set) => Oito2TagsField(
              tags: value,
              onChanged: set,
              maxTags: maxTags,
              suggestions: suggestions,
              hintText: 'Add tag',
              style: style,
              clearable: clearable,
            ),
          ),
        ),
      ),
    );

    testWidgets('the subtle style tints only the focused tag', (tester) async {
      await pumpTags(
        tester,
        initial: ['dart', 'linux'],
        style: Oito2TagsFieldStyle.subtle,
      );
      final scheme = Theme.of(tester.element(find.text('dart'))).colorScheme;
      Color fillOf(String tag) =>
          (tester
                      .widget<Container>(
                        find
                            .ancestor(
                              of: find.text(tag),
                              matching: find.byType(Container),
                            )
                            .first,
                      )
                      .decoration!
                  as BoxDecoration)
              .color!;
      expect(fillOf('dart'), scheme.surfaceContainerHighest);
      expect(fillOf('linux'), scheme.surfaceContainerHighest);
      expect(
        tester.widget<Text>(find.text('dart')).style?.fontWeight,
        FontWeight.w500,
      );
      await tester.tap(find.byType(TextField));
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(fillOf('linux'), isNot(scheme.surfaceContainerHighest));
      expect(fillOf('dart'), scheme.surfaceContainerHighest);
    });

    testWidgets('the clear button removes every tag', (tester) async {
      await pumpTags(tester, initial: ['dart', 'linux'], clearable: true);
      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();
      expect(_hostValue<List<String>>(tester), isEmpty);
      expect(find.byTooltip('Clear'), findsNothing);
    });

    testWidgets('a pasted pair keeps its delimiter when the first is refused', (
      tester,
    ) async {
      await pumpTags(tester, initial: ['dart']);
      await tester.enterText(find.byType(TextField), 'dart,go');
      await tester.pump();
      expect(_hostValue<List<String>>(tester), ['dart']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'go',
      );
      await tester.enterText(find.byType(TextField), 'dart,');
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'dart',
      );
    });

    testWidgets('Enter and delimiters add tags; repeats are refused', (
      tester,
    ) async {
      await pumpTags(tester);
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'dart, linux,flutter,gt');
      await tester.pump();
      expect(_hostValue<List<String>>(tester), ['flutter', 'dart', 'linux']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'gt',
      );
    });

    testWidgets('a refused tag stays in the field with the caret at its end', (
      tester,
    ) async {
      await pumpTags(tester, initial: ['dart']);
      await tester.enterText(find.byType(TextField), 'dart,');
      await tester.pump();
      final controller = tester
          .widget<TextField>(find.byType(TextField))
          .controller!;
      expect(controller.text, 'dart');
      expect(controller.selection, const TextSelection.collapsed(offset: 4));
      expect(_hostValue<List<String>>(tester), ['dart']);
    });

    testWidgets('max tags stops adding', (tester) async {
      await pumpTags(tester, maxTags: 2);
      await tester.enterText(find.byType(TextField), 'a,b,c,');
      await tester.pump();
      expect(_hostValue<List<String>>(tester), ['a', 'b']);
    });

    testWidgets('Backspace reaches and removes tags; the x removes too', (
      tester,
    ) async {
      await pumpTags(tester, initial: ['one', 'two', 'three']);
      await tester.tap(find.byType(TextField));
      await _key(tester, LogicalKeyboardKey.backspace);
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      await _key(tester, LogicalKeyboardKey.backspace);
      expect(_hostValue<List<String>>(tester), ['one', 'three']);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Tooltip && w.message == 'Remove three',
        ),
      );
      await tester.pump();
      expect(_hostValue<List<String>>(tester), ['one']);
    });

    testWidgets('suggestions add a tag', (tester) async {
      await pumpTags(
        tester,
        initial: ['Dart'],
        suggestions: Oito2ListCollection(const ['Dart', 'Flutter', 'Fuchsia']),
      );
      await tester.enterText(find.byType(TextField), 'f');
      await tester.pumpAndSettle();
      expect(find.byType(Oito2HighlightedText), findsNWidgets(2));
      await tester.tap(find.text('Flutter'));
      await tester.pumpAndSettle();
      expect(_hostValue<List<String>>(tester), ['Dart', 'Flutter']);
    });
  });

  group('Oito2Rating', () {
    Future<void> pumpRating(WidgetTester tester, {bool half = false}) =>
        pumpOito2(
          tester,
          Center(
            child: _Host<double>(
              initial: 2,
              builder: (value, set) => Oito2Rating(
                value: value,
                onChanged: set,
                allowHalf: half,
                semanticLabel: 'Quality',
              ),
            ),
          ),
        );

    testWidgets('a value between steps steps to the next one', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: _Host<double>(
            initial: 3.7,
            builder: (value, set) =>
                Oito2Rating(value: value, onChanged: set, allowHalf: true),
          ),
        ),
      );
      final row = tester.getRect(find.byType(Row).last);
      await tester.tapAt(Offset(row.left + 24 * 4 + 18, row.center.dy));
      await tester.pumpAndSettle();
      expect(_hostValue<double>(tester), 5);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_hostValue<double>(tester), 4.5);
    });

    testWidgets('a tap picks a star, a half with allowHalf', (tester) async {
      await pumpRating(tester);
      final row = tester.getRect(find.byType(Row).last);
      await tester.tapAt(Offset(row.left + 24 * 3 + 6, row.center.dy));
      await tester.pumpAndSettle();
      expect(_hostValue<double>(tester), 4);

      await pumpRating(tester, half: true);
      await tester.tapAt(Offset(row.left + 24 * 2 + 4, row.center.dy));
      await tester.pumpAndSettle();
      expect(_hostValue<double>(tester), 2.5);
    });

    testWidgets('keys and semantics change it', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpRating(tester);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(_hostValue<double>(tester), 3);
      await _key(tester, LogicalKeyboardKey.digit5);
      expect(_hostValue<double>(tester), 5);
      await _key(tester, LogicalKeyboardKey.home);
      expect(_hostValue<double>(tester), 0);
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Quality')).value,
        '0 of 5 stars',
      );
      handle.dispose();
    });
  });

  group('Oito2AngleSlider', () {
    Future<void> pumpDial(WidgetTester tester) => pumpOito2(
      tester,
      Center(
        child: _Host<double>(
          initial: 0,
          builder: (value, set) =>
              Oito2AngleSlider(value: value, onChanged: set, size: 100),
        ),
      ),
    );

    testWidgets('points at a tap and steps by keys with wrap', (tester) async {
      await pumpDial(tester);
      final rect = tester.getRect(find.byType(Oito2AngleSlider));
      await tester.tapAt(rect.centerRight - const Offset(5, 0));
      await tester.pump();
      expect(_hostValue<double>(tester), 90);
      expect(find.text('90°'), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.home);
      expect(_hostValue<double>(tester), 0);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_hostValue<double>(tester), 359);
      await _key(tester, LogicalKeyboardKey.pageUp);
      expect(_hostValue<double>(tester), 14);
    });

    testWidgets('a tap and each key press end the change', (tester) async {
      final ends = <double>[];
      await pumpOito2(
        tester,
        Center(
          child: _Host<double>(
            initial: 0,
            builder: (value, set) => Oito2AngleSlider(
              value: value,
              onChanged: set,
              onChangeEnd: ends.add,
              size: 100,
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(Oito2AngleSlider));
      await tester.tapAt(rect.centerRight - const Offset(5, 0));
      await tester.pump();
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(ends, [90, 91]);
    });
  });

  group('Oito2ListBox', () {
    final fruits = Oito2ListCollection(
      const ['Apple', 'Banana', 'Blueberry', 'Cherry', 'Date'],
      isDisabled: (f) => f == 'Cherry',
      groupOf: (f) => f.startsWith('B') ? 'B' : null,
    );

    Future<Oito2SelectionController> pumpList(
      WidgetTester tester,
      Oito2SelectionMode mode, {
      ValueChanged<String>? onActivate,
    }) async {
      final controller = Oito2SelectionController(
        collection: fruits,
        mode: mode,
      );
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 240,
            child: Oito2ListBox(
              collection: fruits,
              controller: controller,
              onActivate: onActivate,
              semanticLabel: 'Fruits',
            ),
          ),
        ),
      );
      return controller;
    }

    testWidgets('single: the arrows select, skipping disabled items', (
      tester,
    ) async {
      final activated = <String>[];
      final controller = await pumpList(
        tester,
        Oito2SelectionMode.single,
        onActivate: activated.add,
      );
      await _key(tester, LogicalKeyboardKey.tab);
      expect(controller.selectedValues, isEmpty);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selectedValues, ['Banana']);
      await _key(tester, LogicalKeyboardKey.end);
      expect(controller.selectedValues, ['Date']);
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(controller.selectedValues, ['Blueberry']);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(activated, ['Blueberry']);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('a double click activates; two slow clicks do not', (
      tester,
    ) async {
      final activated = <String>[];
      await pumpList(
        tester,
        Oito2SelectionMode.single,
        onActivate: activated.add,
      );
      await tester.tap(find.text('Date'));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Date'));
      await tester.pump();
      expect(activated, isEmpty);
      await tester.tap(find.text('Date'));
      await tester.pump(const Duration(milliseconds: 80));
      expect(activated, ['Date']);
    });

    testWidgets('typeahead jumps to matching labels', (tester) async {
      final controller = await pumpList(tester, Oito2SelectionMode.single);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.keyB);
      expect(controller.selectedValues, ['Banana']);
      await _key(tester, LogicalKeyboardKey.keyL);
      expect(controller.selectedValues, ['Blueberry']);
    });

    testWidgets('multiple: Space, Shift+arrows, Control+A and clicks', (
      tester,
    ) async {
      final controller = await pumpList(tester, Oito2SelectionMode.multiple);
      await tester.tap(find.text('Apple'));
      await tester.pump();
      expect(controller.selectedValues, ['Apple']);
      await _key(tester, LogicalKeyboardKey.arrowDown, shift: true);
      expect(controller.selectedValues, ['Apple', 'Banana']);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.space);
      expect(controller.selectedValues, ['Apple', 'Banana', 'Blueberry']);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.text('Banana'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(controller.selectedValues, ['Apple', 'Blueberry']);
      await _key(tester, LogicalKeyboardKey.keyA, control: true);
      expect(controller.selectedValues, [
        'Apple',
        'Banana',
        'Blueberry',
        'Date',
      ]);
    });
  });

  group('Oito2ColorPicker', () {
    test('hex conversion', () {
      expect(oito2ColorToHex(const Color(0xFF3584E4)), '#3584E4');
      expect(oito2ColorToHex(const Color(0x803584E4)), '#3584E480');
      expect(
        oito2ColorToHex(const Color(0x803584E4), withAlpha: false),
        '#3584E4',
      );
      expect(oito2ColorFromHex('#3584e4'), const Color(0xFF3584E4));
      expect(oito2ColorFromHex('f00'), const Color(0xFFFF0000));
      expect(oito2ColorFromHex('#3584E480'), const Color(0x803584E4));
      expect(oito2ColorFromHex('#12345'), isNull);
      expect(oito2ColorFromHex('zzz'), isNull);
      expect(oito2ColorFromHex('12#3456'), isNull);
      expect(oito2ColorFromHex('##123456'), isNull);
    });

    Future<void> pumpPicker(WidgetTester tester) => pumpOito2(
      tester,
      Center(
        child: _Host<Color>(
          initial: const Color(0xFF3584E4),
          builder: (value, set) => Oito2ColorPicker(
            value: value,
            onChanged: set,
            swatches: const [Color(0xFFE01B24), Color(0xFF2EC27E)],
          ),
        ),
      ),
    );

    testWidgets('the hex field, the RGB fields and swatches set it', (
      tester,
    ) async {
      await pumpPicker(tester);
      await tester.enterText(find.byType(TextField), '#ff7800');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(_hostValue<Color>(tester).toARGB32(), 0xFFFF7800);
      await tester.tap(find.text('RGB'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(2), '255');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(_hostValue<Color>(tester).toARGB32(), 0xFFFF78FF);
      await tester.tap(find.bySemanticsLabel('#2EC27E'));
      await tester.pump();
      expect(_hostValue<Color>(tester).toARGB32(), 0xFF2EC27E);
    });

    testWidgets('assistive technologies adjust saturation and brightness', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(tester);
      final start = HSVColor.fromColor(_hostValue<Color>(tester));
      tester.semantics.increase(find.semantics.byLabel('Saturation'));
      await tester.pump();
      final saturated = HSVColor.fromColor(_hostValue<Color>(tester));
      expect(saturated.saturation, greaterThan(start.saturation));
      expect(saturated.value, closeTo(start.value, 0.005));
      tester.semantics.decrease(find.semantics.byLabel('Brightness'));
      await tester.pump();
      final darker = HSVColor.fromColor(_hostValue<Color>(tester));
      expect(darker.value, lessThan(saturated.value));
      handle.dispose();
    });

    testWidgets('grays keep the hue, also typed in HSL', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        Center(
          child: _Host<Color>(
            initial: const Color(0xFF3584E4),
            builder: (value, set) => Oito2ColorPicker(
              value: value,
              onChanged: set,
              swatches: const [Color(0xFF808080)],
            ),
          ),
        ),
      );
      final hue = find.bySemanticsLabel('Hue');
      final before = tester.getSemantics(hue).value;
      await tester.tap(find.bySemanticsLabel('#808080'));
      await tester.pump();
      expect(tester.getSemantics(hue).value, before);
      await tester.tap(find.text('HSL'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '120');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), '50');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(
        HSVColor.fromColor(_hostValue<Color>(tester)).hue,
        closeTo(120, 1),
      );
      handle.dispose();
    });

    testWidgets('typed text applies when the format changes', (tester) async {
      await pumpPicker(tester);
      await tester.tap(find.text('RGB'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '0');
      await tester.tap(find.text('HSL'));
      await tester.pumpAndSettle();
      expect(_hostValue<Color>(tester).toARGB32(), 0xFF0084E4);
    });

    testWidgets('the sliders move by keyboard', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(tester);
      final opacity = find.bySemanticsLabel('Opacity');
      expect(tester.getSemantics(opacity).value, '100%');
      tester.semantics.decrease(find.semantics.byLabel('Opacity'));
      await tester.pump();
      expect(_hostValue<Color>(tester).a, closeTo(0.99, 0.005));
      final hue = find.bySemanticsLabel('Hue');
      final before = tester.getSemantics(hue).value;
      tester.semantics.increase(find.semantics.byLabel('Hue'));
      await tester.pump();
      expect(tester.getSemantics(hue).value, isNot(before));
      handle.dispose();
    });

    testWidgets('the button opens the picker in a popover', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: _Host<Color>(
            initial: const Color(0xFF3584E4),
            builder: (value, set) =>
                Oito2ColorPickerButton(value: value, onChanged: set),
          ),
        ),
      );
      await tester.tap(find.text('#3584E4'));
      await tester.pumpAndSettle();
      expect(find.byType(Oito2ColorPicker), findsOneWidget);
    });
  });

  group('Oito2Calendar', () {
    testWidgets('shows the month of a date selected from outside', (
      tester,
    ) async {
      Widget build(DateTime date) => Center(
        child: Oito2Calendar(
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          selectedDate: date,
          onDateSelected: (_) {},
        ),
      );
      await pumpOito2(tester, build(DateTime(2026, 3, 15)));
      expect(find.text('March 2026'), findsOneWidget);
      await pumpOito2(tester, build(DateTime(2027, 8, 2)));
      expect(find.text('August 2027'), findsOneWidget);
    });

    test('ISO week numbers', () {
      expect(oito2IsoWeekNumber(DateTime(2026, 1, 1)), 1);
      expect(oito2IsoWeekNumber(DateTime(2027, 1, 1)), 53);
      expect(oito2IsoWeekNumber(DateTime(2024, 12, 30)), 1);
      expect(oito2IsoWeekNumber(DateTime(2026, 10, 20)), 43);
      // Dates in daylight-saving time, where a day difference in local time
      // is an hour short.
      expect(oito2IsoWeekNumber(DateTime(2026, 3, 12)), 11);
      expect(oito2IsoWeekNumber(DateTime(2026, 7, 1)), 27);
    });

    Future<void> pumpCalendar(
      WidgetTester tester, {
      bool range = false,
      bool weeks = false,
    }) => pumpOito2(
      tester,
      Center(
        child: _Host<Object?>(
          initial: null,
          builder: (value, set) => Oito2Calendar(
            firstDate: DateTime(2026, 1, 1),
            lastDate: DateTime(2026, 12, 31),
            initialMonth: DateTime(2026, 3),
            showWeekNumbers: weeks,
            selectableDayPredicate: (d) => d.day != 13,
            selectedDate: range ? null : value as DateTime?,
            onDateSelected: range ? null : set,
            selectedRange: range ? value as DateTimeRange? : null,
            onRangeSelected: range ? set : null,
          ),
        ),
      ),
    );

    testWidgets('picks a day, skips refused days and changes month', (
      tester,
    ) async {
      await pumpCalendar(tester);
      expect(find.text('March 2026'), findsOneWidget);
      await tester.tap(find.text('13'));
      await tester.pump();
      expect(_hostValue<Object?>(tester), isNull);
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(_hostValue<Object?>(tester), DateTime(2026, 3, 10));
      await tester.tap(find.byTooltip('Next month'));
      await tester.pump();
      expect(find.text('April 2026'), findsOneWidget);
    });

    testWidgets('the keyboard moves the focused day across months', (
      tester,
    ) async {
      await pumpCalendar(tester);
      await tester.tap(find.text('31'));
      await tester.pump();
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(find.text('April 2026'), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.pageDown, shift: true);
      expect(find.text('December 2026'), findsOneWidget);
      // Shift+Page Down overshoots lastDate, so the focus stops on December
      // 31; Page Up then moves it to November 30.
      await _key(tester, LogicalKeyboardKey.pageUp);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(_hostValue<Object?>(tester), DateTime(2026, 11, 30));
    });

    testWidgets('a range takes two picks in any order', (tester) async {
      await pumpCalendar(tester, range: true);
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(_hostValue<Object?>(tester), isNull);
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(
        _hostValue<Object?>(tester),
        DateTimeRange(start: DateTime(2026, 3, 5), end: DateTime(2026, 3, 20)),
      );
    });

    testWidgets('shows ISO week numbers', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCalendar(tester, weeks: true);
      expect(find.text('Wk'), findsOneWidget);
      // March 2026 in weeks starting on Sunday: each row takes the ISO
      // week of its Wednesday, from March 4 (week 10) to April 1 (week 14).
      for (var week = 10; week <= 14; week++) {
        expect(find.bySemanticsLabel(RegExp('Week $week\\b')), findsOneWidget);
      }
      expect(find.bySemanticsLabel(RegExp(r'Week 9\b')), findsNothing);
      expect(find.bySemanticsLabel(RegExp(r'Week 15\b')), findsNothing);
      handle.dispose();
    });

    testWidgets('days carry their full date', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCalendar(tester);
      expect(find.bySemanticsLabel('Tuesday, March 10, 2026'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Oito2DatePicker', () {
    testWidgets('opens a calendar and shows the picked date', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 260,
            child: _Host<DateTime?>(
              initial: DateTime(2026, 3, 1),
              builder: (value, set) => Oito2DatePicker(
                firstDate: DateTime(2026),
                lastDate: DateTime(2026, 12, 31),
                value: value,
                onChanged: set,
              ),
            ),
          ),
        ),
      );
      expect(find.text('03/01/2026'), findsOneWidget);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('18'));
      await tester.pumpAndSettle();
      expect(find.byType(Oito2Calendar), findsNothing);
      expect(find.text('03/18/2026'), findsOneWidget);
    });

    testWidgets('a range picker shows both ends', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 320,
            child: _Host<DateTimeRange?>(
              // A range in March 2026 opens the calendar on that month.
              initial: DateTimeRange(
                start: DateTime(2026, 3, 2),
                end: DateTime(2026, 3, 4),
              ),
              builder: (value, set) => Oito2DatePicker(
                firstDate: DateTime(2026),
                lastDate: DateTime(2026, 12, 31),
                range: value,
                onRangeChanged: set,
              ),
            ),
          ),
        ),
      );
      expect(find.text('03/02/2026 – 03/04/2026'), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(Oito2Calendar), findsOneWidget);
      await tester.tap(find.text('16'));
      await tester.pump();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(
        _hostValue<DateTimeRange?>(tester),
        DateTimeRange(start: DateTime(2026, 3, 16), end: DateTime(2026, 3, 20)),
      );
      expect(find.byType(Oito2Calendar), findsNothing);
      expect(find.text('03/16/2026 – 03/20/2026'), findsOneWidget);
    });
  });
}
