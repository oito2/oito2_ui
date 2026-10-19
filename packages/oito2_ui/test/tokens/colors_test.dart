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

void main() {
  for (final brightness in Brightness.values) {
    final neutrals = Oito2NeutralPalette.of(brightness);
    final status = Oito2StatusPalette.of(brightness);

    group('${brightness.name} palettes', () {
      test('match the requested brightness', () {
        expect(neutrals.brightness, brightness);
        expect(status.brightness, brightness);
      });

      test('surfaces have the expected brightness', () {
        for (final surface in neutrals.surfaces) {
          expect(
            ThemeData.estimateBrightnessForColor(surface),
            brightness,
            reason: '$surface',
          );
        }
      });

      test('onSurface and onSurfaceVariant reach 4.5:1 on every surface', () {
        for (final surface in neutrals.surfaces) {
          for (final text in [neutrals.onSurface, neutrals.onSurfaceVariant]) {
            expect(
              Oito2Contrast.ratio(text, surface),
              greaterThanOrEqualTo(Oito2Contrast.textAA),
              reason: '$text on $surface',
            );
          }
        }
      });

      test('outline reaches 3:1 on every surface', () {
        for (final surface in neutrals.surfaces) {
          expect(
            Oito2Contrast.ratio(neutrals.outline, surface),
            greaterThanOrEqualTo(Oito2Contrast.nonTextAA),
            reason: 'outline on $surface',
          );
        }
      });

      test('status colors reach 4.5:1 on every surface', () {
        for (final surface in neutrals.surfaces) {
          for (final color in status.colors) {
            expect(
              Oito2Contrast.ratio(color, surface),
              greaterThanOrEqualTo(Oito2Contrast.textAA),
              reason: '$color on $surface',
            );
          }
        }
      });
    });
  }

  test('of returns the matching constant', () {
    expect(Oito2NeutralPalette.of(Brightness.light), Oito2NeutralPalette.light);
    expect(Oito2NeutralPalette.of(Brightness.dark), Oito2NeutralPalette.dark);
    expect(Oito2StatusPalette.of(Brightness.light), Oito2StatusPalette.light);
    expect(Oito2StatusPalette.of(Brightness.dark), Oito2StatusPalette.dark);
  });

  test('accent colors are opaque and distinct', () {
    final colors = Oito2AccentColor.values.map((a) => a.color).toList();
    expect(colors.every((c) => c.a == 1), isTrue);
    expect(colors.toSet(), hasLength(colors.length));
    expect(Oito2AccentColor.fallback, Oito2AccentColor.blue);
  });
}
