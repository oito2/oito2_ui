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

// Writes the oito2_ui design tokens as a JSON fixture for the sibling
// implementations. Run with `flutter test` from tools/parity.

import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart' show TextStyle;
import 'package:material_ui/material_ui.dart' show Typography;
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'support.dart';

Map<String, String> neutrals(Oito2NeutralPalette p) => {
  'surface': hex(p.surface),
  'surfaceContainerLowest': hex(p.surfaceContainerLowest),
  'surfaceContainerLow': hex(p.surfaceContainerLow),
  'surfaceContainer': hex(p.surfaceContainer),
  'surfaceContainerHigh': hex(p.surfaceContainerHigh),
  'surfaceContainerHighest': hex(p.surfaceContainerHighest),
  'titleBar': hex(p.titleBar),
  'onSurface': hex(p.onSurface),
  'onSurfaceVariant': hex(p.onSurfaceVariant),
  'outline': hex(p.outline),
  'outlineVariant': hex(p.outlineVariant),
};

Map<String, String> status(Oito2StatusPalette p) => {
  'success': hex(p.success),
  'warning': hex(p.warning),
  'error': hex(p.error),
  'info': hex(p.info),
  'link': hex(p.link),
};

/// The size, line height, weight and letter spacing of every style of the
/// light oito2 text theme, keyed by the Material style name. The theme is
/// merged over the Material 2021 English-like geometry, as ThemeData does.
Map<String, Object> textScale() {
  final theme = Typography.material2021().englishLike.merge(
    Oito2Typography.textTheme(Brightness.light),
  );
  final styles = <String, TextStyle?>{
    'displayLarge': theme.displayLarge,
    'displayMedium': theme.displayMedium,
    'displaySmall': theme.displaySmall,
    'headlineLarge': theme.headlineLarge,
    'headlineMedium': theme.headlineMedium,
    'headlineSmall': theme.headlineSmall,
    'titleLarge': theme.titleLarge,
    'titleMedium': theme.titleMedium,
    'titleSmall': theme.titleSmall,
    'bodyLarge': theme.bodyLarge,
    'bodyMedium': theme.bodyMedium,
    'bodySmall': theme.bodySmall,
    'labelLarge': theme.labelLarge,
    'labelMedium': theme.labelMedium,
    'labelSmall': theme.labelSmall,
  };
  return {
    for (final MapEntry(:key, :value) in styles.entries)
      key: {
        'fontSize': value!.fontSize,
        'lineHeight': value.fontSize! * value.height!,
        'fontWeight': value.fontWeight!.value,
        'letterSpacing': value.letterSpacing,
      },
  };
}

void main() {
  test('exports the design tokens', () {
    final tokens = <String, Object>{
      'radius': {
        'check': Oito2Radius.check,
        'small': Oito2Radius.small,
        'medium': Oito2Radius.medium,
        'large': Oito2Radius.large,
        'window': Oito2Radius.window,
      },
      'spacing': {
        'xxs': Oito2Spacing.xxs,
        'xs': Oito2Spacing.xs,
        'sm': Oito2Spacing.sm,
        'md': Oito2Spacing.md,
        'lg': Oito2Spacing.lg,
        'page': Oito2Spacing.page,
        'xl': Oito2Spacing.xl,
        'xxl': Oito2Spacing.xxl,
        'xxxl': Oito2Spacing.xxxl,
      },
      'sizes': {
        'buttonHeight': Oito2Sizes.buttonHeight,
        'touchButtonHeight': Oito2Sizes.touchButtonHeight,
        'titleBarHeight': Oito2Sizes.titleBarHeight,
        'titleBarItemHeight': Oito2Sizes.titleBarItemHeight,
        'iconSize': Oito2Sizes.iconSize,
        'progressHeight': Oito2Sizes.progressHeight,
        'focusBorderWidth': Oito2Sizes.focusBorderWidth,
        'windowControlSize': Oito2Sizes.windowControlSize,
        'windowsWindowControlWidth': Oito2Sizes.windowsWindowControlWidth,
        'minPointerTarget': Oito2Sizes.minPointerTarget,
        'minTouchTarget': Oito2Sizes.minTouchTarget,
      },
      'accents': {
        for (final accent in Oito2AccentColor.values)
          accent.name: hex(accent.color),
      },
      'neutrals': {
        'light': neutrals(Oito2NeutralPalette.light),
        'dark': neutrals(Oito2NeutralPalette.dark),
      },
      'status': {
        'light': status(Oito2StatusPalette.light),
        'dark': status(Oito2StatusPalette.dark),
      },
      'typography': {
        'fontFamilyFallback': Oito2Typography.fontFamilyFallback,
        'bodyLargeSize': Oito2Typography.bodyLargeSize,
        'bodyMediumSize': Oito2Typography.bodyMediumSize,
        'bodySmallSize': Oito2Typography.bodySmallSize,
        'emphasisWeight': Oito2Typography.emphasisWeight.value,
        'scale': textScale(),
      },
    };

    expect(writeFixture('tokens.json', tokens).existsSync(), isTrue);
  });
}
