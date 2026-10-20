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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Opens a menu of [menuChildren] over [child] on a secondary click, a
/// long press, Shift+F10 or the menu key.
///
/// The menu is a `MenuAnchor`, so [menuChildren] are `MenuItemButton`s,
/// `SubmenuButton`s for nested menus, `Oito2CheckedMenuItem`s and
/// dividers. It opens where the pointer is, or over the center of
/// [child] from the keyboard, which needs the focus inside [child]. On
/// the web, the browser's own menu is turned off while the pointer is
/// over [child].
class Oito2ContextMenuRegion extends StatefulWidget {
  /// Creates a context menu region.
  const Oito2ContextMenuRegion({
    super.key,
    required this.child,
    required this.menuChildren,
    this.enabled = true,
    this.onOpen,
    this.onClose,
  });

  /// The widget the menu belongs to.
  final Widget child;

  /// The menu items.
  final List<Widget> menuChildren;

  /// Whether the menu opens.
  final bool enabled;

  /// Called when the menu opens.
  final VoidCallback? onOpen;

  /// Called when the menu closes.
  final VoidCallback? onClose;

  @override
  State<Oito2ContextMenuRegion> createState() => _Oito2ContextMenuRegionState();
}

class _Oito2ContextMenuRegionState extends State<Oito2ContextMenuRegion> {
  final _controller = MenuController();
  bool _browserMenuOff = false;

  @override
  void dispose() {
    _setBrowserMenu(enabled: true);
    super.dispose();
  }

  void _setBrowserMenu({required bool enabled}) {
    if (!kIsWeb || _browserMenuOff != enabled) return;
    _browserMenuOff = !enabled;
    enabled
        ? BrowserContextMenu.enableContextMenu()
        : BrowserContextMenu.disableContextMenu();
  }

  void _open([Offset? position]) {
    if (!widget.enabled) return;
    final box = context.findRenderObject() as RenderBox?;
    _controller.open(position: position ?? box?.size.center(Offset.zero));
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      menuChildren: widget.menuChildren,
      onOpen: widget.onOpen,
      onClose: widget.onClose,
      consumeOutsideTap: true,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.f10, shift: true): _open,
          const SingleActivator(LogicalKeyboardKey.contextMenu): _open,
        },
        child: MouseRegion(
          onEnter: (_) => _setBrowserMenu(enabled: !widget.enabled),
          onExit: (_) => _setBrowserMenu(enabled: true),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onSecondaryTapUp: (details) => _open(details.localPosition),
            onLongPressStart: (details) => _open(details.localPosition),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
