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

import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'utilities.dart';
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
/// tabs; [style] picks its look. Throws a [FlutterError] in debug builds
/// when neither [controller] nor a `DefaultTabController` is available.
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
  /// the bar width equally. The [Oito2TabBarStyle.subtle] style always
  /// scrolls, whatever this value.
  final bool isScrollable;

  /// The tab height that [preferredSize] reserves: the touch height by
  /// default, which fits every platform. [Oito2Sizes.buttonHeight] fits
  /// pointer platforms exactly. The tabs size themselves from the theme's
  /// tap target size, not from this value.
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

/// A column of tabs with a rounded marker that slides to the selected one,
/// for side navigation between views of the same content.
///
/// It drives a [TabController] like [Oito2TabBar]: the [controller] given,
/// or the closest `DefaultTabController`; [style] picks the marker look.
/// The tabs take the full width and line up at the leading edge. The
/// selected tab is the bar's one stop in keyboard navigation, and the up
/// and down arrows, Home and End move the selection. Throws a
/// [FlutterError] in debug builds when neither [controller] nor a
/// `DefaultTabController` is available.
class Oito2VerticalTabBar extends StatefulWidget {
  /// Creates a vertical tab bar.
  ///
  /// Throws an [AssertionError] in debug builds when the controller's
  /// length differs from the number of [tabs].
  const Oito2VerticalTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.style = Oito2TabBarStyle.pill,
  });

  /// The tabs, usually [Oito2Tab]s.
  final List<Widget> tabs;

  /// The tab controller; defaults to the closest `DefaultTabController`.
  final TabController? controller;

  /// Called with the index of a tab selected by a tap or a key.
  final ValueChanged<int>? onTap;

  /// The look of the selected tab marker.
  final Oito2TabBarStyle style;

  @override
  State<Oito2VerticalTabBar> createState() => _Oito2VerticalTabBarState();
}

/// Follows the tab controller of [Oito2VerticalTabBar] and owns the focus
/// nodes of its tabs.
class _Oito2VerticalTabBarState extends State<Oito2VerticalTabBar> {
  TabController? _controller;
  final _nodes = <FocusNode>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateController();
  }

  @override
  void didUpdateWidget(Oito2VerticalTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) _updateController();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onIndex);
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Listens to the given controller, or to the closest
  /// `DefaultTabController` when none is given.
  void _updateController() {
    final controller =
        widget.controller ?? DefaultTabController.maybeOf(context);
    assert(() {
      if (controller == null) {
        throw FlutterError(
          'No TabController for Oito2VerticalTabBar.\n'
          'Give the bar a controller, or place a DefaultTabController '
          'above it.',
        );
      }
      return true;
    }());
    if (controller == _controller) return;
    _controller?.removeListener(_onIndex);
    _controller = controller?..addListener(_onIndex);
  }

  /// Rebuilds when the selected tab changes.
  void _onIndex() => setState(() {});

  /// Grows or shrinks [_nodes] to one focus node per tab.
  void _syncNodes() {
    while (_nodes.length > widget.tabs.length) {
      _nodes.removeLast().dispose();
    }
    while (_nodes.length < widget.tabs.length) {
      _nodes.add(FocusNode(debugLabel: 'Vertical tab ${_nodes.length}'));
    }
  }

  /// Selects the tab at [index] and reports it to `onTap`.
  void _select(int index) {
    _controller!.animateTo(
      index,
      duration: motionDuration(context, kTabScrollDuration),
    );
    widget.onTap?.call(index);
  }

  /// Moves the selection and the focus to the tab the up arrow, down
  /// arrow, Home or End key of [event] points at.
  KeyEventResult _onKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final current = _nodes.indexWhere((node) => node.hasPrimaryFocus);
    if (current < 0) return KeyEventResult.ignored;
    final last = widget.tabs.length - 1;
    final target = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => current - 1,
      LogicalKeyboardKey.arrowDown => current + 1,
      LogicalKeyboardKey.home => 0,
      LogicalKeyboardKey.end => last,
      _ => null,
    };
    if (target == null) return KeyEventResult.ignored;
    if (target >= 0 && target <= last && target != current) {
      _select(target);
      _nodes[target].requestFocus();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    assert(
      controller.length == widget.tabs.length,
      'The TabController length (${controller.length}) differs from the '
      'number of tabs (${widget.tabs.length}).',
    );
    _syncNodes();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtle = widget.style == Oito2TabBarStyle.subtle;
    final accent = semanticColorsOf(context).primaryText;
    final touch = theme.materialTapTargetSize == MaterialTapTargetSize.padded;
    final height = touch
        ? Oito2Sizes.touchButtonHeight
        : Oito2Sizes.buttonHeight;
    const gap = Oito2Spacing.xxs;
    final animation = controller.animation!;
    return Semantics(
      role: SemanticsRole.tabBar,
      container: true,
      explicitChildNodes: true,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: (_, event) => _onKey(event),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) => PositionedDirectional(
                top: animation.value * (height + gap),
                start: 0,
                end: 0,
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: subtle
                        ? accent.withValues(alpha: 0.12)
                        : scheme.secondaryContainer,
                    borderRadius: Oito2Radius.mediumAll,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: gap,
              children: [
                for (var i = 0; i < widget.tabs.length; i++)
                  _tab(
                    context,
                    i,
                    height: height,
                    color: i == controller.index
                        ? subtle
                              ? accent
                              : scheme.onSecondaryContainer
                        : scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the tab at [index], [height] tall, with its label and icon in
  /// [color].
  Widget _tab(
    BuildContext context,
    int index, {
    required double height,
    required Color color,
  }) {
    final selected = index == _controller!.index;
    // Only the selected tab is a Tab key stop; the arrow keys reach the
    // others.
    _nodes[index].skipTraversal = !selected;
    final scheme = Theme.of(context).colorScheme;
    return MergeSemantics(
      child: Semantics(
        role: SemanticsRole.tab,
        selected: selected,
        child: Oito2FocusBorder(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              focusNode: _nodes[index],
              onTap: () => _select(index),
              borderRadius: Oito2Radius.mediumAll,
              overlayColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? scheme.onSurface.withValues(alpha: 0.06)
                    : const Color(0x00000000),
              ),
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Oito2Spacing.md,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconTheme.merge(
                      data: IconThemeData(color: color),
                      child: DefaultTextStyle.merge(
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: color),
                        child: widget.tabs[index],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical tabs beside the content of the selected one: an
/// [Oito2VerticalTabBar] at the start side and the matching child of
/// [children] filling the rest.
///
/// Like the bar, it uses the [controller] given or the closest
/// `DefaultTabController`. The tab column scrolls when the tabs don't fit
/// its height.
class Oito2VerticalTabs extends StatelessWidget {
  /// Creates vertical tabs.
  ///
  /// Throws an [AssertionError] in debug builds when [tabs] and
  /// [children] differ in length.
  const Oito2VerticalTabs({
    super.key,
    required this.tabs,
    required this.children,
    this.controller,
    this.onTap,
    this.style = Oito2TabBarStyle.pill,
    this.tabBarWidth = 200,
  }) : assert(tabs.length == children.length);

  /// The tabs, usually [Oito2Tab]s.
  final List<Widget> tabs;

  /// The content of each tab, in the order of [tabs].
  final List<Widget> children;

  /// The tab controller; defaults to the closest `DefaultTabController`.
  final TabController? controller;

  /// Called with the index of a tab selected by a tap or a key.
  final ValueChanged<int>? onTap;

  /// The look of the selected tab marker.
  final Oito2TabBarStyle style;

  /// The width of the tab column.
  final double tabBarWidth;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? DefaultTabController.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: tabBarWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Oito2Spacing.xs),
            child: Oito2VerticalTabBar(
              tabs: tabs,
              controller: controller,
              onTap: onTap,
              style: style,
            ),
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Semantics(
              role: SemanticsRole.tabPanel,
              child: KeyedSubtree(
                key: ValueKey(controller.index),
                child: children[controller.index],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
