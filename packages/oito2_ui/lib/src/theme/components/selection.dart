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

/// Whether [states] holds [WidgetState.selected] without
/// [WidgetState.disabled].
bool _activeSelected(Set<WidgetState> states) =>
    states.contains(WidgetState.selected) &&
    !states.contains(WidgetState.disabled);

MaterialTapTargetSize _tapTarget(ComponentThemeContext c) =>
    c.isTouch ? MaterialTapTargetSize.padded : MaterialTapTargetSize.shrinkWrap;

/// Check boxes: the check radius, an `outline` border and the text-safe
/// primary fill when checked, so the checked state reaches 3:1 against
/// every surface.
CheckboxThemeData buildCheckboxTheme(ComponentThemeContext c) {
  return CheckboxThemeData(
    shape: const RoundedRectangleBorder(borderRadius: Oito2Radius.checkAll),
    side: WidgetStateBorderSide.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return BorderSide(
          color: ComponentThemeContext.fade(c.scheme.onSurface, 0.38),
          width: 1.5,
        );
      }
      if (states.contains(WidgetState.selected)) {
        return const BorderSide(width: 0, color: Color(0x00000000));
      }
      return BorderSide(color: c.scheme.outline, width: 1.5);
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled) &&
          states.contains(WidgetState.selected)) {
        return ComponentThemeContext.fade(c.scheme.onSurface, 0.38);
      }
      return _activeSelected(states) ? c.indicator : null;
    }),
    checkColor: WidgetStatePropertyAll(c.onIndicator),
    materialTapTargetSize: _tapTarget(c),
    visualDensity: c.platform.visualDensity,
  );
}

/// Radio buttons: the text-safe primary tone when selected and `outline`
/// otherwise.
RadioThemeData buildRadioTheme(ComponentThemeContext c) {
  return RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return ComponentThemeContext.fade(c.scheme.onSurface, 0.38);
      }
      return states.contains(WidgetState.selected)
          ? c.indicator
          : c.scheme.outline;
    }),
    materialTapTargetSize: _tapTarget(c),
    visualDensity: c.platform.visualDensity,
  );
}

/// Switches: the text-safe primary track when on, with a thumb in its
/// on-color.
SwitchThemeData buildSwitchTheme(ComponentThemeContext c) {
  return SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith(
      (states) => _activeSelected(states) ? c.indicator : null,
    ),
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => _activeSelected(states) ? c.onIndicator : null,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? null
          : states.contains(WidgetState.disabled)
          ? null
          : c.scheme.outline,
    ),
    materialTapTargetSize: _tapTarget(c),
  );
}

/// Sliders: the text-safe primary tone for the active track and thumb.
SliderThemeData buildSliderTheme(ComponentThemeContext c) {
  return SliderThemeData(
    activeTrackColor: c.indicator,
    thumbColor: c.indicator,
    inactiveTrackColor: c.scheme.surfaceContainerHighest,
    overlayColor: ComponentThemeContext.fade(c.indicator, 0.12),
    valueIndicatorColor: c.scheme.inverseSurface,
    valueIndicatorTextStyle: c.textTheme.labelMedium?.copyWith(
      color: c.scheme.onInverseSurface,
    ),
  );
}

/// Progress indicators: the text-safe primary tone on the highest
/// container track.
ProgressIndicatorThemeData buildProgressIndicatorTheme(
  ComponentThemeContext c,
) {
  return ProgressIndicatorThemeData(
    color: c.indicator,
    linearTrackColor: c.scheme.surfaceContainerHighest,
    circularTrackColor: const Color(0x00000000),
    linearMinHeight: 4,
    borderRadius: const BorderRadius.all(Radius.circular(2)),
  );
}

/// Chips: the medium radius, an `outlineVariant` border and the
/// secondary container when selected.
///
/// A chip is 32 pixels tall plus its label's vertical padding, its
/// 1-pixel side above and below and half of the visual density
/// adjustment; the label padding is set so that the chip is
/// [ComponentThemeContext.controlHeight] tall.
ChipThemeData buildChipTheme(ComponentThemeContext c) {
  const chipBaseHeight = 32.0;
  const sides = 2.0;
  final labelPadding =
      (c.controlHeight -
          chipBaseHeight -
          sides -
          c.platform.visualDensity.baseSizeAdjustment.dy / 2) /
      2;
  return ChipThemeData(
    shape: const RoundedRectangleBorder(borderRadius: Oito2Radius.mediumAll),
    side: WidgetStateBorderSide.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const BorderSide(color: Color(0x00000000))
          : BorderSide(color: c.scheme.outline),
    ),
    backgroundColor: c.scheme.surface,
    selectedColor: c.scheme.secondaryContainer,
    checkmarkColor: c.scheme.onSecondaryContainer,
    labelStyle: c.textTheme.labelLarge,
    iconTheme: IconThemeData(size: Oito2Sizes.iconSize - 2),
    padding: const EdgeInsets.symmetric(horizontal: Oito2Spacing.xs),
    labelPadding: EdgeInsets.symmetric(
      horizontal: Oito2Spacing.sm,
      vertical: labelPadding,
    ),
  );
}
