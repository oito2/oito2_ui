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

import 'package:material_ui/material_ui.dart';

import '../../tokens/geometry.dart';
import 'component_context.dart';

/// Returns the shape, size, padding and text style shared by every text
/// button variant, with the focus ring under keyboard focus and [side]
/// otherwise.
///
/// Buttons are at least [ComponentThemeContext.controlHeight] tall and grow
/// when the label needs more room, such as under a large text scale. The
/// minimum height offsets the visual density, which the button applies on
/// top of it.
ButtonStyle _baseButtonStyle(ComponentThemeContext c, {BorderSide? side}) {
  final density = c.platform.visualDensity.baseSizeAdjustment;
  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(64, c.controlHeight - density.dy)),
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

/// Returns the theme of filled buttons: the scheme's primary fill with its
/// on-color.
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

/// Returns the theme of elevated buttons: the neutral desktop button, a
/// raised container surface that gains a shadow on hover.
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

/// Returns the theme of outlined buttons: a 1-pixel `outline` border with
/// text-safe primary text.
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

/// Returns the theme of text buttons: text-safe primary text without a
/// container, with narrower padding.
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

/// Returns the theme of icon buttons: square, at least
/// [ComponentThemeContext.controlHeight] wide and exactly that size on
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

/// Returns the theme of segmented buttons: control height, medium radius
/// and `outline` borders; the selected segment keeps the Material
/// secondary container fill.
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

/// Returns the theme of floating action buttons: the primary container
/// with the large radius and low elevations.
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
