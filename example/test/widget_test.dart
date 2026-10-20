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
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_example/main.dart';
import 'package:oito2_ui_example/src/showcase_catalog.dart';
import 'package:oito2_ui_example/src/showcase_options.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

/// Advances time over several frames, since some pages show indeterminate
/// progress indicators that never settle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final settings = Oito2SystemSettings.fallback(
    const Oito2Platform(targetPlatform: TargetPlatform.linux, isWeb: false),
    desktopEnvironment: Oito2DesktopEnvironment.kde,
  );

  Future<void> pumpShowcase(
    WidgetTester tester, {
    String? slug,
    ShowcaseOptions options = const ShowcaseOptions(),
    Size size = const Size(1400, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Oito2SystemScope(
        settings: settings,
        child: ShowcaseApp(initialSlug: slug ?? '', initialOptions: options),
      ),
    );
    await _settle(tester);
  }

  test('page slugs are unique', () {
    final slugs = showcasePages.map((page) => page.slug).toSet();
    expect(slugs, hasLength(showcasePages.length));
  });

  test('every page bundles its source', () async {
    for (final page in showcasePages) {
      final source = await rootBundle.loadString(page.sourceAsset);
      expect(source, contains('class '), reason: page.source);
    }
  });

  for (final page in showcasePages) {
    testWidgets('${page.slug} builds side by side, light and English', (
      tester,
    ) async {
      await pumpShowcase(tester, slug: page.slug);
      expect(tester.takeException(), isNull);
      expect(find.text(page.title), findsWidgets);
    });

    testWidgets('${page.slug} builds narrow, dark, right to left, pt-BR', (
      tester,
    ) async {
      await pumpShowcase(
        tester,
        slug: page.slug,
        size: const Size(1000, 900),
        options: const ShowcaseOptions(
          themeMode: ThemeMode.dark,
          rtl: true,
          locale: Locale('pt', 'BR'),
          compactMode: true,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text(page.title), findsWidgets);
    });
  }

  testWidgets('selecting a page in the list shows it', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.text('Oito2CheckButton'));
    await _settle(tester);
    expect(find.text('Show hidden files'), findsOneWidget);
  });

  testWidgets('the search field filters the page list', (tester) async {
    await pumpShowcase(tester);
    await tester.enterText(find.byType(TextField).first, 'button');
    await _settle(tester);
    expect(find.text('Oito2CheckButton'), findsWidgets);
    expect(find.text('Oito2Watermark'), findsNothing);
  });

  testWidgets('the narrow layout pushes the page and goes back', (
    tester,
  ) async {
    await pumpShowcase(tester, size: const Size(500, 900));
    await tester.tap(find.text('Oito2CheckButton'));
    await _settle(tester);
    expect(find.text('Show hidden files'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await _settle(tester);
    expect(find.text('Show hidden files'), findsNothing);
    expect(find.text('Oito2CheckButton'), findsOneWidget);
  });

  testWidgets('split title bars put each window button side on its pane', (
    tester,
  ) async {
    await pumpShowcase(tester);
    final bars = tester
        .widgetList<Oito2WindowTitleBar>(find.byType(Oito2WindowTitleBar))
        .map((bar) => bar.buttonSides)
        .toSet();
    expect(bars, {
      Oito2WindowButtonSides.leading,
      Oito2WindowButtonSides.trailing,
    });
  });

  testWidgets('the scheme menu applies a preset', (tester) async {
    await pumpShowcase(tester, slug: 'colors');
    await tester.tap(find.byTooltip('Color scheme'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(MenuItemButton, 'dracula'));
    await _settle(tester);
    final context = tester.element(find.byType(Scaffold).first);
    expect(
      Theme.of(context).colorScheme.primary,
      Oito2ThemePreset.dracula.colors.colorScheme.primary,
    );
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.byTooltip('High contrast'), findsNothing);
  });

  testWidgets('the settings dialog switches to compact mode', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.text('Settings'));
    await _settle(tester);
    await tester.tap(find.text('Compact mode'));
    await _settle(tester);
    await tester.tap(find.byType(Oito2WindowControl).last);
    await _settle(tester);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(Oito2MasterDetailPage), findsNothing);
  });

  testWidgets('touch control size rebuilds the theme for touch', (
    tester,
  ) async {
    await pumpShowcase(
      tester,
      slug: 'check-button',
      options: const ShowcaseOptions(density: ShowcaseDensity.touch),
    );
    final context = tester.element(find.text('Show hidden files'));
    expect(Theme.of(context).platform, TargetPlatform.android);
  });

  testWidgets('view source shows the page code', (tester) async {
    await pumpShowcase(tester, slug: 'banner');
    await tester.tap(find.byTooltip('View source').first);
    await tester.pump();
    // The asset loads with real I/O, outside the fake test clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await _settle(tester);
    expect(find.text('banner_page.dart'), findsOneWidget);
    expect(find.text('Open on GitHub'), findsOneWidget);
    expect(find.byType(Oito2CodeBlock), findsOneWidget);
  });

  testWidgets('Material dialogs use the chrome dialog tone', (tester) async {
    await pumpShowcase(tester, slug: 'material');
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
    await _settle(tester);
    final dialog = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Material),
          )
          .first,
    );
    final context = tester.element(find.byType(AlertDialog));
    expect(dialog.color, Oito2ChromeColors.maybeOf(context)!.dialog);
  });
}
