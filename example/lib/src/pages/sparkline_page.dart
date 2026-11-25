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

import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

/// The memory use of a machine every hour of a day, in percent.
const _memoryByHour = <double>[
  41, 40, 38, 37, 37, 38, 44, 52, 61, 66, 68, 71, //
  73, 70, 69, 72, 75, 78, 74, 66, 58, 51, 46, 43,
];

/// The processor load of the same day, in percent.
const _cpuByHour = <double>[
  12, 9, 8, 7, 7, 9, 18, 34, 55, 62, 58, 64, //
  70, 48, 52, 66, 81, 88, 69, 44, 30, 22, 17, 14,
];

/// Documents [Oito2Sparkline]: a live transfer speed, usage over a day,
/// the line, area and bar variants, markers, tones and edge cases.
class SparklinePage extends StatefulWidget {
  /// Creates the sparkline page.
  const SparklinePage({super.key});

  @override
  State<SparklinePage> createState() => _SparklinePageState();
}

class _SparklinePageState extends State<SparklinePage> {
  // #region live-data
  /// The seconds of history the transfer speed keeps.
  static const _window = 30;

  final _random = math.Random(8);
  Timer? _timer;

  /// The download speed of the last [_window] seconds, in bytes a second.
  final _speeds = <double>[
    for (var i = 0; i < _window; i++) 4e6 + 2e6 * math.sin(i / 4),
  ];

  /// Adds the speed of the last second and drops the oldest one.
  void _tick(Timer _) {
    final previous = _speeds.last;
    final next = (previous + (_random.nextDouble() - 0.5) * 2e6).clamp(
      0.5e6,
      12e6,
    );
    setState(() {
      _speeds
        ..removeAt(0)
        ..add(next);
    });
  }

  /// Formats [bytesPerSecond] as a speed of the locale, such as
  /// "4.2 MB/s".
  String _speed(BuildContext context, double bytesPerSecond) =>
      '${Oito2Format.of(context).bytes(bytesPerSecond.round())}/s';
  // #endregion

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Starts or stops the live updates.
  void _toggleLive() {
    setState(() {
      if (_timer == null) {
        _timer = Timer.periodic(const Duration(seconds: 1), _tick);
      } else {
        _timer!.cancel();
        _timer = null;
      }
    });
  }

  /// Formats [percent] as a whole percentage, such as "73%".
  String _percent(BuildContext context, double percent) =>
      '${percent.round()}%';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = _timer != null;
    return DocPage(
      title: 'Sparkline',
      description:
          'A small, static chart of a series of values, such as a transfer '
          'speed or the usage of a resource over time, with a text summary '
          'for screen readers.',
      source: 'lib/src/pages/sparkline_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2Sparkline(
            values: [3, 5, 4, 8, 6, 9, 7, 12, 10, 11],
            width: 200,
            height: 40,
            showLast: true,
            semanticsLabel: 'Requests a minute',
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Sparkline` draws `values`, oldest first, evenly spaced '
          'from the start edge to the end edge, as a `line`, an `area` or '
          '`bars` (`type`). The vertical range runs from the lowest to the '
          'highest value, or from `min` to `max` when they are set; bars '
          'also include zero. `showMin`, `showMax` and `showLast` mark '
          'those values with a dot. The color is the primary color, a '
          'semantic `tone` (`Oito2InfoType`) or an explicit `color`. Without '
          '`width`, the sparkline fills the width it gets (120 pixels when '
          'unbounded); `height` defaults to 32.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Live transfer speed', level: 3),
        const DocText(
          'A timer adds the speed of each second and drops the oldest one. '
          'The sparkline only redraws: it doesn\'t animate value changes. '
          '`formatValue` formats the values of the summary as speeds.',
        ),
        ExamplePanel(
          region: 'live',
          regions: const ['live-data'],
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Download',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Text(_speed(context, _speeds.last)),
                  ],
                ),
                // #region live
                Oito2Sparkline(
                  values: _speeds,
                  type: Oito2SparklineType.area,
                  height: 48,
                  showLast: true,
                  min: 0,
                  semanticsLabel: 'Download speed',
                  formatValue: _speed,
                ),
                // #endregion
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    onPressed: _toggleLive,
                    icon: Icon(live ? LucideIcons.pause : LucideIcons.play),
                    label: Text(live ? 'Pause' : 'Resume'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const DocHeading('Usage over a day', level: 3),
        const DocText(
          'Hourly memory and processor use with fixed 0 to 100% ranges, '
          'so both read on the same scale. The bars mark the busiest hour.',
        ),
        ExamplePanel(
          region: 'usage',
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.md,
              children: [
                for (final (title, values, type) in const [
                  ('Memory', _memoryByHour, Oito2SparklineType.line),
                  ('Processor', _cpuByHour, Oito2SparklineType.bars),
                ])
                  Row(
                    spacing: Oito2Spacing.md,
                    children: [
                      SizedBox(width: 80, child: Text(title)),
                      // #region usage
                      Expanded(
                        child: Oito2Sparkline(
                          values: values,
                          type: type,
                          min: 0,
                          max: 100,
                          showMax: true,
                          semanticsLabel: title,
                          formatValue: _percent,
                        ),
                      ),
                      // #endregion
                      SizedBox(
                        width: 48,
                        child: Text(
                          _percent(context, values.last),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const DocHeading('Variants, markers and tones', level: 3),
        const DocText(
          'The tones follow `Oito2InfoType` and are raised to 3:1 against '
          'the surface. Negative values grow down from zero.',
        ),
        const ExamplePanel(
          region: 'variants',
          child: Wrap(
            spacing: Oito2Spacing.xl,
            runSpacing: Oito2Spacing.lg,
            children: [
              // #region variants
              Oito2Sparkline(
                values: [3, 5, 4, 8, 6, 9, 7, 12, 10, 11, 6, 9],
                width: 160,
                height: 40,
                showMin: true,
                showMax: true,
                showLast: true,
              ),
              Oito2Sparkline(
                values: [3, 5, 4, 8, 6, 9, 7, 12, 10, 11, 6, 9],
                type: Oito2SparklineType.area,
                tone: Oito2InfoType.success,
                width: 160,
                height: 40,
              ),
              Oito2Sparkline(
                values: [2, -1, 3, -4, 1, -2, 5, 0],
                type: Oito2SparklineType.bars,
                tone: Oito2InfoType.danger,
                width: 160,
                height: 40,
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Edge cases', level: 3),
        const DocText(
          'Values that aren\'t finite (NaN and the infinities) are skipped: '
          'the line joins the values around them. One value draws a dot, '
          'equal values a flat line, and no values nothing, read as "No '
          'data".',
        ),
        const ExamplePanel(
          region: 'edge-cases',
          child: Wrap(
            spacing: Oito2Spacing.xl,
            runSpacing: Oito2Spacing.lg,
            children: [
              // #region edge-cases
              Oito2Sparkline(
                values: [4, 6, double.nan, 3, 7, double.infinity, 5],
                width: 120,
              ),
              Oito2Sparkline(values: [7], width: 120, showLast: true),
              Oito2Sparkline(values: [5, 5, 5, 5], width: 120),
              Oito2Sparkline(values: [], width: 120),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The sparkline is one image node that reads a summary: the '
          'minimum, maximum and last values and the trend, after '
          '`semanticsLabel`, such as "Download speed, Minimum 1.2 MB/s, '
          'maximum 8 MB/s, last 6.5 MB/s, rising" or, in Portuguese, '
          '"Mínimo 1,2 MB/s, máximo 8 MB/s, último valor 6,5 MB/s, em '
          'alta". One value reads "Value 5"; no values, "No data". The '
          'trend compares the last value with the first: rising or falling '
          'when they differ by more than `trendThreshold` (a tenth of the '
          'range by default), steady otherwise. It isn\'t interactive and '
          'doesn\'t take focus.',
        ),
        const DocText(
          '`Oito2SparklineStats.of` computes the same minimum, maximum, '
          'last value and trend for a list, and `describe` writes the '
          'summary, for a text next to the chart or a table.',
        ),
        ...apiReferenceWidgets([
          'Oito2Sparkline',
          'Oito2SparklineType',
          'Oito2SparklineStats',
          'Oito2SparklineTrend',
        ]),
      ],
    );
  }
}
