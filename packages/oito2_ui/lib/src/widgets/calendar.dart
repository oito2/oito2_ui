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
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'popover.dart';
import 'widget_helpers.dart';

/// The ISO 8601 week number of [date]: weeks start on Monday and week 1
/// holds the year's first Thursday.
int oito2IsoWeekNumber(DateTime date) {
  final day = DateUtils.dateOnly(date);
  final thursday = DateUtils.addDaysToDate(day, 4 - day.weekday);
  final firstOfYear = DateTime(thursday.year);
  final dayOfYear = thursday.difference(firstOfYear).inDays;
  return dayOfYear ~/ 7 + 1;
}

/// A month grid that picks a date, or a range of dates when
/// [onRangeSelected] is set.
///
/// The header changes the month. The grid takes the focus as a whole: the
/// arrow keys move by a day or a week, Home and End to the start and end
/// of the week, Page Up and Page Down by a month (a year with Shift), and
/// Enter or Space picks the focused day. A range takes two picks; the
/// second may come before the first. Days outside [firstDate] and
/// [lastDate], or refused by [selectableDayPredicate], can't be picked.
/// Week numbers follow ISO 8601.
class Oito2Calendar extends StatefulWidget {
  /// Creates a calendar.
  const Oito2Calendar({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.selectedDate,
    this.onDateSelected,
    this.selectedRange,
    this.onRangeSelected,
    this.initialMonth,
    this.selectableDayPredicate,
    this.showWeekNumbers = false,
    this.autofocus = false,
    this.currentDate,
  });

  /// The earliest date that can be picked.
  final DateTime firstDate;

  /// The latest date that can be picked.
  final DateTime lastDate;

  /// The day marked as today; the current date by default.
  final DateTime? currentDate;

  /// The picked date, in single mode.
  final DateTime? selectedDate;

  /// Called with a picked date, in single mode.
  final ValueChanged<DateTime>? onDateSelected;

  /// The picked range, in range mode.
  final DateTimeRange? selectedRange;

  /// Called with a completed range; setting it turns on range mode.
  final ValueChanged<DateTimeRange>? onRangeSelected;

  /// The month shown first; defaults to the selection or today.
  final DateTime? initialMonth;

  /// Restricts which days can be picked.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Whether a week number column shows.
  final bool showWeekNumbers;

  /// Whether the grid takes the focus when shown.
  final bool autofocus;

  @override
  State<Oito2Calendar> createState() => _Oito2CalendarState();
}

class _Oito2CalendarState extends State<Oito2Calendar> {
  final _gridFocus = FocusNode(debugLabel: 'Oito2Calendar grid');
  late DateTime _month;
  late DateTime _focused;
  DateTime? _rangeStart;
  DateTime? _hovered;

  bool get _rangeMode => widget.onRangeSelected != null;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(widget.currentDate ?? DateTime.now());
    final initial =
        widget.initialMonth ??
        widget.selectedDate ??
        widget.selectedRange?.start ??
        _clamp(today);
    _focused = DateUtils.dateOnly(
      widget.selectedDate ?? widget.selectedRange?.start ?? _clamp(today),
    );
    _month = DateTime(initial.year, initial.month);
    _gridFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _gridFocus.dispose();
    super.dispose();
  }

  DateTime _clamp(DateTime day) {
    final first = DateUtils.dateOnly(widget.firstDate);
    final last = DateUtils.dateOnly(widget.lastDate);
    return day.isBefore(first) ? first : (day.isAfter(last) ? last : day);
  }

  bool _canPick(DateTime day) =>
      !day.isBefore(DateUtils.dateOnly(widget.firstDate)) &&
      !day.isAfter(DateUtils.dateOnly(widget.lastDate)) &&
      (widget.selectableDayPredicate?.call(day) ?? true);

  bool get _canGoBack => DateTime(
    _month.year,
    _month.month,
  ).isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));

  bool get _canGoForward => DateTime(
    _month.year,
    _month.month,
  ).isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));

  void _showMonth(int delta) {
    setState(() {
      _month = DateUtils.addMonthsToMonthDate(_month, delta);
      final days = DateUtils.getDaysInMonth(_month.year, _month.month);
      _focused = _clamp(
        DateTime(_month.year, _month.month, _focused.day.clamp(1, days)),
      );
    });
  }

  void _focus(DateTime day) {
    final target = _clamp(day);
    setState(() {
      _focused = target;
      _month = DateTime(target.year, target.month);
    });
  }

  void _pick(DateTime day) {
    if (!_canPick(day)) return;
    setState(() => _focused = day);
    if (!_rangeMode) {
      widget.onDateSelected?.call(day);
      return;
    }
    final start = _rangeStart;
    if (start == null) {
      setState(() => _rangeStart = day);
      return;
    }
    setState(() {
      _rangeStart = null;
      _hovered = null;
    });
    widget.onRangeSelected!(
      day.isBefore(start)
          ? DateTimeRange(start: day, end: start)
          : DateTimeRange(start: start, end: day),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final key = event.logicalKey;
    final l10n = MaterialLocalizations.of(context);
    final weekStart = (_focused.weekday % 7 - l10n.firstDayOfWeekIndex + 7) % 7;
    DateTime days(int n) => DateUtils.addDaysToDate(_focused, n);
    if (key == LogicalKeyboardKey.arrowLeft) {
      _focus(days(rtl ? 1 : -1));
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _focus(days(rtl ? -1 : 1));
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _focus(days(-7));
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _focus(days(7));
    } else if (key == LogicalKeyboardKey.home) {
      _focus(days(-weekStart));
    } else if (key == LogicalKeyboardKey.end) {
      _focus(days(6 - weekStart));
    } else if (key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.pageDown) {
      final months =
          (shift ? 12 : 1) * (key == LogicalKeyboardKey.pageUp ? -1 : 1);
      final month = DateUtils.addMonthsToMonthDate(
        DateTime(_focused.year, _focused.month),
        months,
      );
      final length = DateUtils.getDaysInMonth(month.year, month.month);
      _focus(DateTime(month.year, month.month, _focused.day.clamp(1, length)));
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _pick(_focused);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// Where [day] sits in the shown selection.
  ({bool selected, bool inRange, bool start, bool end}) _state(DateTime day) {
    if (!_rangeMode) {
      final selected =
          widget.selectedDate != null &&
          DateUtils.isSameDay(widget.selectedDate, day);
      return (selected: selected, inRange: false, start: false, end: false);
    }
    DateTime? start;
    DateTime? end;
    final pending = _rangeStart;
    if (pending != null) {
      final other = _hovered ?? pending;
      start = other.isBefore(pending) ? other : pending;
      end = other.isBefore(pending) ? pending : other;
    } else if (widget.selectedRange != null) {
      start = DateUtils.dateOnly(widget.selectedRange!.start);
      end = DateUtils.dateOnly(widget.selectedRange!.end);
    }
    if (start == null || end == null) {
      return (selected: false, inRange: false, start: false, end: false);
    }
    final isStart = DateUtils.isSameDay(day, start);
    final isEnd = DateUtils.isSameDay(day, end);
    final inside = !day.isBefore(start) && !day.isAfter(end);
    return (
      selected: isStart || isEnd,
      inRange: inside,
      start: isStart,
      end: isEnd,
    );
  }

  Widget _day(BuildContext context, DateTime day, double size) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = MaterialLocalizations.of(context);
    final fill = selectedFillOf(context);
    final ring = semanticColorsOf(context).primaryText;
    final enabled = _canPick(day);
    final today = DateUtils.isSameDay(
      day,
      widget.currentDate ?? DateTime.now(),
    );
    final focused =
        _gridFocus.hasFocus &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional &&
        DateUtils.isSameDay(day, _focused);
    final (:selected, :inRange, :start, :end) = _state(day);
    final foreground = !enabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : selected
        ? fill.onFill
        : inRange
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    Widget cell = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? fill.fill : null,
        borderRadius: Oito2Radius.mediumAll,
        border: focused
            ? Border.all(color: ring, width: Oito2Sizes.focusBorderWidth)
            : today && !selected
            ? Border.all(color: ring)
            : null,
      ),
      child: Text(
        '${day.day}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: foreground,
          fontWeight: today ? FontWeight.w600 : null,
        ),
      ),
    );
    if (inRange && !(start && end)) {
      // The band between the range ends, cut in half at each end.
      final band = Container(
        height: size,
        decoration: BoxDecoration(color: scheme.secondaryContainer),
      );
      cell = Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: (start && !rtl) || (end && rtl)
                      ? const SizedBox()
                      : band,
                ),
                Expanded(
                  child: (end && !rtl) || (start && rtl)
                      ? const SizedBox()
                      : band,
                ),
              ],
            ),
          ),
          cell,
        ],
      );
    }
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: l10n.formatFullDate(day),
      hint: today ? l10n.currentDateLabel : null,
      excludeSemantics: true,
      onTap: enabled ? () => _pick(day) : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: _rangeStart == null
            ? null
            : (_) => setState(() => _hovered = day),
        child: GestureDetector(
          onTap: enabled
              ? () {
                  _gridFocus.requestFocus();
                  _pick(day);
                }
              : null,
          child: cell,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = MaterialLocalizations.of(context);
    final strings = Oito2Localizations.of(context);
    final size = controlHeightOf(context) + 2;
    final offset = DateUtils.firstDayOffset(_month.year, _month.month, l10n);
    final length = DateUtils.getDaysInMonth(_month.year, _month.month);
    final rows = ((offset + length) / 7).ceil();
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Widget headingCell(String text, {String? semantics}) => SizedBox(
      width: size,
      height: size * 0.75,
      child: Center(
        child: Text(text, style: muted, semanticsLabel: semantics),
      ),
    );

    final weekdays = [
      for (var i = 0; i < 7; i++)
        l10n.narrowWeekdays[(l10n.firstDayOfWeekIndex + i) % 7],
    ];

    return SizedBox(
      width: size * (widget.showWeekNumbers ? 8 : 7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Oito2Spacing.sm,
                  ),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.formatMonthYear(_month),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.previousMonthTooltip,
                onPressed: _canGoBack ? () => _showMonth(-1) : null,
                icon: const Icon(LucideIcons.chevron_left, size: 18),
              ),
              IconButton(
                tooltip: l10n.nextMonthTooltip,
                onPressed: _canGoForward ? () => _showMonth(1) : null,
                icon: const Icon(LucideIcons.chevron_right, size: 18),
              ),
            ],
          ),
          Focus(
            focusNode: _gridFocus,
            autofocus: widget.autofocus,
            onKeyEvent: _onKey,
            child: MouseRegion(
              onExit: (_) {
                if (_hovered != null) setState(() => _hovered = null);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showWeekNumbers)
                          headingCell(strings.weekNumberHeading),
                        for (final name in weekdays) headingCell(name),
                      ],
                    ),
                  ),
                  for (var row = 0; row < rows; row++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showWeekNumbers)
                          Builder(
                            builder: (context) {
                              final first = DateTime(
                                _month.year,
                                _month.month,
                                row * 7 - offset + 1,
                              );
                              final week = oito2IsoWeekNumber(
                                DateUtils.addDaysToDate(first, 3),
                              );
                              return SizedBox(
                                width: size,
                                height: size,
                                child: Center(
                                  child: Text(
                                    '$week',
                                    style: muted,
                                    semanticsLabel: strings.weekNumber(week),
                                  ),
                                ),
                              );
                            },
                          ),
                        for (var column = 0; column < 7; column++)
                          Builder(
                            builder: (context) {
                              final dayNumber = row * 7 + column - offset + 1;
                              if (dayNumber < 1 || dayNumber > length) {
                                return SizedBox.square(dimension: size);
                              }
                              return _day(
                                context,
                                DateTime(_month.year, _month.month, dayNumber),
                                size,
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A field-like button that shows a date, or a date range when
/// [onRangeChanged] is set, and opens an [Oito2Calendar] in a popover to
/// change it.
///
/// Enter, Space or Alt+Down opens the calendar, which takes the focus; a
/// pick closes it.
class Oito2DatePicker extends StatefulWidget {
  /// Creates a date picker.
  const Oito2DatePicker({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.value,
    this.onChanged,
    this.range,
    this.onRangeChanged,
    this.labelText,
    this.hintText,
    this.selectableDayPredicate,
    this.showWeekNumbers = false,
  });

  /// The earliest date that can be picked.
  final DateTime firstDate;

  /// The latest date that can be picked.
  final DateTime lastDate;

  /// The picked date, in single mode.
  final DateTime? value;

  /// Called with a picked date, in single mode.
  final ValueChanged<DateTime>? onChanged;

  /// The picked range, in range mode.
  final DateTimeRange? range;

  /// Called with a picked range; setting it turns on range mode.
  final ValueChanged<DateTimeRange>? onRangeChanged;

  /// The field label.
  final String? labelText;

  /// The text shown when nothing is picked.
  final String? hintText;

  /// Restricts which days can be picked.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Whether the calendar shows week numbers.
  final bool showWeekNumbers;

  @override
  State<Oito2DatePicker> createState() => _Oito2DatePickerState();
}

class _Oito2DatePickerState extends State<Oito2DatePicker> {
  final _popover = Oito2PopoverController();
  final _text = TextEditingController();

  @override
  void dispose() {
    _popover.dispose();
    _text.dispose();
    super.dispose();
  }

  String _display(MaterialLocalizations l10n) {
    final range = widget.range;
    if (widget.onRangeChanged != null) {
      return range == null
          ? ''
          : '${l10n.formatCompactDate(range.start)} – '
                '${l10n.formatCompactDate(range.end)}';
    }
    final value = widget.value;
    return value == null ? '' : l10n.formatCompactDate(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MaterialLocalizations.of(context);
    final enabled = widget.onChanged != null || widget.onRangeChanged != null;
    final display = _display(l10n);
    if (_text.text != display) _text.text = display;
    return Oito2Popover(
      controller: _popover,
      focusOnOpen: false,
      padding: const EdgeInsets.all(Oito2Spacing.sm),
      semanticLabel: widget.labelText ?? l10n.datePickerHelpText,
      builder: (context, controller) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter): controller.open,
          const SingleActivator(LogicalKeyboardKey.space): controller.open,
          const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
              controller.open,
        },
        child: TextField(
          controller: _text,
          readOnly: true,
          enabled: enabled,
          onTap: controller.toggle,
          mouseCursor: SystemMouseCursors.click,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText ?? l10n.dateHelpText,
            suffixIcon: const Icon(LucideIcons.calendar, size: 18),
          ),
        ),
      ),
      popoverBuilder: (context, controller) => Oito2Calendar(
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        selectedDate: widget.value,
        selectedRange: widget.range,
        selectableDayPredicate: widget.selectableDayPredicate,
        showWeekNumbers: widget.showWeekNumbers,
        autofocus: true,
        onDateSelected: widget.onChanged == null
            ? null
            : (day) {
                widget.onChanged!(day);
                controller.close();
              },
        onRangeSelected: widget.onRangeChanged == null
            ? null
            : (range) {
                widget.onRangeChanged!(range);
                controller.close();
              },
      ),
    );
  }
}
