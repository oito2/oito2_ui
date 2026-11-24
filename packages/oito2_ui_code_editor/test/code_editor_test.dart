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
import 'package:oito2_ui_code_editor/oito2_ui_code_editor.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

// The editor reads the platform once to choose between its desktop and
// mobile input paths, so every test runs as Linux.
final _linux = TargetPlatformVariant.only(TargetPlatform.linux);

Future<void> _pump(WidgetTester tester, Widget editor) async {
  await pumpOito2(tester, Center(child: SizedBox(width: 400, child: editor)));
  await tester.pump();
}

/// Focuses the editor by tapping it.
Future<void> _focus(WidgetTester tester) async {
  await tester.tap(find.byType(Oito2CodeEditor));
  // The editor requests the focus in a zero-delay timer after the press.
  await tester.pump(const Duration(milliseconds: 1));
}

/// Sends [text] to the focused editor as the platform text input would,
/// inserted at the caret of the line the input currently holds.
Future<void> _type(WidgetTester tester, String text) async {
  final client = tester.testTextInput.log
      .lastWhere((call) => call.method == 'TextInput.setClient')
      .arguments[0];
  final state = tester.testTextInput.editingState!;
  final old = state['text'] as String;
  final at = state['selectionBase'] as int;
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.textInput.name,
    SystemChannels.textInput.codec.encodeMethodCall(
      MethodCall('TextInputClient.updateEditingStateWithDeltas', [
        client,
        {
          'deltas': [
            {
              'oldText': old,
              'deltaText': text,
              'deltaStart': at,
              'deltaEnd': at,
              'selectionBase': at + text.length,
              'selectionExtent': at + text.length,
              'selectionAffinity': 'TextAffinity.downstream',
              'selectionIsDirectional': false,
              'composingBase': -1,
              'composingExtent': -1,
            },
          ],
        },
      ]),
    ),
    (_) {},
  );
  await tester.pump();
}

/// Lets the editor's short input timers run, then disposes it so its caret
/// timer stops.
Future<void> _dispose(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

Finder _painterNamed(String name) => find.byWidgetPredicate(
  (widget) =>
      widget is CustomPaint && widget.painter.runtimeType.toString() == name,
);

void main() {
  testWidgets('typing calls onChanged with the whole text', (tester) async {
    final controller = CodeLineEditingController.fromText('a\nb');
    addTearDown(controller.dispose);
    final changes = <String>[];
    await _pump(
      tester,
      Oito2CodeEditor(
        controller: controller,
        minLines: 3,
        onChanged: changes.add,
      ),
    );
    await _focus(tester);
    controller.selection = const CodeLineSelection.collapsed(
      index: 1,
      offset: 1,
    );
    await tester.pump();
    expect(changes, isEmpty, reason: 'selection changes are not reported');
    await _type(tester, 'x');
    expect(controller.text, 'a\nbx');
    expect(changes, ['a\nbx']);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(changes.last, 'a\nbx\n');
    await _dispose(tester);
  }, variant: _linux);

  testWidgets('readOnly blocks edits', (tester) async {
    final controller = CodeLineEditingController.fromText('a\nb');
    addTearDown(controller.dispose);
    final changes = <String>[];
    await _pump(
      tester,
      Oito2CodeEditor(
        controller: controller,
        readOnly: true,
        minLines: 3,
        onChanged: changes.add,
      ),
    );
    await _focus(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(controller.text, 'a\nb');
    expect(changes, isEmpty);
    final semantics = tester.getSemantics(find.byType(Oito2CodeEditor));
    expect(semantics.flagsCollection.isReadOnly, isTrue);
    await _dispose(tester);
  }, variant: _linux);

  testWidgets('markers show their message as tooltip and semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = CodeLineEditingController.fromText('a\nb\nc');
    addTearDown(controller.dispose);
    await _pump(
      tester,
      Oito2CodeEditor(
        controller: controller,
        minLines: 3,
        lineMarkers: const {
          2: Oito2LineMarker.error('Unexpected token'),
          3: Oito2LineMarker.warning('Unused rule'),
        },
      ),
    );
    expect(find.byTooltip('Unexpected token'), findsOneWidget);
    expect(find.byTooltip('Unused rule'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Line 2, Error: Unexpected token'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Line 3, Warning: Unused rule'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Code editor'), findsOneWidget);

    // The marker sits beside its line.
    final markerTop = tester.getTopLeft(find.byTooltip('Unexpected token')).dy;
    final editorTop = tester.getTopLeft(find.byType(Oito2CodeEditor)).dy;
    final lineHeight =
        (tester.getSize(find.byType(Oito2CodeEditor)).height -
            2 * Oito2Spacing.sm) /
        3;
    expect(
      markerTop - editorTop,
      moreOrLessEquals(Oito2Spacing.sm + lineHeight, epsilon: 0.5),
    );

    await tester.longPress(find.byTooltip('Unexpected token'));
    await tester.pumpAndSettle();
    expect(find.text('Unexpected token'), findsOneWidget);
    handle.dispose();
    await _dispose(tester);
  }, variant: _linux);

  testWidgets('highlighted lines paint a tint and a bar', (tester) async {
    final controller = CodeLineEditingController.fromText('a\nb\nc');
    addTearDown(controller.dispose);
    await _pump(
      tester,
      Oito2CodeEditor(
        controller: controller,
        minLines: 3,
        highlightedLines: const {2},
      ),
    );
    final scheme = Theme.of(tester.element(find.byType(Oito2CodeEditor)))
        .colorScheme;
    final painter = _painterNamed('_ParagraphHighlightPainter');
    expect(painter, findsOneWidget);
    expect(
      tester.renderObject(painter),
      paints
        ..rect(color: scheme.primary.withValues(alpha: 0.14))
        ..rect(),
    );
    await _dispose(tester);
  }, variant: _linux);

  testWidgets('grows with its lines between minLines and maxLines', (
    tester,
  ) async {
    final controller = CodeLineEditingController.fromText('a');
    addTearDown(controller.dispose);
    await _pump(
      tester,
      Oito2CodeEditor(controller: controller, minLines: 2, maxLines: 4),
    );
    final two = tester.getSize(find.byType(Oito2CodeEditor)).height;
    controller.text = 'a\nb\nc';
    await tester.pump();
    final three = tester.getSize(find.byType(Oito2CodeEditor)).height;
    controller.text = 'a\nb\nc\nd\ne\nf';
    await tester.pump();
    final four = tester.getSize(find.byType(Oito2CodeEditor)).height;
    final line = three - two;
    expect(line, greaterThan(10));
    expect(four - three, moreOrLessEquals(line));
    await _dispose(tester);
  }, variant: _linux);

  testWidgets('find and save shortcuts reach the widgets around it', (
    tester,
  ) async {
    final controller = CodeLineEditingController.fromText('a');
    addTearDown(controller.dispose);
    final pressed = <String>[];
    await _pump(
      tester,
      CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
              pressed.add('find'),
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
              pressed.add('save'),
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              pressed.add('palette'),
        },
        child: Oito2CodeEditor(controller: controller, minLines: 2),
      ),
    );
    await _focus(tester);
    for (final key in [
      LogicalKeyboardKey.keyF,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyK,
    ]) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(key);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    }
    expect(pressed, ['find', 'save', 'palette']);
    await _dispose(tester);
  }, variant: _linux);

  testWidgets('Tab indents and Ctrl+Tab moves the focus out', (tester) async {
    final controller = CodeLineEditingController.fromText('a');
    addTearDown(controller.dispose);
    final next = FocusNode();
    addTearDown(next.dispose);
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Oito2CodeEditor(controller: controller, minLines: 2),
          Focus(focusNode: next, child: const SizedBox(height: 10)),
        ],
      ),
    );
    await _focus(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    // The caret is at the end, so Tab pads it to the next indent stop.
    expect(controller.text, 'a ');
    expect(next.hasFocus, isFalse);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(next.hasFocus, isTrue);
    await _dispose(tester);
  }, variant: _linux);

  testWidgets('shows a focus border while focused', (tester) async {
    final controller = CodeLineEditingController.fromText('a');
    addTearDown(controller.dispose);
    await _pump(tester, Oito2CodeEditor(controller: controller, minLines: 2));
    BoxBorder? border() =>
        (tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(Oito2CodeEditor),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration)
            .border;
    expect((border()! as Border).top.width, 1);
    await _focus(tester);
    expect((border()! as Border).top.width, Oito2Sizes.focusBorderWidth);
    await _dispose(tester);
  }, variant: _linux);
}
