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

  test('foregroundFor picks black on light and white on dark', () {
    expect(Oito2Contrast.foregroundFor(_white), _black);
    expect(Oito2Contrast.foregroundFor(const Color(0xFFF8E45C)), _black);
    expect(Oito2Contrast.foregroundFor(_black), _white);
    expect(Oito2Contrast.foregroundFor(const Color(0xFF202020)), _white);
  });
}
