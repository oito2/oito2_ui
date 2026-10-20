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

/// Input fields: a soft `surfaceContainerHigh` fill, a 1-pixel `outline`
/// border that reaches 3:1 against the surface, a 2-pixel focus border in
/// the text-safe primary tone and error borders and messages in the
/// text-safe error tone.
///
/// A single-line field is [ComponentThemeContext.controlHeight] tall, the
/// height of the buttons, with or without prefix and suffix icons: the
/// vertical padding centers one line of `bodyLarge` text in that height,
/// net of the platform's visual density adjustment, and the icon boxes
/// are as wide as the field is tall, with no minimum height. Helper and error text are laid out below that height.
InputDecorationThemeData buildInputDecorationTheme(ComponentThemeContext c) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: Oito2Radius.mediumAll,
        borderSide: BorderSide(color: color, width: width),
      );
  final error = c.semantic.errorText;
  final height = c.controlHeight;
  final iconBox = BoxConstraints(minWidth: height);
  return InputDecorationThemeData(
    filled: true,
    fillColor: c.scheme.surfaceContainerHigh,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: Oito2Spacing.md,
      vertical:
          (height -
              inputLineHeight(c) -
              c.platform.visualDensity.baseSizeAdjustment.dy) /
          2,
    ),
    prefixIconConstraints: iconBox,
    suffixIconConstraints: iconBox,
    border: border(c.scheme.outline),
    enabledBorder: border(c.scheme.outline),
    focusedBorder: border(c.indicator, Oito2Sizes.focusBorderWidth),
    errorBorder: border(error),
    focusedErrorBorder: border(error, Oito2Sizes.focusBorderWidth),
    disabledBorder: border(
      ComponentThemeContext.fade(c.scheme.onSurface, 0.12),
    ),
    hintStyle: c.textTheme.bodyMedium?.copyWith(
      color: c.scheme.onSurfaceVariant,
    ),
    labelStyle: c.textTheme.bodyMedium?.copyWith(
      color: c.scheme.onSurfaceVariant,
    ),
    floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
      final color = states.contains(WidgetState.error)
          ? error
          : states.contains(WidgetState.focused)
          ? c.indicator
          : c.scheme.onSurfaceVariant;
      return (c.textTheme.bodyMedium ?? const TextStyle()).copyWith(
        color: color,
      );
    }),
    helperStyle: c.textTheme.bodySmall?.copyWith(
      color: c.scheme.onSurfaceVariant,
    ),
    errorStyle: c.textTheme.bodySmall?.copyWith(color: error),
    prefixIconColor: c.scheme.onSurfaceVariant,
    suffixIconColor: c.scheme.onSurfaceVariant,
  );
}

/// The height of one line of input text: the `bodyLarge` font size times
/// its line height, which is what `TextField` uses by default. Without an
/// explicit height, the `englishLike2021` geometry that `Theme.of`
/// merges in at run time applies.
double inputLineHeight(ComponentThemeContext c) {
  final style = c.textTheme.bodyLarge;
  final geometry = Typography.englishLike2021.bodyLarge!;
  final fontSize = style?.fontSize ?? geometry.fontSize!;
  return fontSize * (style?.height ?? geometry.height!);
}

/// Text selection: the primary fill at 35% alpha, with the cursor and
/// handles in the text-safe primary tone.
TextSelectionThemeData buildTextSelectionTheme(ComponentThemeContext c) {
  return TextSelectionThemeData(
    selectionColor: ComponentThemeContext.fade(c.scheme.primary, 0.35),
    cursorColor: c.indicator,
    selectionHandleColor: c.indicator,
  );
}

/// Dropdown menus: the input field style for the anchor and the menu
/// surface style for the list.
DropdownMenuThemeData buildDropdownMenuTheme(
  ComponentThemeContext c,
  InputDecorationThemeData inputDecorationTheme,
  MenuStyle menuStyle,
) {
  return DropdownMenuThemeData(
    inputDecorationTheme: inputDecorationTheme,
    menuStyle: menuStyle,
    textStyle: c.textTheme.bodyMedium,
  );
}
