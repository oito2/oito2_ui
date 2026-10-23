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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../support/sample_roles.dart';

/// Every theme under test, keyed by a readable name.
Map<String, Oito2ColorTheme> _allThemes() => {
  for (final brightness in Brightness.values)
    for (final highContrast in [false, true])
      for (final accent in Oito2AccentColor.values)
        'base ${brightness.name}${highContrast ? ' HC' : ''} ${accent.name}':
            brightness == Brightness.dark
            ? Oito2ColorTheme.dark(
                accent: accent.color,
                highContrast: highContrast,
              )
            : Oito2ColorTheme.light(
                accent: accent.color,
                highContrast: highContrast,
              ),
  for (final MapEntry(key: name, value: roles) in sampleRoles.entries)
    name: Oito2ColorTheme.fromRoles(roles),
};

/// The text contrast ratio [t] must reach: AAA in high contrast, AA
/// otherwise.
double _textTarget(Oito2ColorTheme t) =>
    t.highContrast ? Oito2Contrast.textAAA : Oito2Contrast.textAA;

/// The contrast ratio outlines of [t] must reach: the AA text ratio in high
/// contrast, the AA non-text ratio otherwise.
double _nonTextTarget(Oito2ColorTheme t) =>
    t.highContrast ? Oito2Contrast.textAA : Oito2Contrast.nonTextAA;

/// Matches a ratio of at least [target], with a small tolerance for
/// floating-point rounding.
Matcher _atLeast(double target) => greaterThanOrEqualTo(target - 0.0001);

void main() {
  _allThemes().forEach((name, theme) {
    group(name, () {
      final s = theme.colorScheme;
      final surfaces = theme.surfaces;

      test('text roles reach the text target on every surface', () {
        final target = _textTarget(theme);
        final roles = {
          'onSurface': s.onSurface,
          'onSurfaceVariant': s.onSurfaceVariant,
          'primaryText': theme.semantic.primaryText,
          'errorText': theme.semantic.errorText,
          'success': theme.semantic.success,
          'warning': theme.semantic.warning,
          'info': theme.semantic.info,
          'link': theme.semantic.link,
        };
        roles.forEach((role, color) {
          expect(
            Oito2Contrast.minRatio(color, surfaces),
            _atLeast(target),
            reason: role,
          );
        });
      });

      test('syntax roles reach the text target on every surface', () {
        for (final color in theme.syntax.colors) {
          expect(
            Oito2Contrast.minRatio(color, surfaces),
            _atLeast(_textTarget(theme)),
            reason: '$color',
          );
        }
      });

      test('outline reaches the non-text target on every surface', () {
        expect(
          Oito2Contrast.minRatio(s.outline, surfaces),
          _atLeast(_nonTextTarget(theme)),
        );
      });

      test('on-colors reach 4.5:1 on their fills', () {
        final pairs = {
          'primary': (s.primary, s.onPrimary),
          'primaryContainer': (s.primaryContainer, s.onPrimaryContainer),
          'secondary': (s.secondary, s.onSecondary),
          'secondaryContainer': (s.secondaryContainer, s.onSecondaryContainer),
          'tertiary': (s.tertiary, s.onTertiary),
          'tertiaryContainer': (s.tertiaryContainer, s.onTertiaryContainer),
          'error': (s.error, s.onError),
          'errorContainer': (s.errorContainer, s.onErrorContainer),
          'inverseSurface': (s.inverseSurface, s.onInverseSurface),
          'inversePrimary': (s.inverseSurface, s.inversePrimary),
        };
        pairs.forEach((role, pair) {
          expect(
            Oito2Contrast.ratio(pair.$1, pair.$2),
            _atLeast(Oito2Contrast.textAA),
            reason: role,
          );
        });
      });

      test('surfaces climb in elevation from lowest to highest', () {
        final ramp = [
          s.surfaceContainerLowest,
          s.surfaceContainerLow,
          s.surfaceContainer,
          s.surfaceContainerHigh,
          s.surfaceContainerHighest,
        ].map((c) => c.computeLuminance()).toList();
        for (var i = 1; i < ramp.length; i++) {
          if (s.brightness == Brightness.dark) {
            expect(ramp[i], greaterThanOrEqualTo(ramp[i - 1]), reason: '$i');
          } else {
            expect(ramp[i], lessThanOrEqualTo(ramp[i - 1]), reason: '$i');
          }
        }
      });

      test('chrome surfaces come from the container roles', () {
        final chrome = theme.chrome;
        expect(chrome.background, theme.background);
        const step = Oito2ChromeColors.minimumStep;
        expect(
          Oito2Contrast.ratio(chrome.sidebar, chrome.background),
          greaterThanOrEqualTo(step),
        );
        expect(
          Oito2Contrast.ratio(chrome.mainbar, chrome.background),
          greaterThanOrEqualTo(step),
        );
        expect(
          Oito2Contrast.ratio(chrome.mainbar, chrome.sidebar),
          greaterThanOrEqualTo(step),
        );
        if (Oito2Contrast.minRatio(s.surfaceContainerHighest, [
              chrome.background,
            ]) >=
            step) {
          expect(chrome.mainbar, s.surfaceContainerHighest);
        }
        expect(
          chrome.dialog,
          s.brightness == Brightness.dark ? s.surfaceContainerHigh : s.surface,
        );
      });

      test('body text reaches its target on every chrome surface', () {
        final chrome = theme.chrome;
        for (final surface in [
          chrome.sidebar,
          chrome.mainbar,
          chrome.dialog,
          chrome.titleBar,
        ]) {
          expect(
            Oito2Contrast.ratio(s.onSurface, surface),
            greaterThanOrEqualTo(Oito2Contrast.textAA),
          );
        }
      });

      test('surfaces carry no elevation tint', () {
        expect(s.surfaceTint.a, 0);
      });
    });
  });

  group('fromRoles', () {
    sampleRoles.forEach((name, roles) {
      test('$name keeps the given accent, error and brightness', () {
        final theme = Oito2ColorTheme.fromRoles(roles);
        expect(theme.brightness, roles.brightness);
        expect(theme.colorScheme.primary, roles.primary);
        expect(
          theme.colorScheme.onPrimary,
          Oito2Contrast.foregroundFor(roles.primary),
        );
        expect(theme.colorScheme.error, roles.destructive);
        expect(theme.background, roles.background);
        expect(theme.colorScheme.surface, roles.card);
        expect(theme.colorScheme.surfaceContainerHighest, roles.secondary);
        expect(theme.colorScheme.outlineVariant, roles.border);
      });
    });

    test('the lowest container is the lower of background and card', () {
      final dim = Oito2ColorTheme.fromRoles(sampleRoles['roles light dim']!);
      expect(
        dim.colorScheme.surfaceContainerLowest,
        sampleRoles['roles light dim']!.card,
      );
      final lifted = Oito2ColorTheme.fromRoles(
        sampleRoles['roles dark lifted']!,
      );
      expect(
        lifted.colorScheme.surfaceContainerLowest,
        sampleRoles['roles dark lifted']!.background,
      );
    });

    test('faint text roles are raised to the text target', () {
      final roles = sampleRoles['roles light dim']!;
      final theme = Oito2ColorTheme.fromRoles(roles);
      expect(theme.colorScheme.onSurfaceVariant, isNot(roles.mutedForeground));
      expect(
        Oito2Contrast.minRatio(theme.colorScheme.onSurfaceVariant, [
          roles.card,
        ]),
        _atLeast(Oito2Contrast.textAA),
      );
    });
  });

  group('base scheme', () {
    test('uses the fallback accent by default', () {
      final theme = Oito2ColorTheme.light();
      final hue = HSLColor.fromColor(theme.colorScheme.primary).hue;
      expect(
        hue,
        closeTo(HSLColor.fromColor(Oito2AccentColor.blue.color).hue, 1),
      );
    });

    test('keeps white text on the accent, adjusting only its lightness', () {
      for (final accent in Oito2AccentColor.values) {
        for (final theme in [
          Oito2ColorTheme.light(accent: accent.color),
          Oito2ColorTheme.dark(accent: accent.color),
        ]) {
          final primary = theme.colorScheme.primary;
          expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
          final before = HSLColor.fromColor(accent.color);
          final after = HSLColor.fromColor(primary);
          expect(after.hue, closeTo(before.hue, 1), reason: accent.name);
          expect(
            after.lightness,
            lessThanOrEqualTo(before.lightness),
            reason: accent.name,
          );
        }
      }
    });

    test('accents that already pass stay unchanged', () {
      final purple = Oito2AccentColor.purple.color;
      expect(Oito2ColorTheme.light(accent: purple).colorScheme.primary, purple);
    });

    test('high contrast raises primary text contrast to 7:1', () {
      final theme = Oito2ColorTheme.light(highContrast: true);
      expect(theme.highContrast, isTrue);
      expect(
        Oito2Contrast.ratio(
          theme.colorScheme.primary,
          theme.colorScheme.onPrimary,
        ),
        _atLeast(Oito2Contrast.textAAA),
      );
      expect(theme.colorScheme.onSurface, const Color(0xFF000000));
      expect(theme.colorScheme.outlineVariant, theme.colorScheme.outline);
    });

    test('uses the GTK neutrals', () {
      final light = Oito2ColorTheme.light();
      expect(light.colorScheme.surface, Oito2NeutralPalette.light.surface);
      expect(light.background, Oito2NeutralPalette.light.surfaceContainerLow);
      expect(light.chrome.titleBar, Oito2NeutralPalette.light.titleBar);
      final dark = Oito2ColorTheme.dark();
      expect(dark.colorScheme.surface, Oito2NeutralPalette.dark.surface);
      expect(dark.chrome.titleBar, Oito2NeutralPalette.dark.titleBar);
    });
  });

  test('equal inputs produce equal themes', () {
    expect(Oito2ColorTheme.light(), Oito2ColorTheme.light());
    expect(Oito2ColorTheme.light().hashCode, Oito2ColorTheme.light().hashCode);
    final roles = sampleRoles['roles dark lifted']!;
    expect(Oito2ColorTheme.fromRoles(roles), Oito2ColorTheme.fromRoles(roles));
    expect(
      Oito2ColorTheme.fromRoles(roles),
      isNot(Oito2ColorTheme.fromRoles(sampleRoles['roles light flat']!)),
    );
  });

  test('Oito2ColorScheme shortcuts match Oito2ColorTheme', () {
    const accent = Color(0xFF3A944A);
    expect(
      Oito2ColorScheme.light(accent: accent),
      Oito2ColorTheme.light(accent: accent).colorScheme,
    );
    expect(
      Oito2ColorScheme.dark(highContrast: true),
      Oito2ColorTheme.dark(highContrast: true).colorScheme,
    );
  });
}
