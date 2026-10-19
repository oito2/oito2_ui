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
    test('takes the sidebar and mainbar from the container roles', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF3584E4),
        brightness: Brightness.dark,
      );
      final chrome = Oito2ChromeColors.fromColorScheme(
        scheme,
        background: _black,
      );
      expect(chrome.background, _black);
      expect(chrome.sidebar, scheme.surfaceContainer);
      expect(chrome.mainbar, scheme.surfaceContainerHighest);
      expect(chrome.titleBar, scheme.surfaceContainer);
      expect(chrome.dialog, scheme.surfaceContainerHigh);
    });

    test('dialogs use surface in a light scheme', () {
      final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3584E4));
      final chrome = Oito2ChromeColors.fromColorScheme(
        scheme,
        background: _white,
      );
      expect(chrome.dialog, scheme.surface);
    });

    test('a chrome surface too close to the background is moved apart', () {
      final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3584E4))
          .copyWith(surfaceContainer: const Color(0xFFF0F0F0));
      final chrome = Oito2ChromeColors.fromColorScheme(
        scheme,
        background: const Color(0xFFF0F0F0),
      );
      for (final other in [chrome.background, chrome.mainbar]) {
        expect(
          Oito2Contrast.ratio(chrome.sidebar, other),
          greaterThanOrEqualTo(Oito2ChromeColors.minimumStep),
        );
      }
    });

    test('an explicit title bar is kept', () {
      final chrome = Oito2ChromeColors.fromColorScheme(
        ColorScheme.fromSeed(seedColor: const Color(0xFF3584E4)),
        background: _white,
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
      final a = Oito2ColorTheme.light().chrome;
      final b = Oito2ColorTheme.dark().chrome;
      expect(a.copyWith(), a);
      expect(a.copyWith(titleBar: _black).titleBar, _black);
      expect(a.copyWith(dialog: _black).dialog, _black);
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(a.lerp(null, 0.5), a);
      expect(a.hashCode, a.copyWith().hashCode);
      expect(a, isNot(b));
    });
  });
}
