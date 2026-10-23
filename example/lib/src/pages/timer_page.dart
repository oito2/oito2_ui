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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2TimerController] as a stopwatch and a countdown.
class TimerPage extends StatefulWidget {
  /// Creates the timer page.
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final _stopwatch = Oito2TimerController(
    interval: const Duration(milliseconds: 100),
  );
  late final _countdown = Oito2TimerController(
    countdown: const Duration(seconds: 10),
    onComplete: () =>
        Oito2Toaster.maybeOf(context)
            ?.show(const Oito2Toast(title: "Time's up")),
  );

  @override
  void dispose() {
    _stopwatch.dispose();
    _countdown.dispose();
    super.dispose();
  }

  /// The time of [timer], with tenths of a second when [tenths] is true,
  /// and its start, pause and reset buttons.
  Widget _controls(Oito2TimerController timer, {bool tenths = false}) {
    final style = Theme.of(context).textTheme.displaySmall;
    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Oito2Spacing.md,
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

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Stopwatch',
          children: [_controls(_stopwatch, tenths: true)],
        ),
        ShowcaseSection(
          '10-second countdown',
          children: [_controls(_countdown)],
        ),
      ],
    );
  }
}
