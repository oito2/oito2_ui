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

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart'
    show RenderAbstractViewport, ScrollCacheExtent;
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/async_list_controller.dart';
import '../collections/list_collection.dart';
import '../collections/selection_controller.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'list_box.dart';
import 'progress.dart';
import 'widget_helpers.dart';

/// A scrolling list of the items of [collection] that builds only the
/// rows in view, for lists of thousands of items, with the selection kept
/// in [controller].
///
/// It selects and responds to the keyboard as an [Oito2ListBox]: the list
/// takes the focus as a whole and marks its active row; the arrow keys,
/// Home, End, Page Up and Page Down move the active row, which a
/// single-selection list also selects. In a multiple-selection list Space
/// toggles the active row, Shift with the movement keys extends the
/// selection and Control (Command on Apple platforms) with A selects all;
/// clicks follow the desktop conventions of
/// [Oito2SelectionController.click]. Typing letters jumps to the next
/// matching label. Enter or a double click calls [onActivate]. Disabled
/// items can't be selected or activated. Groups aren't shown as headings.
///
/// Every row is [itemExtent] tall, or as tall as its content with
/// [variableHeight]. Rows are keyed by their item value, so a row keeps
/// its state when items move. The list rebuilds the rows in view when it
/// rebuilds; to update a single row often, such as a progress, build its
/// changing part from a listenable of that item, such as with a
/// [ValueListenableBuilder] in [itemBuilder], so only that row rebuilds.
///
/// [onReachEnd] runs when the end of the list comes within
/// [reachEndThreshold] of the view, once until the user scrolls away from
/// the end or the number of items changes. With [asyncController], it
/// also loads the next page, and the list ends with a loading row while a
/// page loads, or with an error row and a retry button when it failed;
/// the app builds [collection] from the controller's items.
///
/// The list needs a bounded height, such as from a [SizedBox] or an
/// [Expanded].
class Oito2VirtualList<T> extends StatefulWidget {
  /// Creates a virtual list.
  const Oito2VirtualList({
    super.key,
    required this.collection,
    required this.controller,
    this.itemBuilder,
    this.onActivate,
    this.itemExtent,
    this.variableHeight = false,
    this.cacheExtent,
    this.onReachEnd,
    this.reachEndThreshold = 200,
    this.asyncController,
    this.header,
    this.footer,
    this.placeholder,
    this.showCheckmarks = true,
    this.semanticLabel,
    this.autofocus = false,
  });

  /// The items.
  final Oito2ListCollection<T> collection;

  /// The selection over [collection].
  final Oito2SelectionController controller;

  /// Builds the content of a row; shows the item label when null. It is
  /// called only for the rows being built, so it must be cheap.
  final Oito2ListBoxItemBuilder<T>? itemBuilder;

  /// Called on Enter or a double click on an enabled item.
  final ValueChanged<T>? onActivate;

  /// The height of every row; the theme's control height when null, or,
  /// where the theme pads tap targets (touch platforms), a height that
  /// makes each row [Oito2Sizes.minTouchTarget] tall. With
  /// [variableHeight], the estimated height of the rows not built yet.
  ///
  /// A height set here is kept on every platform, even below the touch
  /// target size.
  final double? itemExtent;

  /// Whether each row is as tall as its content, instead of [itemExtent].
  ///
  /// A row is at least 30 pixels tall, or [Oito2Sizes.minTouchTarget]
  /// where the theme pads tap targets. Each row is then laid out as it
  /// scrolls into view, and moving the
  /// active row to one far away scrolls to an estimated position first.
  final bool variableHeight;

  /// How far beyond the visible area rows are built ahead of scrolling,
  /// in logical pixels; the scroll view's default when null.
  final double? cacheExtent;

  /// Called when the end of the list comes within [reachEndThreshold] of
  /// the view, such as to load more items.
  final VoidCallback? onReachEnd;

  /// How close to the end of the list, in logical pixels, [onReachEnd]
  /// runs.
  final double reachEndThreshold;

  /// The controller the items are loaded through: the list loads its next
  /// page when the end comes near, and shows its loading and error states
  /// after the last row.
  final Oito2AsyncListController<Object?, Object?>? asyncController;

  /// Shown above the first row, scrolling with the rows.
  final Widget? header;

  /// Shown after the last row, scrolling with the rows.
  final Widget? footer;

  /// Shown when [collection] is empty and nothing is loading; a "no
  /// items" text when null.
  final Widget? placeholder;

  /// Whether rows of a multiple-selection list show a check mark when
  /// selected.
  final bool showCheckmarks;

  /// The accessibility label of the list.
  final String? semanticLabel;

  /// Whether the list takes the focus when shown.
  final bool autofocus;

  @override
  State<Oito2VirtualList<T>> createState() => _Oito2VirtualListState<T>();
}

/// Tracks the active row, the type-ahead text, the reach-end state and
/// the contexts of the built rows of [Oito2VirtualList], and turns keys
/// and clicks into selection changes.
class _Oito2VirtualListState<T> extends State<Oito2VirtualList<T>> {
  final _focusNode = FocusNode(debugLabel: 'Oito2VirtualList');
  final _scroll = ScrollController();
  final _headerKey = GlobalKey();

  /// The context of each built row, by item value, to scroll rows of
  /// variable height into view.
  final Map<String, BuildContext> _rows = {};

  /// The value of the active row, or null before the list is used.
  String? _active;

  /// The text typed for type-ahead search, cleared after a pause.
  String _typed = '';
  Timer? _typeTimer;
  final _clicks = DoubleClickDetector();

  /// Whether [Oito2VirtualList.onReachEnd] can run the next time the end
  /// comes near.
  bool _reachEndArmed = true;
  bool _reachEndCheckScheduled = false;

  Oito2ListCollection<T> get _collection => widget.collection;
  Oito2SelectionController get _selection => widget.controller;
  bool get _multiple => _selection.mode == Oito2SelectionMode.multiple;

  /// The space around the rows.
  static const _padding = Oito2Spacing.xs;

  /// The space above and below the tappable part of each row.
  static const _rowGap = 1.0;

  @override
  void initState() {
    super.initState();
    _selection.addListener(_refresh);
    widget.asyncController?.addListener(_onAsyncChange);
    _focusNode.addListener(_onFocus);
    _scheduleReachEndCheck();
  }

  @override
  void didUpdateWidget(Oito2VirtualList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
    if (oldWidget.asyncController != widget.asyncController) {
      oldWidget.asyncController?.removeListener(_onAsyncChange);
      widget.asyncController?.addListener(_onAsyncChange);
    }
    if (_active != null && !_collection.has(_active)) _active = null;
    if (oldWidget.collection.length != widget.collection.length) {
      _reachEndArmed = true;
      _scheduleReachEndCheck();
    }
  }

  @override
  void dispose() {
    _selection.removeListener(_refresh);
    widget.asyncController?.removeListener(_onAsyncChange);
    _focusNode.dispose();
    _scroll.dispose();
    _typeTimer?.cancel();
    _clicks.cancel();
    super.dispose();
  }

  /// Rebuilds when still mounted.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// Rebuilds for the new loading state and, once a load ends, checks
  /// again whether the end is near.
  void _onAsyncChange() {
    if (!mounted) return;
    final async = widget.asyncController!;
    if (!async.isLoading && !async.isLoadingMore) {
      _reachEndArmed = true;
      _scheduleReachEndCheck();
    }
    setState(() {});
  }

  /// Activates the first selected or enabled row when the list gains
  /// focus without an active row, and rebuilds to update the focus marks.
  void _onFocus() {
    if (_focusNode.hasFocus && _active == null) {
      _active = _selection.firstSelectedValue ?? _collection.firstValue;
    }
    _refresh();
  }

  /// Checks after the frame whether the end is near, as when the rows
  /// don't fill the view.
  void _scheduleReachEndCheck() {
    if (_reachEndCheckScheduled) return;
    _reachEndCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reachEndCheckScheduled = false;
      if (mounted && _scroll.hasClients) _checkReachEnd(_scroll.position);
    });
  }

  /// Runs the reach-end callbacks when the end is within the threshold
  /// and they are armed, and arms them again once it is farther.
  void _checkReachEnd(ScrollMetrics metrics) {
    if (metrics.axis != Axis.vertical || !metrics.hasContentDimensions) {
      return;
    }
    if (metrics.extentAfter > widget.reachEndThreshold) {
      _reachEndArmed = true;
      return;
    }
    if (!_reachEndArmed) return;
    _reachEndArmed = false;
    widget.onReachEnd?.call();
    final async = widget.asyncController;
    if (async != null && async.error == null && async.hasMore) {
      unawaited(async.loadMore());
    }
  }

  /// The height of every row, or the estimate of a row of variable
  /// height: [Oito2VirtualList.itemExtent], or a row of the touch target
  /// size where the theme pads tap targets, or the control height.
  double get _extent =>
      widget.itemExtent ??
      (padsTapTargets(context)
          ? Oito2Sizes.minTouchTarget + 2 * _rowGap
          : controlHeightOf(context));

  /// The height of the [Oito2VirtualList.header], or 0.
  double get _headerHeight {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    return box != null && box.hasSize ? box.size.height : 0;
  }

  /// The number of rows a page movement skips: those in view, less one.
  int get _pageRows {
    if (!_scroll.hasClients) return 1;
    final rows = (_scroll.position.viewportDimension / _extent).floor() - 1;
    return math.max(1, rows);
  }

  /// Scrolls the row of [value] fully into view.
  void _reveal(String value) {
    final index = _collection.indexOf(value);
    if (!_scroll.hasClients || index < 0) return;
    final position = _scroll.position;
    if (widget.variableHeight) {
      _revealVariable(value, 8);
      return;
    }
    final top = _headerHeight + _padding + index * _extent;
    final bottom = top + _extent;
    if (top - _padding < position.pixels) {
      _scroll.jumpTo(math.max(0.0, top - _padding));
    } else if (bottom + _padding >
        position.pixels + position.viewportDimension) {
      _scroll.jumpTo(
        math.min(
          position.maxScrollExtent,
          bottom + _padding - position.viewportDimension,
        ),
      );
    }
  }

  /// Scrolls the row of [value], of variable height, fully into view:
  /// when it isn't built, jumps to its position estimated from the
  /// nearest built row and tries again after the frame, at most
  /// [attempts] times.
  void _revealVariable(String value, int attempts) {
    final built = _rows[value];
    if (built != null && built.mounted) {
      _ensureVisible(built);
      return;
    }
    if (attempts <= 0 || !_scroll.hasClients) return;
    final index = _collection.indexOf(value);
    if (index < 0) return;
    final position = _scroll.position;
    var estimate = _headerHeight + _padding + index * _extent;
    var distance = -1;
    for (final MapEntry(key: other, value: context) in _rows.entries) {
      final box = context.mounted ? context.findRenderObject() : null;
      if (box is! RenderBox || !box.attached) continue;
      final otherIndex = _collection.indexOf(other);
      if (otherIndex < 0) continue;
      final gap = (otherIndex - index).abs();
      if (distance >= 0 && gap >= distance) continue;
      final viewport = RenderAbstractViewport.maybeOf(box);
      if (viewport == null) continue;
      distance = gap;
      estimate =
          viewport.getOffsetToReveal(box, 0).offset +
          (index - otherIndex) * _extent;
    }
    _scroll.jumpTo(
      (estimate - position.viewportDimension / 2).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _revealVariable(value, attempts - 1);
    });
  }

  /// Scrolls the row of [context] fully into view.
  void _ensureVisible(BuildContext context) {
    Scrollable.ensureVisible(
      context,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
    Scrollable.ensureVisible(
      context,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    );
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
    _reveal(value);
  }

  /// Returns the value [count] enabled rows after [value], or before it
  /// when [count] is negative, stopping at either end.
  String? _move(String value, int count) {
    var current = value;
    for (var i = 0; i < count.abs(); i++) {
      final next = count > 0
          ? _collection.nextValue(current)
          : _collection.previousValue(current);
      if (next == null) break;
      current = next;
    }
    return current;
  }

  /// Handles navigation, selection, activation and type-ahead keys.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
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
    } else if (key == LogicalKeyboardKey.pageDown) {
      _activate(
        active == null ? _collection.firstValue : _move(active, _pageRows),
        extend: shift,
      );
    } else if (key == LogicalKeyboardKey.pageUp) {
      _activate(
        active == null ? _collection.firstValue : _move(active, -_pageRows),
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
      if (character == null ||
          command ||
          character.trim().isEmpty ||
          character.codeUnitAt(0) < 0x20) {
        return KeyEventResult.ignored;
      }
      _typeTimer?.cancel();
      _typeTimer = Timer(const Duration(milliseconds: 600), () => _typed = '');
      final repeat = _typed == character;
      _typed = repeat ? character : _typed + character;
      final from = repeat || _typed.length == 1 ? active : null;
      final match =
          _collection.search(_typed, from: from) ??
          (from == null ? null : _collection.search(_typed));
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

  /// Builds the row at [index] with its selection, active and disabled
  /// states, keyed by its item value.
  Widget _row(BuildContext context, int index) {
    final item = _collection.items[index];
    final value = _collection.valueOf(item);
    return KeyedSubtree(
      key: ValueKey(value),
      child: Builder(
        builder: (context) {
          if (widget.variableHeight) _track(value, context);
          return _rowContent(context, item, value);
        },
      ),
    );
  }

  /// Keeps [context] as the one of the row of [value], dropping the
  /// contexts of rows no longer built once there are many.
  void _track(String value, BuildContext context) {
    _rows[value] = context;
    if (_rows.length > 512) _rows.removeWhere((_, c) => !c.mounted);
  }

  /// Builds the frame and content of the row of [item].
  Widget _rowContent(BuildContext context, T item, String value) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
        Text(
          _collection.labelOf(item),
          maxLines: widget.variableHeight ? null : 1,
          overflow: widget.variableHeight ? null : TextOverflow.ellipsis,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _rowGap),
      child: Semantics(
        container: true,
        selected: selected,
        enabled: !disabled,
        focused: active,
        button: true,
        onTap: disabled ? null : () => _click(value),
        child: InkWell(
          mouseCursor: WidgetStateMouseCursor.clickable,
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
              minHeight: padsTapTargets(context)
                  ? Oito2Sizes.minTouchTarget
                  : 30,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Oito2Spacing.sm,
              vertical: Oito2Spacing.xxs,
            ),
            decoration: BoxDecoration(
              color: selected ? scheme.secondaryContainer : null,
              borderRadius: Oito2Radius.smallAll,
            ),
            foregroundDecoration: BoxDecoration(
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
                    Expanded(child: content),
                    if (_multiple && widget.showCheckmarks)
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
      ),
    );
  }

  /// Builds the loading or error row of the [Oito2VirtualList.asyncController],
  /// or returns null when it has neither.
  Widget? _statusRow(BuildContext context) {
    final async = widget.asyncController;
    if (async == null) return null;
    final theme = Theme.of(context);
    final strings = Oito2Localizations.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    if (async.error != null) {
      return Padding(
        key: const ValueKey('oito2-virtual-list-error'),
        padding: const EdgeInsets.symmetric(
          horizontal: Oito2Spacing.sm,
          vertical: Oito2Spacing.xs,
        ),
        child: Row(
          spacing: Oito2Spacing.sm,
          children: [
            Icon(
              LucideIcons.circle_x,
              size: 16,
              color: theme.colorScheme.error,
            ),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(strings.loadFailed, style: muted),
              ),
            ),
            TextButton(
              style: const ButtonStyle(
                mouseCursor: WidgetStateMouseCursor.clickable,
              ),
              onPressed: () =>
                  unawaited(async.hasMore ? async.loadMore() : async.reload()),
              child: Text(strings.retry),
            ),
          ],
        ),
      );
    }
    if (async.isLoading || async.isLoadingMore) {
      return SizedBox(
        key: const ValueKey('oito2-virtual-list-loading'),
        height: _extent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Oito2Spacing.sm,
          children: [
            const Oito2CircularProgressIndicator(size: 14, strokeWidth: 2),
            Semantics(
              liveRegion: true,
              child: Text(
                async.isLoading ? strings.loading : strings.loadingMore,
                style: muted,
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final async = widget.asyncController;
    final status = _statusRow(context);
    final empty =
        _collection.isEmpty && status == null && !(async?.isLoading ?? false);
    final delegate = SliverChildBuilderDelegate(
      _row,
      childCount: _collection.length,
      findChildIndexCallback: (key) {
        final index = key is ValueKey<String>
            ? _collection.indexOf(key.value)
            : -1;
        return index < 0 ? null : index;
      },
    );
    final theme = Theme.of(context);
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onKeyEvent: _onKey,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.depth == 0) _checkReachEnd(notification.metrics);
            return false;
          },
          child: CustomScrollView(
            controller: _scroll,
            scrollCacheExtent: switch (widget.cacheExtent) {
              final extent? => ScrollCacheExtent.pixels(extent),
              null => null,
            },
            semanticChildCount: _collection.length,
            slivers: [
              if (widget.header case final header?)
                SliverToBoxAdapter(
                  child: KeyedSubtree(key: _headerKey, child: header),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(_padding),
                sliver: widget.variableHeight
                    ? SliverList(delegate: delegate)
                    : SliverFixedExtentList(
                        itemExtent: _extent,
                        delegate: delegate,
                      ),
              ),
              if (status != null) SliverToBoxAdapter(child: status),
              if (empty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child:
                        widget.placeholder ??
                        Text(
                          Oito2Localizations.of(context).noItems,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                  ),
                ),
              if (widget.footer case final footer?)
                SliverToBoxAdapter(child: footer),
            ],
          ),
        ),
      ),
    );
  }
}
