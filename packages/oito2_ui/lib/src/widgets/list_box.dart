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
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/list_collection.dart';
import '../collections/selection_controller.dart';
import '../tokens/geometry.dart';
import 'list_reorder.dart';
import 'row_drag.dart';
import 'type_ahead.dart';
import 'widget_helpers.dart';

/// Builds the content of an [Oito2ListBox] row.
typedef Oito2ListBoxItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool selected,
);

/// A list of the items of [collection] that the user selects from, with
/// the selection kept in [controller].
///
/// The list takes the focus as a whole and marks its active row. The
/// arrow keys, Home and End move the active row, which a single-selection
/// list also selects. In a multiple-selection list Space toggles the
/// active row, Shift with the arrows extends the selection and Control
/// (Command on Apple platforms) with A selects all; clicks follow the
/// desktop conventions of [Oito2SelectionController.click]. Typing letters
/// jumps to the next matching label. Enter or a double click calls
/// [onActivate]. Grouped items show under their group headings; disabled
/// items can't be selected or activated.
///
/// With [onReorder], the user reorders the items: Alt with Up or Down
/// moves the active row up or down by one, the rows offer "Move up" and
/// "Move down" accessibility actions, and the rows can be dragged, with
/// a line between the rows marking the drop and the list scrolling when
/// the pointer nears its top or bottom edge; Escape cancels a drag. A
/// mouse drags a row once it moves a few pixels and a touch after a long
/// press, or, with [dragHandle], only the grip at the start of each row
/// drags it, with any pointer. Disabled items can't be dragged. The list
/// doesn't change [collection]: the app moves the item. A list whose
/// items fall in more than one group can't be reordered.
///
/// Every row is built, so it suits lists of up to a few hundred items;
/// [Oito2VirtualList] builds only the rows in view, for longer lists.
class Oito2ListBox<T> extends StatefulWidget {
  /// Creates a list box.
  const Oito2ListBox({
    super.key,
    required this.collection,
    required this.controller,
    this.itemBuilder,
    this.onActivate,
    this.maxHeight = double.infinity,
    this.semanticLabel,
    this.autofocus = false,
    this.onReorder,
    this.dragHandle = false,
  });

  /// The items.
  final Oito2ListCollection<T> collection;

  /// The selection over [collection].
  final Oito2SelectionController controller;

  /// Builds the content of a row; shows the item label when null.
  final Oito2ListBoxItemBuilder<T>? itemBuilder;

  /// Called on Enter or a double click on an enabled item.
  final ValueChanged<T>? onActivate;

  /// The largest height; the list scrolls beyond it.
  final double maxHeight;

  /// The accessibility label of the list.
  final String? semanticLabel;

  /// Whether the list takes the focus when shown.
  final bool autofocus;

  /// Called when the user moves an item, with its index in
  /// [Oito2ListCollection.items] and the index it ends at, counted once it
  /// is taken out of its place: moving the first of three items to the end
  /// reports `(0, 2)`. The items can't be reordered when null.
  final void Function(int from, int to)? onReorder;

  /// Whether only a grip at the start of each row drags it, instead of
  /// the whole row, when [onReorder] is set.
  final bool dragHandle;

  @override
  State<Oito2ListBox<T>> createState() => _Oito2ListBoxState<T>();
}

/// Tracks the active row, the type-ahead text and the row keys of
/// [Oito2ListBox], and turns keys and clicks into selection changes.
class _Oito2ListBoxState<T> extends State<Oito2ListBox<T>>
    with ListReorderMixin<T, Oito2ListBox<T>> {
  final _focusNode = FocusNode(debugLabel: 'Oito2ListBox');
  final _scroll = ScrollController();
  final _viewportKey = GlobalKey();

  /// The key of each built row, by item value, to scroll rows into view.
  final Map<String, GlobalKey> _keys = {};

  /// The value of the active row, or null before the list is used.
  String? _active;

  /// The text typed for type-ahead search, cleared after a pause.
  final _typeAhead = TypeAheadBuffer();
  final _clicks = DoubleClickDetector();

  Oito2ListCollection<T> get _collection => widget.collection;
  Oito2SelectionController get _selection => widget.controller;
  bool get _multiple => _selection.mode == Oito2SelectionMode.multiple;

  @override
  Oito2ListCollection<T> get reorderCollection => _collection;

  @override
  void Function(int from, int to)? get onReorder => widget.onReorder;

  @override
  bool get canReorder =>
      widget.onReorder != null && _collection.groups.length <= 1;

  @override
  Iterable<MapEntry<String, BuildContext>> get builtRows sync* {
    for (final MapEntry(:key, :value) in _keys.entries) {
      final context = value.currentContext;
      if (context != null) yield MapEntry(key, context);
    }
  }

  @override
  RenderBox? get reorderViewport =>
      _viewportKey.currentContext?.findRenderObject() as RenderBox?;

  @override
  ScrollPosition? get reorderScroll =>
      _scroll.hasClients ? _scroll.position : null;

  @override
  void activateForReorder(String value) {
    _focusNode.requestFocus();
    setState(() => _active = value);
  }

  @override
  void revealForReorder(String value) {
    final context = _keys[value]?.currentContext;
    if (context == null || !context.mounted) return;
    Scrollable.ensureVisible(
      context,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
    Scrollable.ensureVisible(
      context,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    );
  }

  /// Whether the items can be reordered, computed once per build.
  bool _reorderable = false;

  @override
  void initState() {
    super.initState();
    _selection.addListener(_refresh);
    _focusNode.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(Oito2ListBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
    if (_active != null && !_collection.has(_active)) _active = null;
    if (!identical(oldWidget.collection, widget.collection)) {
      _keys.removeWhere((value, _) => !_collection.has(value));
    }
    if (reorderDragging && !canReorder) stopRowDrag(rebuild: false);
  }

  @override
  void dispose() {
    _selection.removeListener(_refresh);
    _focusNode.dispose();
    _scroll.dispose();
    _typeAhead.dispose();
    _clicks.cancel();
    disposeReorder();
    super.dispose();
  }

  /// Rebuilds when still mounted.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// Activates the first selected or enabled row when the list gains
  /// focus without an active row, and rebuilds to update the focus marks.
  void _onFocus() {
    if (_focusNode.hasFocus && _active == null) {
      _active = _selection.firstSelectedValue ?? _collection.firstValue;
    }
    _refresh();
  }

  /// Makes [value] the active row and scrolls it into view; a single
  /// selection list also selects it, and a multiple one with [extend]
  /// extends the selection from the anchor to it.
  void _activate(String? value, {bool extend = false}) {
    if (value == null) return;
    final anchor = _selection.anchorValue ?? _active;
    setState(() => _active = value);
    if (!_multiple) {
      _selection.replace(value);
    } else if (extend && anchor != null) {
      _selection.extend(anchor, value);
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => revealForReorder(value),
    );
  }

  /// Handles navigation, selection, activation and type-ahead keys.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final reordered = reorderKey(event, _active);
    if (reordered != null) return reordered;
    final keyboard = HardwareKeyboard.instance;
    final shift = keyboard.isShiftPressed;
    final command = keyboard.isControlPressed || keyboard.isMetaPressed;
    final key = event.logicalKey;
    final active = _active;
    if (key == LogicalKeyboardKey.arrowDown) {
      _activate(
        active == null
            ? _collection.firstValue
            : _collection.nextValue(active) ?? active,
        extend: shift,
      );
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _activate(
        active == null
            ? _collection.lastValue
            : _collection.previousValue(active) ?? active,
        extend: shift,
      );
    } else if (key == LogicalKeyboardKey.home) {
      _activate(_collection.firstValue, extend: shift);
    } else if (key == LogicalKeyboardKey.end) {
      _activate(_collection.lastValue, extend: shift);
    } else if (key == LogicalKeyboardKey.space && _multiple && active != null) {
      _selection.toggle(active);
    } else if (key == LogicalKeyboardKey.keyA && command && _multiple) {
      _selection.selectAll();
    } else if (key == LogicalKeyboardKey.enter && active != null) {
      final item = _collection.find(active);
      if (item == null || _collection.isDisabled(item)) {
        return KeyEventResult.ignored;
      }
      widget.onActivate?.call(item);
    } else {
      final character = event.character;
      if (command || !TypeAheadBuffer.accepts(character)) {
        return KeyEventResult.ignored;
      }
      final (:prefix, :fromNext) = _typeAhead.add(character!);
      final from = fromNext ? active : null;
      final match =
          _collection.search(prefix, from: from) ??
          (from == null ? null : _collection.search(prefix));
      if (match != null) _activate(match);
    }
    return KeyEventResult.handled;
  }

  /// Focuses the list, activates the row of [value] and applies a click
  /// with the pressed Shift, Control or Command modifiers.
  void _click(String value) {
    final keyboard = HardwareKeyboard.instance;
    _focusNode.requestFocus();
    setState(() => _active = value);
    _selection.click(
      value,
      extend: keyboard.isShiftPressed,
      toggle: keyboard.isControlPressed || keyboard.isMetaPressed,
    );
  }

  /// Builds the row of [item] with its selection, active and disabled
  /// states.
  Widget _row(BuildContext context, T item) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final value = _collection.valueOf(item);
    final disabled = _collection.isDisabled(item);
    final selected = _selection.isSelected(value);
    final active = _focusNode.hasFocus && _active == value;
    final keyboard =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final foreground = disabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    final content =
        widget.itemBuilder?.call(context, item, selected) ??
        Text(_collection.labelOf(item));
    final drag = _reorderable && !disabled
        ? (Offset global) => startRowDrag(value, global)
        : null;
    final handle = widget.onReorder != null && widget.dragHandle;
    final row = Semantics(
      key: _keys.putIfAbsent(value, GlobalKey.new),
      container: true,
      selected: selected,
      enabled: !disabled,
      focused: active,
      button: true,
      onTap: disabled ? null : () => _click(value),
      customSemanticsActions: _reorderable ? reorderActions(value) : null,
      child: InkWell(
        mouseCursor: reorderDragging
            ? MouseCursor.defer
            : WidgetStateMouseCursor.clickable,
        excludeFromSemantics: true,
        onTap: disabled ? null : () {},
        onTapUp: disabled
            ? null
            : (details) {
                _click(value);
                if (_clicks.click(value)) widget.onActivate?.call(item);
              },
        canRequestFocus: false,
        borderRadius: Oito2Radius.smallAll,
        child: Container(
          constraints: BoxConstraints(
            minHeight: padsTapTargets(context) ? Oito2Sizes.minTouchTarget : 32,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Oito2Spacing.sm,
            vertical: Oito2Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.secondaryContainer : null,
            borderRadius: Oito2Radius.smallAll,
            border: active && keyboard
                ? Border.all(
                    color: semanticColorsOf(context).primaryText,
                    width: Oito2Sizes.focusBorderWidth,
                  )
                : null,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: foreground, size: 16),
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
              child: Row(
                spacing: Oito2Spacing.sm,
                children: [
                  if (handle)
                    RowDragHandle(onStart: drag, dragging: reorderDragging),
                  Expanded(child: content),
                  if (_multiple)
                    Opacity(
                      opacity: selected ? 1 : 0,
                      child: const Icon(LucideIcons.check),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.onReorder == null) return row;
    return decorateReorderRow(
      value,
      RowDragDetector(onStart: handle ? null : drag, child: row),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _collection.groups;
    _reorderable = widget.onReorder != null && groups.length <= 1;
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onKeyEvent: _onKey,
        child: ConstrainedBox(
          key: _viewportKey,
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: MouseRegion(
            cursor: reorderCursor,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(Oito2Spacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 2,
                children: [
                  for (final group in groups) ...[
                    if (group.group != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          Oito2Spacing.sm,
                          Oito2Spacing.sm,
                          Oito2Spacing.sm,
                          Oito2Spacing.xxs,
                        ),
                        child: Semantics(
                          header: true,
                          child: Text(
                            group.group!,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    for (final item in group.items) _row(context, item),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
