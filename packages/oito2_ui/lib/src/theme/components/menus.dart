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

/// Returns the surface shared by menus and dropdown lists: the container
/// surface with a thin `outlineVariant` border, the medium radius, a small
/// shadow and no surface tint.
MenuStyle buildMenuStyle(ComponentThemeContext c) {
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(c.scheme.surfaceContainer),
    surfaceTintColor: const WidgetStatePropertyAll(Color(0x00000000)),
    elevation: const WidgetStatePropertyAll(4),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: Oito2Radius.mediumAll,
        side: BorderSide(color: c.scheme.outlineVariant),
      ),
    ),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(vertical: Oito2Spacing.xs),
    ),
  );
}

/// Returns the theme of menus opened from a `MenuAnchor`, drawn with
/// [style].
MenuThemeData buildMenuTheme(MenuStyle style) => MenuThemeData(style: style);

/// Returns the theme of menu bars: the title bar tone, square and flat.
MenuBarThemeData buildMenuBarTheme(ComponentThemeContext c) {
  return MenuBarThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(c.chrome.titleBar),
      surfaceTintColor: const WidgetStatePropertyAll(Color(0x00000000)),
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
    ),
  );
}

/// Returns the theme of menu items: at least the control height,
/// offsetting the visual density the item applies on top of it, the small
/// radius and the medium body text. Items draw no border: hover, keyboard
/// focus and the selected item show only the highlighted background,
/// without the focus ring the button themes add.
MenuButtonThemeData buildMenuButtonTheme(ComponentThemeContext c) {
  final density = c.platform.visualDensity.baseSizeAdjustment;
  return MenuButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(64, c.controlHeight - density.dy),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Oito2Spacing.md),
      ),
      iconSize: WidgetStatePropertyAll(c.iconSize),
      textStyle: WidgetStatePropertyAll(c.textTheme.bodyMedium),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: Oito2Radius.smallAll),
      ),
      side: const WidgetStatePropertyAll(BorderSide.none),
      visualDensity: c.platform.visualDensity,
    ),
  );
}

/// Returns the theme of popup menus: the same surface as
/// [buildMenuStyle].
PopupMenuThemeData buildPopupMenuTheme(ComponentThemeContext c) {
  return PopupMenuThemeData(
    color: c.scheme.surfaceContainer,
    surfaceTintColor: const Color(0x00000000),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: Oito2Radius.mediumAll,
      side: BorderSide(color: c.scheme.outlineVariant),
    ),
    textStyle: c.textTheme.bodyMedium,
    menuPadding: const EdgeInsets.symmetric(vertical: Oito2Spacing.xs),
  );
}
