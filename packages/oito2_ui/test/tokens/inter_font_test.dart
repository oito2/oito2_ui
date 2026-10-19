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

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _family = 'InterAssetTest';

double _textWidth(FontWeight weight) {
  final painter = TextPainter(
    text: TextSpan(
      text: 'The quick brown fox jumps over the lazy dog',
      style: TextStyle(fontFamily: _family, fontSize: 20, fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final bytes = rootBundle.load(
      'packages/oito2_ui/assets/fonts/inter/InterVariable.ttf',
    );
    await (FontLoader(_family)..addFont(bytes)).load();
  });

  test('Inter variable font maps FontWeight to its weight axis', () {
    final widths = [
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w600,
      FontWeight.w700,
    ].map(_textWidth).toList();

    for (var i = 1; i < widths.length; i++) {
      expect(widths[i], greaterThan(widths[i - 1]));
    }
  });

  test('Inter italic variable font is bundled', () async {
    final data = await rootBundle.load(
      'packages/oito2_ui/assets/fonts/inter/InterVariable-Italic.ttf',
    );
    expect(data.lengthInBytes, greaterThan(0));
  });
}
