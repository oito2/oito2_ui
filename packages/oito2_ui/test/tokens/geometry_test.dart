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

void main() {
  test('radii grow from check to window', () {
    const radii = [
      Oito2Radius.check,
      Oito2Radius.small,
      Oito2Radius.medium,
      Oito2Radius.large,
      Oito2Radius.window,
    ];
    for (var i = 1; i < radii.length; i++) {
      expect(radii[i], greaterThan(radii[i - 1]));
    }
  });

  test('border radius constants match their radius values', () {
    expect(Oito2Radius.checkAll, BorderRadius.circular(Oito2Radius.check));
    expect(Oito2Radius.smallAll, BorderRadius.circular(Oito2Radius.small));
    expect(Oito2Radius.mediumAll, BorderRadius.circular(Oito2Radius.medium));
    expect(Oito2Radius.largeAll, BorderRadius.circular(Oito2Radius.large));
    expect(Oito2Radius.windowAll, BorderRadius.circular(Oito2Radius.window));
  });

  test('spacing follows the 4-point scale above xxs', () {
    const spacing = [
      Oito2Spacing.xs,
      Oito2Spacing.sm,
      Oito2Spacing.md,
      Oito2Spacing.lg,
      Oito2Spacing.page,
      Oito2Spacing.xl,
      Oito2Spacing.xxl,
      Oito2Spacing.xxxl,
    ];
    for (final value in spacing) {
      expect(value % 4, 0, reason: '$value');
    }
    for (var i = 1; i < spacing.length; i++) {
      expect(spacing[i], greaterThan(spacing[i - 1]));
    }
  });

  test('controls meet the minimum pointer target size', () {
    expect(
      Oito2Sizes.buttonHeight,
      greaterThanOrEqualTo(Oito2Sizes.minPointerTarget),
    );
    expect(
      Oito2Sizes.windowControlSize,
      greaterThanOrEqualTo(Oito2Sizes.minPointerTarget),
    );
    expect(
      Oito2Sizes.titleBarItemHeight,
      lessThanOrEqualTo(Oito2Sizes.titleBarHeight),
    );
  });
}
