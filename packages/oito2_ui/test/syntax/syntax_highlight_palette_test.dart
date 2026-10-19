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

const _grey = Color(0xFF999999);

const _palette = SyntaxHighlightPalette(
  foreground: Color(0xFF000000),
  comment: _grey,
  keyword: _grey,
  string: _grey,
  number: _grey,
  function: _grey,
  type: _grey,
  tag: _grey,
  attribute: _grey,
  constant: _grey,
  invalid: _grey,
);

void main() {
  test('exposes the 11 token roles in declaration order', () {
    expect(_palette.colors, hasLength(11));
    expect(_palette.colors.first, _palette.foreground);
    expect(_palette.colors.last, _palette.invalid);
  });

  test('ensureContrast fixes only the roles that fail', () {
    const background = Color(0xFFFFFFFF);
    final fixed = _palette.ensureContrast(const [background]);
    expect(fixed.foreground, _palette.foreground);
    for (final color in fixed.colors) {
      expect(
        Oito2Contrast.ratio(color, background),
        greaterThanOrEqualTo(Oito2Contrast.textAA),
      );
    }
  });

  test('ensureContrast honors a custom target', () {
    const background = Color(0xFFFFFFFF);
    final fixed = _palette.ensureContrast(const [
      background,
    ], target: Oito2Contrast.textAAA);
    expect(
      Oito2Contrast.minRatio(fixed.comment, const [background]),
      greaterThanOrEqualTo(Oito2Contrast.textAAA),
    );
  });

  test('every preset provides a distinct keyword and string color', () {
    for (final preset in Oito2ThemePreset.values) {
      final syntax = Oito2ColorTheme.fromPreset(preset).syntax;
      expect(syntax.keyword, isNot(syntax.string), reason: preset.name);
    }
  });

  test('equality and hashCode', () {
    final copy = _palette.ensureContrast(const []);
    expect(copy, _palette);
    expect(copy.hashCode, _palette.hashCode);
  });

  test('copyWith and lerp', () {
    const white = Color(0xFFFFFFFF);
    expect(_palette.copyWith(), _palette);
    expect(_palette.copyWith(type: white).type, white);
    final target = _palette.copyWith(comment: white);
    expect(_palette.lerp(target, 0), _palette);
    expect(_palette.lerp(target, 1), target);
    expect(_palette.lerp(null, 0.5), _palette);
  });

  group('Oito2SyntaxTheme', () {
    const extension = Oito2SyntaxTheme(_palette);

    test('copyWith, lerp and equality', () {
      final other = Oito2SyntaxTheme(
        _palette.copyWith(keyword: const Color(0xFF123456)),
      );
      expect(extension.copyWith(), extension);
      expect(extension.copyWith(palette: other.palette), other);
      expect(extension.lerp(other, 1), other);
      expect(extension.lerp(null, 0.5), extension);
      expect(extension.hashCode, const Oito2SyntaxTheme(_palette).hashCode);
      expect(extension, isNot(other));
    });

    testWidgets('maybeOf reads the palette from the theme', (tester) async {
      SyntaxHighlightPalette? found;
      await tester.pumpWidget(
        Theme(
          data: ThemeData(extensions: const [extension]),
          child: Builder(
            builder: (context) {
              found = Oito2SyntaxTheme.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(found, _palette);
    });
  });
}
