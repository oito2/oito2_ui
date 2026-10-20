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

import 'package:material_ui/material_ui.dart';

import '../../tokens/geometry.dart';
import 'component_context.dart';

/// The shape, size, padding and text style shared by every text button
/// variant.
ButtonStyle _baseButtonStyle(ComponentThemeContext c, {BorderSide? side}) {
  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(64, c.controlHeight)),
    fixedSize: WidgetStatePropertyAll(Size.fromHeight(c.controlHeight)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: Oito2Spacing.lg),
    ),
    iconSize: WidgetStatePropertyAll(c.iconSize),
    textStyle: WidgetStatePropertyAll(c.textTheme.labelLarge),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: Oito2Radius.mediumAll),
    ),
    side: c.focusRing(otherwise: side),
    tapTargetSize: c.isTouch
        ? MaterialTapTargetSize.padded
        : MaterialTapTargetSize.shrinkWrap,
    visualDensity: c.platform.visualDensity,
  );
}

/// Filled buttons: the scheme's primary fill with its on-color.
FilledButtonThemeData buildFilledButtonTheme(ComponentThemeContext c) {
  return FilledButtonThemeData(
    style: _baseButtonStyle(c).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? ComponentThemeContext.fade(c.scheme.onSurface, 0.12)
            : c.scheme.primary,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? ComponentThemeContext.fade(c.scheme.onSurface, 0.38)
            : c.scheme.onPrimary,
      ),
    ),
  );
}

/// Elevated buttons: the neutral desktop button, a raised container
/// surface that gains a shadow on hover.
ElevatedButtonThemeData buildElevatedButtonTheme(ComponentThemeContext c) {
  return ElevatedButtonThemeData(
    style: _baseButtonStyle(c).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? ComponentThemeContext.fade(c.scheme.onSurface, 0.12)
            : c.scheme.surfaceContainerHigh,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? ComponentThemeContext.fade(c.scheme.onSurface, 0.38)
            : c.scheme.onSurface,
      ),
      elevation: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.hovered) &&
                !states.contains(WidgetState.disabled)
            ? 1
            : 0,
      ),
      shadowColor: WidgetStatePropertyAll(c.scheme.shadow),
      surfaceTintColor: const WidgetStatePropertyAll(Color(0x00000000)),
    ),
  );
}

/// Outlined buttons: a 1-pixel `outline` border with text-safe primary
/// text.
OutlinedButtonThemeData buildOutlinedButtonTheme(ComponentThemeContext c) {
  return OutlinedButtonThemeData(
    style: _baseButtonStyle(c).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? ComponentThemeContext.fade(c.scheme.onSurface, 0.38)
            : c.indicator,
      ),
      side: c.focusRing(otherwise: BorderSide(color: c.scheme.outline)),
    ),
  );
}

/// Text buttons: text-safe primary text without a container.
TextButtonThemeData buildTextButtonTheme(ComponentThemeContext c) {
  return TextButtonThemeData(
    style: _baseButtonStyle(c).copyWith(
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Oito2Spacing.md),
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? ComponentThemeContext.fade(c.scheme.onSurface, 0.38)
            : c.indicator,
      ),
    ),
  );
}

/// Icon buttons: square, [ComponentThemeContext.controlHeight] wide on
/// pointer platforms, with the focus ring.
IconButtonThemeData buildIconButtonTheme(ComponentThemeContext c) {
  return IconButtonThemeData(
    style: ButtonStyle(
      iconSize: WidgetStatePropertyAll(c.iconSize),
      minimumSize: WidgetStatePropertyAll(Size.square(c.controlHeight)),
      fixedSize: c.isTouch
          ? null
          : WidgetStatePropertyAll(Size.square(c.controlHeight)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: Oito2Radius.mediumAll),
      ),
      side: c.focusRing(),
      tapTargetSize: c.isTouch
          ? MaterialTapTargetSize.padded
          : MaterialTapTargetSize.shrinkWrap,
    ),
  );
}

/// Segmented buttons: control height, medium radius and `outline`
/// borders, with the selected segment in the secondary container.
///
/// `SegmentedButton` keeps neither `minimumSize` nor `fixedSize` for its
/// segments: each one is a text button 40 pixels tall adjusted by the
/// style's visual density. The vertical density is therefore set to bring
/// that height to [ComponentThemeContext.controlHeight].
SegmentedButtonThemeData buildSegmentedButtonTheme(ComponentThemeContext c) {
  const segmentBaseHeight = 40.0;
  final density = VisualDensity(
    horizontal: c.platform.visualDensity.horizontal,
    vertical: (c.controlHeight - segmentBaseHeight) / 4,
  );
  return SegmentedButtonThemeData(
    style: ButtonStyle(
      iconSize: WidgetStatePropertyAll(c.iconSize),
      textStyle: WidgetStatePropertyAll(c.textTheme.labelLarge),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: Oito2Radius.mediumAll),
      ),
      side: c.focusRing(otherwise: BorderSide(color: c.scheme.outline)),
      tapTargetSize: c.isTouch
          ? MaterialTapTargetSize.padded
          : MaterialTapTargetSize.shrinkWrap,
      visualDensity: density,
    ),
  );
}

/// Floating action buttons: large radius and no elevation tint.
FloatingActionButtonThemeData buildFloatingActionButtonTheme(
  ComponentThemeContext c,
) {
  return FloatingActionButtonThemeData(
    backgroundColor: c.scheme.primaryContainer,
    foregroundColor: c.scheme.onPrimaryContainer,
    shape: const RoundedRectangleBorder(borderRadius: Oito2Radius.largeAll),
    elevation: 2,
    hoverElevation: 3,
    focusElevation: 3,
  );
}
