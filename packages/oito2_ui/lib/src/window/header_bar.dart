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

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/platform_info.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import '../widgets/icon_buttons.dart';
import '../widgets/search.dart';
import '../widgets/tab_bar.dart';
import 'title_bar.dart';
import 'window_controller.dart';

/// The search of an [Oito2HeaderBar]: what the search field reports and
/// how it looks.
@immutable
class Oito2HeaderBarSearch {
  /// Creates a header bar search.
  const Oito2HeaderBarSearch({
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.hintText,
    this.fieldWidth = 280,
  });

  /// Called whenever the search text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the search text is submitted with Enter.
  final ValueChanged<String>? onSubmitted;

  /// Controls the search text, so it survives closing the search; one is
  /// created by the field when null.
  final TextEditingController? controller;

  /// The hint of the search field; defaults to the localized "Search".
  final String? hintText;

  /// The width of the search field, in logical pixels.
  final double fieldWidth;
}

/// A header bar: the window title bar with the app's controls in it, as in
/// GNOME apps.
///
/// [start] widgets sit after the leading window buttons, such as a back
/// button or a sidebar toggle, and [end] widgets before the trailing ones,
/// such as icon buttons or menus. The middle shows [title], or [tabs] as
/// an [Oito2TabBar] that switches the pages of a `TabBarView`.
///
/// With [search], a search button joins the end widgets; while the search
/// is active the middle shows a search field in place of the title or the
/// tabs, and Escape on the empty field, or the button again, closes it.
/// [searchActive] makes the search controlled, together with
/// [onSearchActiveChanged]; without it the bar keeps the state itself.
/// With [menuChildren], a menu button opens the app's main menu at the
/// very end.
///
/// The bar is an [Oito2WindowTitleBar], so it moves, maximizes and shows
/// the window controls as the system does.
class Oito2HeaderBar extends StatefulWidget implements PreferredSizeWidget {
  /// Creates a header bar.
  ///
  /// Throws an [AssertionError] in debug builds when both [title] and
  /// [tabs] are given.
  const Oito2HeaderBar({
    super.key,
    this.title,
    this.tabs,
    this.tabController,
    this.onTabTap,
    this.tabStyle = Oito2TabBarStyle.pill,
    this.tabWidth = 120,
    this.start = const [],
    this.end = const [],
    this.search,
    this.searchActive,
    this.onSearchActiveChanged,
    this.menuChildren,
    this.menuTooltip,
    this.controller,
    this.platform,
    this.buttonSides = Oito2WindowButtonSides.both,
    this.backgroundColor,
    this.border,
  }) : assert(title == null || tabs == null);

  /// The title in the middle, usually a [Text].
  final Widget? title;

  /// The tabs in the middle, usually [Oito2Tab]s, in place of [title].
  final List<Widget>? tabs;

  /// The controller of [tabs]; defaults to the closest
  /// `DefaultTabController`.
  final TabController? tabController;

  /// Called with the index of a tapped tab.
  final ValueChanged<int>? onTabTap;

  /// The look of [tabs].
  final Oito2TabBarStyle tabStyle;

  /// The width of each tab of the pill style, in logical pixels; the tabs
  /// share it equally and stay centered in the bar.
  final double tabWidth;

  /// The widgets after the leading window buttons.
  final List<Widget> start;

  /// The widgets before the search and menu buttons and the trailing
  /// window buttons.
  final List<Widget> end;

  /// The search; null shows no search button.
  final Oito2HeaderBarSearch? search;

  /// Whether the search is open; null lets the bar keep that state.
  final bool? searchActive;

  /// Called with the requested search state when the search button,
  /// Escape or the field change it.
  final ValueChanged<bool>? onSearchActiveChanged;

  /// The entries of the main menu, such as `MenuItemButton`s; null shows
  /// no menu button.
  final List<Widget>? menuChildren;

  /// The tooltip of the menu button; defaults to the localized
  /// "Main menu".
  final String? menuTooltip;

  /// The window controller; defaults to the closest window scope's.
  final Oito2WindowController? controller;

  /// The platform used to compute [preferredSize]; see
  /// [Oito2WindowTitleBar.platform].
  final Oito2Platform? platform;

  /// Which sides of the system button layout the bar shows.
  final Oito2WindowButtonSides buttonSides;

  /// The bar color; defaults to the title bar color of the theme.
  final Color? backgroundColor;

  /// The line under the bar; defaults to the title bar theme's.
  final BorderSide? border;

  @override
  Size get preferredSize =>
      Oito2WindowTitleBar(platform: platform).preferredSize;

  @override
  State<Oito2HeaderBar> createState() => _Oito2HeaderBarState();
}

class _Oito2HeaderBarState extends State<Oito2HeaderBar> {
  bool _searchActive = false;
  final _searchButton = FocusNode(debugLabel: 'Oito2HeaderBar search');

  bool get _active =>
      widget.search != null && (widget.searchActive ?? _searchActive);

  @override
  void dispose() {
    _searchButton.dispose();
    super.dispose();
  }

  /// Opens or closes the search, reporting the request; a closed search
  /// gives the focus back to its button.
  void _setSearch(bool active) {
    if (widget.searchActive == null) setState(() => _searchActive = active);
    widget.onSearchActiveChanged?.call(active);
    if (!active) _searchButton.requestFocus();
  }

  /// The middle of the bar: the search field, the tabs or the title.
  Widget? _middle(BuildContext context) {
    final search = widget.search;
    if (_active && search != null) {
      return SizedBox(
        width: search.fieldWidth,
        child: Oito2SearchField(
          controller: search.controller,
          hintText: search.hintText,
          autofocus: true,
          onChanged: search.onChanged,
          onSubmitted: search.onSubmitted,
          onEscape: () => _setSearch(false),
        ),
      );
    }
    final tabs = widget.tabs;
    if (tabs != null) {
      // A tab bar fills the width it gets, so the bar gives it the width
      // of its tabs to keep them centered.
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tabs.length * widget.tabWidth),
        child: Oito2TabBar(
          tabs: tabs,
          controller: widget.tabController,
          onTap: widget.onTabTap,
          style: widget.tabStyle,
          tabHeight: Oito2Sizes.titleBarItemHeight,
        ),
      );
    }
    return widget.title;
  }

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final search = widget.search;
    final menuChildren = widget.menuChildren;
    return Oito2WindowTitleBar(
      title: _middle(context),
      // Tabs and the search field take clicks; a plain title lets the
      // window move from it.
      interactiveTitle: widget.tabs != null || _active,
      leading: widget.start.isEmpty
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.xs,
              children: widget.start,
            ),
      actions: [
        ...widget.end,
        if (search != null)
          Oito2IconButton(
            focusNode: _searchButton,
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            isSelected: _active,
            icon: const Icon(LucideIcons.search),
            onPressed: () => _setSearch(!_active),
          ),
        if (menuChildren != null)
          MenuAnchor(
            menuChildren: menuChildren,
            builder: (context, controller, _) => Oito2IconButton(
              tooltip: widget.menuTooltip ?? strings.mainMenu,
              isSelected: controller.isOpen,
              icon: const Icon(LucideIcons.menu),
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
          ),
      ],
      controller: widget.controller,
      platform: widget.platform,
      buttonSides: widget.buttonSides,
      backgroundColor: widget.backgroundColor,
      border: widget.border,
    );
  }
}
