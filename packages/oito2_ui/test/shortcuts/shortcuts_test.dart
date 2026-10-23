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
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

void main() {
  group('Oito2Shortcut', () {
    test('parses chords, modifiers and sequences', () {
      final palette = Oito2Shortcut.parse('Mod+Shift+P');
      expect(palette.chords.single.key, LogicalKeyboardKey.keyP);
      expect(palette.chords.single.primary, isTrue);
      expect(palette.chords.single.shift, isTrue);
      final goHome = Oito2Shortcut.parse('G H');
      expect(goHome.chords.map((c) => c.key), [
        LogicalKeyboardKey.keyG,
        LogicalKeyboardKey.keyH,
      ]);
      expect(
        Oito2Shortcut.parse('F5').chords.single.key,
        LogicalKeyboardKey.f5,
      );
      expect(
        Oito2Shortcut.parse('Ctrl+,').chords.single.key,
        LogicalKeyboardKey.comma,
      );
      expect(() => Oito2Shortcut.parse('Hyper+K'), throwsFormatException);
      expect(() => Oito2Shortcut.parse('Ctrl+Pause'), throwsFormatException);
    });

    test('resolves the primary modifier per platform', () {
      final shortcut = Oito2Shortcut.parse('Mod+K');
      expect(
        shortcut.matches(Oito2Shortcut.parse('Ctrl+K'), TargetPlatform.linux),
        isTrue,
      );
      expect(
        shortcut.matches(Oito2Shortcut.parse('Cmd+K'), TargetPlatform.macOS),
        isTrue,
      );
      expect(
        shortcut.matches(Oito2Shortcut.parse('Ctrl+K'), TargetPlatform.macOS),
        isFalse,
      );
    });

    test('labels follow the platform notation', () {
      final shortcut = Oito2Shortcut.parse('Mod+Shift+K');
      expect(shortcut.label(TargetPlatform.linux), 'Ctrl+Shift+K');
      expect(shortcut.label(TargetPlatform.windows), 'Ctrl+Shift+K');
      expect(shortcut.label(TargetPlatform.macOS), '⇧⌘K');
      expect(Oito2Shortcut.parse('G H').label(TargetPlatform.linux), 'G H');
      expect(
        Oito2Shortcut.parse('Alt+Enter').label(TargetPlatform.macOS),
        '⌥↩',
      );
    });
  });

  group('Oito2Commands', () {
    Future<List<String>> pumpCommands(
      WidgetTester tester, {
      Widget? child,
    }) async {
      final runs = <String>[];
      await pumpOito2(
        tester,
        Oito2Commands(
          commands: [
            Oito2Command(
              id: 'palette',
              label: 'Open the command palette',
              shortcut: Oito2Shortcut.parse('Mod+K'),
              onInvoke: () => runs.add('palette'),
            ),
            Oito2Command(
              id: 'home',
              label: 'Go home',
              shortcut: Oito2Shortcut.parse('G H'),
              onInvoke: () => runs.add('home'),
            ),
            Oito2Command(
              id: 'off',
              label: 'Disabled',
              shortcut: Oito2Shortcut.parse('Mod+D'),
              enabled: false,
              onInvoke: () => runs.add('off'),
            ),
          ],
          child: child ?? const Focus(autofocus: true, child: SizedBox()),
        ),
      );
      await tester.pump();
      return runs;
    }

    testWidgets('runs a command from its shortcut', (tester) async {
      final runs = await pumpCommands(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(runs, ['palette']);
    });

    testWidgets('the primary modifier follows the theme platform', (
      tester,
    ) async {
      final runs = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: Oito2Commands(
            commands: [
              Oito2Command(
                id: 'palette',
                label: 'Open the command palette',
                shortcut: Oito2Shortcut.parse('Mod+K'),
                onInvoke: () => runs.add('palette'),
              ),
            ],
            child: const Focus(autofocus: true, child: SizedBox()),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(runs, isEmpty);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      expect(runs, ['palette']);
    });

    testWidgets('clashing commands given on a rebuild are reported', (
      tester,
    ) async {
      Widget build(List<Oito2Command> commands) =>
          Oito2Commands(commands: commands, child: const SizedBox());
      Oito2Command command(String id) => Oito2Command(
        id: id,
        label: id,
        shortcut: Oito2Shortcut.parse('Mod+K'),
        onInvoke: () {},
      );
      await pumpOito2(tester, build([command('a')]));
      await pumpOito2(tester, build([command('a'), command('b')]));
      expect(tester.takeException(), isFlutterError);
    });

    testWidgets('runs a sequence pressed in time', (tester) async {
      final runs = await pumpCommands(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
      expect(runs, ['home']);
    });

    testWidgets('drops a sequence after the timeout', (tester) async {
      final runs = await pumpCommands(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pump(const Duration(seconds: 2));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
      expect(runs, isEmpty);
    });

    testWidgets('plain-key shortcuts skip text fields', (tester) async {
      final runs = await pumpCommands(
        tester,
        child: const TextField(autofocus: true),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(runs, ['palette']);
    });

    testWidgets('inner scopes override outer commands by id', (tester) async {
      late BuildContext inner;
      await pumpOito2(
        tester,
        Oito2Commands(
          commands: [
            Oito2Command(id: 'save', label: 'Save all', onInvoke: () {}),
            Oito2Command(id: 'quit', label: 'Quit', onInvoke: () {}),
          ],
          child: Oito2Commands(
            commands: [
              Oito2Command(id: 'save', label: 'Save file', onInvoke: () {}),
            ],
            child: Builder(
              builder: (context) {
                inner = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(
        [for (final c in Oito2Commands.availableAt(inner)) c.label],
        ['Save file', 'Quit'],
      );
    });

    testWidgets('an inner command hides the outer shortcut of its id', (
      tester,
    ) async {
      final runs = <String>[];
      await pumpOito2(
        tester,
        Oito2Commands(
          commands: [
            Oito2Command(
              id: 'save',
              label: 'Save all',
              shortcut: Oito2Shortcut.parse('Ctrl+Shift+S'),
              onInvoke: () => runs.add('outer'),
            ),
          ],
          child: Oito2Commands(
            commands: [
              Oito2Command(
                id: 'save',
                label: 'Save file',
                shortcut: Oito2Shortcut.parse('Ctrl+S'),
                enabled: false,
                onInvoke: () => runs.add('inner'),
              ),
            ],
            child: const Focus(autofocus: true, child: SizedBox()),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(runs, isEmpty);
    });

    testWidgets('an inner scope that is not rebuilt sees the outer update', (
      tester,
    ) async {
      final runs = <String>[];
      late BuildContext innerContext;
      var version = 1;
      late StateSetter setVersion;
      // The same inner widget instance, so the outer rebuild skips it.
      final inner = Oito2Commands(
        commands: [Oito2Command(id: 'inner', label: 'Inner', onInvoke: () {})],
        child: Builder(
          builder: (context) {
            innerContext = context;
            return const Focus(autofocus: true, child: SizedBox());
          },
        ),
      );
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setVersion = setState;
            final current = version;
            return Oito2Commands(
              commands: [
                Oito2Command(
                  id: 'save',
                  label: 'Save v$current',
                  shortcut: Oito2Shortcut.parse('Ctrl+S'),
                  onInvoke: () => runs.add('v$current'),
                ),
              ],
              child: inner,
            );
          },
        ),
      );
      setVersion(() => version = 2);
      await tester.pump();
      expect(
        [for (final c in Oito2Commands.availableAt(innerContext)) c.label],
        ['Inner', 'Save v2'],
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(runs, ['v2']);
    });

    test('reports clashing and prefix shortcuts', () {
      void noop() {}
      final commands = [
        Oito2Command(
          id: 'a',
          label: 'A',
          shortcut: Oito2Shortcut.parse('G'),
          onInvoke: noop,
        ),
        Oito2Command(
          id: 'b',
          label: 'B',
          shortcut: Oito2Shortcut.parse('G H'),
          onInvoke: noop,
        ),
        Oito2Command(
          id: 'c',
          label: 'C',
          shortcut: Oito2Shortcut.parse('Ctrl+K'),
          onInvoke: noop,
        ),
        Oito2Command(
          id: 'd',
          label: 'D',
          shortcut: Oito2Shortcut.parse('Mod+K'),
          onInvoke: noop,
        ),
      ];
      final clashes = Oito2Commands.conflicts(
        commands,
        platform: TargetPlatform.linux,
      );
      expect([for (final (a, b) in clashes) '${a.id}${b.id}'], ['ab', 'cd']);
      expect(
        Oito2Commands.conflicts(commands, platform: TargetPlatform.macOS),
        hasLength(1),
      );
    });
  });

  group('Oito2ShortcutLabel', () {
    testWidgets('shows key caps and reads as text', (tester) async {
      await pumpOito2(
        tester,
        Center(child: Oito2ShortcutLabel(Oito2Shortcut.parse('Mod+Shift+K'))),
      );
      expect(find.text('Ctrl'), findsOneWidget);
      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('K'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(Oito2ShortcutLabel)),
        isSemantics(label: 'Ctrl+Shift+K'),
      );
    });
  });

  group('Oito2ShortcutRecorder', () {
    Future<List<Oito2Shortcut?>> pumpRecorder(
      WidgetTester tester, {
      Oito2Shortcut? value,
    }) async {
      final changes = <Oito2Shortcut?>[];
      await pumpOito2(
        tester,
        Center(
          child: Oito2ShortcutRecorder(value: value, onChanged: changes.add),
        ),
      );
      return changes;
    }

    testWidgets('records the next chord with the primary modifier', (
      tester,
    ) async {
      final changes = await pumpRecorder(tester);
      expect(find.text('No shortcut'), findsOneWidget);
      await tester.tap(find.text('No shortcut'));
      await tester.pump();
      expect(find.text('Press a shortcut'), findsOneWidget);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(changes, [Oito2Shortcut.parse('Mod+J')]);
    });

    testWidgets('Escape cancels and Backspace clears', (tester) async {
      final changes = await pumpRecorder(
        tester,
        value: Oito2Shortcut.parse('Mod+J'),
      );
      await tester.tap(find.byType(Oito2ShortcutLabel));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(changes, isEmpty);
      expect(find.byType(Oito2ShortcutLabel), findsOneWidget);
      await tester.tap(find.byType(Oito2ShortcutLabel));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      expect(changes, [null]);
    });

    testWidgets('the clear button clears the shortcut', (tester) async {
      final changes = await pumpRecorder(
        tester,
        value: Oito2Shortcut.parse('Mod+J'),
      );
      await tester.tap(find.byTooltip('Clear shortcut'));
      expect(changes, [null]);
    });
  });

  group('command palette', () {
    Future<List<String>> openPalette(WidgetTester tester) async {
      final runs = <String>[];
      await pumpOito2(
        tester,
        Oito2Commands(
          commands: [
            Oito2Command(
              id: 'theme',
              label: 'Toggle dark style',
              group: 'View',
              shortcut: Oito2Shortcut.parse('Mod+Shift+L'),
              onInvoke: () => runs.add('theme'),
            ),
            Oito2Command(
              id: 'settings',
              label: 'Open settings',
              keywords: const ['preferences'],
              onInvoke: () => runs.add('settings'),
            ),
            Oito2Command(
              id: 'search',
              label: 'Search pages',
              onInvoke: () => runs.add('search'),
            ),
          ],
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showOito2CommandPalette(context),
              child: const Text('Commands'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Commands'));
      await tester.pumpAndSettle();
      return runs;
    }

    testWidgets('lists the commands with their shortcuts', (tester) async {
      await openPalette(tester);
      expect(find.text('Type a command'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(Oito2ShortcutLabel), findsOneWidget);
    });

    testWidgets('filters by label and keywords and runs with Enter', (
      tester,
    ) async {
      final runs = await openPalette(tester);
      await tester.enterText(find.byType(TextField), 'prefer');
      await tester.pump();
      expect(find.byType(ListTile), findsOneWidget);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(runs, ['settings']);
      expect(find.text('Type a command'), findsNothing);
    });

    testWidgets('arrow keys move the highlight', (tester) async {
      final runs = await openPalette(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(runs, ['search']);
    });

    testWidgets('keeps the declaration order among equal matches', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showOito2CommandPalette(
              context,
              commands: [
                for (var i = 0; i < 60; i++)
                  Oito2Command(
                    id: 'c$i',
                    label: 'Command ${i.toString().padLeft(2, '0')}',
                    onInvoke: () {},
                  ),
              ],
            ),
            child: const Text('Commands'),
          ),
        ),
      );
      await tester.tap(find.text('Commands'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'mand');
      await tester.pump();
      final shown = [
        for (final tile in tester.widgetList<ListTile>(find.byType(ListTile)))
          ((tile.title! as Oito2HighlightedText).text),
      ];
      expect(shown, [...shown]..sort());
    });

    testWidgets('keeps the highlighted command in view', (tester) async {
      await pumpOito2(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showOito2CommandPalette(
              context,
              commands: [
                for (var i = 0; i < 30; i++)
                  Oito2Command(id: 'c$i', label: 'Command $i', onInvoke: () {}),
              ],
            ),
            child: const Text('Commands'),
          ),
        ),
      );
      await tester.tap(find.text('Commands'));
      await tester.pumpAndSettle();
      final list = tester.getRect(find.byType(ListView));
      bool shown(String label) {
        final finder = find.text(label);
        if (finder.evaluate().isEmpty) return false;
        final rect = tester.getRect(finder);
        return rect.top >= list.top && rect.bottom <= list.bottom;
      }

      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.pump();
      }
      expect(shown('Command 12'), isTrue);
      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        await tester.pump();
      }
      expect(shown('Command 0'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.pump();
      expect(shown('Command 29'), isTrue);
    });

    testWidgets('shows a message when nothing matches', (tester) async {
      await openPalette(tester);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(find.text('No commands found'), findsOneWidget);
    });
  });
}
