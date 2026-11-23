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

import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';

import '../format/format.dart';
import '../l10n/oito2_localizations.dart';
import 'info.dart';
import 'progress.dart';
import 'widget_helpers.dart';

/// A bar that shows how much of a quota is used, such as the storage of
/// an account, with a title and a "1.2 GB of 15 GB" label.
///
/// The bar fills by [value] over [total]. From [warningAt] of the total it
/// turns to the warning tone, and from [dangerAt] to the danger tone, as
/// does the label; above the total (over quota) the bar stays full in the
/// danger tone. The [compact] variant puts a thin bar over one line of
/// small text, for navigation rails and side panes.
///
/// Assistive technologies read the title and the label, with the used
/// percentage as the value.
class Oito2UsageBar extends StatelessWidget {
  /// Creates a usage bar of [value] over [total]; with the default total
  /// of 1, [value] is a fraction and the label is a percentage.
  const Oito2UsageBar({
    super.key,
    required this.value,
    this.total = 1,
    this.title,
    this.label,
    this.formatValue,
    this.warningAt = 0.7,
    this.dangerAt = 0.9,
    this.compact = false,
    this.semanticsLabel,
  }) : byteUnits = null;

  /// Creates a usage bar of [used] over [total] bytes, labelled with
  /// [Oito2Format.bytes] in [units] for the locale, such as "1.2 GB of
  /// 15 GB".
  const Oito2UsageBar.bytes({
    super.key,
    required int used,
    required int total,
    Oito2ByteUnits units = Oito2ByteUnits.si,
    this.title,
    this.label,
    this.warningAt = 0.7,
    this.dangerAt = 0.9,
    this.compact = false,
    this.semanticsLabel,
  }) : value = used + 0.0,
       total = total + 0.0,
       byteUnits = units,
       formatValue = null;

  /// The amount used.
  final double value;

  /// The quota; [value] is a fraction when it is 1.
  final double total;

  /// The name of what is measured, such as an account or a drive, usually
  /// a [Text].
  final Widget? title;

  /// Replaces the "X of Y" label, usually a [Text].
  final Widget? label;

  /// Formats [value] and [total] in the default label; when null, a
  /// fraction shows as a percentage and other totals as locale numbers.
  final String Function(BuildContext context, double amount)? formatValue;

  /// The byte units of a bar made with [Oito2UsageBar.bytes], or null.
  final Oito2ByteUnits? byteUnits;

  /// The used fraction from which the bar shows the warning tone.
  final double warningAt;

  /// The used fraction from which the bar shows the danger tone.
  final double dangerAt;

  /// Whether the bar is thin with one line of small text below.
  final bool compact;

  /// The accessibility label; defaults to the text of [title] and the
  /// label.
  final String? semanticsLabel;

  /// Returns the used fraction, 0 when [total] isn't positive; above 1
  /// when over quota.
  double get fraction => total <= 0 ? 0 : value / total;

  /// Returns the tone of the fraction: danger from [dangerAt] or over
  /// quota, warning from [warningAt], and null below.
  Oito2InfoType? get tone {
    final fraction = this.fraction;
    if (fraction > 1 || fraction >= dangerAt) return Oito2InfoType.danger;
    if (fraction >= warningAt) return Oito2InfoType.warning;
    return null;
  }

  /// Returns [amount] as text for the default label.
  String _format(BuildContext context, double amount) {
    final formatValue = this.formatValue;
    if (formatValue != null) return formatValue(context, amount);
    final units = byteUnits;
    if (units != null) {
      return Oito2Format.of(context).bytes(amount.round(), units: units);
    }
    final locale = Oito2Format.of(context).locale;
    return NumberFormat.decimalPattern(locale).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final locale = Oito2Format.of(context).locale;
    final tone = this.tone;
    final percent = NumberFormat.percentPattern(locale)
        .format(fraction.isFinite ? fraction : 0);
    final text = total == 1 && formatValue == null && byteUnits == null
        ? percent
        : strings.usageOf(_format(context, value), _format(context, total));
    final barColor = tone?.colorIn(semanticColorsOf(context));
    final labelColor = tone == null
        ? scheme.onSurfaceVariant
        : infoColorsOf(context, tone, 0).$2;
    final title = this.title;
    final labelWidget = DefaultTextStyle.merge(
      style: (compact ? theme.textTheme.labelSmall : theme.textTheme.bodySmall)
          ?.copyWith(color: labelColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: label ?? Text(text),
    );
    final titleWidget = title == null
        ? null
        : DefaultTextStyle.merge(
            style: compact
                ? theme.textTheme.labelSmall?.copyWith(color: scheme.onSurface)
                : theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: title,
          );
    final bar = ExcludeSemantics(
      child: Oito2LinearProgressIndicator(
        value: fraction.isFinite ? fraction.clamp(0, 1).toDouble() : 0,
        color: barColor,
        height: compact ? 4 : null,
      ),
    );
    final texts = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        if (titleWidget != null) Flexible(child: titleWidget),
        // The amount keeps more room than the title when both are long.
        Flexible(flex: 3, child: labelWidget),
      ],
    );
    return MergeSemantics(
      child: Semantics(
        label: semanticsLabel,
        value: percent,
        excludeSemantics: semanticsLabel != null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: compact ? 4 : 6,
          children: compact ? [bar, texts] : [texts, bar],
        ),
      ),
    );
  }
}
