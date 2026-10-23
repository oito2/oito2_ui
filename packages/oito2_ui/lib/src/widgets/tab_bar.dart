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

import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// A tab of an [Oito2TabBar]: a [label] with an optional [icon] beside
/// it. A label wider than the tab ends with an ellipsis.
class Oito2Tab extends StatelessWidget {
  /// Creates a tab.
  const Oito2Tab({super.key, required this.label, this.icon});

  /// The tab label, usually a [Text].
  final Widget label;

  /// An icon before the label.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final touch =
        Theme.of(context).materialTapTargetSize == MaterialTapTargetSize.padded;
    return SizedBox(
      height: touch ? Oito2Sizes.touchButtonHeight : Oito2Sizes.buttonHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: Oito2Spacing.sm,
        children: [
          if (icon case final icon?)
            IconTheme.merge(
              data: const IconThemeData(size: Oito2Sizes.iconSize),
              child: icon,
            ),
          Flexible(
            child: DefaultTextStyle.merge(
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              child: label,
            ),
          ),
        ],
      ),
    );
  }
}

/// The look of an [Oito2TabBar].
enum Oito2TabBarStyle {
  /// A pill in the secondary container color behind the selected tab, as in
  /// GNOME view switchers.
  pill,

  /// The selected tab tinted with a faint accent fill and accent text, the
  /// others plain; the tabs keep their own width and start at the leading
  /// edge.
  subtle,
}

/// A row of tabs with a rounded marker behind the selected one, a pill as
/// in GNOME view switchers by default.
///
/// It drives a [TabController] like Material's `TabBar`: the [controller]
/// given, or the closest `DefaultTabController`. The marker slides between
/// tabs; [style] picks its look.
class Oito2TabBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a tab bar.
  const Oito2TabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
    this.tabHeight = Oito2Sizes.touchButtonHeight,
    this.style = Oito2TabBarStyle.pill,
  });

  /// The tabs, usually [Oito2Tab]s.
  final List<Widget> tabs;

  /// The tab controller; defaults to the closest `DefaultTabController`.
  final TabController? controller;

  /// Called with the index of a tapped tab.
  final ValueChanged<int>? onTap;

  /// Whether the tabs keep their own width and scroll, instead of sharing
  /// the bar width equally.
  final bool isScrollable;

  /// The height of the tabs that [preferredSize] reserves: the touch
  /// height by default, which fits every platform. [Oito2Sizes.buttonHeight]
  /// fits pointer platforms exactly.
  final double tabHeight;

  /// The look of the selected tab marker.
  final Oito2TabBarStyle style;

  @override
  Size get preferredSize => Size.fromHeight(tabHeight + 2 * Oito2Spacing.xs);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtle = style == Oito2TabBarStyle.subtle;
    final accent = semanticColorsOf(context).primaryText;
    // The subtle tabs always keep their own width, so they line up at the
    // leading edge.
    final scrollable = isScrollable || subtle;
    return Padding(
      padding: const EdgeInsets.all(Oito2Spacing.xs),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: scrollable,
        tabAlignment: scrollable ? TabAlignment.start : TabAlignment.fill,
        tabs: tabs,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: ShapeDecoration(
          color: subtle
              ? accent.withValues(alpha: 0.12)
              : scheme.secondaryContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: Oito2Radius.mediumAll,
          ),
        ),
        indicatorPadding: subtle
            ? const EdgeInsets.symmetric(horizontal: Oito2Spacing.xxs)
            : EdgeInsets.zero,
        splashBorderRadius: Oito2Radius.mediumAll,
        labelColor: subtle ? accent : scheme.onSecondaryContainer,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge,
        unselectedLabelStyle: theme.textTheme.labelLarge,
        labelPadding: const EdgeInsets.symmetric(horizontal: Oito2Spacing.md),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? scheme.onSurface.withValues(alpha: 0.06)
              : null,
        ),
      ),
    );
  }
}
