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

/// Commands in three groups, one disabled and one without a shortcut.
List<Oito2Command> sampleCommands({VoidCallback? onHelp}) => [
  Oito2Command(
    id: 'settings',
    label: 'Open settings',
    shortcut: Oito2Shortcut.parse('Mod+,'),
    onInvoke: () {},
  ),
  Oito2Command(
    id: 'theme',
    label: 'Switch style',
    group: 'Appearance',
    description: 'Light, dark or system',
    shortcut: Oito2Shortcut.parse('Mod+Shift+L'),
    onInvoke: () {},
  ),
  Oito2Command(
    id: 'home',
    label: 'Go to the first page',
    group: 'Pages',
    shortcut: Oito2Shortcut.parse('G H'),
    onInvoke: () {},
  ),
  Oito2Command(
    id: 'contrast',
    label: 'Toggle high contrast',
    group: 'Appearance',
    onInvoke: () {},
  ),
  Oito2Command(
    id: 'menu',
    label: 'Ação do menu',
    group: 'Appearance',
    shortcut: Oito2Shortcut.parse('Alt+M'),
    enabled: false,
    onInvoke: () {},
  ),
  if (onHelp != null)
    Oito2Command.shortcutsHelp(label: 'Keyboard shortcuts', onInvoke: onHelp),
];

/// Pumps a scope of [sampleCommands] with a button that opens the help,
/// on a [size] view, and opens it.
Future<void> openHelp(
  WidgetTester tester, {
  Size size = const Size(1000, 800),
  ThemeData? theme,
}) async {
  await pumpOito2(
    tester,
    Oito2Commands(
      commands: sampleCommands(),
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => showOito2ShortcutsHelp(context),
          child: const Text('Help'),
        ),
      ),
    ),
    size: size,
    theme: theme,
  );
  await tester.tap(find.text('Help'));
  await tester.pumpAndSettle();
}

/// The labels of the rows shown, in reading order.
List<String> rowLabels(WidgetTester tester) => [
  for (final element
      in find
          .descendant(
            of: find.byType(Oito2ShortcutsHelpView),
            matching: find.byType(Oito2HighlightedText),
          )
          .evaluate())
    (element.widget as Oito2HighlightedText).text,
];

void main() {
  group('showOito2ShortcutsHelp', () {
    testWidgets('groups the commands with shortcuts in first-seen order', (
      tester,
    ) async {
      await openHelp(tester);
      expect(find.text('Keyboard shortcuts'), findsOneWidget);
      expect(find.text('Search shortcuts'), findsOneWidget);
      expect(rowLabels(tester), [
        'Open settings',
        'Switch style',
        'Light, dark or system',
        'Ação do menu',
        'Go to the first page',
      ]);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Pages'), findsOneWidget);
      expect(find.text('Toggle high contrast'), findsNothing);
      final general = tester.getTopLeft(find.text('General'));
      final pages = tester.getTopLeft(find.text('Pages'));
      expect(pages.dx, greaterThan(general.dx), reason: 'two columns');
    });

    testWidgets('shows one column on a narrow screen', (tester) async {
      await openHelp(tester, size: const Size(400, 800));
      final general = tester.getTopLeft(find.text('General'));
      final pages = tester.getTopLeft(find.text('Pages'));
      expect(pages.dx, general.dx);
      expect(pages.dy, greaterThan(general.dy));
    });

    testWidgets('rows are at least a touch target tall', (tester) async {
      await openHelp(tester);
      final row = find.ancestor(
        of: find.text('Open settings'),
        matching: find.byType(ConstrainedBox),
      );
      expect(
        tester.getSize(row.first).height,
        greaterThanOrEqualTo(Oito2Sizes.minTouchTarget),
      );
    });

    testWidgets('filters by label, description and key names, folding '
        'accents, and highlights the matches', (tester) async {
      await openHelp(tester);
      await tester.enterText(find.byType(TextField), 'acao');
      await tester.pump();
      expect(rowLabels(tester), ['Ação do menu']);
      expect(Oito2HighlightedText.matches('Ação do menu', 'acao'), [
        const TextRange(start: 0, end: 4),
      ]);
      final rich = tester.widget<RichText>(
        find.descendant(
          of: find.byType(Oito2HighlightedText),
          matching: find.byType(RichText),
        ),
      );
      final spans = (rich.text as TextSpan).children!.first as TextSpan;
      expect(spans.children!.first.toPlainText(), 'Ação');
      expect(
        (spans.children!.first as TextSpan).style?.fontWeight,
        FontWeight.w700,
      );

      await tester.enterText(find.byType(TextField), 'system');
      await tester.pump();
      expect(rowLabels(tester), ['Switch style', 'Light, dark or system']);

      await tester.enterText(find.byType(TextField), 'shift ctrl');
      await tester.pump();
      expect(rowLabels(tester), ['Switch style', 'Light, dark or system']);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(rowLabels(tester), isEmpty);
      expect(find.text('No shortcuts found'), findsOneWidget);
    });

    testWidgets('reads each row as its label and shortcut, disabled rows as '
        'disabled', (tester) async {
      final semantics = tester.ensureSemantics();
      await openHelp(tester);
      expect(
        find.bySemanticsLabel('Open settings, shortcut Ctrl+,'),
        findsOneWidget,
      );
      final disabled = tester.getSemantics(
        find.bySemanticsLabel('Ação do menu, shortcut Alt+M'),
      );
      expect(
        disabled,
        isSemantics(
          label: 'Ação do menu, shortcut Alt+M',
          hasEnabledState: true,
          isEnabled: false,
          isFocusable: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Switch style, shortcut Ctrl+Shift+L'),
        ),
        isSemantics(
          hint: 'Light, dark or system',
          hasEnabledState: false,
          isFocusable: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('dims disabled commands', (tester) async {
      await openHelp(tester);
      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('Ação do menu'),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('arrow keys move from the search through the rows', (
      tester,
    ) async {
      await openHelp(tester);
      bool focused(String label) {
        final focus = FocusManager.instance.primaryFocus;
        final context = focus?.context;
        if (context == null) return false;
        return find
            .descendant(
              of: find.byElementPredicate((e) => e == context),
              matching: find.text(label),
            )
            .evaluate()
            .isNotEmpty;
      }

      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'Shortcuts help search',
        reason: 'the search has the focus first',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused('Open settings'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused('Switch style'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused('Ação do menu'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focused('Open settings'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'Shortcuts help search',
      );
    });

    testWidgets('Escape on a row closes the dialog', (tester) async {
      await openHelp(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Oito2ShortcutsHelpView), findsNothing);
    });

    testWidgets('Escape clears the search, then closes the dialog', (
      tester,
    ) async {
      await openHelp(tester);
      await tester.enterText(find.byType(TextField), 'style');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Oito2ShortcutsHelpView), findsOneWidget);
      expect(rowLabels(tester), hasLength(5));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Oito2ShortcutsHelpView), findsNothing);
    });

    testWidgets('the close button closes the dialog', (tester) async {
      await openHelp(tester);
      await tester.tap(find.byType(Oito2CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(Oito2ShortcutsHelpView), findsNothing);
    });

    testWidgets('uses the given commands and title', (tester) async {
      await pumpOito2(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showOito2ShortcutsHelp(
              context,
              title: 'Editor keys',
              commands: [
                Oito2Command(
                  id: 'save',
                  label: 'Save',
                  shortcut: Oito2Shortcut.parse('Mod+S'),
                  onInvoke: () {},
                ),
              ],
            ),
            child: const Text('Help'),
          ),
        ),
      );
      await tester.tap(find.text('Help'));
      await tester.pumpAndSettle();
      expect(find.text('Editor keys'), findsOneWidget);
      expect(rowLabels(tester), ['Save']);
    });

    testWidgets('shows the Apple notation on macOS', (tester) async {
      final semantics = tester.ensureSemantics();
      await openHelp(
        tester,
        theme: Oito2Theme.fromColors(
          Oito2ColorTheme.light(),
          platform: const Oito2Platform(
            targetPlatform: TargetPlatform.macOS,
            isWeb: false,
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Switch style, shortcut ⇧⌘L'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), '⌘');
      await tester.pump();
      expect(rowLabels(tester), [
        'Open settings',
        'Switch style',
        'Light, dark or system',
      ]);
      semantics.dispose();
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await openHelp(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('meets the touch target guideline on touch platforms', (
      tester,
    ) async {
      await openHelp(
        tester,
        size: const Size(400, 800),
        theme: Oito2Theme.fromColors(
          Oito2ColorTheme.dark(),
          platform: const Oito2Platform(
            targetPlatform: TargetPlatform.android,
            isWeb: false,
          ),
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('localizes the strings in Brazilian Portuguese', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt', 'BR'),
          supportedLocales: Oito2Localizations.supportedLocales,
          localizationsDelegates: const [
            Oito2Localizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(
            body: Oito2ShortcutsHelpView(commands: sampleCommands()),
          ),
        ),
      );
      expect(find.text('Buscar atalhos'), findsOneWidget);
      expect(find.text('Geral'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Open settings, atalho Ctrl+,'),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });

  group('Oito2ShortcutsHelpView', () {
    testWidgets('lists the commands of the scope, disabled included', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Oito2Commands(
          commands: sampleCommands(),
          child: const SingleChildScrollView(child: Oito2ShortcutsHelpView()),
        ),
      );
      expect(rowLabels(tester), contains('Ação do menu'));
      expect(rowLabels(tester), hasLength(5));
    });
  });

  group('Oito2Command.shortcutsHelp', () {
    /// Pumps a scope with the help command (when [bound]) and a text
    /// field, and returns the number of times the command ran.
    Future<List<int>> pumpBound(
      WidgetTester tester, {
      bool bound = true,
    }) async {
      final runs = <int>[0];
      await pumpOito2(
        tester,
        Oito2Commands(
          commands: [
            if (bound)
              Oito2Command.shortcutsHelp(
                label: 'Keyboard shortcuts',
                onInvoke: () => runs[0]++,
              ),
          ],
          child: const Focus(autofocus: true, child: TextField()),
        ),
      );
      await tester.pump();
      return runs;
    }

    Future<void> pressCtrlQuestion(WidgetTester tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    }

    testWidgets('runs on F1 and Ctrl+Shift+/', (tester) async {
      final runs = await pumpBound(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      expect(runs.single, 1);
      await pressCtrlQuestion(tester);
      expect(runs.single, 2);
    });

    testWidgets('F1 runs while a text field has focus', (tester) async {
      final runs = await pumpBound(tester);
      await tester.showKeyboard(find.byType(TextField));
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      expect(runs.single, 1);
    });

    testWidgets('nothing runs when the command is not bound', (tester) async {
      final runs = await pumpBound(tester, bound: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await pressCtrlQuestion(tester);
      expect(runs.single, 0);
    });

    testWidgets('opens the help from a scope', (tester) async {
      late BuildContext scopeContext;
      await pumpOito2(
        tester,
        Oito2Commands(
          commands: sampleCommands(
            onHelp: () => showOito2ShortcutsHelp(scopeContext),
          ),
          child: Builder(
            builder: (context) {
              scopeContext = context;
              return const Focus(autofocus: true, child: SizedBox());
            },
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pumpAndSettle();
      expect(find.byType(Oito2ShortcutsHelpView), findsOneWidget);
      expect(rowLabels(tester), contains('Keyboard shortcuts'));
      expect(find.byType(Oito2ShortcutLabel), findsNWidgets(6));
    });

    testWidgets('F1 with the help open from above the Navigator opens no '
        'second help', (tester) async {
      var runs = 0;
      late BuildContext navigatorContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: Oito2Theme.light(),
          builder: (context, child) => Oito2Commands(
            commands: [
              Oito2Command.shortcutsHelp(
                label: 'Keyboard shortcuts',
                onInvoke: () {
                  runs++;
                  showOito2ShortcutsHelp(navigatorContext);
                },
              ),
            ],
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              navigatorContext = context;
              return const Focus(autofocus: true, child: SizedBox());
            },
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pumpAndSettle();
      expect(runs, 2);
      expect(find.byType(Oito2ShortcutsHelpView), findsOneWidget);
      await tester.tap(find.byType(Oito2CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(Oito2ShortcutsHelpView), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pumpAndSettle();
      expect(find.byType(Oito2ShortcutsHelpView), findsOneWidget);
    });

    test('lists both shortcuts and labels them per platform', () {
      final command = Oito2Command.shortcutsHelp(
        label: 'Keyboard shortcuts',
        onInvoke: () {},
      );
      expect(command.id, Oito2Command.shortcutsHelpId);
      expect(
        [for (final s in command.shortcuts) s.label(TargetPlatform.linux)],
        ['F1', 'Ctrl+Shift+/'],
      );
      expect(
        [for (final s in command.shortcuts) s.label(TargetPlatform.macOS)],
        ['F1', '⇧⌘/'],
      );
    });

    test('alternate shortcuts count as conflicts', () {
      final help = Oito2Command.shortcutsHelp(label: 'Help', onInvoke: () {});
      final other = Oito2Command(
        id: 'comment',
        label: 'Comment',
        shortcut: Oito2Shortcut.parse('Ctrl+Shift+/'),
        onInvoke: () {},
      );
      expect(
        Oito2Commands.conflicts([help, other], platform: TargetPlatform.linux),
        hasLength(1),
      );
    });
  });

  testWidgets('availableAt includes disabled commands on request', (
    tester,
  ) async {
    late BuildContext inner;
    await pumpOito2(
      tester,
      Oito2Commands(
        commands: [
          Oito2Command(id: 'a', label: 'Outer A', onInvoke: () {}),
          Oito2Command(id: 'b', label: 'Outer B', onInvoke: () {}),
        ],
        child: Oito2Commands(
          commands: [
            Oito2Command(
              id: 'a',
              label: 'Inner A',
              enabled: false,
              onInvoke: () {},
            ),
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
    List<String> labels(List<Oito2Command> commands) => [
      for (final c in commands) c.label,
    ];
    expect(labels(Oito2Commands.availableAt(inner)), ['Outer A', 'Outer B']);
    expect(labels(Oito2Commands.availableAt(inner, includeDisabled: true)), [
      'Inner A',
      'Outer B',
    ]);
  });
}
