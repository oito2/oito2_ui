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
/// [pageStep], Home and End jump to [min] and [max]. With the focus in
/// the field the mouse wheel steps too, and dragging sideways on the
/// buttons scrubs the value one [step] per 4 pixels.
class Oito2NumberEntry extends StatefulWidget {
  /// Creates a number entry.
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
       assert(decimals >= 0);

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

  /// The number of decimal places shown and kept.
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

class _Oito2NumberEntryState extends State<Oito2NumberEntry> {
  final _controller = TextEditingController();
  FocusNode? _ownFocusNode;
  NumberFormat? _format;
  double _scrub = 0;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  bool get _enabled => widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _format = NumberFormat.decimalPatternDigits(
      locale: Localizations.maybeLocaleOf(context)?.toString(),
      decimalDigits: widget.decimals,
    );
    _show(widget.value);
  }

  @override
  void didUpdateWidget(Oito2NumberEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocus);
      _focusNode.addListener(_onFocus);
    }
    if (oldWidget.decimals != widget.decimals) didChangeDependencies();
    if (oldWidget.value != widget.value) _show(widget.value);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _ownFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _show(double value) {
    final text = _format!.format(value);
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  double? _parse() {
    final number = _format?.tryParse(_controller.text.trim());
    return number?.toDouble();
  }

  double _normalize(double value) {
    final rounded = double.parse(value.toStringAsFixed(widget.decimals));
    return rounded.clamp(widget.min, widget.max);
  }

  void _commit() {
    final parsed = _parse();
    if (parsed == null || !_enabled) {
      _show(widget.value);
      return;
    }
    _set(parsed);
  }

  void _set(double value) {
    final next = _normalize(value);
    _show(next);
    if (next != widget.value) widget.onChanged?.call(next);
  }

  void _stepBy(double delta) {
    if (!_enabled) return;
    _set((_parse() ?? widget.value) + delta);
  }

  void _onFocus() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _onScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_focusNode.hasFocus) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _stepBy(event.scrollDelta.dy < 0 ? widget.step : -widget.step);
    });
  }

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
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-+\s ]')),
          ],
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
