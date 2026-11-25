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

/// Pages whose text contrast is not checked, with the reason.
const _contrastExceptions = {
  'undershoot':
      'The undershoot fades the items at the list edge into the surface '
      'on purpose.',
};

/// Controls laid out in a dense grid or strip of small cells by design,
/// where 48-pixel cells would not fit the content.
const _touchDense = 'Dense grid or strip of small cells by design.';

/// Pages whose touch target sizes are not checked, with the reason.
const _touchTargetExceptions = {
  'calendar': '$_touchDense The day cells are 42 px in a 7-column month.',
  'carousel': '$_touchDense The page dots are 24 px.',
  'color-disk': '$_touchDense The color swatches are 28 px.',
  'color-picker':
      '$_touchDense Only the swatch grid: the color swatches are 28 px.',
  'page-indicator': '$_touchDense The page dots are 24 px.',
  'week-schedule-grid':
      '$_touchDense The hour cells are 30 by 28 px in a 24-column week.',
};

/// Checks the text contrast, unless [slug] is in [_contrastExceptions],
/// and that every tap target has a label.
Future<void> _expectPointerGuidelines(WidgetTester tester, String slug) async {
  if (!_contrastExceptions.containsKey(slug)) {
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
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

  test('the accessibility exceptions name existing pages', () {
    final slugs = showcasePages.map((page) => page.slug).toSet();
    expect(
      slugs,
      containsAll([
        ..._contrastExceptions.keys,
        ..._touchTargetExceptions.keys,
      ]),
    );
  });

  for (final page in showcasePages) {
    testWidgets('${page.slug} builds side by side, light and English', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpShowcase(tester, slug: page.slug);
      expect(tester.takeException(), isNull);
      expect(find.text(page.title), findsWidgets);
      await _expectPointerGuidelines(tester, page.slug);
      semantics.dispose();
    });

    testWidgets('${page.slug} builds narrow, dark, right to left, pt-BR', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
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
      await _expectPointerGuidelines(tester, page.slug);
      semantics.dispose();
    });

    // Only touch controls promise 48-pixel targets; pointer controls are
    // 34 pixels high on purpose.
    if (!_touchTargetExceptions.containsKey(page.slug)) {
      testWidgets('${page.slug} has 48-pixel targets with touch controls', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpShowcase(
          tester,
          slug: page.slug,
          options: const ShowcaseOptions(density: ShowcaseDensity.touch),
        );
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        semantics.dispose();
      });
    }
  }

  testWidgets('the foundation page shows the motion, text and cursor values', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Oito2SystemScope(
        settings: settings.copyWith(
          reduceMotion: true,
          textScaleFactor: 1.25,
          cursorSize: 48,
        ),
        child: const ShowcaseApp(initialSlug: 'foundation'),
      ),
    );
    await _settle(tester);
    for (final text in ['Reduced motion', 'true', '1.25×', '48 px']) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    expect(find.text('Text scale (applied)'), findsOneWidget);
  });

  testWidgets('selecting a page in the list shows it', (tester) async {
    await pumpShowcase(tester);
    await _scrollToPage(tester, 'Oito2CheckButton');
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
    expect(find.text('Oito2Alert'), findsWidgets);
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
    await _scrollToPage(tester, 'Oito2CheckButton');
    await tester.tap(find.text('Oito2CheckButton'));
    await _settle(tester);
    expect(find.text('Show hidden files'), findsOneWidget);
    await tester.tap(find.byType(Oito2BackButton));
    await _settle(tester);
    expect(find.text('Show hidden files'), findsNothing);
    await _scrollToPage(tester, 'Oito2CheckButton');
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
    // The page itself shows code blocks too; one is in the dialog.
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(Oito2CodeBlock),
      ),
      findsOneWidget,
    );
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

  testWidgets('the live sparkline updates every second and pauses', (
    tester,
  ) async {
    await pumpShowcase(tester, slug: 'sparkline');
    Oito2Sparkline live() => tester.widget(
      find.byWidgetPredicate(
        (w) => w is Oito2Sparkline && w.semanticsLabel == 'Download speed',
      ),
    );
    final before = [...live().values];
    await tester.pump(const Duration(seconds: 1));
    final after = [...live().values];
    expect(after, hasLength(before.length));
    expect(after.sublist(0, after.length - 1), before.sublist(1));
    await tester.ensureVisible(find.text('Pause'));
    await tester.tap(find.text('Pause'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(live().values, after);
    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets('F1 and Ctrl+? open the shortcuts help', (tester) async {
    await pumpShowcase(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await _settle(tester);
    expect(find.byType(Oito2ShortcutsHelpView), findsOneWidget);
    expect(find.text('Show all commands'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(find.byType(Oito2ShortcutsHelpView), findsNothing);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await _settle(tester);
    expect(find.byType(Oito2ShortcutsHelpView), findsOneWidget);
  });

  testWidgets('the palette lists the keyboard shortcuts help', (tester) async {
    await pumpShowcase(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await _settle(tester);
    await tester.enterText(find.byType(TextField).last, 'keyboard shortcuts');
    await _settle(tester);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _settle(tester);
    expect(find.byType(Oito2ShortcutsHelpView), findsOneWidget);
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
    final success = find.widgetWithText(OutlinedButton, 'success');
    await tester.ensureVisible(success);
    await _settle(tester);
    await tester.tap(success);
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

    group('unsaved changes on the form page', () {
      /// The name field of the form page.
      final name = find
          .descendant(
            of: find.byType(Oito2FormFieldAdapter),
            matching: find.byType(TextField),
          )
          .first;

      /// The title bar of the watermark page.
      final watermarkTitle = find.widgetWithText(
        Oito2WindowTitleBar,
        'Oito2Watermark',
      );

      /// Opens the form page in a view of [size] and changes the name.
      Future<void> pumpEdited(
        WidgetTester tester, {
        Size size = const Size(1400, 1000),
      }) async {
        await pumpShowcase(tester, slug: 'form', size: size);
        await tester.enterText(name, 'Bo');
        await _settle(tester);
        expect(find.text('Not saved'), findsOneWidget);
      }

      testWidgets('picking another page asks first', (tester) async {
        await pumpEdited(tester);
        await _scrollToPage(tester, 'Oito2Watermark');
        await tester.tap(find.text('Oito2Watermark'));
        await _settle(tester);
        expect(find.text('Discard unsaved changes?'), findsOneWidget);
        await tester.tap(find.text('Keep editing'));
        await _settle(tester);
        expect(watermarkTitle, findsNothing);
        expect(find.text('Bo'), findsOneWidget);

        await tester.tap(find.text('Oito2Watermark'));
        await _settle(tester);
        await tester.tap(find.text('Discard'));
        await _settle(tester);
        expect(watermarkTitle, findsOneWidget);
      });

      testWidgets('a refused address change keeps the page and its address', (
        tester,
      ) async {
        await pumpEdited(tester);
        await pushAddress(tester, '/watermark');
        expect(find.text('Discard unsaved changes?'), findsOneWidget);
        await tester.tap(find.text('Keep editing'));
        await _settle(tester);
        expect(
          find.widgetWithText(Oito2WindowTitleBar, 'Oito2Form'),
          findsOneWidget,
        );
        expect(find.text('Bo'), findsOneWidget);
      });

      testWidgets('going back in the narrow layout asks first', (tester) async {
        await pumpEdited(tester, size: const Size(500, 900));
        await tester.tap(find.byType(Oito2BackButton));
        await _settle(tester);
        expect(find.text('Discard unsaved changes?'), findsOneWidget);
        await tester.tap(find.text('Discard'));
        await _settle(tester);
        expect(find.byType(Oito2BackButton), findsNothing);
      });

      testWidgets('saving from the dialog with errors stays and shows them', (
        tester,
      ) async {
        await pumpEdited(tester);
        await _scrollToPage(tester, 'Oito2Watermark');
        await tester.tap(find.text('Oito2Watermark'));
        await _settle(tester);
        await tester.tap(find.text('Save').last);
        await _settle(tester);
        expect(watermarkTitle, findsNothing);
        expect(find.text('Fix 1 error to continue'), findsOneWidget);
      });
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

    testWidgets('going back to the narrow list clears the address', (
      tester,
    ) async {
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
      await pumpShowcase(
        tester,
        slug: 'check-button',
        size: const Size(500, 900),
      );
      expect(find.text('Show hidden files'), findsOneWidget);
      await tester.tap(find.byType(Oito2BackButton));
      await _settle(tester);
      expect(find.text('Show hidden files'), findsNothing);
      expect(reported.last, '/');
    });
  });
}

/// Scrolls the page list until the entry titled [title] is built and in
/// view.
Future<void> _scrollToPage(WidgetTester tester, String title) =>
    tester.scrollUntilVisible(
      find.text(title),
      200,
      scrollable: find
          .descendant(
            of: find.byType(Oito2MasterListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
