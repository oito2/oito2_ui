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

/// The fifteen Material 3 text styles of [t], from displayLarge to
/// labelSmall.
List<TextStyle> _styles(TextTheme t) => [
  t.displayLarge!,
  t.displayMedium!,
  t.displaySmall!,
  t.headlineLarge!,
  t.headlineMedium!,
  t.headlineSmall!,
  t.titleLarge!,
  t.titleMedium!,
  t.titleSmall!,
  t.bodyLarge!,
  t.bodyMedium!,
  t.bodySmall!,
  t.labelLarge!,
  t.labelMedium!,
  t.labelSmall!,
];

void main() {
  for (final brightness in Brightness.values) {
    group('${brightness.name} text theme', () {
      final theme = Oito2Typography.textTheme(brightness);

      test('uses the bundled Inter with unprefixed system fallbacks', () {
        for (final style in _styles(theme)) {
          expect(style.fontFamily, 'packages/oito2_ui/Inter');
          expect(style.fontFamilyFallback, Oito2Typography.fontFamilyFallback);
        }
      });

      test('sets body sizes to 16, 14 and 12', () {
        expect(theme.bodyLarge!.fontSize, 16);
        expect(theme.bodyMedium!.fontSize, 14);
        expect(theme.bodySmall!.fontSize, 12);
      });

      test('emphasizes headlines, titles and labelLarge', () {
        for (final style in [
          theme.headlineLarge!,
          theme.headlineMedium!,
          theme.headlineSmall!,
          theme.titleLarge!,
          theme.titleMedium!,
          theme.titleSmall!,
          theme.labelLarge!,
        ]) {
          expect(style.fontWeight, FontWeight.w600);
        }
      });

      test('uses glyph colors for the brightness', () {
        final color = theme.bodyMedium!.color!;
        expect(
          ThemeData.estimateBrightnessForColor(color),
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        );
      });
    });
  }
}
