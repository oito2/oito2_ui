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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../support/sample_roles.dart';

const _linux = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);
const _windows = Oito2Platform(
  targetPlatform: TargetPlatform.windows,
  isWeb: false,
);
const _android = Oito2Platform(
  targetPlatform: TargetPlatform.android,
  isWeb: false,
);
const _web = Oito2Platform(targetPlatform: TargetPlatform.linux, isWeb: true);

const _focused = {WidgetState.focused};
const _none = <WidgetState>{};

Map<String, Oito2ColorTheme> _schemes() => {
  'base light': Oito2ColorTheme.light(),
  'base dark': Oito2ColorTheme.dark(),
  'base light HC': Oito2ColorTheme.light(highContrast: true),
  for (final MapEntry(key: name, value: roles) in sampleRoles.entries)
    name: Oito2ColorTheme.fromRoles(roles),
};

void main() {
  _schemes().forEach((name, colors) {
    group(name, () {
      final theme = Oito2Theme.fromColors(colors, platform: _linux);
      final s = colors.colorScheme;
      final semantic = colors.semantic;

      test('carries the scheme, background and extensions', () {
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme, s);
        expect(theme.brightness, colors.brightness);
        expect(theme.scaffoldBackgroundColor, colors.background);
        expect(theme.extension<Oito2SemanticColors>(), semantic);
        expect(theme.extension<Oito2ChromeColors>(), colors.chrome);
        expect(theme.extension<Oito2SyntaxTheme>()?.palette, colors.syntax);
      });

      test('text uses Inter in onSurface', () {
        final body = theme.textTheme.bodyMedium!;
        expect(body.fontFamily, Oito2Typography.fontFamily);
        expect(body.color, s.onSurface);
      });

      test('text buttons and outlined buttons use the text-safe tone', () {
        expect(
          theme.textButtonTheme.style!.foregroundColor!.resolve(_none),
          semantic.primaryText,
        );
        expect(
          theme.outlinedButtonTheme.style!.foregroundColor!.resolve(_none),
          semantic.primaryText,
        );
        expect(
          theme.outlinedButtonTheme.style!.side!.resolve(_none)!.color,
          s.outline,
        );
      });

      test('filled buttons keep the primary fill', () {
        final style = theme.filledButtonTheme.style!;
        expect(style.backgroundColor!.resolve(_none), s.primary);
        expect(style.foregroundColor!.resolve(_none), s.onPrimary);
      });

      test('every button shows a 2-pixel focus ring', () {
        for (final style in [
          theme.filledButtonTheme.style!,
          theme.elevatedButtonTheme.style!,
          theme.outlinedButtonTheme.style!,
          theme.textButtonTheme.style!,
          theme.iconButtonTheme.style!,
          theme.segmentedButtonTheme.style!,
        ]) {
          final ring = style.side!.resolve(_focused)!;
          expect(ring.width, Oito2Sizes.focusBorderWidth);
          expect(ring.color, semantic.primaryText);
        }
      });

      test('selected toggles reach 3:1 on every surface', () {
        const selected = {WidgetState.selected};
        final fills = [
          theme.checkboxTheme.fillColor!.resolve(selected)!,
          theme.radioTheme.fillColor!.resolve(selected)!,
          theme.switchTheme.trackColor!.resolve(selected)!,
          theme.progressIndicatorTheme.color!,
          theme.sliderTheme.activeTrackColor!,
        ];
        for (final fill in fills) {
          expect(
            Oito2Contrast.minRatio(fill, colors.surfaces),
            greaterThanOrEqualTo(Oito2Contrast.nonTextAA),
          );
        }
        expect(
          Oito2Contrast.ratio(
            theme.checkboxTheme.fillColor!.resolve(selected)!,
            theme.checkboxTheme.checkColor!.resolve(selected)!,
          ),
          greaterThanOrEqualTo(Oito2Contrast.nonTextAA),
        );
      });

      test('input fields use outline, focus and error tones', () {
        final input = theme.inputDecorationTheme;
        expect(input.filled, isTrue);
        expect(input.fillColor, s.surfaceContainerHigh);
        expect(input.enabledBorder!.borderSide.color, s.outline);
        expect(input.focusedBorder!.borderSide.color, semantic.primaryText);
        expect(
          input.focusedBorder!.borderSide.width,
          Oito2Sizes.focusBorderWidth,
        );
        expect(input.errorBorder!.borderSide.color, semantic.errorText);
        expect(input.errorStyle!.color, semantic.errorText);
      });

      test('text selection uses the primary at 35% alpha', () {
        expect(
          theme.textSelectionTheme.selectionColor,
          s.primary.withValues(alpha: 0.35),
        );
        expect(theme.textSelectionTheme.cursorColor, semantic.primaryText);
      });

      test('cards are flat with an outlineVariant border', () {
        final card = theme.cardTheme;
        expect(card.elevation, 0);
        final shape = card.shape! as RoundedRectangleBorder;
        expect(shape.side.color, s.outlineVariant);
        expect(shape.borderRadius, Oito2Radius.largeAll);
      });

      test('modals use the chrome dialog tone with the window radius', () {
        expect(theme.dialogTheme.backgroundColor, colors.chrome.dialog);
        expect(
          (theme.dialogTheme.shape! as RoundedRectangleBorder).borderRadius,
          Oito2Radius.windowAll,
        );
        expect(theme.bottomSheetTheme.backgroundColor, colors.chrome.dialog);
        expect(
          theme.bottomSheetTheme.modalBackgroundColor,
          colors.chrome.dialog,
        );
      });

      test('chrome components use the chrome tones', () {
        expect(theme.appBarTheme.backgroundColor, colors.chrome.titleBar);
        expect(
          theme.navigationRailTheme.backgroundColor,
          colors.chrome.sidebar,
        );
      });
    });
  });

  testWidgets('the Inter license shows in the license page', (tester) async {
    Oito2Theme.light(platform: _linux);
    final packages = await tester.runAsync(() async {
      final names = <String>{};
      await for (final entry in LicenseRegistry.licenses) {
        names.addAll(entry.packages);
      }
      return names;
    });
    expect(packages, contains('Inter'));
  });

  group('caching', () {
    test('the same inputs return the same scheme and theme', () {
      expect(Oito2ColorTheme.light(), same(Oito2ColorTheme.light()));
      final roles = sampleRoles['roles light dim']!;
      expect(
        Oito2ColorTheme.fromRoles(roles),
        same(Oito2ColorTheme.fromRoles(roles)),
      );
      expect(
        Oito2Theme.light(platform: _linux),
        same(Oito2Theme.light(platform: _linux)),
      );
    });

    test('fromRoles honors high contrast', () {
      final roles = sampleRoles['roles light dim']!;
      final normal = Oito2ColorTheme.fromRoles(roles);
      final high = Oito2ColorTheme.fromRoles(roles, highContrast: true);
      expect(high.highContrast, isTrue);
      expect(
        Oito2Contrast.ratio(
          high.colorScheme.onSurfaceVariant,
          high.colorScheme.surface,
        ),
        greaterThanOrEqualTo(Oito2Contrast.textAAA),
      );
      expect(normal.highContrast, isFalse);
    });
  });

  group('platform adaptation', () {
    test('pointer platforms use compact controls without splashes', () {
      for (final platform in [_linux, _windows, _web]) {
        final theme = Oito2Theme.light(platform: platform);
        expect(theme.visualDensity, VisualDensity.comfortable);
        expect(theme.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
        expect(theme.splashFactory, NoSplash.splashFactory);
        expect(
          theme.filledButtonTheme.style!.minimumSize!.resolve(_none)!.height,
          Oito2Sizes.buttonHeight - theme.visualDensity.baseSizeAdjustment.dy,
        );
        expect(theme.appBarTheme.toolbarHeight, Oito2Sizes.titleBarHeight);
      }
    });

    test('touch platforms use standard density and padded targets', () {
      final theme = Oito2Theme.light(platform: _android);
      expect(theme.visualDensity, VisualDensity.standard);
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(theme.splashFactory, isNot(NoSplash.splashFactory));
      expect(
        theme.filledButtonTheme.style!.minimumSize!.resolve(_none)!.height,
        Oito2Sizes.touchButtonHeight,
      );
      expect(theme.appBarTheme.toolbarHeight, isNull);
    });

    test('native Linux centers the app bar title', () {
      expect(Oito2Theme.light(platform: _linux).appBarTheme.centerTitle, true);
      expect(
        Oito2Theme.light(platform: _windows).appBarTheme.centerTitle,
        isNull,
      );
      expect(Oito2Theme.light(platform: _web).appBarTheme.centerTitle, isNull);
    });

    test('the theme platform follows the given platform', () {
      expect(
        Oito2Theme.light(platform: _windows).platform,
        TargetPlatform.windows,
      );
    });

    test('page transitions use the desktop builder on Linux and Windows', () {
      final builders = Oito2Theme.light(platform: _linux)
          .pageTransitionsTheme
          .builders;
      expect(
        builders[TargetPlatform.linux],
        isA<Oito2DesktopPageTransitionsBuilder>(),
      );
      expect(
        builders[TargetPlatform.windows],
        isA<Oito2DesktopPageTransitionsBuilder>(),
      );
      final defaults = const PageTransitionsTheme().builders;
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ]) {
        expect(builders[platform], defaults[platform]);
      }
    });
  });

  group('builders', () {
    test('light, dark and fromColors wrap Oito2ColorTheme', () {
      const accent = Color(0xFF3A944A);
      expect(
        Oito2Theme.light(accent: accent, platform: _linux).colorScheme,
        Oito2ColorScheme.light(accent: accent),
      );
      expect(
        Oito2Theme.dark(highContrast: true, platform: _linux).colorScheme,
        Oito2ColorScheme.dark(highContrast: true),
      );
      final colors = Oito2ColorTheme.fromRoles(
        sampleRoles['roles dark lifted']!,
      );
      expect(
        Oito2Theme.fromColors(colors, platform: _linux).colorScheme,
        colors.colorScheme,
      );
    });

    test('fromSystem follows the system accent and contrast', () {
      final settings = Oito2SystemSettings.fallback(_windows).copyWith(
        accentColor: Oito2AccentColor.orange.color,
        highContrast: true,
      );
      final theme = Oito2Theme.fromSystem(
        settings,
        brightness: Brightness.dark,
      );
      expect(
        theme.colorScheme,
        Oito2ColorScheme.dark(
          accent: Oito2AccentColor.orange.color,
          highContrast: true,
        ),
      );
      expect(theme.platform, TargetPlatform.windows);
    });

    test('fromSystem prefers an explicit accent', () {
      final settings = Oito2SystemSettings.fallback(_linux)
          .copyWith(accentColor: Oito2AccentColor.orange.color);
      expect(
        Oito2Theme.fromSystem(
          settings,
          brightness: Brightness.light,
          accent: Oito2AccentColor.teal.color,
        ).colorScheme,
        Oito2ColorScheme.light(accent: Oito2AccentColor.teal.color),
      );
    });
  });

  group('rendered components', () {
    Future<void> pump(
      WidgetTester tester,
      Oito2Platform platform,
      Widget child,
    ) {
      return tester.pumpWidget(
        MaterialApp(
          theme: Oito2Theme.light(platform: platform),
          home: Scaffold(body: Center(child: child)),
        ),
      );
    }

    testWidgets('buttons are 34 tall on pointer platforms', (tester) async {
      await pump(
        tester,
        _linux,
        FilledButton(onPressed: () {}, child: const Text('Save')),
      );
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        Oito2Sizes.buttonHeight,
      );
    });

    testWidgets('buttons grow with a large text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: Oito2Theme.light(platform: _linux),
          home: MediaQuery.withClampedTextScaling(
            minScaleFactor: 3,
            maxScaleFactor: 3,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(onPressed: () {}, child: const Text('Save')),
                    MenuItemButton(onPressed: () {}, child: const Text('Open')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      for (final type in [FilledButton, MenuItemButton]) {
        final button = tester.getRect(find.byType(type));
        final label = tester.getRect(
          find.descendant(of: find.byType(type), matching: find.byType(Text)),
        );
        expect(button.height, greaterThan(Oito2Sizes.buttonHeight));
        expect(label.top, greaterThanOrEqualTo(button.top));
        expect(label.bottom, lessThanOrEqualTo(button.bottom));
      }
    });

    testWidgets('buttons keep a 48 tap target on touch platforms', (
      tester,
    ) async {
      await pump(
        tester,
        _android,
        FilledButton(onPressed: () {}, child: const Text('Save')),
      );
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        Oito2Sizes.minTouchTarget,
      );
    });

    testWidgets('icon buttons are square on pointer platforms', (tester) async {
      await pump(
        tester,
        _linux,
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      );
      expect(
        tester.getSize(find.byType(IconButton)),
        const Size.square(Oito2Sizes.buttonHeight),
      );
    });

    testWidgets('a text field shows its error in the error text tone', (
      tester,
    ) async {
      await pump(
        tester,
        _linux,
        const SizedBox(
          width: 240,
          child: TextField(decoration: InputDecoration(errorText: 'Required')),
        ),
      );
      final text = tester.widget<Text>(find.text('Required'));
      final style = DefaultTextStyle.of(tester.element(find.text('Required')))
          .style
          .merge(text.style);
      expect(style.color, Oito2ColorTheme.light().semantic.errorText);
    });

    testWidgets('the desktop page transition runs to completion', (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          theme: Oito2Theme.light(platform: _linux),
          home: const Text('first'),
        ),
      );
      navigator.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Text('second')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('second'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('first'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
