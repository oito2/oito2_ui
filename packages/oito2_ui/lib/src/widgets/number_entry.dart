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

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import 'widget_helpers.dart';

/// A number field with decrease and increase buttons, like a GNOME spin
/// button.
///
/// It shows [value] in the locale's number format with [decimals]
/// decimal places. Typed text is read when the field loses focus or on
/// Enter, rounded, kept between [min] and [max], and reported through
/// [onChanged]; text that isn't a number is replaced by the current
/// value.
///
/// The arrow keys change the value by [step], Page Up and Page Down by
/// [pageStep], Home and End jump to [min] and [max] when they are finite.
/// With the focus in
/// the field the mouse wheel steps too, and dragging sideways on the
/// buttons scrubs the value one [step] per 4 pixels.
class Oito2NumberEntry extends StatefulWidget {
  /// Creates a number entry.
  ///
  /// [pageStep] defaults to ten times [step]. Throws an [AssertionError] in
  /// debug mode when [min] is greater than [max], when [step] is not
  /// greater than zero, or when [decimals] is not between 0 and 20.
  const Oito2NumberEntry({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = double.negativeInfinity,
    this.max = double.infinity,
    this.step = 1,
    double? pageStep,
    this.decimals = 0,
    this.labelText,
    this.hintText,
    this.focusNode,
    this.autofocus = false,
  }) : pageStep = pageStep ?? step * 10,
       assert(min <= max),
       assert(step > 0),
       assert(decimals >= 0 && decimals <= 20);

  /// The current value.
  final double value;

  /// Called with each new value; the entry is read-only when null.
  final ValueChanged<double>? onChanged;

  /// The smallest value.
  final double min;

  /// The largest value.
  final double max;

  /// The change of the arrow keys, the buttons and the wheel.
  final double step;

  /// The change of Page Up and Page Down; ten steps by default.
  final double pageStep;

  /// The number of decimal places shown and kept, from 0 to 20.
  final int decimals;

  /// The field label.
  final String? labelText;

  /// The hint shown while the field is empty.
  final String? hintText;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the field takes the focus when shown.
  final bool autofocus;

  @override
  State<Oito2NumberEntry> createState() => _Oito2NumberEntryState();
}

class _Oito2NumberEntryState extends State<Oito2NumberEntry>
    with OwnedFocusNodeMixin {
  final _controller = TextEditingController();
  NumberFormat? _format;
  double _scrub = 0;

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  FocusNode get _focusNode => effectiveFocusNode;

  bool get _enabled => widget.onChanged != null;

  /// Builds the number format of the locale and [Oito2NumberEntry.decimals].
  void _updateFormat() {
    _format = NumberFormat.decimalPatternDigits(
      locale: Localizations.maybeLocaleOf(context)?.toString(),
      decimalDigits: widget.decimals,
    );
  }

  /// Reformats the value when the locale changes, unless the text is being
  /// edited.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFormat();
    if (!_focusNode.hasFocus) _show(widget.value);
  }

  @override
  void didUpdateWidget(Oito2NumberEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    final decimalsChanged = oldWidget.decimals != widget.decimals;
    if (decimalsChanged) _updateFormat();
    if (decimalsChanged || oldWidget.value != widget.value) {
      _show(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Shows [value] formatted in the field, keeping the text when it is
  /// already the same.
  void _show(double value) {
    final text = _format!.format(value);
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  /// Allows ASCII and locale digits, the separators and signs of
  /// [_format], and white space, which includes the no-break spaces some
  /// locales group digits with.
  TextInputFormatter? get _filter {
    final format = _format;
    if (format == null) return null;
    final symbols = format.symbols;
    final zero = symbols.ZERO_DIGIT.codeUnitAt(0);
    final allowed = [
      '0123456789',
      String.fromCharCodes([for (var i = 0; i < 10; i++) zero + i]),
      symbols.DECIMAL_SEP,
      symbols.GROUP_SEP,
      symbols.MINUS_SIGN,
      symbols.PLUS_SIGN,
      '-+',
    ].join();
    // Each character is escaped on its own, so a sign such as '-' is
    // literal inside the character class.
    final escaped = [
      for (final c in allowed.runes) '\\u{${c.toRadixString(16)}}',
    ].join();
    return FilteringTextInputFormatter.allow(
      RegExp('[$escaped\\s]', unicode: true),
    );
  }

  /// Returns the number typed in the field, or null when the text is not a
  /// number in the locale's format.
  double? _parse() {
    final number = _format?.tryParse(_controller.text.trim());
    return number?.toDouble();
  }

  /// Rounds [value] to the decimal places and clamps it between the
  /// bounds.
  double _normalize(double value) {
    final rounded = double.parse(value.toStringAsFixed(widget.decimals));
    return rounded.clamp(widget.min, widget.max);
  }

  /// Applies the typed text, or restores the current value when the text
  /// is not a number or the entry is read-only.
  void _commit() {
    final parsed = _parse();
    if (parsed == null || !_enabled) {
      _show(widget.value);
      return;
    }
    _set(parsed);
  }

  /// Normalizes and shows [value], reporting it when it differs from the
  /// current value.
  void _set(double value) {
    final next = _normalize(value);
    _show(next);
    if (next != widget.value) widget.onChanged?.call(next);
  }

  /// Adds [delta] to the typed number, or to the current value when the
  /// text is not a number.
  void _stepBy(double delta) {
    if (!_enabled) return;
    _set((_parse() ?? widget.value) + delta);
  }

  @override
  void onEffectiveFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  /// Steps the value on a vertical mouse wheel scroll while the field has
  /// the focus; sideways scrolls are left to the enclosing widgets.
  void _onScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        !_focusNode.hasFocus ||
        event.scrollDelta.dy == 0) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _stepBy(event.scrollDelta.dy < 0 ? widget.step : -widget.step);
    });
  }

  /// Accumulates the horizontal drag, mirrored in right-to-left text, and
  /// steps once per 4 pixels.
  void _onScrub(DragUpdateDetails details) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    _scrub += details.delta.dx * (rtl ? -1 : 1);
    while (_scrub.abs() >= 4) {
      final up = _scrub > 0;
      _scrub += up ? -4 : 4;
      _stepBy(up ? widget.step : -widget.step);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final value = _parse() ?? widget.value;
    final buttons = GestureDetector(
      onHorizontalDragStart: _enabled ? (_) => _scrub = 0 : null,
      onHorizontalDragUpdate: _enabled ? _onScrub : null,
      child: MouseRegion(
        cursor: _enabled
            ? SystemMouseCursors.resizeLeftRight
            : MouseCursor.defer,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FieldIconButton(
              icon: LucideIcons.minus,
              tooltip: strings.decrease,
              onPressed: _enabled && value > widget.min
                  ? () => _stepBy(-widget.step)
                  : null,
            ),
            FieldIconButton(
              icon: LucideIcons.plus,
              tooltip: strings.increase,
              onPressed: _enabled && value < widget.max
                  ? () => _stepBy(widget.step)
                  : null,
            ),
          ],
        ),
      ),
    );
    return Listener(
      onPointerSignal: _onScroll,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
              _stepBy(widget.step),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
              _stepBy(-widget.step),
          const SingleActivator(LogicalKeyboardKey.pageUp): () =>
              _stepBy(widget.pageStep),
          const SingleActivator(LogicalKeyboardKey.pageDown): () =>
              _stepBy(-widget.pageStep),
          if (widget.min.isFinite)
            const SingleActivator(LogicalKeyboardKey.home): () =>
                _set(widget.min),
          if (widget.max.isFinite)
            const SingleActivator(LogicalKeyboardKey.end): () =>
                _set(widget.max),
        },
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          readOnly: !_enabled,
          textAlign: TextAlign.end,
          keyboardType: TextInputType.numberWithOptions(
            signed: widget.min < 0,
            decimal: widget.decimals > 0,
          ),
          inputFormatters: [?_filter],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _commit(),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            suffixIcon: buttons,
          ),
        ),
      ),
    );
  }
}
