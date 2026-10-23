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

import '../tokens/geometry.dart';
import '../window/title_bar.dart';
import '../theme/extensions/navigation_themes.dart';
import '../window/title_bar_theme.dart';
import 'icon_buttons.dart';
import 'page_controller.dart';
import 'paned_view.dart';
import 'utilities.dart';
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
  ///
  /// Throws an [AssertionError] in debug mode unless exactly one of
  /// [length] and [controller] is given.
  const Oito2MasterDetailPage({
    super.key,
    this.length,
    this.controller,
    required this.tileBuilder,
    required this.pageBuilder,
    this.emptyBuilder,
    this.initialIndex,
    this.onSelected,
    this.breakpoint,
    this.paneSize,
    this.minPaneSize,
    this.minPageSize,
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

  /// Builds the content shown when there are no items, in place of the
  /// list: [masterBar] and [masterFooter] stay, so a search that matches
  /// nothing can still be cleared.
  final WidgetBuilder? emptyBuilder;

  /// The item selected at start, when no [controller] is given.
  final int? initialIndex;

  /// Called when the user selects an item.
  final ValueChanged<int>? onSelected;

  /// The width at which the master and the detail are shown side by side;
  /// defaults to the theme's [Oito2MasterDetailThemeData], then 620.
  final double? breakpoint;

  /// The initial master pane width; defaults to the theme, then 280.
  final double? paneSize;

  /// The smallest master pane width; defaults to the theme, then 180.
  final double? minPaneSize;

  /// The smallest width left for the detail page; defaults to the theme,
  /// then 320.
  final double? minPageSize;

  /// Whether the master pane can be resized.
  final bool resizable;

  /// A bar above the master list, such as a title bar with a search field.
  final PreferredSizeWidget? masterBar;

  /// A widget below the master list.
  final Widget? masterFooter;

  @override
  State<Oito2MasterDetailPage> createState() => _Oito2MasterDetailPageState();
}

class _Oito2MasterDetailPageState extends State<Oito2MasterDetailPage>
    with OwnedControllerMixin<Oito2MasterDetailPage, Oito2PageController> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Oito2PageController? get widgetController => widget.controller;

  @override
  Oito2PageController createOwnedController() => Oito2PageController(
    length: widget.length!,
    initialIndex: widget.initialIndex ?? -1,
  );

  @override
  void onControllerChange() => _onChanged();

  Oito2PageController get _controller => effectiveController;

  @override
  void didUpdateWidget(Oito2MasterDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && widget.length != null) {
      _controller.length = widget.length!;
    }
  }

  void _onChanged() => setState(() {});

  /// Selects the first item, which the side-by-side layout shows when
  /// nothing is selected, so the controller tells what is on screen.
  void _selectShownSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_controller.hasSelection && _controller.length > 0) {
        _controller.index = 0;
      }
    });
  }

  /// Selects the item at [index] and reports it to the `onSelected`
  /// callback.
  void _select(int index) {
    _controller.index = index;
    widget.onSelected?.call(index);
  }

  /// Builds the master pane at [width] with the tile at [selected]
  /// highlighted, showing [content] in place of the list when given.
  Widget _master(
    BuildContext context,
    double width,
    int selected, {
    Widget? content,
  }) {
    final theme = Oito2MasterDetailThemeData.maybeOf(context);
    final bar = widget.masterBar;
    final footer = widget.masterFooter;
    return Material(
      color: theme?.paneColor ?? chromeColorsOf(context).mainbar,
      child: Column(
        children: [
          ?bar,
          Expanded(
            child:
                content ??
                Oito2MasterListView(
                  length: _controller.length,
                  selectedIndex: selected,
                  availableWidth: width,
                  padding: theme?.listPadding,
                  tileSpacing: theme?.tileSpacing,
                  onTap: _select,
                  builder: widget.tileBuilder,
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
      final empty =
          widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
      if (widget.masterBar == null && widget.masterFooter == null) return empty;
      // Keeps the pane bar and footer around the empty content.
      return LayoutBuilder(
        builder: (context, constraints) =>
            _master(context, constraints.maxWidth, -1, content: empty),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Oito2MasterDetailThemeData.maybeOf(context);
        final width = constraints.maxWidth;
        if (width >= (widget.breakpoint ?? theme?.breakpoint ?? 620)) {
          final index = _controller.hasSelection ? _controller.index : 0;
          if (!_controller.hasSelection) _selectShownSoon();
          return Oito2PanedView(
            initialPaneSize: widget.paneSize ?? theme?.paneSize ?? 280,
            minPaneSize: widget.minPaneSize ?? theme?.minPaneSize ?? 180,
            minPageSize: widget.minPageSize ?? theme?.minPageSize ?? 320,
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
        // The system back button returns from the page to the master
        // before it leaves the enclosing route.
        return NavigatorPopHandler<void>(
          onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
          child: Navigator(
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
          ),
        );
      },
    );
  }
}

/// The list of an [Oito2MasterDetailPage] master pane: one tile per item,
/// built by [builder], with undershoot shadows at the scroll edges.
///
/// It keeps the selected tile in view: when [selectedIndex] changes, or
/// on first show, the list scrolls just enough to reveal it, even if it
/// starts far below the visible part.
class Oito2MasterListView extends StatefulWidget {
  /// Creates a master list.
  const Oito2MasterListView({
    super.key,
    required this.length,
    required this.selectedIndex,
    required this.builder,
    required this.onTap,
    required this.availableWidth,
    this.padding,
    this.tileSpacing,
  });

  /// The number of tiles.
  final int length;

  /// The selected tile, or -1 for none.
  final int selectedIndex;

  /// Builds a tile; [Oito2MasterTile]s take their selection and tap action
  /// from the surrounding [Oito2MasterTileScope].
  final Oito2MasterTileBuilder builder;

  /// Called with the index of an activated tile.
  final ValueChanged<int> onTap;

  /// The width of the pane, passed to [builder].
  final double availableWidth;

  /// Space around the list; defaults to 8 pixels.
  final EdgeInsetsGeometry? padding;

  /// Space between tiles; defaults to 4 pixels.
  final double? tileSpacing;

  @override
  State<Oito2MasterListView> createState() => _Oito2MasterListViewState();
}

class _Oito2MasterListViewState extends State<Oito2MasterListView> {
  final _scroll = ScrollController();

  /// One key per built tile, kept while the selection moves, so the focused
  /// tile keeps its element and its focus.
  final Map<int, GlobalKey> _tileKeys = {};

  GlobalKey _keyFor(int index) => _tileKeys.putIfAbsent(index, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _revealSoon(animate: false);
  }

  @override
  void didUpdateWidget(Oito2MasterListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tileKeys.removeWhere((index, _) => index >= widget.length);
    if (oldWidget.selectedIndex != widget.selectedIndex) _revealSoon();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Schedules a reveal of the selected tile after the current frame.
  void _revealSoon({bool animate = true}) {
    if (widget.selectedIndex < 0) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _reveal(animate: animate, retries: 3),
    );
  }

  /// Centers the selected tile when it isn't fully visible. A tile far
  /// below the built part of the list isn't built yet, so the list first
  /// jumps near it, using the average tile height, and retries on the next
  /// frame.
  void _reveal({required bool animate, required int retries}) {
    if (!mounted || !_scroll.hasClients) return;
    final position = _scroll.position;
    if (!position.hasContentDimensions) {
      if (retries > 0) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _reveal(animate: animate, retries: retries - 1),
        );
      }
      return;
    }
    final tile = _tileKeys[widget.selectedIndex]?.currentContext;
    if (tile == null || tile.findRenderObject() == null) {
      if (retries == 0 || widget.length == 0) return;
      final extent = position.maxScrollExtent + position.viewportDimension;
      final estimate = extent / widget.length * widget.selectedIndex;
      _scroll.jumpTo(
        (estimate - position.viewportDimension / 2).clamp(
          0,
          position.maxScrollExtent,
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _reveal(animate: false, retries: retries - 1),
      );
      return;
    }
    revealCentered(
      tile,
      duration: animate ? const Duration(milliseconds: 200) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = widget.tileSpacing ?? Oito2Spacing.xs;
    return Oito2ScrollViewUndershoot(
      child: ListView.builder(
        controller: _scroll,
        padding: widget.padding ?? const EdgeInsets.all(Oito2Spacing.sm),
        itemCount: widget.length,
        itemBuilder: (context, index) {
          final selected = index == widget.selectedIndex;
          return Padding(
            key: _keyFor(index),
            padding: EdgeInsets.only(top: index == 0 ? 0 : spacing),
            child: Oito2MasterTileScope(
              index: index,
              selected: selected,
              onTap: () => widget.onTap(index),
              child: widget.builder(
                context,
                index,
                selected,
                widget.availableWidth,
              ),
            ),
          );
        },
      ),
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
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      selected: selected ?? scope?.selected ?? false,
      onTap: onTap ?? scope?.onTap,
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
