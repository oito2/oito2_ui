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

import '../theme/extensions/navigation_themes.dart';
import 'navigation_rail.dart';
import 'page_controller.dart';
import 'unsaved_changes.dart';
import 'widget_helpers.dart';

/// Top-level navigation between pages that adapts to the available width
/// and the input.
///
/// - On touch platforms below [compactBreakpoint] wide, two or more
///   destinations are a bottom [NavigationBar].
/// - Otherwise they are an [Oito2NavigationRail] at the start side:
///   compact (icons only) below [compactBreakpoint] on pointer platforms,
///   labelled up to [extendedBreakpoint], and extended (labels beside the
///   icons) from it. [railStyle] forces one style.
///
/// Breakpoints, the rail color and padding and the separator default to
/// the theme's [Oito2NavigationPageThemeData]. The selected page fades in
/// when it changes.
///
/// Under an [Oito2UnsavedChangesScope], picking another destination while
/// a guard of the shown page has unsaved changes asks first.
class Oito2NavigationPage extends StatefulWidget {
  /// Creates a navigation page.
  ///
  /// Throws an [AssertionError] in debug mode when [items] is empty.
  const Oito2NavigationPage({
    super.key,
    required this.items,
    required this.pageBuilder,
    this.controller,
    this.initialIndex = 0,
    this.onSelected,
    this.leading,
    this.trailing,
    this.compactBreakpoint,
    this.extendedBreakpoint,
    this.railStyle,
  }) : assert(items.length > 0, 'Oito2NavigationPage needs at least one item.');

  /// The destinations, in order; at least one.
  ///
  /// A single destination is shown in a rail also where two or more would
  /// be a bottom bar, since a [NavigationBar] needs two destinations.
  final List<Oito2NavigationItem> items;

  /// Builds the page of a destination.
  final IndexedWidgetBuilder pageBuilder;

  /// Controls the selected destination; its length must match [items].
  ///
  /// Throws an [AssertionError] in debug mode, when the page builds, if its
  /// length differs from the number of [items].
  final Oito2PageController? controller;

  /// The destination selected at start, when no [controller] is given.
  final int initialIndex;

  /// Called when the user selects a destination.
  final ValueChanged<int>? onSelected;

  /// A widget above the rail destinations.
  ///
  /// With the bottom bar, it moves to the title bar of the page: an
  /// [Oito2WindowTitleBar] in the page shows it before the title when the
  /// bar has no leading widget of its own. A page with another bar reads
  /// it with [titleBarWidgetsOf].
  final Widget? leading;

  /// A widget below the rail destinations.
  ///
  /// With the bottom bar, it moves to the title bar of the page: an
  /// [Oito2WindowTitleBar] in the page shows it after its actions. A page
  /// with another bar reads it with [titleBarWidgetsOf].
  final Widget? trailing;

  /// Returns the [leading] and [trailing] widgets of the closest
  /// [Oito2NavigationPage] while it shows the bottom bar, for the title
  /// bar of its page; null while it shows the rail, which holds them, or
  /// outside a navigation page.
  static ({Widget? leading, Widget? trailing})? titleBarWidgetsOf(
    BuildContext context,
  ) {
    final slots = context.dependOnInheritedWidgetOfExactType<_TitleBarSlots>();
    if (slots == null || (slots.leading == null && slots.trailing == null)) {
      return null;
    }
    return (leading: slots.leading, trailing: slots.trailing);
  }

  /// The width below which touch layouts use a bottom bar and pointer
  /// layouts a compact rail; defaults to the theme, then 600.
  final double? compactBreakpoint;

  /// The width at which the rail shows labels beside the icons; defaults
  /// to the theme, where null never extends it.
  final double? extendedBreakpoint;

  /// Forces a rail style instead of choosing it by width.
  final Oito2NavigationRailStyle? railStyle;

  @override
  State<Oito2NavigationPage> createState() => _Oito2NavigationPageState();
}

class _Oito2NavigationPageState extends State<Oito2NavigationPage>
    with OwnedControllerMixin<Oito2NavigationPage, Oito2PageController> {
  @override
  Oito2PageController? get widgetController => widget.controller;

  @override
  Oito2PageController createOwnedController() => Oito2PageController(
    length: widget.items.length,
    initialIndex: widget.initialIndex,
  );

  @override
  void onControllerChange() => _onChanged();

  Oito2PageController get _controller => effectiveController;

  @override
  void didUpdateWidget(Oito2NavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null) {
      _controller.length = widget.items.length;
    }
  }

  final _pageKey = GlobalKey();

  void _onChanged() => setState(() {});

  /// Selects the destination at [index] and reports it to the `onSelected`
  /// callback, once the closest [Oito2UnsavedChangesScope], if any,
  /// confirms leaving the destination shown.
  void _select(int index) => runGuardedSwitch(
    context,
    isCurrent: index == _controller.index,
    apply: () => _apply(index),
  );

  /// Selects the destination at [index] and reports it to the `onSelected`
  /// callback.
  void _apply(int index) {
    _controller.index = index;
    widget.onSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      _controller.length == widget.items.length,
      'The controller of Oito2NavigationPage has length '
      '${_controller.length}, but there are ${widget.items.length} items.',
    );
    final index = _controller.hasSelection ? _controller.index : 0;
    // The global key moves the page between the bar and rail layouts
    // without losing its state.
    final page = KeyedSubtree(
      key: _pageKey,
      child: AnimatedSwitcher(
        duration: motionDuration(context, const Duration(milliseconds: 150)),
        child: KeyedSubtree(
          key: ValueKey(index),
          child: widget.pageBuilder(context, index),
        ),
      ),
    );

    final theme = Oito2NavigationPageThemeData.maybeOf(context);
    final compact = widget.compactBreakpoint ?? theme?.compactBreakpoint ?? 600;
    final extended = widget.extendedBreakpoint ?? theme?.extendedBreakpoint;
    final touch = padsTapTargets(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (touch &&
            width < compact &&
            widget.railStyle == null &&
            widget.items.length >= 2) {
          return Column(
            children: [
              Expanded(
                child: _TitleBarSlots(
                  leading: widget.leading,
                  trailing: widget.trailing,
                  child: page,
                ),
              ),
              NavigationBar(
                selectedIndex: index,
                onDestinationSelected: _select,
                destinations: [
                  for (final item in widget.items)
                    NavigationDestination(
                      icon: item.icon,
                      selectedIcon: item.selectedIcon,
                      label: item.label,
                      tooltip: item.tooltip,
                    ),
                ],
              ),
            ],
          );
        }
        final style =
            widget.railStyle ??
            (width < compact
                ? Oito2NavigationRailStyle.compact
                : extended != null && width >= extended
                ? Oito2NavigationRailStyle.labelledExtended
                : Oito2NavigationRailStyle.labelled);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Oito2NavigationRail(
              items: widget.items,
              selectedIndex: index,
              onDestinationSelected: _select,
              style: style,
              leading: widget.leading,
              trailing: widget.trailing,
              backgroundColor: theme?.railColor,
              padding:
                  theme?.railPadding ?? const EdgeInsets.symmetric(vertical: 8),
            ),
            if (theme?.includeSeparator ?? true)
              const VerticalDivider(width: 1),
            Expanded(child: _TitleBarSlots(child: page)),
          ],
        );
      },
    );
  }
}

/// Hands the [leading] and [trailing] widgets of an [Oito2NavigationPage]
/// that shows the bottom bar to the title bar of its page.
class _TitleBarSlots extends InheritedWidget {
  const _TitleBarSlots({this.leading, this.trailing, required super.child});

  final Widget? leading;

  final Widget? trailing;

  @override
  bool updateShouldNotify(_TitleBarSlots oldWidget) =>
      leading != oldWidget.leading || trailing != oldWidget.trailing;
}
