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

import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'touch_target.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// A segment of an [Oito2Breadcrumb], such as a folder of a path.
@immutable
class Oito2BreadcrumbItem<T> {
  /// Creates a breadcrumb segment named [label].
  const Oito2BreadcrumbItem({required this.label, this.icon, this.value});

  /// The segment name.
  final String label;

  /// An icon before [label], such as a drive or home icon.
  final IconData? icon;

  /// The value the segment stands for, such as a folder path.
  final T? value;
}

/// A path bar: the [items] from the root to the current location, with
/// chevron separators that point toward the end of the reading direction.
///
/// Every segment but the last is a button that calls [onSelected] with its
/// index; the last one is the current location and reads as such to
/// assistive technologies. When the segments don't fit the width, the
/// ones after the first collapse into a "…" button, as few as needed, so
/// the last segments stay visible; the button opens a menu with the
/// hidden segments. When even the first and the last don't fit, the first
/// collapses too and the last one is cut with an ellipsis.
///
/// With [onSubmitted], the bar can turn into a text field holding [path]:
/// through the edit button at its end, or a click on its empty area.
/// Enter submits the text to [onSubmitted] and Escape, or moving the focus
/// away, cancels. Left and Right move the focus between the segment
/// buttons.
class Oito2Breadcrumb<T> extends StatefulWidget {
  /// Creates a breadcrumb.
  const Oito2Breadcrumb({
    super.key,
    required this.items,
    this.onSelected,
    this.onSubmitted,
    this.path,
    this.pathSeparator = '/',
  });

  /// The segments, from the root to the current location.
  final List<Oito2BreadcrumbItem<T>> items;

  /// Called with the index of an activated segment; null makes the
  /// segments plain text.
  final ValueChanged<int>? onSelected;

  /// Called with the text submitted in the edit mode; null turns the
  /// edit mode off.
  final ValueChanged<String>? onSubmitted;

  /// The text of the edit field; defaults to the labels of [items] joined
  /// by [pathSeparator].
  final String? path;

  /// The separator that joins the labels into the default [path].
  final String pathSeparator;

  /// The width of the chevron between two segments.
  static const double separatorWidth = 20;

  /// The width of the "…" and edit buttons, before any padding to the
  /// touch target.
  static const double buttonWidth = 28;

  /// Returns which segments a breadcrumb collapses into its "…" button
  /// when its segments, [widths] wide from the root to the current
  /// location, are laid out in [maxWidth].
  ///
  /// Every segment but the last is at least [minSegmentWidth] wide, the
  /// segments are [separatorWidth] apart, the "…" button is [buttonWidth]
  /// wide and [editWidth] is kept free at the end for the edit button and
  /// its gap. When every segment fits, none collapses. Otherwise the
  /// segments after the first collapse, from the second on and as few as
  /// needed, so the last ones stay; when even the first and the last
  /// don't fit with the button, every segment but the last collapses.
  ///
  /// Returns the collapsed range of indexes, from `collapsedStart`
  /// inclusive to `collapsedEnd` exclusive and empty when none collapses,
  /// and `lastTruncated`, whether the row is still wider than the space,
  /// so the last segment is cut with an ellipsis.
  static ({int collapsedStart, int collapsedEnd, bool lastTruncated}) collapse(
    List<double> widths, {
    required double maxWidth,
    double separatorWidth = Oito2Breadcrumb.separatorWidth,
    double buttonWidth = Oito2Breadcrumb.buttonWidth,
    double minSegmentWidth = 0,
    double editWidth = 0,
  }) {
    final n = widths.length;
    final laid = [
      for (var i = 0; i < n; i++)
        i < n - 1 ? math.max(widths[i], minSegmentWidth) : widths[i],
    ];
    final available = maxWidth - editWidth;
    double widthOf(int start, int end) {
      var total = 0.0;
      var count = 0;
      for (var i = 0; i < n; i++) {
        if (i >= start && i < end) continue;
        total += laid[i];
        count++;
      }
      if (end > start) {
        total += buttonWidth;
        count++;
      }
      return total + (count - 1) * separatorWidth;
    }

    ({int collapsedStart, int collapsedEnd, bool lastTruncated}) result(
      int start,
      int end,
    ) => (
      collapsedStart: start,
      collapsedEnd: end,
      lastTruncated: n > 0 && widthOf(start, end) > available,
    );

    if (n < 2 || widthOf(0, 0) <= available) return result(0, 0);
    for (var end = 2; end < n; end++) {
      if (widthOf(1, end) <= available) return result(1, end);
    }
    return result(0, n - 1);
  }

  @override
  State<Oito2Breadcrumb<T>> createState() => _Oito2BreadcrumbState<T>();
}

/// The key of the focus node of the "…" button in
/// [_Oito2BreadcrumbState._nodes].
const _overflowSlot = -1;

/// The key of the focus node of the edit button.
const _editSlot = -2;

class _Oito2BreadcrumbState<T> extends State<Oito2Breadcrumb<T>> {
  /// The focus nodes of the segment buttons by index, and of the "…" and
  /// edit buttons by [_overflowSlot] and [_editSlot].
  final Map<int, FocusNode> _nodes = {};

  /// The focus nodes of the shown buttons, in reading order.
  List<FocusNode> _order = const [];

  final _text = TextEditingController();
  final _field = FocusNode(debugLabel: 'Oito2Breadcrumb field');
  bool _editing = false;

  /// The horizontal padding of a segment button.
  static const _padding = Oito2Spacing.sm;

  /// The size of a segment icon.
  static const _iconSize = 16.0;

  /// The space between a segment icon and its label.
  static const _iconGap = Oito2Spacing.xs;

  /// The width of a separator.
  static const _separatorWidth = Oito2Breadcrumb.separatorWidth;

  /// The width of the "…" and edit buttons.
  static const _buttonWidth = Oito2Breadcrumb.buttonWidth;

  /// The height of the buttons.
  static const _buttonHeight = 28.0;

  /// The least width that a button takes in the layout: the touch target
  /// when the theme pads tap targets, and none otherwise.
  double get _minButtonWidth =>
      padsTapTargets(context) ? Oito2Sizes.minTouchTarget : 0;

  /// The width of the "…" and edit buttons in the layout.
  double get _iconButtonWidth => math.max(_buttonWidth, _minButtonWidth);

  @override
  void initState() {
    super.initState();
    _field.addListener(_onFieldFocus);
  }

  @override
  void didUpdateWidget(Oito2Breadcrumb<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pruneNodes();
  }

  /// Releases the focus nodes of segment buttons past the new last
  /// segment, and of the edit button when the path can't be edited. They
  /// are disposed after the frame, once the buttons that hold them are
  /// gone.
  void _pruneNodes() {
    final stale = <FocusNode>[];
    _nodes.removeWhere((slot, node) {
      final remove =
          slot >= widget.items.length - 1 ||
          (slot == _editSlot && widget.onSubmitted == null);
      if (remove) stale.add(node);
      return remove;
    });
    if (stale.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final node in stale) {
        node.dispose();
      }
    });
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    _field.dispose();
    _text.dispose();
    super.dispose();
  }

  FocusNode _node(int slot) => _nodes.putIfAbsent(
    slot,
    () => FocusNode(debugLabel: 'Oito2Breadcrumb $slot'),
  );

  /// The text of the edit field: the given path or the joined labels.
  String get _path =>
      widget.path ??
      widget.items.map((item) => item.label).join(widget.pathSeparator);

  /// Turns the bar into the edit field, with the whole path selected.
  void _startEditing() {
    if (widget.onSubmitted == null || _editing) return;
    final path = _path;
    _text.value = TextEditingValue(
      text: path,
      selection: TextSelection(baseOffset: 0, extentOffset: path.length),
    );
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _editing) _field.requestFocus();
    });
  }

  /// Leaves the edit mode, giving the focus back to the edit button when
  /// [refocus].
  void _stopEditing({bool refocus = true}) {
    if (!_editing) return;
    setState(() => _editing = false);
    if (refocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _nodes[_editSlot]?.requestFocus();
      });
    }
  }

  /// Sends [text] to `onSubmitted` and leaves the edit mode.
  void _submit(String text) {
    _stopEditing();
    widget.onSubmitted?.call(text);
  }

  /// Cancels the edit mode when the field loses the focus.
  void _onFieldFocus() {
    if (!_field.hasFocus && _editing) _stopEditing(refocus: false);
  }

  /// Moves the focus to the shown button [step] places after the focused
  /// one, in reading order, when there is one.
  void _move(int step) {
    final current = _order.indexWhere((node) => node.hasPrimaryFocus);
    if (current < 0) return;
    final next = current + step;
    if (next >= 0 && next < _order.length) _order[next].requestFocus();
  }

  /// The measured label widths, by label and current state, for
  /// [_widthsKey].
  Map<(String, bool), double> _widths = {};

  /// The styles, text scaler and direction the cached widths were
  /// measured with.
  Object? _widthsKey;

  /// Returns the width of a segment showing [item], measured with [style]
  /// and [scaler], reusing the label width measured for [widths] when it
  /// holds one.
  double _segmentWidth(
    Oito2BreadcrumbItem<T> item,
    TextStyle? style,
    TextScaler scaler,
    bool current,
    Map<(String, bool), double> widths,
  ) {
    final width = widths[(item.label, current)] ??= _labelWidth(
      item.label,
      style,
      scaler,
    );
    return _padding * 2 +
        (item.icon == null ? 0 : _iconSize + _iconGap) +
        width;
  }

  /// Returns the width of [label] in [style] at [scaler], rounded up.
  double _labelWidth(String label, TextStyle? style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width.ceilToDouble();
  }

  /// Returns the range of segment indexes, start inclusive and end
  /// exclusive, that collapse into the "…" button for [maxWidth], or null
  /// when every segment fits.
  (int, int)? _collapsed(
    double maxWidth,
    TextStyle? style,
    TextStyle? currentStyle,
    TextScaler scaler,
  ) {
    final items = widget.items;
    final n = items.length;
    if (n < 2) return null;
    // Labels are measured once per style, scaler and direction; the cache
    // keeps only the labels of the current items.
    final key = (style, currentStyle, scaler, Directionality.of(context));
    final previous = key == _widthsKey
        ? _widths
        : const <(String, bool), double>{};
    _widthsKey = key;
    final widths = <(String, bool), double>{
      for (var i = 0; i < n; i++)
        (items[i].label, i == n - 1): ?previous[(items[i].label, i == n - 1)],
    };
    _widths = widths;
    final (
      :collapsedStart,
      :collapsedEnd,
      lastTruncated: _,
    ) = Oito2Breadcrumb.collapse(
      [
        for (var i = 0; i < n - 1; i++)
          _segmentWidth(items[i], style, scaler, false, widths),
        _segmentWidth(items[n - 1], currentStyle, scaler, true, widths),
      ],
      maxWidth: maxWidth,
      buttonWidth: _iconButtonWidth,
      minSegmentWidth: _minButtonWidth,
      editWidth: widget.onSubmitted == null
          ? 0
          : _iconButtonWidth + Oito2Spacing.xs,
    );
    return collapsedEnd > collapsedStart
        ? (collapsedStart, collapsedEnd)
        : null;
  }

  /// The arrow key bindings that move the focus between the buttons.
  Map<ShortcutActivator, VoidCallback> _arrowBindings(BuildContext context) {
    final arrows = readingArrowsOf(context);
    return {
      SingleActivator(arrows.forward): () => _move(1),
      SingleActivator(arrows.back): () => _move(-1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final height = controlHeightOf(context);
    if (_editing) {
      return Oito2TouchTarget(
        child: SizedBox(
          height: height,
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _stopEditing,
            },
            child: TextField(
              controller: _text,
              focusNode: _field,
              textInputAction: TextInputAction.go,
              onSubmitted: _submit,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                hintText: strings.pathBar,
              ),
            ),
          ),
        ),
      );
    }

    final style = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final currentStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    final scaler = MediaQuery.textScalerOf(context);
    final items = widget.items;
    final onSelected = widget.onSelected;

    return LayoutBuilder(
      builder: (context, constraints) {
        final collapsed = items.isEmpty
            ? null
            : _collapsed(constraints.maxWidth, style, currentStyle, scaler);
        final order = <FocusNode>[];
        final children = <Widget>[];
        void separator() => children.add(
          SizedBox(
            width: _separatorWidth,
            child: Icon(
              directionalChevron(context, forward: true),
              size: 14,
              color: scheme.onSurfaceVariant,
            ),
          ),
        );
        for (var i = 0; i < items.length; i++) {
          if (collapsed != null && i >= collapsed.$1 && i < collapsed.$2) {
            if (i != collapsed.$1) continue;
            if (children.isNotEmpty) separator();
            final node = _node(_overflowSlot);
            order.add(node);
            children.add(
              _OverflowButton(
                focusNode: node,
                size: _buttonWidth,
                height: _buttonHeight,
                tooltip: strings.showPathSegments,
                menuChildren: [
                  for (var j = collapsed.$1; j < collapsed.$2; j++)
                    MenuItemButton(
                      leadingIcon: Icon(
                        items[j].icon ?? LucideIcons.folder,
                        size: _iconSize,
                      ),
                      onPressed: onSelected == null
                          ? null
                          : () => onSelected(j),
                      child: Text(items[j].label),
                    ),
                ],
              ),
            );
            continue;
          }
          if (children.isNotEmpty) separator();
          final item = items[i];
          if (i == items.length - 1) {
            children.add(
              Flexible(
                child: Semantics(
                  label: item.label,
                  value: strings.currentLocation,
                  excludeSemantics: true,
                  child: _SegmentContent(
                    item: item,
                    style: currentStyle,
                    padding: _padding,
                    iconSize: _iconSize,
                    iconGap: _iconGap,
                  ),
                ),
              ),
            );
          } else {
            final node = _node(i);
            if (onSelected != null) order.add(node);
            children.add(
              _SegmentButton(
                focusNode: node,
                height: _buttonHeight,
                onPressed: onSelected == null ? null : () => onSelected(i),
                child: _SegmentContent(
                  item: item,
                  style: style,
                  padding: _padding,
                  iconSize: _iconSize,
                  iconGap: _iconGap,
                ),
              ),
            );
          }
        }
        final editable = widget.onSubmitted != null;
        final row = <Widget>[Expanded(child: Row(children: children))];
        if (editable) {
          final node = _node(_editSlot);
          order.add(node);
          row.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(start: Oito2Spacing.xs),
              child: _SegmentButton(
                focusNode: node,
                height: _buttonHeight,
                tooltip: strings.editPath,
                onPressed: _startEditing,
                child: const SizedBox(
                  width: _buttonWidth,
                  child: Icon(LucideIcons.pencil, size: _iconSize),
                ),
              ),
            ),
          );
        }
        _order = order;
        Widget bar = SizedBox(
          height: math.max(height, _minButtonWidth),
          child: Row(children: row),
        );
        if (editable) {
          // A click on the empty area of the bar starts editing.
          bar = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _startEditing,
              child: bar,
            ),
          );
        }
        return Semantics(
          container: true,
          explicitChildNodes: true,
          label: strings.pathBar,
          child: FocusTraversalGroup(
            child: CallbackShortcuts(
              bindings: _arrowBindings(context),
              child: bar,
            ),
          ),
        );
      },
    );
  }
}

/// The icon and label of a breadcrumb segment, padded as a button.
class _SegmentContent extends StatelessWidget {
  const _SegmentContent({
    required this.item,
    required this.style,
    required this.padding,
    required this.iconSize,
    required this.iconGap,
  });

  final Oito2BreadcrumbItem<Object?> item;
  final TextStyle? style;
  final double padding;
  final double iconSize;
  final double iconGap;

  @override
  Widget build(BuildContext context) {
    final icon = item.icon;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: iconGap,
        children: [
          if (icon != null) Icon(icon, size: iconSize, color: style?.color),
          Flexible(
            child: Text(
              item.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

/// A flat button of a breadcrumb, with the focus ring and the click
/// cursor.
class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.focusNode,
    required this.height,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.expanded,
  });

  final FocusNode focusNode;
  final double height;
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final bool? expanded;

  @override
  Widget build(BuildContext context) {
    const radius = Oito2Radius.smallAll;
    Widget button = Oito2FocusBorder(
      borderRadius: radius,
      child: Material(
        type: MaterialType.transparency,
        shape: const RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          focusNode: focusNode,
          canRequestFocus: onPressed != null,
          mouseCursor: WidgetStateMouseCursor.clickable,
          focusColor: Colors.transparent,
          onTap: onPressed,
          child: SizedBox(
            height: height,
            child: Center(widthFactor: 1, child: child),
          ),
        ),
      ),
    );
    final tooltip = this.tooltip;
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: button,
      );
    }
    return Oito2TouchTarget(
      mergeSemantics: true,
      child: Semantics(
        button: onPressed != null,
        enabled: onPressed != null,
        expanded: expanded,
        label: tooltip,
        child: button,
      ),
    );
  }
}

/// The "…" button of a breadcrumb, which opens a menu of the hidden
/// segments.
class _OverflowButton extends StatelessWidget {
  const _OverflowButton({
    required this.focusNode,
    required this.size,
    required this.height,
    required this.tooltip,
    required this.menuChildren,
  });

  final FocusNode focusNode;
  final double size;
  final double height;
  final String tooltip;
  final List<Widget> menuChildren;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: focusNode,
      menuChildren: menuChildren,
      builder: (context, controller, _) => _SegmentButton(
        focusNode: focusNode,
        height: height,
        tooltip: tooltip,
        expanded: controller.isOpen,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        child: SizedBox(
          width: size,
          child: Icon(
            LucideIcons.ellipsis,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
