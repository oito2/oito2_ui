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

import 'package:material_ui/material_ui.dart';

/// A stopwatch, or a countdown when [countdown] is set, that notifies its
/// listeners every [interval] while it runs.
///
/// A countdown stops by itself at zero and calls [onComplete]. Time is
/// measured from the clock [now], so it stays exact however late the ticks
/// arrive; the default clock is monotonic, unaffected by changes to the
/// system time.
class Oito2TimerController extends ChangeNotifier {
  /// Creates a stopped timer at zero.
  ///
  /// [now] overrides the clock time is measured with, for example in tests.
  /// Throws an [AssertionError] in debug builds when [interval] is not
  /// positive.
  Oito2TimerController({
    this.countdown,
    this.interval = const Duration(seconds: 1),
    this.onTick,
    this.onComplete,
    DateTime Function()? now,
  }) : _now = now ?? _monotonicClock(),
       assert(interval > Duration.zero);

  /// Returns a clock that starts at the current time and advances with a
  /// [Stopwatch], so it never jumps with the system time.
  static DateTime Function() _monotonicClock() {
    final origin = DateTime.now();
    final stopwatch = Stopwatch()..start();
    return () => origin.add(stopwatch.elapsed);
  }

  /// The length of a countdown, or null for a stopwatch.
  final Duration? countdown;

  /// How often listeners are notified while the timer runs.
  final Duration interval;

  /// Called with [elapsed] on every tick, including the final tick of a
  /// countdown.
  final ValueChanged<Duration>? onTick;

  /// Called when a countdown reaches zero, after the listeners are
  /// notified.
  final VoidCallback? onComplete;

  final DateTime Function() _now;
  DateTime? _startedAt;
  Duration _offset = Duration.zero;

  /// The time run so far, not clamped to [countdown].
  Duration get _raw =>
      _offset +
      (_startedAt == null ? Duration.zero : _now().difference(_startedAt!));
  Timer? _timer;
  Timer? _completion;
  bool _completed = false;
  bool _disposed = false;

  /// The time run so far, up to [countdown].
  Duration get elapsed {
    final elapsed = _raw;
    final countdown = this.countdown;
    return countdown != null && elapsed > countdown ? countdown : elapsed;
  }

  /// The time left of a countdown, or null for a stopwatch.
  Duration? get remaining => countdown == null ? null : countdown! - elapsed;

  /// Whether the timer is running.
  bool get isRunning => _startedAt != null;

  /// Whether a countdown has reached zero.
  bool get isCompleted => _completed;

  /// Starts or resumes the timer; does nothing while it runs, after a
  /// countdown completes (see [restart]) or once disposed.
  void start() {
    if (_disposed || isRunning || _completed) return;
    _startedAt = _now();
    _timer = Timer.periodic(interval, (_) => _tick());
    // A countdown also ticks exactly when it reaches zero.
    final left = remaining;
    if (left != null) _completion = Timer(left, _tick);
    notifyListeners();
  }

  /// Cancels the periodic tick and the countdown completion timers.
  void _cancelTimers() {
    _timer?.cancel();
    _timer = null;
    _completion?.cancel();
    _completion = null;
  }

  /// Pauses the timer, keeping the time run so far; does nothing when it
  /// isn't running or after [dispose].
  void pause() {
    if (_disposed || !isRunning) return;
    _offset = _raw;
    _startedAt = null;
    _cancelTimers();
    notifyListeners();
  }

  /// Stops the timer and sets it back to zero, clearing [isCompleted];
  /// does nothing after [dispose].
  void reset() {
    if (_disposed) return;
    _startedAt = null;
    _cancelTimers();
    _offset = Duration.zero;
    _completed = false;
    notifyListeners();
  }

  /// Sets the timer back to zero and starts it.
  void restart() {
    reset();
    start();
  }

  /// Notifies a tick, and completes a countdown that reached zero.
  void _tick() {
    final countdown = this.countdown;
    if (countdown != null && _raw >= countdown) {
      _startedAt = null;
      _offset = countdown;
      _cancelTimers();
      _completed = true;
      onTick?.call(elapsed);
      notifyListeners();
      onComplete?.call();
      return;
    }
    onTick?.call(elapsed);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimers();
    super.dispose();
  }
}

/// Formats [duration] as `m:ss`, or `h:mm:ss` from an hour, with tenths
/// of a second (truncated) when [tenths] is set.
///
/// A negative [duration] gets a leading minus sign.
String oito2FormatDuration(Duration duration, {bool tenths = false}) {
  final negative = duration.isNegative;
  final d = duration.abs();
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  final seconds = d.inSeconds % 60;
  final base = hours > 0
      ? '$hours:${two(minutes)}:${two(seconds)}'
      : '$minutes:${two(seconds)}';
  final fraction = tenths ? '.${(d.inMilliseconds % 1000) ~/ 100}' : '';
  return '${negative ? '-' : ''}$base$fraction';
}

/// The time of an [Oito2TimerController] as text: the remaining time of a
/// countdown or the elapsed time of a stopwatch, in tabular figures so the
/// digits don't shift.
class Oito2TimerText extends StatelessWidget {
  /// Creates a timer text.
  const Oito2TimerText({
    super.key,
    required this.controller,
    this.style,
    this.tenths = false,
  });

  /// The timer shown.
  final Oito2TimerController controller;

  /// The text style, merged over tabular figures.
  final TextStyle? style;

  /// Whether tenths of a second show; without them a countdown rounds up
  /// to the whole second.
  final bool tenths;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final time = controller.remaining ?? controller.elapsed;
        // Rounds a countdown up, so it shows 0:00 only at the end.
        final shown = controller.remaining != null && !tenths
            ? Duration(seconds: (time.inMilliseconds / 1000).ceil())
            : time;
        return Text(
          oito2FormatDuration(shown, tenths: tenths),
          style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])
              .merge(style),
        );
      },
    );
  }
}
