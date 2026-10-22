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

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'resize_handle.dart';

/// One pane of an [Oito2Splitter].
@immutable
class Oito2SplitterPane {
  /// Creates a splitter pane.
  const Oito2SplitterPane({
    required this.child,
    this.initialFraction,
    this.minSize = 48,
    this.maxSize = double.infinity,
    this.collapsible = false,
    this.collapsedSize = 0,
    this.initiallyCollapsed = false,
  }) : assert(minSize >= 0 && maxSize >= minSize),
       assert(!initiallyCollapsed || collapsible);

  /// The content.
  final Widget child;

  /// The share of the space at start, from 0 to 1; the panes without one
  /// share what is left equally.
  final double? initialFraction;

  /// The smallest size in logical pixels.
  final double minSize;

  /// The largest size in logical pixels.
  final double maxSize;

  /// Whether the pane can collapse to [collapsedSize].
  final bool collapsible;

  /// The size of the collapsed pane.
  final double collapsedSize;

  /// Whether the pane starts collapsed.
  final bool initiallyCollapsed;
}

/// Panes side by side, or stacked when [axis] is vertical, with a
/// draggable divider between each two.
///
/// A divider keeps both of its panes within their limits. From the
/// keyboard a focused divider moves by [keyboardStep] with the arrow
/// keys, Home and End take the pane before it to its smallest and largest
/// size, and Enter collapses or restores the collapsible pane next to it,
/// as a double click does. Splitters nest. For a single resizable side
/// pane, `Oito2PanedView` is simpler.
class Oito2Splitter extends StatefulWidget {
  /// Creates a splitter.
  const Oito2Splitter({
    super.key,
    required this.panes,
    this.axis = Axis.horizontal,
    this.onSizesChanged,
    this.keyboardStep = 16,
    this.resizeLabel,
  });

  /// The panes, from the start (top when vertical); two or more.
  final List<Oito2SplitterPane> panes;

  /// Whether the panes sit side by side or stacked.
  final Axis axis;

  /// Called with the pane sizes in logical pixels after a change.
  final ValueChanged<List<double>>? onSizesChanged;

  /// The change of one arrow key press.
  final double keyboardStep;

  /// The accessibility label of the dividers; defaults to the localized
  /// "Resize pane".
  final String? resizeLabel;

  @override
  State<Oito2Splitter> createState() => _Oito2SplitterState();
}

class _Oito2SplitterState extends State<Oito2Splitter> {
  /// The pane sizes in pixels, or empty before the first layout.
  List<double> _sizes = [];
  late List<bool> _collapsed = [
    for (final pane in widget.panes) pane.initiallyCollapsed,
  ];
  late List<double?> _restore = List.filled(widget.panes.length, null);
  double _available = 0;

  List<Oito2SplitterPane> get _panes => widget.panes;
  bool get _horizontal => widget.axis == Axis.horizontal;

  @override
  void initState() {
    super.initState();
    assert(widget.panes.length >= 2, 'A splitter needs two panes or more.');
  }

  double _min(int i) =>
      _collapsed[i] ? _panes[i].collapsedSize : _panes[i].minSize;
  double _max(int i) =>
      _collapsed[i] ? _panes[i].collapsedSize : _panes[i].maxSize;

  /// Lays the panes out in [available] pixels, keeping the current
  /// proportions or, at first, the initial fractions.
  void _fit(double available) {
    if (_sizes.length == _panes.length && _available > 0) {
      final scale = available / _available;
      _sizes = [for (final size in _sizes) size * scale];
    } else {
      final given = [for (final p in _panes) p.initialFraction];
      final used = given.whereType<double>().fold(0.0, (a, b) => a + b);
      final open = given.where((f) => f == null).length;
      final share = open == 0 ? 0.0 : (1 - used).clamp(0.0, 1.0) / open;
      _sizes = [for (final f in given) (f ?? share) * available];
    }
    _available = available;
    for (var i = 0; i < _sizes.length; i++) {
      if (_collapsed[i]) _sizes[i] = _panes[i].collapsedSize;
    }
    _balance();
  }

  /// Clamps every pane to its limits and gives the difference to the
  /// panes that can take it, so the sizes fill the space.
  void _balance() {
    for (var i = 0; i < _sizes.length; i++) {
      _sizes[i] = _sizes[i].clamp(_min(i), _max(i));
    }
    var excess = _available - _sizes.fold(0.0, (a, b) => a + b);
    for (var pass = 0; pass < 2 && excess.abs() > 0.01; pass++) {
      for (var i = _sizes.length - 1; i >= 0 && excess.abs() > 0.01; i--) {
        final next = (_sizes[i] + excess).clamp(_min(i), _max(i));
        excess -= next - _sizes[i];
        _sizes[i] = next;
      }
    }
  }

  /// Moves the divider after pane [i] by [delta] pixels toward the end.
  void _move(int i, double delta) {
    final a = _sizes[i];
    final b = _sizes[i + 1];
    final total = a + b;
    var next = (a + delta).clamp(_min(i), _max(i));
    next = next.clamp(total - _max(i + 1), total - _min(i + 1));
    if (next < _min(i) || next > _max(i)) return;
    if (next == a) return;
    setState(() {
      _sizes[i] = next;
      _sizes[i + 1] = total - next;
    });
    widget.onSizesChanged?.call(List.unmodifiable(_sizes));
  }

  /// Collapses or restores the collapsible pane next to divider [i],
  /// preferring the one before it.
  void _toggle(int i) {
    final target = _panes[i].collapsible
        ? i
        : _panes[i + 1].collapsible
        ? i + 1
        : null;
    if (target == null) return;
    final neighbor = target == i ? i + 1 : i;
    setState(() {
      if (_collapsed[target]) {
        _collapsed[target] = false;
        final restore = _restore[target] ?? _panes[target].minSize;
        final gain = restore - _sizes[target];
        _sizes[target] = restore;
        _sizes[neighbor] -= gain;
      } else {
        _restore[target] = _sizes[target];
        final freed = _sizes[target] - _panes[target].collapsedSize;
        _collapsed[target] = true;
        _sizes[target] = _panes[target].collapsedSize;
        _sizes[neighbor] += freed;
      }
      _balance();
    });
    widget.onSizesChanged?.call(List.unmodifiable(_sizes));
  }

  /// Home and End move divider [i] to the limits of its panes.
  KeyEventResult _onKey(int i, KeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.home) {
      _move(i, _min(i) - _sizes[i]);
    } else if (key == LogicalKeyboardKey.end) {
      _move(i, _sizes[i + 1] - _min(i + 1));
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Widget _handle(BuildContext context, int i, bool rtl) {
    final strings = Oito2Localizations.of(context);
    String label(double size) =>
        '${(_available <= 0 ? 0 : size / _available * 100).round()}%';
    final step = widget.keyboardStep;
    return ResizeHandle(
      axis: widget.axis,
      keyboardStep: step,
      dragStartBehavior: DragStartBehavior.down,
      // In right-to-left rows the pane before the divider is on its right.
      onMove: (delta) => _move(i, _horizontal && rtl ? -delta : delta),
      semanticLabel: widget.resizeLabel ?? strings.resizePane,
      value: label(_sizes[i]),
      increasedValue: label((_sizes[i] + step).clamp(_min(i), _max(i))),
      decreasedValue: label((_sizes[i] - step).clamp(_min(i), _max(i))),
      onIncrease: () => _move(i, step),
      onDecrease: () => _move(i, -step),
      onToggle: () => _toggle(i),
      onKey: (event) => _onKey(i, event),
    );
  }

  @override
  void didUpdateWidget(Oito2Splitter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.panes.length != widget.panes.length) {
      _sizes = [];
      _available = 0;
      _collapsed = [for (final pane in widget.panes) pane.initiallyCollapsed];
      _restore = List.filled(widget.panes.length, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final divider = Theme.of(context).colorScheme.outlineVariant;
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = _horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final available = (extent - (_panes.length - 1)).clamp(
          0.0,
          double.infinity,
        );
        if (available != _available || _sizes.length != _panes.length) {
          _fit(available);
        }
        final children = <Widget>[];
        final handles = <Widget>[];
        var position = 0.0;
        for (var i = 0; i < _panes.length; i++) {
          children.add(
            SizedBox(
              width: _horizontal ? _sizes[i] : null,
              height: _horizontal ? null : _sizes[i],
              child: ClipRect(
                child: _collapsed[i] && _panes[i].collapsedSize == 0
                    ? const SizedBox.shrink()
                    : _panes[i].child,
              ),
            ),
          );
          position += _sizes[i];
          if (i < _panes.length - 1) {
            children.add(
              Container(
                width: _horizontal ? 1 : null,
                height: _horizontal ? null : 1,
                color: divider,
              ),
            );
            final start = position + 0.5 - Oito2Spacing.sm / 2;
            handles.add(
              _horizontal
                  ? PositionedDirectional(
                      start: start,
                      top: 0,
                      bottom: 0,
                      child: _handle(context, i, rtl),
                    )
                  : Positioned(
                      top: start,
                      left: 0,
                      right: 0,
                      child: _handle(context, i, rtl),
                    ),
            );
            position += 1;
          }
        }
        final content = Stack(
          children: [
            Flex(
              direction: widget.axis,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
            ...handles,
          ],
        );
        // When the minimum sizes don't fit, the panes keep them and the
        // end is clipped, instead of overflowing.
        final needed = position;
        if (needed <= extent) return content;
        return ClipRect(
          child: OverflowBox(
            alignment: AlignmentDirectional.topStart,
            minWidth: _horizontal ? needed : null,
            maxWidth: _horizontal ? needed : null,
            minHeight: _horizontal ? null : needed,
            maxHeight: _horizontal ? null : needed,
            child: content,
          ),
        );
      },
    );
  }
}
