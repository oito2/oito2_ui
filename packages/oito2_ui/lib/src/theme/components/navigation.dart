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

/// App bars: the title bar tone without elevation or scroll tint. On
/// pointer platforms they are [Oito2Sizes.titleBarHeight] tall with a
/// bottom border, and native Linux centers the title as GNOME does.
AppBarThemeData buildAppBarTheme(ComponentThemeContext c) {
  final isPointer = !c.isTouch;
  return AppBarThemeData(
    backgroundColor: c.chrome.titleBar,
    foregroundColor: c.scheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: const Color(0x00000000),
    toolbarHeight: isPointer ? Oito2Sizes.titleBarHeight : null,
    centerTitle: c.platform.isDesktopNative && c.platform.isLinux ? true : null,
    titleTextStyle: c.textTheme.titleMedium,
    iconTheme: IconThemeData(color: c.scheme.onSurface, size: c.iconSize),
    actionsIconTheme: IconThemeData(
      color: c.scheme.onSurface,
      size: c.iconSize,
    ),
    shape: isPointer
        ? Border(bottom: BorderSide(color: c.scheme.outlineVariant))
        : null,
  );
}

/// Tab bars: the text-safe primary tone for the selected label and
/// indicator.
TabBarThemeData buildTabBarTheme(ComponentThemeContext c) {
  return TabBarThemeData(
    labelColor: c.indicator,
    unselectedLabelColor: c.scheme.onSurfaceVariant,
    indicatorColor: c.indicator,
    dividerColor: c.scheme.outlineVariant,
    labelStyle: c.textTheme.labelLarge,
    unselectedLabelStyle: c.textTheme.labelLarge,
    indicatorSize: TabBarIndicatorSize.label,
  );
}

/// Navigation rails: the sidebar tone with the secondary container
/// indicator.
NavigationRailThemeData buildNavigationRailTheme(ComponentThemeContext c) {
  return NavigationRailThemeData(
    backgroundColor: c.chrome.sidebar,
    indicatorColor: c.scheme.secondaryContainer,
    selectedIconTheme: IconThemeData(
      color: c.scheme.onSecondaryContainer,
      size: c.iconSize,
    ),
    unselectedIconTheme: IconThemeData(
      color: c.scheme.onSurfaceVariant,
      size: c.iconSize,
    ),
    selectedLabelTextStyle: c.textTheme.labelMedium?.copyWith(
      color: c.scheme.onSurface,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelTextStyle: c.textTheme.labelMedium?.copyWith(
      color: c.scheme.onSurfaceVariant,
    ),
  );
}

/// Navigation bars: the sidebar tone, 64 tall on pointer platforms.
NavigationBarThemeData buildNavigationBarTheme(ComponentThemeContext c) {
  return NavigationBarThemeData(
    backgroundColor: c.chrome.sidebar,
    surfaceTintColor: const Color(0x00000000),
    elevation: 0,
    height: c.isTouch ? null : 64,
    indicatorColor: c.scheme.secondaryContainer,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        size: c.iconSize,
        color: states.contains(WidgetState.selected)
            ? c.scheme.onSecondaryContainer
            : c.scheme.onSurfaceVariant,
      ),
    ),
  );
}

/// Navigation drawers: the chrome dialog tone with the secondary container
/// indicator.
NavigationDrawerThemeData buildNavigationDrawerTheme(ComponentThemeContext c) {
  return NavigationDrawerThemeData(
    backgroundColor: c.chrome.dialog,
    surfaceTintColor: const Color(0x00000000),
    indicatorColor: c.scheme.secondaryContainer,
    indicatorShape: const RoundedRectangleBorder(
      borderRadius: Oito2Radius.mediumAll,
    ),
    tileHeight: c.isTouch ? null : 40,
  );
}

/// List tiles: the medium radius, compact padding on pointer platforms and
/// the text-safe primary tone when selected.
ListTileThemeData buildListTileTheme(ComponentThemeContext c) {
  return ListTileThemeData(
    shape: const RoundedRectangleBorder(borderRadius: Oito2Radius.mediumAll),
    contentPadding: EdgeInsets.symmetric(
      horizontal: c.isTouch ? Oito2Spacing.lg : Oito2Spacing.md,
    ),
    iconColor: c.scheme.onSurfaceVariant,
    textColor: c.scheme.onSurface,
    selectedColor: c.indicator,
    selectedTileColor: ComponentThemeContext.fade(c.scheme.primary, 0.12),
    titleTextStyle: c.textTheme.bodyLarge,
    subtitleTextStyle: c.textTheme.bodyMedium?.copyWith(
      color: c.scheme.onSurfaceVariant,
    ),
    visualDensity: c.platform.visualDensity,
    minVerticalPadding: c.isTouch ? null : Oito2Spacing.xs,
  );
}

/// Expansion tiles: no borders when expanded or collapsed and the
/// text-safe primary tone for the expanded icon.
ExpansionTileThemeData buildExpansionTileTheme(ComponentThemeContext c) {
  return ExpansionTileThemeData(
    shape: const Border(),
    collapsedShape: const Border(),
    iconColor: c.indicator,
    collapsedIconColor: c.scheme.onSurfaceVariant,
    textColor: c.scheme.onSurface,
    collapsedTextColor: c.scheme.onSurface,
  );
}

/// Scrollbars: thin, rounded and semi-transparent `onSurface` thumbs,
/// wider on hover on pointer platforms.
ScrollbarThemeData buildScrollbarTheme(ComponentThemeContext c) {
  return ScrollbarThemeData(
    thickness: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.hovered) ? 10 : 6,
    ),
    radius: const Radius.circular(Oito2Radius.check),
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => ComponentThemeContext.fade(
        c.scheme.onSurface,
        states.contains(WidgetState.dragged)
            ? 0.6
            : states.contains(WidgetState.hovered)
            ? 0.45
            : 0.3,
      ),
    ),
    interactive: !c.isTouch,
  );
}
