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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'calendar.dart';
import 'form.dart';
import 'popover.dart';
import 'touch_target.dart';
import 'widget_helpers.dart';

/// Shared behaviour of the date and time entries: a text field whose text
/// is parsed into a value, with the error shown only after the field
/// loses focus or is submitted, so partial input isn't flagged while
/// typing, or at once after its form found errors.
abstract class _ParsedEntryState<W extends StatefulWidget, T> extends State<W>
    with OwnedFocusNodeMixin<W>, Oito2FormFieldMixin<W> {
  /// The controller of the text field.
  final controller = TextEditingController();
  bool _initialized = false;
  bool _showError = false;
  String? _error;

  /// The text the field holds while it has no unsaved changes.
  String _cleanText = '';

  /// Checks a parsed value; null accepts every value.
  String? Function(T? value)? get validator;

  /// Whether an empty field shows the required error.
  bool get isRequired;

  /// The focus node in use: the widget's, or the one this state owns.
  FocusNode get focusNode => effectiveFocusNode;

  /// Formats [value] for display.
  String format(T value);

  /// Parses [text], returning the value and a null error, or a null value
  /// and the error message.
  (T?, String?) parse(String text);

  /// The value shown in the field at start.
  T? get initialValue;

  /// Reports a new valid value, or null for an accepted empty field.
  void report(T? value);

  /// Reports that the text stopped parsing, with the error message, or
  /// parses again, with null.
  void reportError(String? error);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final value = initialValue;
      if (value != null) controller.text = format(value);
      _cleanText = controller.text;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void onEffectiveFocusChange() {
    if (!focusNode.hasFocus) setState(() => _showError = true);
  }

  /// Parses [text], reports a change of the parse error and, when it
  /// parses, the value; a valid text also hides the shown error.
  void onTextChanged(String text) {
    final (value, error) = parse(text);
    if (error != _error) reportError(error);
    setState(() {
      _error = error;
      if (error == null) _showError = false;
    });
    if (error == null) report(value);
    notifyFormFieldChanged();
  }

  /// Shows the current error, if any, after the field is submitted.
  void onSubmitted(String _) => setState(() => _showError = true);

  /// Returns the error of [text]: the parse error, the required error of
  /// an empty field, or the validator error of the parsed value.
  String? errorOf(String text) {
    final (value, error) = parse(text);
    if (error != null) return error;
    if (isRequired && text.trim().isEmpty) {
      return Oito2Localizations.of(context).fieldRequired;
    }
    return validator?.call(value);
  }

  @override
  String? get formFieldError => errorOf(controller.text);

  @override
  FocusNode get formFieldFocusNode => focusNode;

  @override
  bool get isFormFieldDirty => controller.text != _cleanText;

  @override
  void showFormFieldError() {
    if (mounted) setState(() => _showError = true);
  }

  @override
  void markFormFieldClean() => _cleanText = controller.text;

  @override
  void resetFormField() {
    if (controller.text != _cleanText) {
      controller.text = _cleanText;
      onTextChanged(_cleanText);
    }
    setState(() => _showError = false);
  }

  /// Shows [value] in the field and reports it.
  void setValue(T value) {
    controller.text = format(value);
    onTextChanged(controller.text);
  }

  /// The error to show once the field has lost focus or been submitted,
  /// or after its form found errors: the parse error, the required error
  /// or the validator error; otherwise null.
  String? get visibleError =>
      _showError || formShowsErrors ? errorOf(controller.text) : null;
}

/// A date text field that accepts the locale's compact date format (such
/// as mm/dd/yyyy) and offers a calendar picker button.
///
/// Parsing, the format hint and the error messages come from
/// `MaterialLocalizations`, so they follow the app language. Errors show
/// after the field loses focus or is submitted, or at once after its
/// [Oito2Form] found errors.
class Oito2DateEntry extends StatefulWidget {
  /// Creates a date entry.
  const Oito2DateEntry({
    super.key,
    this.participatesInForm = true,
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.onChanged,
    this.onErrorChanged,
    this.validator,
    this.required = false,
    this.selectableDayPredicate,
    this.labelText,
    this.acceptEmpty = true,
    this.autofocus = false,
    this.focusNode,
    this.showPickerButton = true,
    this.currentDate,
  });

  /// The earliest accepted date.
  final DateTime firstDate;

  /// The latest accepted date.
  final DateTime lastDate;

  /// The date shown at start.
  final DateTime? initialDate;

  /// Called with each valid date, or null when the field is emptied.
  ///
  /// Invalid text doesn't call it, so the last valid date stays reported;
  /// [onErrorChanged] tells when the text doesn't parse.
  final ValueChanged<DateTime?>? onChanged;

  /// Called with the error message when the text stops being a valid
  /// date, and with null when it is valid again.
  ///
  /// It reports only the parse errors, not those of [validator] or
  /// [required].
  final ValueChanged<String?>? onErrorChanged;

  /// Checks a valid date, or null for an empty field, and returns an
  /// error message, or null to accept it.
  ///
  /// The error shows like a parse error; [onChanged] still reports the
  /// date.
  final String? Function(DateTime? date)? validator;

  /// Whether an empty field shows the localized "This field is required"
  /// error.
  final bool required;

  /// Decides which days between [firstDate] and [lastDate] are accepted;
  /// every day is when null.
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

  /// The day the calendar marks as today and opens on when no date is
  /// set; the current date by default.
  final DateTime? currentDate;

  /// Parses [text] in the compact date format of [localizations] (such as
  /// mm/dd/yyyy), ignoring surrounding spaces.
  ///
  /// A year written with one or two digits is taken as the year with those
  /// last digits that falls from 80 years before to 19 years after the
  /// year of [reference] (today when null), so `26` reads as 2026 in 2026
  /// and `99` as 1999. A year written with three or more digits is used as
  /// written. Returns null when the text doesn't parse.
  static DateTime? parseDate(
    String text,
    MaterialLocalizations localizations, {
    DateTime? reference,
  }) {
    final date = localizations.parseCompactDate(text.trim());
    if (date == null || date.year >= 100) return date;
    if (_longNumber.hasMatch(text)) return date;
    final referenceYear = (reference ?? DateTime.now()).year;
    var year = referenceYear - referenceYear % 100 + date.year;
    if (year > referenceYear + 19) {
      year -= 100;
    } else if (year < referenceYear - 80) {
      year += 100;
    }
    final expanded = DateTime(year, date.month, date.day);
    return expanded.month == date.month ? expanded : null;
  }

  /// Matches a run of three or more decimal digits in any script.
  static final _longNumber = RegExp(r'\p{Nd}{3,}', unicode: true);

  /// Whether the field registers with the closest [Oito2Form], taking
  /// part in its validation, error summary and dirty state; true by
  /// default. When false, the field shows its own errors as outside a
  /// form.
  final bool participatesInForm;

  @override
  State<Oito2DateEntry> createState() => _Oito2DateEntryState();
}

/// Parses and formats dates for [Oito2DateEntry] and shows its calendar
/// popover.
class _Oito2DateEntryState extends _ParsedEntryState<Oito2DateEntry, DateTime> {
  MaterialLocalizations get _l10n => MaterialLocalizations.of(context);

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  DateTime? get initialValue => widget.initialDate;

  @override
  String? Function(DateTime? value)? get validator => widget.validator;

  @override
  bool get isRequired => widget.required;

  @override
  bool get participatesInForm => widget.participatesInForm;

  @override
  String get formFieldLabel => widget.labelText ?? _l10n.dateInputLabel;

  @override
  String format(DateTime value) => _l10n.formatCompactDate(value);

  @override
  void report(DateTime? value) => widget.onChanged?.call(value);

  @override
  void reportError(String? error) => widget.onErrorChanged?.call(error);

  /// Whether [date] is within the limits and accepted by the predicate.
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
    final date = Oito2DateEntry.parseDate(
      text,
      _l10n,
      reference: widget.currentDate,
    );
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
      builder: (context, popover) => Oito2TouchTarget(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: widget.autofocus,
          keyboardType: TextInputType.datetime,
          // Compact date patterns of some locales hold letters or native
          // digits, so the parser validates the text instead of a filter.
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
      ),
      popoverBuilder: (context, popover) => Oito2Calendar(
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        selectedDate: current,
        currentDate: widget.currentDate,
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
/// `MaterialLocalizations`. Errors show after the field loses focus or is
/// submitted, or at once after its [Oito2Form] found errors.
class Oito2TimeEntry extends StatefulWidget {
  /// Creates a time entry.
  const Oito2TimeEntry({
    super.key,
    this.participatesInForm = true,
    this.initialTime,
    this.onChanged,
    this.onErrorChanged,
    this.validator,
    this.required = false,
    this.labelText,
    this.acceptEmpty = true,
    this.autofocus = false,
    this.focusNode,
    this.showPickerButton = true,
  });

  /// The time shown at start.
  final TimeOfDay? initialTime;

  /// Called with each valid time, or null when the field is emptied.
  ///
  /// Invalid text doesn't call it, so the last valid time stays reported;
  /// [onErrorChanged] tells when the text doesn't parse.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// Called with the error message when the text stops being a valid
  /// time, and with null when it is valid again.
  ///
  /// It reports only the parse errors, not those of [validator] or
  /// [required].
  final ValueChanged<String?>? onErrorChanged;

  /// Checks a valid time, or null for an empty field, and returns an
  /// error message, or null to accept it.
  final String? Function(TimeOfDay? time)? validator;

  /// Whether an empty field shows the localized "This field is required"
  /// error.
  final bool required;

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

  /// Parses [text] as `H:MM` or `HH:MM` (also with `.` or `h` as the
  /// separator), with an optional day-period marker before or after the
  /// time, as the locale writes it (such as `9:30 PM`): [am] or [pm]
  /// (case-insensitive), `am`/`pm`, or the letters a/p.
  ///
  /// Without a marker the hour must be 0 to 23; with one, 1 to 12. Returns
  /// null for anything else.
  static TimeOfDay? parseTime(
    String text, {
    String am = 'AM',
    String pm = 'PM',
  }) {
    final match = _timePattern.firstMatch(text);
    if (match == null) return null;
    final prefix = match.group(1)!.toLowerCase();
    var hour = int.parse(match.group(2)!);
    final minute = int.parse(match.group(3)!);
    final suffix = match.group(4)!.toLowerCase();
    if (minute > 59) return null;
    if (prefix.isNotEmpty && suffix.isNotEmpty) return null;
    final marker = suffix.isNotEmpty ? suffix : prefix;
    if (marker.isEmpty) {
      return hour > 23 ? null : TimeOfDay(hour: hour, minute: minute);
    }
    final isAm = marker == am.toLowerCase() || marker == 'a' || marker == 'am';
    final isPm = marker == pm.toLowerCase() || marker == 'p' || marker == 'pm';
    if (!isAm && !isPm) return null;
    if (hour < 1 || hour > 12) return null;
    hour = hour % 12 + (isPm ? 12 : 0);
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Captures an optional prefix marker, the hour, the minutes and an
  /// optional suffix marker.
  static final _timePattern = RegExp(
    r'^\s*(\D*?)\s*(\d{1,2})\s*[:.hH]\s*(\d{2})\s*(\S*)\s*$',
  );

  /// Whether the field registers with the closest [Oito2Form], taking
  /// part in its validation, error summary and dirty state; true by
  /// default. When false, the field shows its own errors as outside a
  /// form.
  final bool participatesInForm;

  @override
  State<Oito2TimeEntry> createState() => _Oito2TimeEntryState();
}

/// Parses and formats times for [Oito2TimeEntry] and opens its time
/// picker dialog.
class _Oito2TimeEntryState
    extends _ParsedEntryState<Oito2TimeEntry, TimeOfDay> {
  MaterialLocalizations get _l10n => MaterialLocalizations.of(context);

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  TimeOfDay? get initialValue => widget.initialTime;

  @override
  String? Function(TimeOfDay? value)? get validator => widget.validator;

  @override
  bool get isRequired => widget.required;

  @override
  bool get participatesInForm => widget.participatesInForm;

  @override
  String get formFieldLabel =>
      widget.labelText ?? _l10n.timePickerInputHelpText;

  @override
  String format(TimeOfDay value) => _l10n.formatTimeOfDay(
    value,
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );

  @override
  void report(TimeOfDay? value) => widget.onChanged?.call(value);

  @override
  void reportError(String? error) => widget.onErrorChanged?.call(error);

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

  /// Opens the time picker at the entered time, or now, and shows the
  /// picked time.
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
    return Oito2TouchTarget(
      child: TextField(
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
      ),
    );
  }
}

/// A date entry and a time entry side by side that report one combined
/// [DateTime]. An empty time means midnight.
///
/// In an [Oito2Form], the two entries take part as two fields.
class Oito2DateTimeEntry extends StatefulWidget {
  /// Creates a date and time entry.
  const Oito2DateTimeEntry({
    super.key,
    this.participatesInForm = true,
    required this.firstDate,
    required this.lastDate,
    this.initialDateTime,
    this.onChanged,
    this.onErrorChanged,
    this.validator,
    this.required = false,
    this.dateLabelText,
    this.timeLabelText,
  });

  /// The earliest accepted date.
  final DateTime firstDate;

  /// The latest accepted date.
  final DateTime lastDate;

  /// The date and time shown at start.
  final DateTime? initialDateTime;

  /// Called with each new valid combination, or null without a date.
  ///
  /// It isn't called while either field holds invalid text; once both
  /// parse again, it reports the combination if it changed.
  /// [onErrorChanged] tells when one of them doesn't parse.
  final ValueChanged<DateTime?>? onChanged;

  /// Called with the error message of the date field, or else of the time
  /// field, when either stops parsing, and with null when both parse.
  ///
  /// It reports only the parse errors, not those of [validator] or
  /// [required].
  final ValueChanged<String?>? onErrorChanged;

  /// Checks the combination of a valid date and time, or null without a
  /// date, and returns an error message, shown under the date field, or
  /// null to accept it.
  final String? Function(DateTime? dateTime)? validator;

  /// Whether an empty date field shows the localized "This field is
  /// required" error.
  final bool required;

  /// The date field label; defaults to the localized "Enter Date".
  final String? dateLabelText;

  /// The time field label; defaults to the localized "Enter time".
  final String? timeLabelText;

  /// Whether the field registers with the closest [Oito2Form], taking
  /// part in its validation, error summary and dirty state; true by
  /// default. When false, the field shows its own errors as outside a
  /// form.
  final bool participatesInForm;

  @override
  State<Oito2DateTimeEntry> createState() => _Oito2DateTimeEntryState();
}

/// Combines the last valid date and time of [Oito2DateTimeEntry] and
/// merges the errors of both fields.
class _Oito2DateTimeEntryState extends State<Oito2DateTimeEntry> {
  late DateTime? _date = widget.initialDateTime == null
      ? null
      : DateUtils.dateOnly(widget.initialDateTime!);
  late TimeOfDay? _time = widget.initialDateTime == null
      ? null
      : TimeOfDay.fromDateTime(widget.initialDateTime!);

  String? _dateError;
  String? _timeError;
  String? _reportedError;

  /// The combination reported last, starting with the initial one.
  DateTime? _reportedValue;

  @override
  void initState() {
    super.initState();
    _reportedValue = _combined;
  }

  /// Reports the date error, or else the time error, when it changed.
  void _reportError() {
    final error = _dateError ?? _timeError;
    if (error == _reportedError) return;
    _reportedError = error;
    widget.onErrorChanged?.call(error);
  }

  /// The date at the time, or at midnight without a time, or null without
  /// a date.
  DateTime? get _combined => _combine(_date);

  /// Returns [date] at the last valid time, or at midnight without a time,
  /// or null without a date.
  DateTime? _combine(DateTime? date) {
    final time = _time ?? const TimeOfDay(hour: 0, minute: 0);
    return date == null
        ? null
        : DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Reports the combination when it changed and neither field holds
  /// invalid text.
  void _report() {
    if (_dateError != null || _timeError != null) return;
    final value = _combined;
    if (value == _reportedValue) return;
    _reportedValue = value;
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final validator = widget.validator;
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
            required: widget.required,
            participatesInForm: widget.participatesInForm,
            validator: validator == null
                ? null
                : (date) => validator(_combine(date)),
            onChanged: (date) {
              _date = date;
              _report();
            },
            onErrorChanged: (error) {
              _dateError = error;
              _reportError();
              _report();
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Oito2TimeEntry(
            initialTime: _time,
            labelText: widget.timeLabelText,
            participatesInForm: widget.participatesInForm,
            onChanged: (time) {
              // Rebuilds so the date field checks the new combination.
              setState(() => _time = time);
              _report();
            },
            onErrorChanged: (error) {
              _timeError = error;
              _reportError();
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
/// Focus moves to the next segment when one fills up or when the first
/// visible character of the delimiter is typed, and back to the previous
/// one on Backspace in an empty segment or on the arrow toward the start
/// of the reading direction (the left arrow in left-to-right text) at its
/// start.
///
/// With [validator] or [required], an error shows below the segments once
/// the focus leaves the entry, or at once after its [Oito2Form] found
/// errors.
class Oito2SegmentedEntry extends StatefulWidget {
  /// Creates a segmented entry.
  const Oito2SegmentedEntry({
    super.key,
    this.participatesInForm = true,
    required this.segments,
    this.delimiter = '.',
    this.initialValues,
    this.onChanged,
    this.validator,
    this.required = false,
    this.labelText,
  });

  /// The segments, in order.
  final List<Oito2EntrySegment> segments;

  /// The text drawn between segments; typing its first visible character,
  /// such as `-` for `' - '`, advances focus.
  final String delimiter;

  /// The text of each segment at start.
  final List<String>? initialValues;

  /// Called with the text of every segment whenever one changes.
  final ValueChanged<List<String>>? onChanged;

  /// Checks the text of every segment and returns an error message, or
  /// null to accept it.
  final String? Function(List<String> values)? validator;

  /// Whether an entry with every segment empty shows the localized "This
  /// field is required" error.
  final bool required;

  /// The name of the entry in an [Oito2FormErrorSummary].
  final String? labelText;

  /// Whether the field registers with the closest [Oito2Form], taking
  /// part in its validation, error summary and dirty state; true by
  /// default. When false, the field shows its own errors as outside a
  /// form.
  final bool participatesInForm;

  @override
  State<Oito2SegmentedEntry> createState() => _Oito2SegmentedEntryState();
}

/// Owns a controller and a focus node per segment of
/// [Oito2SegmentedEntry] and moves the focus between segments.
class _Oito2SegmentedEntryState extends State<Oito2SegmentedEntry>
    with Oito2FormFieldMixin {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _nodes = [];

  /// Whether the error shows, once the focus left the entry.
  bool _showError = false;

  /// The text of every segment while the entry has no unsaved changes.
  late List<String> _cleanValues;

  @override
  void initState() {
    super.initState();
    _syncSegments();
    _cleanValues = _values;
  }

  /// The text of every segment.
  List<String> get _values => [for (final c in _controllers) c.text];

  @override
  bool get participatesInForm => widget.participatesInForm;

  @override
  String? get formFieldLabel => widget.labelText;

  @override
  FocusNode? get formFieldFocusNode => _nodes.firstOrNull;

  @override
  String? get formFieldError {
    final values = _values;
    if (widget.required && values.every((value) => value.isEmpty)) {
      return Oito2Localizations.of(context).fieldRequired;
    }
    return widget.validator?.call(values);
  }

  @override
  bool get isFormFieldDirty => !listEquals(_values, _cleanValues);

  @override
  void showFormFieldError() {
    if (mounted) setState(() => _showError = true);
  }

  @override
  void markFormFieldClean() => _cleanValues = _values;

  @override
  void resetFormField() {
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < _cleanValues.length ? _cleanValues[i] : '';
    }
    setState(() => _showError = false);
    widget.onChanged?.call(_values);
    notifyFormFieldChanged();
  }

  @override
  void didUpdateWidget(Oito2SegmentedEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSegments();
  }

  /// Keeps one controller and focus node per segment, adding the missing
  /// ones and disposing the extra ones.
  void _syncSegments() {
    final initial = widget.initialValues;
    while (_controllers.length < widget.segments.length) {
      final i = _controllers.length;
      _controllers.add(
        TextEditingController(
          text: initial != null && i < initial.length ? initial[i] : '',
        ),
      );
      _nodes.add(FocusNode(onKeyEvent: (node, event) => _onKey(i, event)));
    }
    while (_controllers.length > widget.segments.length) {
      _controllers.removeLast().dispose();
      _nodes.removeLast().dispose();
    }
  }

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

  /// Moves the focus from the segment at [index] for Backspace in an
  /// empty segment, the arrows at its edges and the delimiter key.
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
    // The segments follow the reading direction, and so do the arrows.
    final (:back, :forward) = readingArrowsOf(context);
    if (key == LogicalKeyboardKey.backspace && controller.text.isEmpty) {
      _focus(index - 1);
      return KeyEventResult.handled;
    }
    if (key == back && atStart && index > 0) {
      _focus(index - 1);
      return KeyEventResult.handled;
    }
    if (key == forward && atEnd && index < _nodes.length - 1) {
      _nodes[index + 1].requestFocus();
      _controllers[index + 1].selection = const TextSelection.collapsed(
        offset: 0,
      );
      return KeyEventResult.handled;
    }
    if (event.character == _advanceCharacter && index < _nodes.length - 1) {
      _nodes[index + 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// The character that advances focus: the first non-blank character of
  /// the delimiter, or the delimiter itself when it is blank.
  String get _advanceCharacter {
    final visible = widget.delimiter.trim();
    return visible.isEmpty ? widget.delimiter : visible[0];
  }

  /// Advances to the next segment when the one at [index] is full and
  /// reports every segment's text.
  void _onChanged(int index, String text) {
    if (text.length >= widget.segments[index].length) _focus(index + 1);
    widget.onChanged?.call(_values);
    // Rebuilds so a shown error follows the text.
    setState(() {});
    notifyFormFieldChanged();
  }

  /// The measured segment widths, by digit count, for [_widthsKey].
  final Map<int, double> _widths = {};

  /// The text style and scaler the cached widths were measured with.
  Object? _widthsKey;

  /// Returns the field width that fits as many digits as [segment] holds,
  /// plus the padding, measured once per length, style and text scale.
  double _segmentWidth(BuildContext context, Oito2EntrySegment segment) {
    final style = Theme.of(context).textTheme.bodyLarge;
    final scaler = MediaQuery.textScalerOf(context);
    final key = (style, scaler);
    if (key != _widthsKey) {
      _widthsKey = key;
      _widths.clear();
    }
    return _widths.putIfAbsent(segment.length, () {
      final painter = TextPainter(
        text: TextSpan(text: '0' * segment.length, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width + Oito2Spacing.md * 2 + 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = _showError || formShowsErrors ? formFieldError : null;
    final row = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: (focused) {
        if (!focused) setState(() => _showError = true);
      },
      child: _segmentsRow(context),
    );
    if (error == null) return row;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: Oito2Spacing.md,
            top: Oito2Spacing.xs,
          ),
          child: Semantics(
            liveRegion: true,
            child: Text(
              error,
              style:
                  theme.inputDecorationTheme.errorStyle ??
                  theme.textTheme.bodySmall?.copyWith(
                    color: semanticColorsOf(context).errorText,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the segments with the delimiters between them.
  Widget _segmentsRow(BuildContext context) {
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
          Oito2TouchTarget(
            child: SizedBox(
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
                        RegExp(RegExp.escape(_advanceCharacter)),
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
          ),
        ],
      ],
    );
  }
}
