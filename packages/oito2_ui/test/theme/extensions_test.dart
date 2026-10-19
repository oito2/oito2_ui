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

const _black = Color(0xFF000000);
const _white = Color(0xFFFFFFFF);

void main() {
  group('Oito2SemanticColors', () {
    const a = Oito2SemanticColors(
      primaryText: _black,
      errorText: _black,
      success: _black,
      warning: _black,
      info: _black,
      link: _black,
    );
    const b = Oito2SemanticColors(
      primaryText: _white,
      errorText: _white,
      success: _white,
      warning: _white,
      info: _white,
      link: _white,
    );

    test('copyWith replaces only the given colors', () {
      final copy = a.copyWith(link: _white);
      expect(copy.link, _white);
      expect(copy.primaryText, _black);
      expect(a.copyWith(), a);
    });

    test('lerp interpolates every color', () {
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(a.lerp(null, 0.5), a);
      expect(a.lerp(b, 0.5).errorText, Color.lerp(_black, _white, 0.5));
    });

    test('equality and hashCode', () {
      expect(a, a.copyWith());
      expect(a.hashCode, a.copyWith().hashCode);
      expect(a, isNot(b));
    });

    testWidgets('maybeOf reads the theme extension', (tester) async {
      Oito2SemanticColors? found;
      await tester.pumpWidget(
        Theme(
          data: ThemeData(extensions: const [a]),
          child: Builder(
            builder: (context) {
              found = Oito2SemanticColors.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(found, a);
    });
  });

  group('Oito2ChromeColors', () {
    test('derive blends onSurface over the background for the sidebar', () {
      final chrome = Oito2ChromeColors.derive(
        background: const Color(0xFF202020),
        onSurface: _white,
      );
      expect(
        chrome.sidebar,
        Color.alphaBlend(
          _white.withValues(alpha: 0.03),
          const Color(0xFF202020),
        ),
      );
      expect(
        chrome.mainbar,
        Color.alphaBlend(_white.withValues(alpha: 0.05), chrome.sidebar),
      );
      expect(chrome.titleBar, chrome.mainbar);
    });

    test('darkerMainbarPresets blend black over the sidebar', () {
      for (final preset in Oito2ChromeColors.darkerMainbarPresets) {
        expect(preset.isDark, isFalse, reason: preset.name);
        final chrome = Oito2ChromeColors.derive(
          background: _white,
          onSurface: _black,
          preset: preset,
        );
        expect(
          chrome.mainbar,
          Color.alphaBlend(_black.withValues(alpha: 0.04), chrome.sidebar),
        );
      }
    });

    test('every light preset is in darkerMainbarPresets', () {
      expect(
        Oito2ChromeColors.darkerMainbarPresets,
        Oito2ThemePreset.values.where((p) => !p.isDark).toSet(),
      );
    });

    test('darkerMainbar overrides the preset check', () {
      final chrome = Oito2ChromeColors.derive(
        background: _white,
        onSurface: _black,
        darkerMainbar: true,
      );
      expect(
        chrome.mainbar.computeLuminance(),
        lessThan(chrome.sidebar.computeLuminance()),
      );
    });

    test('an explicit title bar is kept', () {
      final chrome = Oito2ChromeColors.derive(
        background: _white,
        onSurface: _black,
        titleBar: const Color(0xFFEBEBEB),
      );
      expect(chrome.titleBar, const Color(0xFFEBEBEB));
    });

    test('fromTheme and fromColorScheme agree', () {
      final colors = Oito2ColorTheme.dark();
      final theme = ThemeData(
        colorScheme: colors.colorScheme,
        scaffoldBackgroundColor: colors.background,
      );
      expect(
        Oito2ChromeColors.fromTheme(theme),
        Oito2ChromeColors.fromColorScheme(
          colors.colorScheme,
          background: colors.background,
        ),
      );
    });

    test('copyWith, lerp and equality', () {
      final a = Oito2ChromeColors.derive(background: _white, onSurface: _black);
      final b = Oito2ChromeColors.derive(background: _black, onSurface: _white);
      expect(a.copyWith(), a);
      expect(a.copyWith(titleBar: _black).titleBar, _black);
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(a.lerp(null, 0.5), a);
      expect(a.hashCode, a.copyWith().hashCode);
      expect(a, isNot(b));
    });
  });
}
