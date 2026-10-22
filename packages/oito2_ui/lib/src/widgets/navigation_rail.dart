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
import 'utilities.dart';
import 'widget_helpers.dart';

/// A destination of an [Oito2NavigationRail] or an `Oito2NavigationPage`.
@immutable
class Oito2NavigationItem {
  /// Creates a navigation item.
  const Oito2NavigationItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.tooltip,
  });

  /// The icon, usually an [Icon].
  final Widget icon;

  /// The icon shown while selected; defaults to [icon].
  final Widget? selectedIcon;

  /// The destination name, shown as a label and announced to assistive
  /// technologies.
  final String label;

  /// The tooltip; defaults to [label] where labels are hidden.
  final String? tooltip;
}

/// How an [Oito2NavigationRail] shows its destinations.
enum Oito2NavigationRailStyle {
  /// Icons only, with the label as a tooltip.
  compact,

  /// Icons with a small label below.
  labelled,

  /// Icons with the label beside them, in a wider rail.
  labelledExtended;

  /// The rail width in this style.
  double get width => switch (this) {
    compact => 64,
    labelled => 88,
    labelledExtended => 240,
  };
}

/// A destination button of an [Oito2NavigationRail].
///
/// The selected destination sits on a rounded pill in the secondary
/// container color. The button shows the keyboard focus ring and reads as
/// a selectable button with its label to assistive technologies.
class Oito2NavigationRailItem extends StatelessWidget {
  /// Creates a rail item.
  const Oito2NavigationRailItem({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
    required this.style,
  });

  /// The destination.
  final Oito2NavigationItem item;

  /// Whether the destination is selected.
  final bool selected;

  /// Called when the destination is activated.
  final VoidCallback? onTap;

  /// How the item is laid out.
  final Oito2NavigationRailStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    final icon = IconTheme.merge(
      data: IconThemeData(color: foreground, size: Oito2Sizes.iconSize),
      child: selected ? item.selectedIcon ?? item.icon : item.icon,
    );
    final pillColor = selected ? scheme.secondaryContainer : null;
    const pillRadius = Oito2Radius.largeAll;

    Widget pill(Widget child, {double? width, double height = 32}) =>
        Oito2FocusBorder(
          borderRadius: pillRadius,
          child: Material(
            color: pillColor ?? Colors.transparent,
            shape: const RoundedRectangleBorder(borderRadius: pillRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              focusColor: Colors.transparent,
              child: SizedBox(width: width, height: height, child: child),
            ),
          ),
        );

    final Widget content = switch (style) {
      Oito2NavigationRailStyle.compact => Tooltip(
        message: item.tooltip ?? item.label,
        child: pill(Center(child: icon), width: 48, height: 40),
      ),
      Oito2NavigationRailStyle.labelled => GestureDetector(
        // The label under the pill activates the item too.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Oito2Spacing.xxs,
          children: [
            pill(Center(child: icon), width: 56),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
      Oito2NavigationRailStyle.labelledExtended => pill(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Oito2Spacing.md),
          child: Row(
            spacing: Oito2Spacing.md,
            children: [
              icon,
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
        height: 40,
      ),
    };

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Oito2Spacing.sm,
          vertical: style == Oito2NavigationRailStyle.labelled
              ? Oito2Spacing.xs
              : Oito2Spacing.xxs,
        ),
        child: content,
      ),
    );
  }
}

/// A vertical bar of destinations at the start side of a window, in one
/// of three [style]s: icons only, icons with labels below, or a wider rail
/// with labels beside the icons. The width animates when the style
/// changes.
///
/// The destinations scroll, with undershoot shadows, when they don't fit
/// the height, and the selected destination is scrolled into view when it
/// changes or first shows; [leading] and [trailing] stay at the top and
/// bottom. The rail uses the chrome sidebar color unless
/// [backgroundColor] is given.
class Oito2NavigationRail extends StatefulWidget {
  /// Creates a navigation rail.
  const Oito2NavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.style = Oito2NavigationRailStyle.labelled,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: Oito2Spacing.sm),
  });

  /// The destinations, in order.
  final List<Oito2NavigationItem> items;

  /// The selected destination, or -1 for none.
  final int selectedIndex;

  /// Called with the index of an activated destination.
  final ValueChanged<int> onDestinationSelected;

  /// How the destinations are shown.
  final Oito2NavigationRailStyle style;

  /// A widget above the destinations.
  final Widget? leading;

  /// A widget below the destinations.
  final Widget? trailing;

  /// The rail background; defaults to the chrome sidebar color.
  final Color? backgroundColor;

  /// Space around the destinations.
  final EdgeInsetsGeometry padding;

  @override
  State<Oito2NavigationRail> createState() => _Oito2NavigationRailState();
}

class _Oito2NavigationRailState extends State<Oito2NavigationRail> {
  /// One key per item, kept while the selection moves, so the focused item
  /// keeps its element and its focus.
  final Map<int, GlobalKey> _itemKeys = {};

  GlobalKey _keyFor(int index) => _itemKeys.putIfAbsent(index, GlobalKey.new);

  BuildContext? get _selectedContext =>
      _itemKeys[widget.selectedIndex]?.currentContext;

  @override
  void initState() {
    super.initState();
    _revealSoon();
  }

  @override
  void didUpdateWidget(Oito2NavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _itemKeys.removeWhere((index, _) => index >= widget.items.length);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.style != widget.style) {
      _revealSoon();
    }
  }

  /// Centers the selected destination after the next frame when it isn't
  /// fully visible.
  void _revealSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _selectedContext;
      if (mounted && context != null) revealCentered(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final items = widget.items;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: AnimatedContainer(
        duration: reduced ? Duration.zero : const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: style.width,
        color: widget.backgroundColor ?? chromeColorsOf(context).sidebar,
        clipBehavior: Clip.hardEdge,
        child: OverflowBox(
          alignment: AlignmentDirectional.topStart,
          minWidth: 0,
          maxWidth: style.width,
          child: Padding(
            padding: widget.padding,
            child: Column(
              crossAxisAlignment:
                  style == Oito2NavigationRailStyle.labelledExtended
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.center,
              children: [
                ?widget.leading,
                Expanded(
                  child: Oito2ScrollViewUndershoot(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            style == Oito2NavigationRailStyle.labelledExtended
                            ? CrossAxisAlignment.stretch
                            : CrossAxisAlignment.center,
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Oito2NavigationRailItem(
                              key: _keyFor(i),
                              item: items[i],
                              selected: i == widget.selectedIndex,
                              style: style,
                              onTap: () => widget.onDestinationSelected(i),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                ?widget.trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
