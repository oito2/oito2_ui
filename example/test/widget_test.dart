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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_example/main.dart';

void main() {
  final settings = Oito2SystemSettings.fallback(
    const Oito2Platform(targetPlatform: TargetPlatform.linux, isWeb: false),
    desktopEnvironment: Oito2DesktopEnvironment.kde,
  );

  Future<void> pumpShowcase(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ShowcaseApp(settings: settings));
  }

  testWidgets('foundation page shows the system settings', (tester) async {
    await pumpShowcase(tester);

    expect(find.text('oito2_ui · Foundation'), findsOneWidget);
    expect(find.text('kde'), findsOneWidget);
    expect(find.text('breeze'), findsOneWidget);
  });

  testWidgets('navigates to the tokens and typography pages', (tester) async {
    await pumpShowcase(tester);

    await tester.tap(find.text('Tokens'));
    await tester.pumpAndSettle();
    expect(find.text('oito2_ui · Tokens'), findsOneWidget);
    expect(find.text('Accents'), findsOneWidget);

    await tester.tap(find.text('Typography'));
    await tester.pumpAndSettle();
    expect(find.text('oito2_ui · Typography'), findsOneWidget);
    expect(find.textContaining('displayLarge'), findsOneWidget);
  });

  testWidgets('colors page follows the selected preset', (tester) async {
    await pumpShowcase(tester);

    await tester.tap(find.text('Colors'));
    await tester.pumpAndSettle();
    expect(find.text('oito2_ui · Colors'), findsOneWidget);
    expect(
      find.textContaining('primaryText', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('oito2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('dracula'));
    await tester.pumpAndSettle();

    final primary = Oito2ColorTheme.fromPreset(Oito2ThemePreset.dracula)
        .colorScheme
        .primary;
    final context = tester.element(find.text('oito2_ui · Colors'));
    expect(Theme.of(context).colorScheme.primary, primary);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.byTooltip('Accent color'), findsNothing);
  });

  testWidgets('components page renders themed controls and a dialog', (
    tester,
  ) async {
    await pumpShowcase(tester);
    // Indeterminate progress indicators never settle, so advance time
    // explicitly instead of using pumpAndSettle.
    Future<void> settle() => tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Components'));
    await settle();
    expect(find.text('oito2_ui · Components'), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Filled')).height,
      Oito2Sizes.buttonHeight,
    );

    await tester.scrollUntilVisible(
      find.text('Open dialog'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Open dialog'));
    await settle();
    expect(find.text('Discard changes?'), findsOneWidget);
    final dialog = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Material),
          )
          .first,
    );
    final context = tester.element(find.byType(AlertDialog));
    expect(dialog.color, Oito2ChromeColors.maybeOf(context)!.mainbar);

    await tester.tap(find.text('Cancel'));
    await settle();
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('window page previews every control style and the dialog', (
    tester,
  ) async {
    await pumpShowcase(tester);

    await tester.tap(find.text('Window'));
    await tester.pumpAndSettle();
    expect(find.text('oito2_ui · Window'), findsOneWidget);
    final styles = tester
        .widgetList<Oito2WindowControl>(find.byType(Oito2WindowControl))
        .map((c) => c.style)
        .toSet();
    expect(
      styles,
      containsAll([
        Oito2WindowControlStyle.breeze,
        Oito2WindowControlStyle.gnome,
        Oito2WindowControlStyle.xfwm,
      ]),
    );

    final page = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Open dialog'),
      300,
      scrollable: page,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Preferences'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(Oito2DialogTitleBar),
        matching: find.byType(Oito2WindowControl),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Preferences'), findsNothing);
  });

  testWidgets('the shell uses the window title bar with KDE controls', (
    tester,
  ) async {
    await pumpShowcase(tester);
    expect(find.byType(Oito2WindowTitleBar), findsOneWidget);
    final shellControls = find.descendant(
      of: find.byType(Oito2WindowTitleBar),
      matching: find.byType(Oito2WindowControl),
    );
    expect(shellControls, findsNWidgets(3));
    expect(
      tester.widget<Oito2WindowControl>(shellControls.first).style,
      Oito2WindowControlStyle.breeze,
    );
  });
}
