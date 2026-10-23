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
import 'package:oito2_ui_example/main.dart';
import 'package:oito2_ui_example/src/showcase_catalog.dart';
import 'package:oito2_ui_example/src/showcase_options.dart';
import 'package:oito2_ui_example/src/showcase_shell.dart' as shell;
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

  /// Pumps the showcase on the page [slug], or with no page selected when
  /// it is null, with [options] in a view of [size] logical pixels.
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

  testWidgets('a search without results keeps the field to clear it', (
    tester,
  ) async {
    await pumpShowcase(tester);
    await tester.enterText(find.byType(TextField).first, 'zzzz');
    await _settle(tester);
    expect(find.text('Oito2CheckButton'), findsNothing);
    expect(find.byType(TextField), findsWidgets);
    await tester.enterText(find.byType(TextField).first, '');
    await _settle(tester);
    expect(find.text('Oito2Banner'), findsWidgets);
  });

  testWidgets('the search also matches page addresses', (tester) async {
    await pumpShowcase(tester);
    await tester.enterText(find.byType(TextField).first, 'check-button');
    await _settle(tester);
    expect(find.text('Oito2CheckButton'), findsWidgets);
  });

  test('options with the same values are equal', () {
    expect(
      const ShowcaseOptions(rtl: true),
      const ShowcaseOptions().copyWith(rtl: true),
    );
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
    await tester.tap(find.byType(Oito2BackButton));
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
    await pumpShowcase(tester, slug: 'theme');
    await tester.tap(find.byTooltip('Color scheme'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(MenuItemButton, 'Dracula'));
    await _settle(tester);
    final context = tester.element(find.byType(Scaffold).first);
    expect(
      Theme.of(context).colorScheme.primary,
      Oito2ThemePreset.dracula.colors.colorScheme.primary,
    );
    expect(Theme.of(context).brightness, Brightness.dark);
    // High contrast stays available, and applies to the preset.
    await tester.tap(find.byTooltip('High contrast'));
    await _settle(tester);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).colorScheme,
      Oito2ColorTheme.fromRoles(
        Oito2ThemePreset.dracula.roles,
        highContrast: true,
      ).colorScheme,
    );
  });

  testWidgets('the settings dialog switches to compact mode', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.text('Settings'));
    await _settle(tester);
    await tester.tap(find.text('Compact mode'));
    await _settle(tester);
    await tester.tap(find.byType(Oito2WindowControl).last);
    await _settle(tester);
    expect(find.byType(Oito2NavigationRail), findsOneWidget);
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
    await pumpShowcase(tester, slug: 'theme');
    await tester.tap(find.text('Containers').last);
    await _settle(tester);
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

  testWidgets('Ctrl+K opens the palette and runs a page command', (
    tester,
  ) async {
    await pumpShowcase(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await _settle(tester);
    expect(find.text('Type a command'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'go to watermark');
    await _settle(tester);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _settle(tester);
    expect(find.text('Type a command'), findsNothing);
    expect(find.text('No messages'), findsOneWidget);
  });

  testWidgets('Ctrl+F focuses the page search', (tester) async {
    await pumpShowcase(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await _settle(tester);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Page search');
  });

  testWidgets('the page list highlights the search matches', (tester) async {
    await pumpShowcase(tester);
    await tester.enterText(find.byType(TextField).first, 'swap');
    await _settle(tester);
    expect(
      find.descendant(
        of: find.byType(Oito2MasterTile),
        matching: find.byType(Oito2HighlightedText),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the app toaster shows toasts from a page', (tester) async {
    await pumpShowcase(tester, slug: 'toast');
    await tester.tap(find.widgetWithText(OutlinedButton, 'success'));
    await _settle(tester);
    expect(find.text('A success message.'), findsOneWidget);
    await tester.tap(find.byTooltip('Dismiss'));
    await _settle(tester);
    expect(find.text('A success message.'), findsNothing);
  });

  for (final (name, size, options) in [
    ('wide', const Size(1400, 1000), const ShowcaseOptions()),
    (
      'narrow',
      const Size(600, 900),
      const ShowcaseOptions(themeMode: ThemeMode.dark, compactMode: true),
    ),
  ]) {
    testWidgets('every Material theme section builds, $name', (tester) async {
      await pumpShowcase(tester, slug: 'theme', size: size, options: options);
      for (final label in [
        'Colors',
        'Controls',
        'Text fields',
        'Containers',
        'Fonts',
        'Tokens',
        'Home',
      ]) {
        final navigation = find.byType(
          name == 'narrow' ? NavigationBar : NavigationRail,
        );
        await tester.tap(
          find.descendant(of: navigation, matching: find.text(label)),
        );
        await _settle(tester);
        expect(tester.takeException(), isNull, reason: label);
        expect(find.widgetWithText(AppBar, label), findsOneWidget);
      }
      if (name == 'narrow') {
        expect(find.byType(NavigationBar), findsOneWidget);
      } else {
        expect(find.byType(NavigationRail), findsOneWidget);
      }
    });
  }

  group('addresses', () {
    /// Sends [location] as the platform does when the address changes, such
    /// as after editing it or pressing the browser's back button.
    Future<void> pushAddress(WidgetTester tester, String location) async {
      final message = const JSONMethodCodec().encodeMethodCall(
        MethodCall('pushRouteInformation', {
          'location': location,
          'state': null,
        }),
      );
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        message,
        (_) {},
      );
      await _settle(tester);
    }

    testWidgets('an address change selects its page in the same shell', (
      tester,
    ) async {
      await pumpShowcase(tester, slug: 'check-button');
      await pushAddress(tester, '/watermark');
      expect(tester.takeException(), isNull);
      expect(find.byType(shell.ShowcaseShell), findsOneWidget);
      expect(
        find.widgetWithText(Oito2WindowTitleBar, 'Oito2Watermark'),
        findsOneWidget,
      );
      await pushAddress(tester, '/check-button');
      expect(
        find.widgetWithText(Oito2WindowTitleBar, 'Oito2CheckButton'),
        findsOneWidget,
      );
    });

    testWidgets('an address change shows its page in compact mode', (
      tester,
    ) async {
      await pumpShowcase(
        tester,
        slug: 'watermark',
        options: const ShowcaseOptions(compactMode: true),
      );
      await pushAddress(tester, '/check-button');
      expect(
        find.widgetWithText(Oito2WindowTitleBar, 'Oito2CheckButton'),
        findsOneWidget,
      );
      expect(find.text('Show hidden files'), findsOneWidget);
    });

    testWidgets('an unknown or empty address keeps the app working', (
      tester,
    ) async {
      await pumpShowcase(tester, slug: 'banner');
      await pushAddress(tester, '/no-such-page');
      await pushAddress(tester, '/');
      expect(tester.takeException(), isNull);
      expect(find.byType(shell.ShowcaseShell), findsOneWidget);
    });

    testWidgets('picking a page publishes its address', (tester) async {
      final reported = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.navigation,
        (call) async {
          if (call.method == 'routeInformationUpdated') {
            reported.add((call.arguments as Map)['uri'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          null,
        ),
      );
      await pumpShowcase(tester, slug: 'banner');
      await tester.tap(find.text('Oito2Carousel').first);
      await _settle(tester);
      expect(reported.last, '/carousel');
    });
  });
}
