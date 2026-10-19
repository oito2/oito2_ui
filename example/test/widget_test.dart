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
}
