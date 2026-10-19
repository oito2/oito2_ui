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

import 'page_controller.dart';

/// A destination of an [Oito2NavigationPage].
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

/// Top-level navigation between pages that adapts to the available width.
///
/// Below [compactBreakpoint] wide, the destinations are a bottom
/// [NavigationBar]. Otherwise they are a [NavigationRail] at the start
/// side, extended with labels beside the icons at or above
/// [extendedBreakpoint] when given. Both use the theme's chrome colors
/// through `Oito2Theme`. The selected page fades in when it changes.
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
    this.compactBreakpoint = 600,
    this.extendedBreakpoint,
    this.labelType = NavigationRailLabelType.all,
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

  /// The width below which the destinations move to a bottom bar.
  final double compactBreakpoint;

  /// The width at which the rail shows labels beside the icons; null
  /// keeps it compact.
  final double? extendedBreakpoint;

  /// How the compact rail shows labels.
  final NavigationRailLabelType labelType;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < widget.compactBreakpoint) {
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
        final extended =
            widget.extendedBreakpoint != null &&
            width >= widget.extendedBreakpoint!;
        return Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: _select,
              extended: extended,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : widget.labelType,
              leading: widget.leading,
              trailing: widget.trailing,
              destinations: [
                for (final item in widget.items)
                  NavigationRailDestination(
                    icon: Tooltip(
                      message: item.tooltip ?? item.label,
                      child: item.icon,
                    ),
                    selectedIcon: item.selectedIcon,
                    label: Text(item.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: page),
          ],
        );
      },
    );
  }
}
