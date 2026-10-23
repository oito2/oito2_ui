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

/// Documents [Oito2TimerController] and [Oito2TimerText] as a stopwatch
/// and a countdown, and [oito2FormatDuration].
class TimerPage extends StatefulWidget {
  /// Creates the timer page.
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  // #region stopwatch-data
  final _stopwatch = Oito2TimerController(
    interval: const Duration(milliseconds: 100),
  );
  // #endregion
  // #region countdown-data
  late final _countdown = Oito2TimerController(
    countdown: const Duration(seconds: 10),
    onComplete: () =>
        Oito2Toaster.maybeOf(context)
            ?.show(const Oito2Toast(title: "Time's up")),
  );
  // #endregion

  @override
  void dispose() {
    _stopwatch.dispose();
    _countdown.dispose();
    super.dispose();
  }

  // #region controls
  /// The time of [timer], with tenths of a second when [tenths] is true,
  /// and its start, pause and reset buttons.
  Widget _controls(Oito2TimerController timer, {bool tenths = false}) {
    final style = Theme.of(context).textTheme.displaySmall;
    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) => Wrap(
        spacing: Oito2Spacing.md,
        runSpacing: Oito2Spacing.sm,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: Oito2TimerText(
              controller: timer,
              style: style,
              tenths: tenths,
            ),
          ),
          FilledButton(
            onPressed: timer.isCompleted
                ? null
                : timer.isRunning
                ? timer.pause
                : timer.start,
            child: Text(timer.isRunning ? 'Pause' : 'Start'),
          ),
          OutlinedButton(onPressed: timer.reset, child: const Text('Reset')),
        ],
      ),
    );
  }
  // #endregion

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Timer',
      description:
          'A stopwatch or a countdown that keeps exact time, and a text that '
          'shows it.',
      source: 'lib/src/pages/timer_page.dart',
      children: [
        ExamplePanel(
          regions: const ['stopwatch-data', 'controls', 'preview'],
          // #region preview
          child: _controls(_stopwatch, tenths: true),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2TimerController` is a stopwatch that notifies its listeners '
          'every `interval` while it runs, one second by default. `start` '
          'starts or resumes it, `pause` keeps the time run so far, `reset` '
          'sets it back to zero and `restart` resets and starts it. '
          '`elapsed`, `isRunning` and `isCompleted` describe its state. '
          'Dispose of it with the state that owns it.',
        ),
        const DocText(
          'Time is measured from a monotonic clock, so it stays exact however '
          'late the ticks arrive and does not jump when the system time '
          'changes. `onTick` receives the elapsed time on every tick.',
        ),
        const DocText(
          '`Oito2TimerText` shows the remaining time of a countdown or the '
          'elapsed time of a stopwatch, in tabular figures so the digits do '
          'not shift; `style` merges over them.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Countdown', level: 3),
        const DocText(
          'With `countdown`, the timer counts that length down, stops by '
          'itself at zero and calls `onComplete`. `remaining` gives the time '
          'left. A completed countdown does not start again until `reset` or '
          '`restart`. Without `tenths`, the text rounds up to the whole '
          'second, so it shows 0:00 only at the end.',
        ),
        ExamplePanel(
          regions: const ['countdown-data', 'countdown'],
          // #region countdown
          child: _controls(_countdown),
          // #endregion
        ),
        const DocHeading('Formatting a duration', level: 3),
        const DocText(
          '`oito2FormatDuration` formats a `Duration` as `m:ss`, or `h:mm:ss` '
          'from an hour, with truncated tenths of a second when `tenths` is '
          'set; a negative duration gets a leading minus sign.',
        ),
        ExamplePanel(
          region: 'format',
          // #region format
          child: Text(
            [
              oito2FormatDuration(const Duration(seconds: 75)),
              oito2FormatDuration(const Duration(hours: 1, minutes: 2)),
              oito2FormatDuration(
                const Duration(seconds: 9, milliseconds: 870),
                tenths: true,
              ),
            ].join('  ·  '),
          ),
          // #endregion
        ),
        ...apiReferenceWidgets([
          'Oito2TimerController',
          'Oito2TimerText',
          'oito2FormatDuration',
        ]),
      ],
    );
  }
}
