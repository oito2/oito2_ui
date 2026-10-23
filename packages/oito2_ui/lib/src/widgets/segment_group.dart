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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// A choice of an [Oito2SegmentGroup].
@immutable
class Oito2Segment<T> {
  /// Creates a segment for [value].
  const Oito2Segment({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  /// The value the segment selects.
  final T value;

  /// The segment label, usually a [Text].
  final Widget label;

  /// An icon before the label.
  final Widget? icon;

  /// Whether the segment can be selected.
  final bool enabled;
}

/// A row (or column) of mutually exclusive choices on a recessed track,
/// with a raised marker that slides to the selected one.
///
/// The group is one stop in keyboard navigation: the arrow keys select the
/// previous or next enabled segment. Assistive technologies read it as a
/// group of radio buttons.
class Oito2SegmentGroup<T> extends StatefulWidget {
  /// Creates a segment group.
  const Oito2SegmentGroup({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.orientation = Axis.horizontal,
  });

  /// The choices, in order.
  final List<Oito2Segment<T>> segments;

  /// The value of the selected segment, or null.
  final T? selected;

  /// Called with the value of a segment chosen; null disables the group.
  final ValueChanged<T>? onChanged;

  /// Whether the segments run across or down.
  final Axis orientation;

  @override
  State<Oito2SegmentGroup<T>> createState() => _Oito2SegmentGroupState<T>();
}

class _Oito2SegmentGroupState<T> extends State<Oito2SegmentGroup<T>> {
  final _stackKey = GlobalKey();
  final List<GlobalKey> _segmentKeys = [];
  final List<FocusNode> _nodes = [];

  /// The rectangle of the selected segment in the track, once measured.
  Rect? _marker;

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncSegments() {
    while (_nodes.length < widget.segments.length) {
      _nodes.add(FocusNode(debugLabel: 'Oito2SegmentGroup segment'));
      _segmentKeys.add(GlobalKey());
    }
    while (_nodes.length > widget.segments.length) {
      final node = _nodes.removeLast();
      _segmentKeys.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => node.dispose());
    }
  }

  int get _selectedIndex =>
      widget.segments.indexWhere((s) => s.value == widget.selected);

  bool _canSelect(int index) =>
      widget.onChanged != null && widget.segments[index].enabled;

  void _select(int index) {
    if (!_canSelect(index)) return;
    _nodes[index].requestFocus();
    if (widget.segments[index].value != widget.selected) {
      widget.onChanged!(widget.segments[index].value);
    }
  }

  /// Measures the selected segment after layout and moves the marker
  /// there when it changed.
  void _measure() {
    if (!mounted) return;
    final index = _selectedIndex;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final segment =
        (index < 0 ? null : _segmentKeys[index].currentContext)
                ?.findRenderObject()
            as RenderBox?;
    Rect? rect;
    if (stack != null && segment != null && segment.hasSize) {
      rect = segment.localToGlobal(Offset.zero, ancestor: stack) & segment.size;
    }
    if (rect != _marker) setState(() => _marker = rect);
  }

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
      _select(index);
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
    final count = widget.segments.length;
    for (var i = 1; i < count; i++) {
      final next = (index + step * i) % count;
      if (_canSelect(next)) {
        _select(next);
        break;
      }
    }
    return KeyEventResult.handled;
  }

  Widget _segment(int index, int tabStop) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final segment = widget.segments[index];
    final selected = index == _selectedIndex;
    final enabled = _canSelect(index);
    final foreground = selected
        ? semanticColorsOf(context).primaryText
        : scheme.onSurface;
    Widget content = Container(
      key: _segmentKeys[index],
      constraints: BoxConstraints(minHeight: controlHeightOf(context)),
      padding: const EdgeInsets.symmetric(horizontal: Oito2Spacing.md),
      // The selected segment carries the marker itself until it is
      // measured.
      decoration: selected && _marker == null ? _markerDecoration() : null,
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        alignment: widget.orientation == Axis.vertical
            ? AlignmentDirectional.centerStart
            : Alignment.center,
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: Oito2Sizes.iconSize),
          child: DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.sm,
              children: [?segment.icon, segment.label],
            ),
          ),
        ),
      ),
    );
    if (!segment.enabled) content = Opacity(opacity: 0.5, child: content);
    return MergeSemantics(
      child: Oito2FocusBorder(
        borderRadius: Oito2Radius.smallAll,
        child: Focus(
          focusNode: _nodes[index],
          canRequestFocus: enabled,
          skipTraversal: index != tabStop,
          onKeyEvent: (_, event) => _onKey(index, event),
          child: Semantics(
            inMutuallyExclusiveGroup: true,
            checked: selected,
            enabled: enabled,
            onTap: enabled ? () => _select(index) : null,
            child: MouseRegion(
              cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? () => _select(index) : null,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Sizes a vertical group to its widest segment, so the segments can
  /// share that width.
  Widget _intrinsicWidthIfVertical(Widget child) =>
      widget.orientation == Axis.vertical
      ? IntrinsicWidth(child: child)
      : child;

  BoxDecoration _markerDecoration() {
    final scheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: scheme.surface,
      borderRadius: Oito2Radius.smallAll,
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.12),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncSegments();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final scheme = Theme.of(context).colorScheme;
    final selectedIndex = _selectedIndex;
    // The selected segment, or the first enabled one, is the group's stop
    // in keyboard navigation.
    final tabStop = selectedIndex >= 0 && _canSelect(selectedIndex)
        ? selectedIndex
        : List.generate(
            widget.segments.length,
            (i) => i,
          ).firstWhere(_canSelect, orElse: () => -1);
    final marker = _marker;
    return Container(
      padding: const EdgeInsets.all(Oito2Spacing.xs),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: Oito2Radius.mediumAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Stack(
        key: _stackKey,
        children: [
          if (marker != null)
            AnimatedPositioned.fromRect(
              rect: marker,
              duration: motionDuration(
                context,
                const Duration(milliseconds: 150),
              ),
              curve: Curves.easeOut,
              child: DecoratedBox(decoration: _markerDecoration()),
            ),
          _intrinsicWidthIfVertical(
            Flex(
              direction: widget.orientation,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.orientation == Axis.vertical
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.segments.length; i++)
                  _segment(i, tabStop),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
