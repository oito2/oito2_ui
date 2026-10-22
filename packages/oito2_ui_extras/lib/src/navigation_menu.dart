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

import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

/// An entry of an [Oito2NavigationMenu]: a link, or a trigger that opens
/// a panel built by [panelBuilder].
@immutable
class Oito2NavigationMenuItem {
  /// Creates a navigation menu item.
  const Oito2NavigationMenuItem({
    required this.label,
    this.onPressed,
    this.panelBuilder,
  }) : assert(
         onPressed == null || panelBuilder == null,
         'An item is either a link or a panel trigger.',
       );

  /// The item text.
  final String label;

  /// Called when a link item is pressed.
  final VoidCallback? onPressed;

  /// Builds the panel of a trigger item.
  final WidgetBuilder? panelBuilder;
}

/// A website-style header menu: links and triggers in a row, a line that
/// slides under the [selectedIndex] item, and flyout panels below the
/// triggers.
///
/// A panel opens on hover after [hoverDelay], or when its trigger is
/// pressed or gets Down, which also move the focus into it; moving the
/// pointer to another trigger switches panels at once.
/// The arrow keys move between the items and Escape closes a panel.
class Oito2NavigationMenu extends StatefulWidget {
  /// Creates a navigation menu.
  const Oito2NavigationMenu({
    super.key,
    required this.items,
    this.selectedIndex,
    this.hoverDelay = const Duration(milliseconds: 150),
    this.panelMaxWidth = 560,
    this.semanticLabel,
  }) : assert(selectedIndex == null || selectedIndex >= 0);

  /// The items, in order.
  final List<Oito2NavigationMenuItem> items;

  /// The item that marks the current page, or null for none.
  final int? selectedIndex;

  /// The wait before a hovered trigger opens its panel.
  final Duration hoverDelay;

  /// The largest panel width.
  final double panelMaxWidth;

  /// The accessibility label of the menu.
  final String? semanticLabel;

  @override
  State<Oito2NavigationMenu> createState() => _Oito2NavigationMenuState();
}

/// The text-safe accent of the theme, or its primary color when the
/// theme wasn't built by `Oito2Theme`.
Color _accent(BuildContext context) =>
    Oito2SemanticColors.maybeOf(context)?.primaryText ??
    Theme.of(context).colorScheme.primary;

class _Oito2NavigationMenuState extends State<Oito2NavigationMenu> {
  final _stackKey = GlobalKey();
  late List<GlobalKey> _keys;
  late List<Oito2PopoverController> _popovers;
  Rect? _indicator;
  int? _open;
  bool _keyboard = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _createItems();
  }

  @override
  void didUpdateWidget(Oito2NavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _disposeItems();
      _createItems();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeItems();
    super.dispose();
  }

  void _createItems() {
    _keys = [for (final _ in widget.items) GlobalKey()];
    _popovers = [for (final _ in widget.items) Oito2PopoverController()];
    _open = null;
  }

  void _disposeItems() {
    for (final popover in _popovers) {
      popover.dispose();
    }
  }

  /// Measures the selected item after layout and moves the line under it.
  void _measure() {
    final index = widget.selectedIndex;
    final stack = _stackKey.currentContext?.findRenderObject();
    Rect? rect;
    if (index != null &&
        index < _keys.length &&
        stack is RenderBox &&
        stack.hasSize) {
      final box = _keys[index].currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize) {
        final topLeft = box.localToGlobal(Offset.zero, ancestor: stack);
        rect = topLeft & box.size;
      }
    }
    if (rect != _indicator && mounted) setState(() => _indicator = rect);
  }

  void _show(int? index, {bool keyboard = false}) {
    _timer?.cancel();
    if (index == _open) return;
    setState(() {
      _keyboard = keyboard;
      _open = index;
    });
    // Opens after the rebuild, so the popover knows whether to take the
    // focus.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (var i = 0; i < _popovers.length; i++) {
        i == _open ? _popovers[i].open() : _popovers[i].close();
      }
    });
  }

  void _hoverTrigger(int index) {
    _timer?.cancel();
    if (_open != null) {
      _show(index);
    } else {
      _timer = Timer(widget.hoverDelay, () => _show(index));
    }
  }

  void _leave() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 250), () => _show(null));
  }

  Widget _trigger(BuildContext context, int index) {
    final theme = Theme.of(context);
    final item = widget.items[index];
    final selected = widget.selectedIndex == index;
    final open = _open == index;
    final color = selected ? _accent(context) : theme.colorScheme.onSurface;
    final hasPanel = item.panelBuilder != null;
    final button = TextButton(
      key: _keys[index],
      style: TextButton.styleFrom(foregroundColor: color),
      onPressed: hasPanel
          ? () => _show(open ? null : index, keyboard: true)
          : item.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Oito2Spacing.xs,
        children: [
          Text(item.label),
          if (hasPanel)
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: MediaQuery.maybeDisableAnimationsOf(context) ?? false
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              child: const Icon(LucideIcons.chevron_down, size: 16),
            ),
        ],
      ),
    );
    final semantics = Semantics(
      selected: selected,
      expanded: hasPanel ? open : null,
      child: button,
    );
    if (!hasPanel) return semantics;
    return Oito2Popover(
      controller: _popovers[index],
      focusOnOpen: _keyboard,
      maxWidth: widget.panelMaxWidth,
      padding: const EdgeInsets.all(Oito2Spacing.lg),
      semanticLabel: item.label,
      onOpenChanged: (isOpen) {
        if (!isOpen && _open == index) setState(() => _open = null);
      },
      builder: (context, _) => MouseRegion(
        onEnter: (_) => _hoverTrigger(index),
        onExit: (_) => _leave(),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                _show(index, keyboard: true),
          },
          child: semantics,
        ),
      ),
      popoverBuilder: (context, _) => MouseRegion(
        onEnter: (_) => _timer?.cancel(),
        onExit: (_) => _leave(),
        child: item.panelBuilder!(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _measure());
    final indicator = _indicator;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Stack(
        key: _stackKey,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.xs,
            children: [
              for (var i = 0; i < widget.items.length; i++)
                _trigger(context, i),
            ],
          ),
          if (indicator != null)
            AnimatedPositioned(
              duration: reduced
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              left: indicator.left + Oito2Spacing.sm,
              width: indicator.width - Oito2Spacing.sm * 2,
              top: indicator.bottom - 2,
              height: 2,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _accent(context),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
