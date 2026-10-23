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

import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';

import '../icons/animated_icons.dart';
import '../l10n/oito2_localizations.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// A row of [max] stars showing [value], which the user can change by
/// clicking, tapping or with the keyboard.
///
/// With [allowHalf] the value moves in halves: the start half of a star
/// gives the half value. Hovering previews the value under the pointer.
/// The arrow keys change the value by one step, Home and End jump to 0
/// and [max], and the digit keys 0 to 9 pick that whole value, up to
/// [max]. A star animates when
/// it fills. Assistive technologies see it as a slider.
class Oito2Rating extends StatefulWidget {
  /// Creates a rating.
  ///
  /// Throws an [AssertionError] in debug mode when [max] is not greater
  /// than zero or [value] is outside 0 to [max].
  const Oito2Rating({
    super.key,
    required this.value,
    required this.onChanged,
    this.max = 5,
    this.allowHalf = false,
    this.size = 24,
    this.color,
    this.semanticLabel,
  }) : assert(max > 0),
       assert(value >= 0 && value <= max);

  /// The current value, from 0 to [max].
  final double value;

  /// Called with each new value; the rating is read-only when null.
  final ValueChanged<double>? onChanged;

  /// The number of stars.
  final int max;

  /// Whether half values can be picked.
  final bool allowHalf;

  /// The star size.
  final double size;

  /// The filled star color; defaults to the theme's warning color.
  final Color? color;

  /// The accessibility label, such as what is rated.
  final String? semanticLabel;

  @override
  State<Oito2Rating> createState() => _Oito2RatingState();
}

class _Oito2RatingState extends State<Oito2Rating> {
  double? _hover;
  final _focusNode = FocusNode(debugLabel: 'Oito2Rating');
  NumberFormat? _wholeFormat;
  NumberFormat? _halfFormat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    _wholeFormat = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    );
    _halfFormat = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  double get _step => widget.allowHalf ? 0.5 : 1;

  bool get _enabled => widget.onChanged != null;

  /// [value] aligned to the rating step, so 3.7 reads 3.5 or 4.
  double _aligned(double value) => (value / _step).round() * _step;

  /// Steps from the aligned value, so a value between steps moves to the
  /// next one instead of by a whole step past it.
  void _stepBy(int steps) => _set(_aligned(widget.value) + steps * _step);

  /// Aligns [value] to the step, clamps it between 0 and the maximum, and
  /// reports it when it differs from the current value.
  void _set(double value) {
    final next = _aligned(value).clamp(0, widget.max).toDouble();
    if (next != widget.value) widget.onChanged?.call(next);
  }

  /// The value at [dx] pixels from the start of the row.
  double _valueAt(double dx) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final width = widget.size * widget.max;
    final position = (rtl ? width - dx : dx).clamp(0.0, width - 0.001);
    final star = position / widget.size;
    final whole = star.floor();
    final half = widget.allowHalf && star - whole < 0.5;
    return whole + (half ? 0.5 : 1);
  }

  /// The localized accessibility text of [value] out of the maximum.
  String _format(double value) {
    final format = value % 1 == 0 ? _wholeFormat! : _halfFormat!;
    return Oito2Localizations.of(context)
        .ratingValue(format.format(value), widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final filled = widget.color ?? semanticColorsOf(context).warning;
    final shown = _hover ?? widget.value;
    final step = _step;

    Widget star(int index) {
      final fill = (shown - index).clamp(0.0, 1.0);
      final data = fill >= 1
          ? Oito2AnimatedIcons.starFilled
          : fill >= 0.5
          ? Oito2AnimatedIcons.starHalfFilled
          : Oito2AnimatedIcons.star;
      final icon = Oito2AnimatedIcon(
        data,
        key: ValueKey((index, data)),
        size: widget.size,
        color: fill > 0 ? filled : scheme.outline,
        mode: _hover != null || data == Oito2AnimatedIcons.star
            ? Oito2AnimationMode.still
            : Oito2AnimationMode.once,
      );
      return rtl && data == Oito2AnimatedIcons.starHalfFilled
          ? Transform.flip(flipX: true, child: icon)
          : icon;
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 0; i < widget.max; i++) star(i)],
    );
    if (!_enabled) {
      return Semantics(
        label: widget.semanticLabel,
        value: _format(widget.value),
        child: ExcludeSemantics(child: row),
      );
    }
    final (:back, :forward) = readingArrowsOf(context);
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: _format(widget.value),
      increasedValue: _format(
        (_aligned(widget.value) + step).clamp(0, widget.max).toDouble(),
      ),
      decreasedValue: _format(
        (_aligned(widget.value) - step).clamp(0, widget.max).toDouble(),
      ),
      onIncrease: () => _stepBy(1),
      onDecrease: () => _stepBy(-1),
      child: CallbackShortcuts(
        bindings: {
          SingleActivator(forward): () => _stepBy(1),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => _stepBy(1),
          SingleActivator(back): () => _stepBy(-1),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
              _stepBy(-1),
          const SingleActivator(LogicalKeyboardKey.home): () => _set(0),
          const SingleActivator(LogicalKeyboardKey.end): () =>
              _set(widget.max.toDouble()),
          for (var n = 0; n <= widget.max && n <= 9; n++)
            SingleActivator(
              LogicalKeyboardKey(LogicalKeyboardKey.digit0.keyId + n),
            ): () =>
                _set(n.toDouble()),
        },
        child: Oito2FocusBorder(
          borderRadius: BorderRadius.circular(4),
          child: Focus(
            focusNode: _focusNode,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (event) =>
                  setState(() => _hover = _valueAt(event.localPosition.dx)),
              onExit: (_) => setState(() => _hover = null),
              child: GestureDetector(
                onTapUp: (details) {
                  // A click focuses the stars, so the keys work next.
                  _focusNode.requestFocus();
                  setState(() => _hover = null);
                  _set(_valueAt(details.localPosition.dx));
                },
                child: ExcludeSemantics(child: row),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
