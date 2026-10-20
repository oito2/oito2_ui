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
import 'calendar.dart';
import 'popover.dart';
import 'widget_helpers.dart';

/// Shared behaviour of the date and time entries: a text field whose text
/// is parsed into a value, with the error shown only after the field
/// loses focus or is submitted, so partial input isn't flagged while
/// typing.
abstract class _ParsedEntryState<W extends StatefulWidget, T> extends State<W> {
  final controller = TextEditingController();
  FocusNode? _ownFocusNode;
  bool _initialized = false;
  bool _showError = false;
  String? _error;

  FocusNode? get externalFocusNode;
  FocusNode get focusNode =>
      externalFocusNode ?? (_ownFocusNode ??= FocusNode());

  /// Formats [value] for display.
  String format(T value);

  /// Parses [text], returning the value or an error message.
  (T?, String?) parse(String text);

  /// The value shown at start.
  T? get initialValue;

  /// Reports a new value.
  void report(T? value);

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final value = initialValue;
      if (value != null) controller.text = format(value);
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocus);
    _ownFocusNode?.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!focusNode.hasFocus) setState(() => _showError = true);
  }

  void onTextChanged(String text) {
    final (value, error) = parse(text);
    setState(() {
      _error = error;
      if (error == null) _showError = false;
    });
    if (error == null) report(value);
  }

  void onSubmitted(String _) => setState(() => _showError = true);

  /// Shows [value] in the field and reports it.
  void setValue(T value) {
    controller.text = format(value);
    onTextChanged(controller.text);
  }

  String? get visibleError => _showError ? _error : null;
}

/// A date text field that accepts the locale's compact date format (such
/// as mm/dd/yyyy) and offers a calendar picker button.
///
/// Parsing, the format hint and the error messages come from
/// `MaterialLocalizations`, so they follow the app language. Errors show
/// after the field loses focus or is submitted.
class Oito2DateEntry extends StatefulWidget {
  /// Creates a date entry.
  const Oito2DateEntry({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.onChanged,
    this.selectableDayPredicate,
    this.labelText,
    this.acceptEmpty = true,
    this.autofocus = false,
    this.focusNode,
    this.showPickerButton = true,
  });

  /// The earliest accepted date.
  final DateTime firstDate;

  /// The latest accepted date.
  final DateTime lastDate;

  /// The date shown at start.
  final DateTime? initialDate;

  /// Called with each valid date, or null when the field is emptied.
  final ValueChanged<DateTime?>? onChanged;

  /// Restricts which days are accepted.
  final SelectableDayPredicate? selectableDayPredicate;

  /// The field label; defaults to the localized "Enter Date".
  final String? labelText;

  /// Whether an empty field is valid.
  final bool acceptEmpty;

  /// Whether the field takes focus when shown.
  final bool autofocus;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the calendar picker button is shown.
  final bool showPickerButton;

  @override
  State<Oito2DateEntry> createState() => _Oito2DateEntryState();
}

class _Oito2DateEntryState extends _ParsedEntryState<Oito2DateEntry, DateTime> {
  MaterialLocalizations get _l10n => MaterialLocalizations.of(context);

  @override
  FocusNode? get externalFocusNode => widget.focusNode;

  @override
  DateTime? get initialValue => widget.initialDate;

  @override
  String format(DateTime value) => _l10n.formatCompactDate(value);

  @override
  void report(DateTime? value) => widget.onChanged?.call(value);

  bool _accepts(DateTime date) =>
      !date.isBefore(DateUtils.dateOnly(widget.firstDate)) &&
      !date.isAfter(DateUtils.dateOnly(widget.lastDate)) &&
      (widget.selectableDayPredicate?.call(date) ?? true);

  @override
  (DateTime?, String?) parse(String text) {
    if (text.trim().isEmpty) {
      return widget.acceptEmpty
          ? (null, null)
          : (null, _l10n.invalidDateFormatLabel);
    }
    final date = _l10n.parseCompactDate(text.trim());
    if (date == null) return (null, _l10n.invalidDateFormatLabel);
    if (!_accepts(date)) return (null, _l10n.dateOutOfRangeLabel);
    return (date, null);
  }

  final _popover = Oito2PopoverController();

  @override
  void dispose() {
    _popover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (current, _) = parse(controller.text);
    return Oito2Popover(
      controller: _popover,
      focusOnOpen: false,
      padding: const EdgeInsets.all(Oito2Spacing.sm),
      semanticLabel: _l10n.datePickerHelpText,
      builder: (context, popover) => TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.datetime,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9./\- ]')),
        ],
        onChanged: onTextChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: widget.labelText ?? _l10n.dateInputLabel,
          hintText: _l10n.dateHelpText,
          errorText: visibleError,
          suffixIcon: widget.showPickerButton
              ? FieldIconButton(
                  tooltip: _l10n.datePickerHelpText,
                  onPressed: popover.toggle,
                  icon: LucideIcons.calendar,
                )
              : null,
        ),
      ),
      popoverBuilder: (context, popover) => Oito2Calendar(
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        selectedDate: current,
        selectableDayPredicate: widget.selectableDayPredicate,
        autofocus: true,
        onDateSelected: (day) {
          setValue(day);
          popover.close();
        },
      ),
    );
  }
}

/// A time text field that accepts `H:MM` and `HH:MM`, with an optional
/// AM/PM suffix in 12-hour locales, and offers a clock picker button.
///
/// The display format follows the locale and the platform 24-hour
/// setting; the error message and the labels come from
/// `MaterialLocalizations`.
class Oito2TimeEntry extends StatefulWidget {
  /// Creates a time entry.
  const Oito2TimeEntry({
    super.key,
    this.initialTime,
    this.onChanged,
    this.labelText,
    this.acceptEmpty = true,
    this.autofocus = false,
    this.focusNode,
    this.showPickerButton = true,
  });

  /// The time shown at start.
  final TimeOfDay? initialTime;

  /// Called with each valid time, or null when the field is emptied.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// The field label; defaults to the localized "Enter time".
  final String? labelText;

  /// Whether an empty field is valid.
  final bool acceptEmpty;

  /// Whether the field takes focus when shown.
  final bool autofocus;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the clock picker button is shown.
  final bool showPickerButton;

  /// Parses `H:MM` or `HH:MM` (also with `.` or `h` as separator), with an
  /// optional AM/PM suffix matching [am] or [pm] (case-insensitive) or the
  /// letters a/p. Returns null for anything else.
  static TimeOfDay? parseTime(
    String text, {
    String am = 'AM',
    String pm = 'PM',
  }) {
    final match = RegExp(r'^\s*(\d{1,2})\s*[:.hH]\s*(\d{2})\s*(\S*)\s*$')
        .firstMatch(text);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final suffix = match.group(3)!.toLowerCase();
    if (minute > 59) return null;
    if (suffix.isEmpty) {
      return hour > 23 ? null : TimeOfDay(hour: hour, minute: minute);
    }
    final isAm = suffix == am.toLowerCase() || suffix == 'a' || suffix == 'am';
    final isPm = suffix == pm.toLowerCase() || suffix == 'p' || suffix == 'pm';
    if (!isAm && !isPm) return null;
    if (hour < 1 || hour > 12) return null;
    hour = hour % 12 + (isPm ? 12 : 0);
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  State<Oito2TimeEntry> createState() => _Oito2TimeEntryState();
}

class _Oito2TimeEntryState
    extends _ParsedEntryState<Oito2TimeEntry, TimeOfDay> {
  MaterialLocalizations get _l10n => MaterialLocalizations.of(context);

  @override
  FocusNode? get externalFocusNode => widget.focusNode;

  @override
  TimeOfDay? get initialValue => widget.initialTime;

  @override
  String format(TimeOfDay value) => _l10n.formatTimeOfDay(
    value,
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );

  @override
  void report(TimeOfDay? value) => widget.onChanged?.call(value);

  @override
  (TimeOfDay?, String?) parse(String text) {
    if (text.trim().isEmpty) {
      return widget.acceptEmpty ? (null, null) : (null, _l10n.invalidTimeLabel);
    }
    final time = Oito2TimeEntry.parseTime(
      text,
      am: _l10n.anteMeridiemAbbreviation,
      pm: _l10n.postMeridiemAbbreviation,
    );
    return time == null ? (null, _l10n.invalidTimeLabel) : (time, null);
  }

  Future<void> _pick() async {
    final (current, _) = parse(controller.text);
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) setValue(picked);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.datetime,
      onChanged: onTextChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText ?? _l10n.timePickerInputHelpText,
        errorText: visibleError,
        suffixIcon: widget.showPickerButton
            ? FieldIconButton(
                tooltip: _l10n.timePickerDialHelpText,
                onPressed: _pick,
                icon: LucideIcons.clock,
              )
            : null,
      ),
    );
  }
}

/// A date entry and a time entry side by side that report one combined
/// [DateTime]. An empty time means midnight.
class Oito2DateTimeEntry extends StatefulWidget {
  /// Creates a date and time entry.
  const Oito2DateTimeEntry({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.initialDateTime,
    this.onChanged,
    this.dateLabelText,
    this.timeLabelText,
  });

  /// The earliest accepted date.
  final DateTime firstDate;

  /// The latest accepted date.
  final DateTime lastDate;

  /// The date and time shown at start.
  final DateTime? initialDateTime;

  /// Called with each valid combination, or null without a date.
  final ValueChanged<DateTime?>? onChanged;

  /// The date field label.
  final String? dateLabelText;

  /// The time field label.
  final String? timeLabelText;

  @override
  State<Oito2DateTimeEntry> createState() => _Oito2DateTimeEntryState();
}

class _Oito2DateTimeEntryState extends State<Oito2DateTimeEntry> {
  late DateTime? _date = widget.initialDateTime == null
      ? null
      : DateUtils.dateOnly(widget.initialDateTime!);
  late TimeOfDay? _time = widget.initialDateTime == null
      ? null
      : TimeOfDay.fromDateTime(widget.initialDateTime!);

  void _report() {
    final date = _date;
    final time = _time ?? const TimeOfDay(hour: 0, minute: 0);
    widget.onChanged?.call(
      date == null
          ? null
          : DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Oito2Spacing.sm,
      children: [
        Expanded(
          flex: 3,
          child: Oito2DateEntry(
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialDate: _date,
            labelText: widget.dateLabelText,
            onChanged: (date) {
              _date = date;
              _report();
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Oito2TimeEntry(
            initialTime: _time,
            labelText: widget.timeLabelText,
            onChanged: (time) {
              _time = time;
              _report();
            },
          ),
        ),
      ],
    );
  }
}

/// One part of an [Oito2SegmentedEntry].
@immutable
class Oito2EntrySegment {
  /// Creates a segment that holds up to [length] characters.
  const Oito2EntrySegment({
    required this.length,
    this.hint,
    this.numeric = true,
    this.label,
  });

  /// The number of characters the segment holds.
  final int length;

  /// The placeholder, such as `000`.
  final String? hint;

  /// Whether only digits are accepted.
  final bool numeric;

  /// The accessibility label; defaults to the [Oito2Localizations]
  /// "part n of m" string.
  final String? label;
}

/// A row of short text fields joined by a [delimiter], for values like
/// IP addresses or license keys.
///
/// Focus moves to the next segment when one fills up or when the
/// delimiter is typed, and back to the previous one on Backspace in an
/// empty segment or on the left arrow at its start.
class Oito2SegmentedEntry extends StatefulWidget {
  /// Creates a segmented entry.
  const Oito2SegmentedEntry({
    super.key,
    required this.segments,
    this.delimiter = '.',
    this.initialValues,
    this.onChanged,
  });

  /// The segments, in order.
  final List<Oito2EntrySegment> segments;

  /// The text drawn between segments, which also advances focus when
  /// typed.
  final String delimiter;

  /// The text of each segment at start.
  final List<String>? initialValues;

  /// Called with the text of every segment whenever one changes.
  final ValueChanged<List<String>>? onChanged;

  @override
  State<Oito2SegmentedEntry> createState() => _Oito2SegmentedEntryState();
}

class _Oito2SegmentedEntryState extends State<Oito2SegmentedEntry> {
  late final List<TextEditingController> _controllers = [
    for (var i = 0; i < widget.segments.length; i++)
      TextEditingController(
        text: (widget.initialValues != null && i < widget.initialValues!.length)
            ? widget.initialValues![i]
            : '',
      ),
  ];
  late final List<FocusNode> _nodes = [
    for (var i = 0; i < widget.segments.length; i++)
      FocusNode(onKeyEvent: (node, event) => _onKey(i, event)),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Focuses the segment at [index], if any, with the caret at its end.
  void _focus(int index) {
    if (index < 0 || index >= _nodes.length) return;
    _nodes[index].requestFocus();
    final controller = _controllers[index];
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final controller = _controllers[index];
    final atStart =
        controller.selection.isCollapsed && controller.selection.start == 0;
    final atEnd =
        controller.selection.isCollapsed &&
        controller.selection.end == controller.text.length;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace && controller.text.isEmpty) {
      _focus(index - 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft && atStart && index > 0) {
      _focus(index - 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight &&
        atEnd &&
        index < _nodes.length - 1) {
      _nodes[index + 1].requestFocus();
      _controllers[index + 1].selection = const TextSelection.collapsed(
        offset: 0,
      );
      return KeyEventResult.handled;
    }
    if (event.character == widget.delimiter && index < _nodes.length - 1) {
      _nodes[index + 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onChanged(int index, String text) {
    if (text.length >= widget.segments[index].length) _focus(index + 1);
    widget.onChanged?.call([for (final c in _controllers) c.text]);
  }

  double _segmentWidth(BuildContext context, Oito2EntrySegment segment) {
    final style = Theme.of(context).textTheme.bodyLarge;
    final painter = TextPainter(
      text: TextSpan(text: '0' * segment.length, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width + Oito2Spacing.md * 2 + 2;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.segments.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Oito2Spacing.xs),
              child: ExcludeSemantics(child: Text(widget.delimiter)),
            ),
          SizedBox(
            width: _segmentWidth(context, widget.segments[i]),
            child: Semantics(
              label:
                  widget.segments[i].label ??
                  Oito2Localizations.of(context).partOf(i + 1, count),
              child: TextField(
                controller: _controllers[i],
                focusNode: _nodes[i],
                textAlign: TextAlign.center,
                keyboardType: widget.segments[i].numeric
                    ? TextInputType.number
                    : TextInputType.text,
                inputFormatters: [
                  if (widget.segments[i].numeric)
                    FilteringTextInputFormatter.digitsOnly
                  else
                    FilteringTextInputFormatter.deny(
                      RegExp(RegExp.escape(widget.delimiter)),
                    ),
                  LengthLimitingTextInputFormatter(widget.segments[i].length),
                ],
                onChanged: (text) => _onChanged(i, text),
                decoration: InputDecoration(
                  hintText: widget.segments[i].hint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Oito2Spacing.md,
                    vertical: Oito2Spacing.sm,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
