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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2Format]: byte sizes, compact numbers and relative times
/// in the app language.
class FormatPage extends StatelessWidget {
  /// Creates the format page.
  const FormatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // #region usage
    final format = Oito2Format.of(context);
    // #endregion
    final now = DateTime.now();
    // #region portuguese-data
    final portuguese = Oito2Format(
      locale: 'pt_BR',
      strings: const Oito2LocalizationsPtBr(),
    );
    // #endregion
    Widget row(String input, String output) => SizedBox(
      width: 360,
      child: Row(
        spacing: Oito2Spacing.md,
        children: [
          Expanded(child: Text(input, overflow: TextOverflow.ellipsis)),
          Text(output, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
    return DocPage(
      title: 'Format',
      description:
          'Formats byte sizes, compact numbers and relative times in the '
          'locale and language of the app.',
      source: 'lib/src/pages/format_page.dart',
      children: [
        ExamplePanel(
          regions: const ['usage', 'preview'],
          // #region preview
          child: Column(
            spacing: Oito2Spacing.xs,
            children: [
              Text(format.bytes(1536)),
              Text(format.compactNumber(1234)),
              Text(
                format.relativeTime(
                  now.subtract(const Duration(minutes: 3)),
                  now: now,
                ),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Format.of(context)` creates a formatter for the locale and '
          'the `Oito2Localizations` of the context, with English when the '
          'context has no locale. Numbers follow the locale through `intl`; '
          'relative times use the localized strings, so switching the app '
          'language switches every output.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          '`Oito2Format` covers sizes, compact numbers and relative times '
          'only. Format plain numbers, dates and times with `intl` '
          'directly.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Byte sizes', level: 3),
        const DocText(
          '`bytes` picks the largest unit, up to petabytes, that keeps the '
          'value at least 1, with at most one decimal; counts below one '
          'kilobyte keep no decimals. Units are powers of 1000 by default.',
        ),
        ExamplePanel(
          region: 'bytes',
          // #region bytes
          child: Column(
            children: [
              for (final bytes in [512, 1536, 2500000, 7340032000])
                row('$bytes bytes', format.bytes(bytes)),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Binary units and decimals', level: 3),
        const DocText(
          '`units: Oito2ByteUnits.iec` uses powers of 1024 and the KiB, '
          'MiB and GiB names. `fractionDigits` sets the largest number of '
          'decimals.',
        ),
        ExamplePanel(
          region: 'iec',
          // #region iec
          child: Column(
            children: [
              row(
                '1536 bytes, IEC units',
                format.bytes(1536, units: Oito2ByteUnits.iec),
              ),
              row(
                '1234567 bytes, 2 decimals',
                format.bytes(1234567, fractionDigits: 2),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Compact numbers', level: 3),
        const DocText(
          '`compactNumber` shortens a number to three significant digits '
          'with a locale suffix, such as "1.23K".',
        ),
        ExamplePanel(
          region: 'compact',
          // #region compact
          child: Column(
            children: [
              for (final value in [999, 1234, 56789, 1250000])
                row('$value', format.compactNumber(value)),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Relative time', level: 3),
        const DocText(
          '`relativeTime` describes a time against `now`, the current time '
          'by default, such as "3 minutes ago" or "in 2 days". Differences '
          'within 45 seconds read as now; larger ones round to minutes, '
          'hours, days, weeks, months of 30 days or years.',
        ),
        ExamplePanel(
          region: 'relative',
          // #region relative
          child: Column(
            children: [
              for (final offset in const [
                Duration(seconds: -20),
                Duration(minutes: -3),
                Duration(hours: 5),
                Duration(days: -2),
                Duration(days: 40),
                Duration(days: -800),
              ])
                row('$offset', format.relativeTime(now.add(offset), now: now)),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Outside widgets', level: 3),
        const DocText(
          'Without a context, create the formatter with a `locale`, such as '
          '`pt_BR`, and the relative-time `strings`. Locales `intl` doesn\'t '
          'know fall back to English number formats.',
        ),
        ExamplePanel(
          regions: const ['portuguese-data', 'portuguese'],
          // #region portuguese
          child: Column(
            children: [
              row('1536 bytes', portuguese.bytes(1536)),
              row('1234', portuguese.compactNumber(1234)),
            ],
          ),
          // #endregion
        ),
        ...apiReferenceWidgets(['Oito2Format', 'Oito2ByteUnits']),
      ],
    );
  }
}
