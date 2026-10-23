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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// A button of an [Oito2ToggleGroup].
@immutable
class Oito2ToggleItem<T> {
  /// Creates a toggle item for [value].
  const Oito2ToggleItem({
    required this.value,
    required this.child,
    this.tooltip,
    this.enabled = true,
  });

  /// The value the item turns on and off.
  final T value;

  /// The item content: an [Icon], a [Text] or both.
  final Widget child;

  /// The tooltip, also the accessibility label of an item showing only an
  /// icon.
  final String? tooltip;

  /// Whether the item can be toggled and focused; a disabled item is
  /// dimmed.
  final bool enabled;
}

/// A joined row (or column) of buttons that turn on and off, such as text
/// formatting or alignment buttons.
///
/// With [multiple], each item turns on and off by itself; otherwise turning
/// one on turns the others off, and [deselectable] says whether the one
/// that is on can be turned off. Items that are on are raised from the
/// track.
///
/// The group is one stop in keyboard navigation: the arrow keys move
/// between the enabled items, wrapping at the ends, and Space or Enter
/// toggles the focused one.
class Oito2ToggleGroup<T> extends StatefulWidget {
  /// Creates a toggle group.
  const Oito2ToggleGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.multiple = false,
    this.deselectable = true,
    this.orientation = Axis.horizontal,
  });

  /// The items, in order.
  final List<Oito2ToggleItem<T>> items;

  /// The values of the items that are on.
  final Set<T> selected;

  /// Called with the new set of values that are on; null disables the
  /// group.
  final ValueChanged<Set<T>>? onChanged;

  /// Whether several items can be on at once.
  final bool multiple;

  /// Whether the only item that is on can be turned off, leaving none on;
  /// ignored when [multiple].
  final bool deselectable;

  /// Whether the items run across or down.
  final Axis orientation;

  @override
  State<Oito2ToggleGroup<T>> createState() => _Oito2ToggleGroupState<T>();
}

class _Oito2ToggleGroupState<T> extends State<Oito2ToggleGroup<T>> {
  final List<FocusNode> _nodes = [];

  /// The item that is the group's stop in keyboard navigation.
  int _focused = 0;

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Keeps one focus node per item, disposing removed nodes after the
  /// frame.
  void _syncNodes() {
    while (_nodes.length < widget.items.length) {
      _nodes.add(FocusNode(debugLabel: 'Oito2ToggleGroup item'));
    }
    while (_nodes.length > widget.items.length) {
      final node = _nodes.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => node.dispose());
    }
  }

  /// Whether the item at [index] responds to input.
  bool _canToggle(int index) =>
      widget.onChanged != null && widget.items[index].enabled;

  /// Focuses the item at [index] and reports the selection with it turned
  /// on or off.
  void _toggle(int index) {
    if (!_canToggle(index)) return;
    setState(() => _focused = index);
    _nodes[index].requestFocus();
    final value = widget.items[index].value;
    final on = widget.selected.contains(value);
    final Set<T> next;
    if (widget.multiple) {
      next = on
          ? ({...widget.selected}..remove(value))
          : {...widget.selected, value};
    } else if (on) {
      if (!widget.deselectable) return;
      next = {};
    } else {
      next = {value};
    }
    widget.onChanged!(next);
  }

  /// Moves focus to the next enabled item along the arrow pressed, or
  /// toggles the item at [index] on Space or Enter.
  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final (:back, :forward) = readingArrowsOf(context);
    final vertical = widget.orientation == Axis.vertical;
    final int step;
    if (key == (vertical ? LogicalKeyboardKey.arrowUp : back)) {
      step = -1;
    } else if (key == (vertical ? LogicalKeyboardKey.arrowDown : forward)) {
      step = 1;
    } else if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.enter) {
      _toggle(index);
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
    final count = widget.items.length;
    for (var i = 1; i < count; i++) {
      final next = (index + step * i) % count;
      if (_canToggle(next)) {
        setState(() => _focused = next);
        _nodes[next].requestFocus();
        break;
      }
    }
    return KeyEventResult.handled;
  }

  /// Builds the item at [index]; only the item at [tabStop] takes part in
  /// focus traversal.
  Widget _item(int index, int tabStop) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.items[index];
    final on = widget.selected.contains(item.value);
    final enabled = _canToggle(index);
    final height = controlHeightOf(context);
    Widget content = _ToggleItemSurface(
      on: on,
      enabled: enabled,
      onTap: () => _toggle(index),
      child: Container(
        constraints: BoxConstraints(minWidth: height, minHeight: height),
        padding: const EdgeInsets.symmetric(horizontal: Oito2Spacing.sm),
        child: Align(
          widthFactor: 1,
          heightFactor: 1,
          child: IconTheme.merge(
            data: IconThemeData(
              color: scheme.onSurface,
              size: Oito2Sizes.iconSize,
            ),
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              child: item.child,
            ),
          ),
        ),
      ),
    );
    if (!item.enabled) content = Opacity(opacity: 0.5, child: content);
    Widget result = MergeSemantics(
      child: Oito2FocusBorder(
        borderRadius: Oito2Radius.checkAll,
        child: Focus(
          focusNode: _nodes[index],
          canRequestFocus: enabled,
          skipTraversal: index != tabStop,
          onFocusChange: (focused) {
            if (focused && _focused != index) setState(() => _focused = index);
          },
          onKeyEvent: (_, event) => _onKey(index, event),
          child: Semantics(
            button: true,
            toggled: on,
            enabled: enabled,
            label: item.tooltip,
            onTap: enabled ? () => _toggle(index) : null,
            child: content,
          ),
        ),
      ),
    );
    if (item.tooltip case final tooltip?) {
      result = Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: result,
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final scheme = Theme.of(context).colorScheme;
    // The last focused item, or the first enabled one, is the group's stop
    // in keyboard navigation.
    final tabStop = _focused < widget.items.length && _canToggle(_focused)
        ? _focused
        : List.generate(
            widget.items.length,
            (i) => i,
          ).firstWhere(_canToggle, orElse: () => -1);
    final vertical = widget.orientation == Axis.vertical;
    final flex = Flex(
      direction: widget.orientation,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      spacing: 1,
      children: [
        for (var i = 0; i < widget.items.length; i++) _item(i, tabStop),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(Oito2Spacing.xxs),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: Oito2Radius.smallAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: vertical ? IntrinsicWidth(child: flex) : flex,
    );
  }
}

/// The surface of a toggle item: transparent when off, tinted on hover,
/// raised when on.
class _ToggleItemSurface extends StatefulWidget {
  const _ToggleItemSurface({
    required this.on,
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  final bool on;
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_ToggleItemSurface> createState() => _ToggleItemSurfaceState();
}

class _ToggleItemSurfaceState extends State<_ToggleItemSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.on
        ? scheme.surface
        : _hovered && widget.enabled
        ? scheme.surfaceContainerHighest
        : null;
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: motionDuration(context, const Duration(milliseconds: 100)),
          decoration: BoxDecoration(
            color: color,
            borderRadius: Oito2Radius.checkAll,
            boxShadow: widget.on
                ? [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.12),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
