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

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Opens a menu of [menuChildren] over [child] on a secondary click, a
/// long press, Shift+F10 or the menu key.
///
/// The menu is a `MenuAnchor`, so [menuChildren] are `MenuItemButton`s,
/// `SubmenuButton`s for nested menus, `Oito2CheckedMenuItem`s and
/// dividers. It opens where the pointer is, or over the center of
/// [child] from the keyboard, which needs the focus inside [child] and
/// moves it to the first item that can take it. On
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

  /// Whether the menu can open; when false, the browser's own menu stays
  /// available on the web.
  final bool enabled;

  /// Called when the menu opens.
  final VoidCallback? onOpen;

  /// Called when the menu closes.
  final VoidCallback? onClose;

  @override
  State<Oito2ContextMenuRegion> createState() => _Oito2ContextMenuRegionState();
}

/// Owns the menu controller of [Oito2ContextMenuRegion] and turns the
/// browser's context menu off while the pointer is over it.
class _Oito2ContextMenuRegionState extends State<Oito2ContextMenuRegion> {
  final _controller = MenuController();
  bool _browserMenuOff = false;

  /// One non-focusable node around each menu child, through which the
  /// focusable items inside are found.
  final _itemNodes = <FocusNode>[];

  @override
  void dispose() {
    _setBrowserMenu(enabled: true);
    for (final node in _itemNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Grows or shrinks [_itemNodes] to one node per menu child.
  void _syncItemNodes() {
    final count = widget.menuChildren.length;
    while (_itemNodes.length > count) {
      _itemNodes.removeLast().dispose();
    }
    while (_itemNodes.length < count) {
      _itemNodes.add(
        FocusNode(
          debugLabel: 'Context menu item ${_itemNodes.length}',
          canRequestFocus: false,
          skipTraversal: true,
        ),
      );
    }
  }

  /// Focuses the first menu item that can take the focus, once the open
  /// menu is built.
  void _focusFirstItem() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isOpen) return;
      for (final node in _itemNodes) {
        final item = node.descendants
            .where((d) => d.canRequestFocus && !d.skipTraversal)
            .firstOrNull;
        if (item != null) {
          item.requestFocus();
          return;
        }
      }
    });
  }

  /// The number of regions under the pointer that turned the browser menu
  /// off. The menu is a page-wide setting, so it comes back only when the
  /// last of them, such as the outer one of nested regions, lets it go.
  static int _browserMenuHolds = 0;

  /// Releases (when [enabled]) or takes this region's hold on the
  /// browser menu; does nothing off the web or when the hold is already
  /// in that state.
  void _setBrowserMenu({required bool enabled}) {
    if (!kIsWeb || _browserMenuOff != enabled) return;
    _browserMenuOff = !enabled;
    if (enabled) {
      _browserMenuHolds--;
      if (_browserMenuHolds == 0) BrowserContextMenu.enableContextMenu();
    } else {
      _browserMenuHolds++;
      if (_browserMenuHolds == 1) BrowserContextMenu.disableContextMenu();
    }
  }

  /// Opens the menu at [position], or at the center of the region with
  /// the first item focused when null; does nothing when the region is
  /// disabled.
  void _open([Offset? position]) {
    if (!widget.enabled) return;
    final box = context.findRenderObject() as RenderBox?;
    _controller.open(position: position ?? box?.size.center(Offset.zero));
    if (position == null) _focusFirstItem();
  }

  @override
  Widget build(BuildContext context) {
    _syncItemNodes();
    return MenuAnchor(
      controller: _controller,
      menuChildren: [
        for (var i = 0; i < widget.menuChildren.length; i++)
          Focus(focusNode: _itemNodes[i], child: widget.menuChildren[i]),
      ],
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
