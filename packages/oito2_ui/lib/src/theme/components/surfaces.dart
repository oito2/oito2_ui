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

const _noTint = Color(0x00000000);

/// Returns the theme of cards: no elevation, the scheme surface and a thin
/// `outlineVariant` border with the large radius.
CardThemeData buildCardTheme(ComponentThemeContext c) {
  return CardThemeData(
    elevation: 0,
    color: c.scheme.surface,
    surfaceTintColor: _noTint,
    shadowColor: _noTint,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: Oito2Radius.largeAll,
      side: BorderSide(color: c.scheme.outlineVariant),
    ),
  );
}

/// Returns the theme of dialogs: the chrome dialog tone with the window
/// radius and a thin `outlineVariant` border.
DialogThemeData buildDialogTheme(ComponentThemeContext c) {
  return DialogThemeData(
    backgroundColor: c.chrome.dialog,
    surfaceTintColor: _noTint,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: Oito2Radius.windowAll,
      side: BorderSide(color: c.scheme.outlineVariant),
    ),
    titleTextStyle: c.textTheme.titleLarge,
    contentTextStyle: c.textTheme.bodyMedium,
    actionsPadding: const EdgeInsets.fromLTRB(
      Oito2Spacing.xl,
      0,
      Oito2Spacing.xl,
      Oito2Spacing.xl,
    ),
  );
}

/// Returns the theme of bottom sheets: the chrome dialog tone with the
/// window radius on top, and a drag handle on touch platforms.
BottomSheetThemeData buildBottomSheetTheme(ComponentThemeContext c) {
  return BottomSheetThemeData(
    backgroundColor: c.chrome.dialog,
    modalBackgroundColor: c.chrome.dialog,
    surfaceTintColor: _noTint,
    showDragHandle: c.isTouch,
    dragHandleColor: c.scheme.onSurfaceVariant,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Oito2Radius.window),
      ),
    ),
  );
}

/// Returns the theme of drawers: the chrome dialog tone, square and flat on
/// pointer platforms.
DrawerThemeData buildDrawerTheme(ComponentThemeContext c) {
  return DrawerThemeData(
    backgroundColor: c.chrome.dialog,
    surfaceTintColor: _noTint,
    elevation: c.isTouch ? 1 : 0,
    shape: c.isTouch ? null : const RoundedRectangleBorder(),
    endShape: c.isTouch ? null : const RoundedRectangleBorder(),
  );
}

/// Returns the theme of dividers: one pixel of `outlineVariant`.
DividerThemeData buildDividerTheme(ComponentThemeContext c) {
  return DividerThemeData(
    color: c.scheme.outlineVariant,
    thickness: 1,
    space: 1,
  );
}

/// Returns the theme of snack bars: the inverse surface, floating with the
/// medium radius on pointer platforms and fixed on touch platforms.
SnackBarThemeData buildSnackBarTheme(ComponentThemeContext c) {
  return SnackBarThemeData(
    behavior: c.isTouch ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
    backgroundColor: c.scheme.inverseSurface,
    actionTextColor: c.scheme.inversePrimary,
    contentTextStyle: c.textTheme.bodyMedium?.copyWith(
      color: c.scheme.onInverseSurface,
    ),
    shape: c.isTouch
        ? null
        : const RoundedRectangleBorder(borderRadius: Oito2Radius.mediumAll),
  );
}

/// Returns the theme of tooltips: the inverse surface with the small
/// radius, shown after a 500 ms hover delay on pointer platforms.
TooltipThemeData buildTooltipTheme(ComponentThemeContext c) {
  return TooltipThemeData(
    decoration: BoxDecoration(
      color: c.scheme.inverseSurface,
      borderRadius: Oito2Radius.smallAll,
    ),
    textStyle: c.textTheme.bodySmall?.copyWith(
      color: c.scheme.onInverseSurface,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: Oito2Spacing.sm,
      vertical: Oito2Spacing.xs,
    ),
    waitDuration: c.isTouch ? null : const Duration(milliseconds: 500),
  );
}

/// Returns the theme of carousels: the container surface with the large
/// radius and no elevation.
CarouselViewThemeData buildCarouselViewTheme(ComponentThemeContext c) {
  return CarouselViewThemeData(
    backgroundColor: c.scheme.surfaceContainer,
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: Oito2Radius.largeAll),
  );
}
