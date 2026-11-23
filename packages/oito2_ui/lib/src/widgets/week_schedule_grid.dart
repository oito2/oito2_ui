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

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'info.dart';
import 'touch_target.dart';
import 'widget_helpers.dart';

/// A value an [Oito2WeekScheduleGrid] can paint, with its legend [label]
/// and its color.
@immutable
class Oito2ScheduleValue<T> {
  /// Creates a schedule value; the cell color is [color], else the color
  /// of [type], else a color of the theme's scheme.
  const Oito2ScheduleValue({
    required this.value,
    required this.label,
    this.color,
    this.type,
  });

  /// The value the schedule holds.
  final T value;

  /// The name shown in the legend and read for each cell, such as
  /// "Limited".
  final String label;

  /// The cell and legend color.
  final Color? color;

  /// The semantic tone used when [color] is null.
  final Oito2InfoType? type;
}

/// A cell of an [Oito2WeekScheduleGrid]: a day and a slot of that day.
typedef Oito2ScheduleCell = ({int day, int slot});

/// A week of time slots, one row per day, each holding one of [values],
/// such as when a sync runs at full speed, limited or paused.
///
/// The [schedule] is a flat list of `7 × slotsPerDay` values, day after
/// day: the value of [day] at [slot] is at `day * slotsPerDay + slot`
/// (see [indexOf]). Days count from Monday (0) to Sunday (6), as
/// `DateTime.weekday - 1`; the rows start at the first day of the week of
/// the locale's [MaterialLocalizations.firstDayOfWeekIndex]. A day has
/// [slotsPerDay] slots, 24 hours by default, or 48 half hours for
/// example.
///
/// The legend below the grid picks the value painted (the brush). A click
/// paints a cell and a drag paints the rectangle from the first cell to
/// the current one, previewed while dragging; [onChanged] receives the
/// new schedule. The grid takes the focus as a whole: the arrow keys move
/// the active cell, Home and End to the start and end of the day, Shift
/// with them extends a rectangular selection, Space or Enter paints the
/// selection or the active cell, Escape clears the selection, and the
/// digits 1 to 9 pick a value of the legend. Without [onChanged] the grid
/// is read-only.
///
/// Cells shrink with the width down to [minCellWidth]; below that the
/// grid scrolls sideways. Hour labels skip slots when they don't fit.
/// Assistive technologies read each cell as its day, time range and
/// value, such as "Monday 14:00–15:00, Limited".
class Oito2WeekScheduleGrid<T> extends StatefulWidget {
  /// Creates a week schedule grid.
  const Oito2WeekScheduleGrid({
    super.key,
    required this.values,
    required this.schedule,
    this.onChanged,
    this.paintValue,
    this.onPaintValueChanged,
    this.slotsPerDay = 24,
    this.slotLabel,
    this.minCellWidth = 16,
    this.cellHeight = 28,
    this.showLegend = true,
    this.autofocus = false,
    this.semanticsLabel,
  }) : assert(slotsPerDay > 0);

  /// The values cells can hold, in legend order.
  final List<Oito2ScheduleValue<T>> values;

  /// The value of every cell, `7 × slotsPerDay` values from Monday's first
  /// slot to Sunday's last.
  final List<T> schedule;

  /// Called with the new schedule after painting; the grid is read-only
  /// when null.
  final ValueChanged<List<T>>? onChanged;

  /// The value painted; the grid keeps its own choice, starting at the
  /// first of [values], when null.
  final T? paintValue;

  /// Called when the legend or a digit key picks another value to paint.
  final ValueChanged<T>? onPaintValueChanged;

  /// The number of slots in a day.
  final int slotsPerDay;

  /// Returns the header text of [slot]; by default the start time of the
  /// slots that start on the hour, such as "14" or "2 PM".
  final String Function(BuildContext context, int slot)? slotLabel;

  /// The narrowest cell before the grid scrolls sideways.
  final double minCellWidth;

  /// The height of a day row.
  final double cellHeight;

  /// Whether the legend shows below the grid.
  final bool showLegend;

  /// Whether the grid takes the focus when shown.
  final bool autofocus;

  /// The accessibility label of the grid; defaults to the localized
  /// "Weekly schedule".
  final String? semanticsLabel;

  /// Returns the index in a schedule of [day] (Monday 0) at [slot], with
  /// [slotsPerDay] slots a day.
  static int indexOf(int day, int slot, {int slotsPerDay = 24}) =>
      day * slotsPerDay + slot;

  @override
  State<Oito2WeekScheduleGrid<T>> createState() =>
      _Oito2WeekScheduleGridState<T>();
}

/// The rows and slots from one corner of a rectangle to the other.
typedef _Rect = ({int top, int bottom, int start, int end});

class _Oito2WeekScheduleGridState<T> extends State<Oito2WeekScheduleGrid<T>> {
  final _focus = FocusNode(debugLabel: 'Oito2WeekScheduleGrid');
  final _scroll = ScrollController();

  /// The value the legend picked while [Oito2WeekScheduleGrid.paintValue]
  /// is null.
  T? _ownBrush;

  /// The active cell, as a row on screen and a slot.
  ({int row, int slot}) _active = (row: 0, slot: 0);

  /// Where a Shift selection started, while there is one.
  ({int row, int slot})? _anchor;

  /// Where a drag started and where it is now, while dragging.
  ({int row, int slot})? _dragStart;
  ({int row, int slot})? _dragEnd;

  /// The day column width and cell width of the last layout.
  double _dayWidth = 0;
  double _cellWidth = 0;

  bool get _editable => widget.onChanged != null;

  T? get _brush =>
      widget.paintValue ??
      _ownBrush ??
      (widget.values.isEmpty ? null : widget.values.first.value);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Rebuilds to show or hide the focus ring.
  void _onFocus() => setState(() {});

  /// Returns the day, Monday 0, shown on [row].
  int _dayOfRow(int row) =>
      (MaterialLocalizations.of(context).firstDayOfWeekIndex + row + 6) % 7;

  /// Returns the rectangle between [a] and [b].
  static _Rect _rect(({int row, int slot}) a, ({int row, int slot}) b) => (
    top: math.min(a.row, b.row),
    bottom: math.max(a.row, b.row),
    start: math.min(a.slot, b.slot),
    end: math.max(a.slot, b.slot),
  );

  static bool _contains(_Rect? rect, int row, int slot) =>
      rect != null &&
      row >= rect.top &&
      row <= rect.bottom &&
      slot >= rect.start &&
      slot <= rect.end;

  /// The keyboard selection, if any.
  _Rect? get _selection {
    final anchor = _anchor;
    return anchor == null ? null : _rect(anchor, _active);
  }

  /// The rectangle a drag would paint, if dragging.
  _Rect? get _preview {
    final start = _dragStart;
    final end = _dragEnd;
    return start == null || end == null ? null : _rect(start, end);
  }

  /// Sets every cell of [rect] to the brush and reports the new schedule
  /// when it differs.
  void _paint(_Rect rect) {
    final onChanged = widget.onChanged;
    final brush = _brush;
    if (onChanged == null || brush is! T) return;
    final slots = widget.slotsPerDay;
    final next = List<T>.of(widget.schedule);
    var changed = false;
    for (var row = rect.top; row <= rect.bottom; row++) {
      final day = _dayOfRow(row);
      for (var slot = rect.start; slot <= rect.end; slot++) {
        final index = day * slots + slot;
        if (next[index] != brush) {
          next[index] = brush;
          changed = true;
        }
      }
    }
    if (changed) onChanged(List.unmodifiable(next));
  }

  /// Picks [value] as the brush.
  void _pickBrush(T value) {
    setState(() => _ownBrush = value);
    widget.onPaintValueChanged?.call(value);
  }

  /// Returns the cell under [position] in the cell area, kept inside the
  /// grid.
  ({int row, int slot}) _cellAt(Offset position) {
    final slots = widget.slotsPerDay;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    var slot = (position.dx / _cellWidth).floor().clamp(0, slots - 1);
    if (rtl) slot = slots - 1 - slot;
    final row = (position.dy / widget.cellHeight).floor().clamp(0, 6);
    return (row: row, slot: slot);
  }

  /// Makes [cell] active, clearing the keyboard selection unless
  /// [extend], and scrolls it into view.
  void _moveTo(({int row, int slot}) cell, {required bool extend}) {
    setState(() {
      if (extend) {
        _anchor ??= _active;
      } else {
        _anchor = null;
      }
      _active = (
        row: cell.row.clamp(0, 6),
        slot: cell.slot.clamp(0, widget.slotsPerDay - 1),
      );
    });
    _reveal();
  }

  /// Scrolls the active cell into view when the grid scrolls sideways.
  void _reveal() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final start = _dayWidth + _active.slot * _cellWidth;
    final end = start + _cellWidth;
    if (start - _dayWidth < position.pixels) {
      _scroll.jumpTo(
        (start - _dayWidth).clamp(0, position.maxScrollExtent).toDouble(),
      );
    } else if (end > position.pixels + position.viewportDimension) {
      _scroll.jumpTo(
        (end - position.viewportDimension)
            .clamp(0, position.maxScrollExtent)
            .toDouble(),
      );
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final key = event.logicalKey;
    final (:row, :slot) = _active;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveTo((row: row, slot: slot + (rtl ? 1 : -1)), extend: shift);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _moveTo((row: row, slot: slot + (rtl ? -1 : 1)), extend: shift);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveTo((row: row - 1, slot: slot), extend: shift);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _moveTo((row: row + 1, slot: slot), extend: shift);
    } else if (key == LogicalKeyboardKey.home) {
      _moveTo((row: row, slot: 0), extend: shift);
    } else if (key == LogicalKeyboardKey.end) {
      _moveTo((row: row, slot: widget.slotsPerDay - 1), extend: shift);
    } else if (key == LogicalKeyboardKey.escape && _anchor != null) {
      setState(() => _anchor = null);
    } else if (_editable &&
        (key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter)) {
      _paint(_selection ?? _rect(_active, _active));
    } else {
      final digit = _digit(key);
      if (!_editable || digit == null || digit > widget.values.length) {
        return KeyEventResult.ignored;
      }
      _pickBrush(widget.values[digit - 1].value);
    }
    return KeyEventResult.handled;
  }

  /// Returns the digit 1 to 9 of [key], or null.
  static int? _digit(LogicalKeyboardKey key) {
    const keys = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
    ];
    final index = keys.indexOf(key);
    return index < 0 ? null : index + 1;
  }

  /// Returns the color of [value] over the surface, a color of the scheme
  /// when it has none, picked by its [index] in the legend.
  Color _colorOf(Oito2ScheduleValue<T>? value, int index) {
    final scheme = Theme.of(context).colorScheme;
    if (value == null) return scheme.surfaceContainerHighest;
    final base =
        value.color ??
        value.type?.colorIn(semanticColorsOf(context)) ??
        [
          scheme.primary,
          scheme.tertiary,
          scheme.secondary,
          scheme.error,
        ][index % 4];
    return Color.alphaBlend(base.withValues(alpha: 0.75), scheme.surface);
  }

  /// Returns the name of [day], Monday 0, in the locale: short, such as
  /// "Mon", or full, such as "Monday".
  String _dayName(int day, {required bool short}) {
    final date = DateTime(2024, 1, 1 + day);
    final locale = Localizations.maybeLocaleOf(context)?.toString() ?? 'en';
    try {
      return (short ? DateFormat.E(locale) : DateFormat.EEEE(locale)).format(
        date,
      );
    } on Object {
      return (short ? DateFormat.E('en') : DateFormat.EEEE('en')).format(date);
    }
  }

  /// Returns the minute of the day [slot] starts at.
  int _minuteOf(int slot) => (slot * 1440 / widget.slotsPerDay).round();

  /// Returns the time of [minute] of the day in the locale's format.
  String _time(int minute) {
    final time = TimeOfDay(hour: (minute ~/ 60) % 24, minute: minute % 60);
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  /// Returns the header text of [slot], or null when the default labels
  /// skip it because it doesn't start on the hour.
  String? _slotLabel(int slot) {
    final custom = widget.slotLabel;
    if (custom != null) return custom(context, slot);
    final minute = _minuteOf(slot);
    if (minute % 60 != 0) return null;
    return _time(minute).replaceFirst(RegExp(r'[:.]00'), '');
  }

  /// Returns the width of [text] in [style].
  double _textWidth(String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  /// Returns how many slots apart header labels show so that each fits
  /// in the slots up to the next one: the smallest divisor of the slot
  /// count that fits [labelWidth] in cells of [cellWidth] and, for the
  /// default labels, lands on whole hours.
  int _labelStep(double labelWidth, double cellWidth) {
    final slots = widget.slotsPerDay;
    for (var step = 1; step <= slots; step++) {
      if (slots % step != 0) continue;
      if (step * cellWidth < labelWidth + 6) continue;
      if (widget.slotLabel == null &&
          _slotLabel(step) == null &&
          step < slots) {
        continue;
      }
      return step;
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = widget.slotsPerDay;
    assert(
      widget.schedule.length == 7 * slots,
      'The schedule holds ${widget.schedule.length} values instead of '
      '${7 * slots}.',
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final dayStyle = theme.textTheme.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final byValue = {
      for (final (index, value) in widget.values.indexed)
        value.value: (value, index),
    };
    final days = [for (var row = 0; row < 7; row++) _dayOfRow(row)];
    final shortNames = [for (final day in days) _dayName(day, short: true)];
    final fullNames = [for (final day in days) _dayName(day, short: false)];
    final times = [
      for (var slot = 0; slot <= slots; slot++) _time(_minuteOf(slot)),
    ];
    final dayWidth =
        shortNames.map((name) => _textWidth(name, dayStyle)).reduce(math.max) +
        Oito2Spacing.md;
    final labels = [for (var slot = 0; slot < slots; slot++) _slotLabel(slot)];
    final labelWidth = labels
        .whereType<String>()
        .map((label) => _textWidth(label, muted))
        .fold(0.0, math.max);

    final grid = LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : dayWidth + slots * 28;
        final cellWidth = math.max(
          widget.minCellWidth,
          (available - dayWidth) / slots,
        );
        _dayWidth = dayWidth;
        _cellWidth = cellWidth;
        final step = _labelStep(labelWidth, cellWidth);
        final cellsWidth = cellWidth * slots;
        final header = SizedBox(
          width: cellsWidth,
          height: (muted?.fontSize ?? 11) * 1.6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var slot = 0; slot < slots; slot += step)
                if (labels[slot] case final label?)
                  PositionedDirectional(
                    start: slot * cellWidth,
                    top: 0,
                    child: Text(label, style: muted, maxLines: 1),
                  ),
            ],
          ),
        );
        final selection = _focus.hasFocus ? _selection : null;
        final preview = _preview;
        final showFocus =
            _focus.hasFocus &&
            FocusManager.instance.highlightMode ==
                FocusHighlightMode.traditional;
        final ring = semanticColorsOf(context).primaryText;
        final brush = _brush;
        final brushEntry = brush == null ? null : byValue[brush];

        Widget cell(int row, int slot) {
          final day = days[row];
          final value = widget.schedule[day * slots + slot];
          final inPreview = _contains(preview, row, slot);
          final shown = inPreview ? brushEntry : byValue[value];
          final active =
              showFocus && _active.row == row && _active.slot == slot;
          final selected = _contains(selection, row, slot);
          return Semantics(
            label: strings.scheduleSlot(
              fullNames[row],
              times[slot],
              times[slot + 1],
              byValue[value]?.$1.label ?? '',
            ),
            button: _editable,
            selected: selected,
            onTap: _editable
                ? () => _paint(
                    _rect((row: row, slot: slot), (row: row, slot: slot)),
                  )
                : null,
            excludeSemantics: true,
            child: SizedBox(
              width: cellWidth,
              height: widget.cellHeight,
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _colorOf(shown?.$1, shown?.$2 ?? 0),
                    borderRadius: BorderRadius.circular(3),
                    border: active
                        ? Border.all(
                            color: ring,
                            width: Oito2Sizes.focusBorderWidth,
                          )
                        : selected || inPreview
                        ? Border.all(color: scheme.onSurface, width: 1.5)
                        : null,
                  ),
                ),
              ),
            ),
          );
        }

        Widget cells = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row = 0; row < 7; row++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var slot = 0; slot < slots; slot++) cell(row, slot),
                ],
              ),
          ],
        );
        if (_editable) {
          cells = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              // Each cell exposes its own tap action.
              excludeFromSemantics: true,
              // The rectangle starts where the pointer went down, not
              // where the drag was recognized.
              dragStartBehavior: DragStartBehavior.down,
              onTapDown: (_) => _focus.requestFocus(),
              onTapUp: (details) {
                final target = _cellAt(details.localPosition);
                _moveTo(target, extend: false);
                _paint(_rect(target, target));
              },
              onPanStart: (details) {
                _focus.requestFocus();
                final target = _cellAt(details.localPosition);
                setState(() {
                  _anchor = null;
                  _dragStart = target;
                  _dragEnd = target;
                });
              },
              onPanUpdate: (details) {
                final target = _cellAt(details.localPosition);
                if (target != _dragEnd) setState(() => _dragEnd = target);
              },
              onPanEnd: (_) {
                final rect = _preview;
                final end = _dragEnd;
                setState(() {
                  _dragStart = null;
                  _dragEnd = null;
                  if (end != null) _active = end;
                });
                if (rect != null) _paint(rect);
              },
              onPanCancel: () => setState(() {
                _dragStart = null;
                _dragEnd = null;
              }),
              child: cells,
            ),
          );
        }

        Widget content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final name in shortNames)
                    SizedBox(
                      width: dayWidth,
                      height: widget.cellHeight,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(name, style: dayStyle, maxLines: 1),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: header),
                cells,
              ],
            ),
          ],
        );
        if (dayWidth + cellsWidth > available + 0.5) {
          content = Scrollbar(
            controller: _scroll,
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: Oito2Spacing.sm),
              child: content,
            ),
          );
        }
        return content;
      },
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticsLabel ?? strings.weekSchedule,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Oito2Spacing.sm,
        children: [
          Focus(
            focusNode: _focus,
            autofocus: widget.autofocus,
            onKeyEvent: _onKey,
            child: grid,
          ),
          if (widget.showLegend)
            Wrap(
              spacing: Oito2Spacing.sm,
              runSpacing: Oito2Spacing.xs,
              children: [
                for (final (index, value) in widget.values.indexed)
                  _LegendChip(
                    label: value.label,
                    color: _colorOf(value, index),
                    selected: _editable && value.value == _brush,
                    onPressed: _editable ? () => _pickBrush(value.value) : null,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A legend entry: a color swatch and a label, which picks the brush when
/// [onPressed] is set.
class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ring = semanticColorsOf(context).primaryText;
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Oito2Spacing.sm,
        vertical: Oito2Spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Oito2Spacing.xs + 2,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
    final onPressed = this.onPressed;
    if (onPressed == null) return content;
    return Oito2TouchTarget(
      mergeSemantics: true,
      child: Semantics(
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          type: MaterialType.transparency,
          shape: StadiumBorder(
            side: selected
                ? BorderSide(color: ring, width: 2)
                : BorderSide(color: scheme.outlineVariant),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            mouseCursor: WidgetStateMouseCursor.clickable,
            onTap: onPressed,
            child: content,
          ),
        ),
      ),
    );
  }
}
