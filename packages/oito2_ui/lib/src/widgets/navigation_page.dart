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

import '../theme/extensions/navigation_themes.dart';
import 'navigation_rail.dart';
import 'page_controller.dart';

/// Top-level navigation between pages that adapts to the available width
/// and the input.
///
/// - On touch platforms below [compactBreakpoint] wide, the destinations
///   are a bottom [NavigationBar].
/// - Otherwise they are an [Oito2NavigationRail] at the start side:
///   compact (icons only) below [compactBreakpoint] on pointer platforms,
///   labelled up to [extendedBreakpoint], and extended (labels beside the
///   icons) from it. [railStyle] forces one style.
///
/// Breakpoints, the rail color and padding and the separator default to
/// the theme's [Oito2NavigationPageThemeData]. The selected page fades in
/// when it changes.
class Oito2NavigationPage extends StatefulWidget {
  /// Creates a navigation page.
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
  });

  /// The destinations, in order.
  final List<Oito2NavigationItem> items;

  /// Builds the page of a destination.
  final IndexedWidgetBuilder pageBuilder;

  /// Controls the selected destination; its length must match [items].
  final Oito2PageController? controller;

  /// The destination selected at start, when no [controller] is given.
  final int initialIndex;

  /// Called when the user selects a destination.
  final ValueChanged<int>? onSelected;

  /// A widget above the rail destinations.
  final Widget? leading;

  /// A widget below the rail destinations.
  final Widget? trailing;

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

class _Oito2NavigationPageState extends State<Oito2NavigationPage> {
  Oito2PageController? _ownController;

  Oito2PageController get _controller =>
      widget.controller ??
      (_ownController ??= Oito2PageController(
        length: widget.items.length,
        initialIndex: widget.initialIndex,
      ));

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(Oito2NavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller ?? _ownController;
    if (oldController != _controller) {
      oldController?.removeListener(_onChanged);
      _controller.addListener(_onChanged);
    }
    if (widget.controller == null) {
      _controller.length = widget.items.length;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _ownController?.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _select(int index) {
    _controller.index = index;
    widget.onSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final index = _controller.hasSelection ? _controller.index : 0;
    final page = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: KeyedSubtree(
        key: ValueKey(index),
        child: widget.pageBuilder(context, index),
      ),
    );

    final theme = Oito2NavigationPageThemeData.maybeOf(context);
    final compact = widget.compactBreakpoint ?? theme?.compactBreakpoint ?? 600;
    final extended = widget.extendedBreakpoint ?? theme?.extendedBreakpoint;
    final touch =
        Theme.of(context).materialTapTargetSize == MaterialTapTargetSize.padded;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (touch && width < compact && widget.railStyle == null) {
          return Column(
            children: [
              Expanded(child: page),
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
            Expanded(child: page),
          ],
        );
      },
    );
  }
}
