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

const _black = Color(0xFF000000);
const _white = Color(0xFFFFFFFF);

void main() {
  group('ratio', () {
    test('black on white is 21', () {
      expect(Oito2Contrast.ratio(_black, _white), closeTo(21, 0.01));
    });

    test('is symmetric', () {
      const a = Color(0xFF3584E4);
      expect(Oito2Contrast.ratio(a, _white), Oito2Contrast.ratio(_white, a));
    });

    test('a color against itself is 1', () {
      const a = Color(0xFF777777);
      expect(Oito2Contrast.ratio(a, a), closeTo(1, 0.0001));
    });

    test('matches a known WCAG value', () {
      // #767676 on white is the classic 4.54:1 reference pair.
      expect(
        Oito2Contrast.ratio(const Color(0xFF767676), _white),
        closeTo(4.54, 0.01),
      );
    });

    test('ignores alpha', () {
      expect(
        Oito2Contrast.ratio(const Color(0x00000000), _white),
        closeTo(21, 0.01),
      );
    });
  });

  test('foregroundFor picks the higher-contrast of black and white', () {
    expect(Oito2Contrast.foregroundFor(_white), _black);
    expect(Oito2Contrast.foregroundFor(const Color(0xFFF8E45C)), _black);
    expect(Oito2Contrast.foregroundFor(_black), _white);
    expect(Oito2Contrast.foregroundFor(const Color(0xFF202020)), _white);
    // Luminance below 0.5, yet black contrasts more (5.57 vs 3.77).
    expect(Oito2Contrast.foregroundFor(const Color(0xFF3584E4)), _black);
    expect(Oito2Contrast.foregroundFor(const Color(0xFF9141AC)), _white);
  });

  test('minRatio returns the lowest ratio, or 21 without backgrounds', () {
    const grey = Color(0xFF777777);
    expect(
      Oito2Contrast.minRatio(_black, const [_white, grey]),
      Oito2Contrast.ratio(_black, grey),
    );
    expect(Oito2Contrast.minRatio(_black, const []), 21);
  });

  group('ensure', () {
    test('returns the color unchanged when it already passes', () {
      const color = Color(0xFF1966C2);
      expect(Oito2Contrast.ensure(color, const [_white], 4.5), color);
    });

    test('darkens on light backgrounds until the target is met', () {
      const accent = Color(0xFF3584E4);
      final fixed = Oito2Contrast.ensure(accent, const [_white], 4.5);
      expect(Oito2Contrast.ratio(fixed, _white), greaterThanOrEqualTo(4.5));
      expect(fixed.computeLuminance(), lessThan(accent.computeLuminance()));
      final before = HSLColor.fromColor(accent);
      final after = HSLColor.fromColor(fixed);
      expect(after.hue, closeTo(before.hue, 1));
      expect(after.saturation, closeTo(before.saturation, 0.02));
    });

    test('lightens on dark backgrounds until the target is met', () {
      const red = Color(0xFFBF616A);
      const dark = Color(0xFF3B4252);
      final fixed = Oito2Contrast.ensure(red, const [dark], 4.5);
      expect(Oito2Contrast.ratio(fixed, dark), greaterThanOrEqualTo(4.5));
      expect(fixed.computeLuminance(), greaterThan(red.computeLuminance()));
    });

    test('satisfies every background at once', () {
      const backgrounds = [Color(0xFFFFFFFF), Color(0xFFE8E8E8)];
      final fixed = Oito2Contrast.ensure(
        const Color(0xFFC88800),
        backgrounds,
        4.5,
      );
      expect(
        Oito2Contrast.minRatio(fixed, backgrounds),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('falls back to black or white when no lightness passes', () {
      const backgrounds = [_white, _black];
      expect(
        Oito2Contrast.ensure(const Color(0xFF3584E4), backgrounds, 15),
        anyOf(_black, _white),
      );
    });

    test('keeps the alpha channel', () {
      final fixed = Oito2Contrast.ensure(const Color(0x803584E4), const [
        _white,
      ], 4.5);
      expect(fixed.a, closeTo(0x80 / 255, 0.01));
    });
  });
}
