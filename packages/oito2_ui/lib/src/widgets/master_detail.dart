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
import '../window/title_bar.dart';
import '../window/title_bar_theme.dart';
import 'icon_buttons.dart';
import 'page_controller.dart';
import 'paned_view.dart';
import 'widget_helpers.dart';

/// Builds the master list tile at [index]; [selected] tells whether its
/// page is shown and [availableWidth] is the width of the master pane.
typedef Oito2MasterTileBuilder = Widget Function(
  BuildContext context,
  int index,
  bool selected,
  double availableWidth,
);

/// A list of items (the master) next to the page of the selected item
/// (the detail), as in settings apps.
///
/// At or above [breakpoint] wide, the master is a resizable pane beside
/// the detail. Below it, the master fills the area and selecting an item
/// pushes its detail page on a nested navigator; going back clears the
/// selection. The selection survives switching between the two layouts.
class Oito2MasterDetailPage extends StatefulWidget {
  /// Creates a master-detail page.
  const Oito2MasterDetailPage({
    super.key,
    this.length,
    this.controller,
    required this.tileBuilder,
    required this.pageBuilder,
    this.emptyBuilder,
    this.initialIndex,
    this.onSelected,
    this.breakpoint = 620,
    this.paneSize = 280,
    this.minPaneSize = 180,
    this.minPageSize = 320,
    this.resizable = true,
    this.masterBar,
    this.masterFooter,
  }) : assert(
         (length == null) != (controller == null),
         'Provide either length or controller',
       );

  /// The number of items, when no [controller] is given.
  final int? length;

  /// Controls the number of items and the selection.
  final Oito2PageController? controller;

  /// Builds the master list tiles, usually [Oito2MasterTile]s.
  final Oito2MasterTileBuilder tileBuilder;

  /// Builds the detail page of an item, usually an [Oito2DetailPage].
  final IndexedWidgetBuilder pageBuilder;

  /// Builds the content shown when there are no items.
  final WidgetBuilder? emptyBuilder;

  /// The item selected at start, when no [controller] is given.
  final int? initialIndex;

  /// Called when the user selects an item.
  final ValueChanged<int>? onSelected;

  /// The width at which the master and the detail are shown side by side.
  final double breakpoint;

  /// The initial master pane width.
  final double paneSize;

  /// The smallest master pane width.
  final double minPaneSize;

  /// The smallest width left for the detail page.
  final double minPageSize;

  /// Whether the master pane can be resized.
  final bool resizable;

  /// A bar above the master list, such as a title bar with a search field.
  final PreferredSizeWidget? masterBar;

  /// A widget below the master list.
  final Widget? masterFooter;

  @override
  State<Oito2MasterDetailPage> createState() => _Oito2MasterDetailPageState();
}

class _Oito2MasterDetailPageState extends State<Oito2MasterDetailPage> {
  Oito2PageController? _ownController;
  final _navigatorKey = GlobalKey<NavigatorState>();

  Oito2PageController get _controller =>
      widget.controller ?? (_ownController ??= _createController());

  Oito2PageController _createController() => Oito2PageController(
    length: widget.length!,
    initialIndex: widget.initialIndex ?? -1,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(Oito2MasterDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller ?? _ownController;
    if (oldController != _controller) {
      oldController?.removeListener(_onChanged);
      _controller.addListener(_onChanged);
    }
    if (widget.controller == null && widget.length != null) {
      _controller.length = widget.length!;
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

  Widget _master(BuildContext context, double width, int selected) {
    final bar = widget.masterBar;
    final footer = widget.masterFooter;
    return Material(
      color: chromeColorsOf(context).mainbar,
      child: Column(
        children: [
          ?bar,
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(Oito2Spacing.sm),
              itemCount: _controller.length,
              itemBuilder: (context, index) => Oito2MasterTileScope(
                index: index,
                selected: index == selected,
                onTap: () => _select(index),
                child: widget.tileBuilder(
                  context,
                  index,
                  index == selected,
                  width,
                ),
              ),
            ),
          ),
          ?footer,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.length == 0) {
      return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= widget.breakpoint) {
          final index = _controller.hasSelection ? _controller.index : 0;
          return Oito2PanedView(
            initialPaneSize: widget.paneSize,
            minPaneSize: widget.minPaneSize,
            minPageSize: widget.minPageSize,
            resizable: widget.resizable,
            pane: LayoutBuilder(
              builder: (context, pane) =>
                  _master(context, pane.maxWidth, index),
            ),
            page: KeyedSubtree(
              key: ValueKey(index),
              child: widget.pageBuilder(context, index),
            ),
          );
        }
        final index = _controller.index;
        return Navigator(
          key: _navigatorKey,
          pages: [
            MaterialPage<void>(
              key: const ValueKey('master'),
              child: _master(context, width, index),
            ),
            if (index >= 0)
              MaterialPage<void>(
                key: ValueKey(index),
                child: widget.pageBuilder(context, index),
              ),
          ],
          onDidRemovePage: (page) {
            if (page.key != const ValueKey('master')) _controller.index = -1;
          },
        );
      },
    );
  }
}

/// Gives an [Oito2MasterTile] its index, selection and tap action inside
/// an [Oito2MasterDetailPage].
class Oito2MasterTileScope extends InheritedWidget {
  /// Creates a master tile scope.
  const Oito2MasterTileScope({
    super.key,
    required this.index,
    required this.selected,
    required this.onTap,
    required super.child,
  });

  /// The tile index.
  final int index;

  /// Whether the tile's page is shown.
  final bool selected;

  /// Selects the tile.
  final VoidCallback onTap;

  /// Returns the closest scope, or null outside a master list.
  static Oito2MasterTileScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Oito2MasterTileScope>();

  @override
  bool updateShouldNotify(Oito2MasterTileScope oldWidget) =>
      index != oldWidget.index || selected != oldWidget.selected;
}

/// A tile of an [Oito2MasterDetailPage] master list: a [ListTile] that
/// takes its selection and tap action from the enclosing
/// [Oito2MasterTileScope].
class Oito2MasterTile extends StatelessWidget {
  /// Creates a master tile.
  const Oito2MasterTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.selected,
    this.onTap,
  });

  /// A widget before the title, usually an icon.
  final Widget? leading;

  /// The primary text.
  final Widget? title;

  /// The secondary text.
  final Widget? subtitle;

  /// A widget after the text.
  final Widget? trailing;

  /// Overrides the selection from the scope.
  final bool? selected;

  /// Overrides the tap action from the scope.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scope = Oito2MasterTileScope.maybeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Oito2Spacing.xxs),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        selected: selected ?? scope?.selected ?? false,
        onTap: onTap ?? scope?.onTap,
      ),
    );
  }
}

/// A detail page of an [Oito2MasterDetailPage]: a [Scaffold] whose bar
/// shows a back button when the page can be popped, which happens in the
/// narrow layout.
class Oito2DetailPage extends StatelessWidget {
  /// Creates a detail page.
  const Oito2DetailPage({
    super.key,
    this.title,
    this.actions = const [],
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
  });

  /// The title of the default bar.
  final Widget? title;

  /// Actions of the default bar.
  final List<Widget> actions;

  /// Replaces the default bar.
  final PreferredSizeWidget? appBar;

  /// The page content.
  final Widget body;

  /// A floating action button.
  final Widget? floatingActionButton;

  /// The background; defaults to the scaffold background.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final bar =
        appBar ??
        (title == null && actions.isEmpty && !canPop
            ? null
            : Oito2TitleBar(
                title: title,
                actions: actions,
                style: Oito2TitleBarStyle.undecorated,
                isDraggable: false,
                leading: canPop ? const Oito2BackButton() : null,
              ));
    return Scaffold(
      appBar: bar,
      body: body,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
    );
  }
}
