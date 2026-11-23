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
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import 'progress.dart';

/// Shows a busy state on any button, such as a [FilledButton] that
/// started a call to a server, without changing its look or width.
///
/// While [busy], the button keeps its colors and focus but ignores
/// clicks, taps, the activation keys (Enter, Space and Select) and the
/// tap action of assistive technologies, which read it with "Loading" as
/// its value; the pointer shows the progress cursor over it. Put an
/// [Oito2BusyLabel] around the button's icon or label to show a spinner
/// in its place.
///
/// ```dart
/// Oito2BusyButton(
///   busy: saving,
///   child: FilledButton.icon(
///     onPressed: save,
///     icon: const Oito2BusyLabel(child: Icon(LucideIcons.save)),
///     label: const Text('Save'),
///   ),
/// )
/// ```
class Oito2BusyButton extends StatelessWidget {
  /// Creates a busy button wrapper.
  const Oito2BusyButton({super.key, required this.busy, required this.child});

  /// Whether the action of the button is running.
  final bool busy;

  /// The button.
  final Widget child;

  /// Returns whether the closest [Oito2BusyButton] around [context] is
  /// busy, or false when there is none.
  static bool isBusy(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BusyScope>()?.busy ?? false;

  /// The keys that activate a focused button.
  static const _activators = [
    SingleActivator(LogicalKeyboardKey.enter),
    SingleActivator(LogicalKeyboardKey.numpadEnter),
    SingleActivator(LogicalKeyboardKey.space),
    SingleActivator(LogicalKeyboardKey.select),
    SingleActivator(LogicalKeyboardKey.gameButtonA),
  ];

  @override
  Widget build(BuildContext context) {
    return _BusyScope(
      busy: busy,
      child: CallbackShortcuts(
        bindings: {
          if (busy)
            for (final activator in _activators) activator: () {},
        },
        child: MergeSemantics(
          child: Semantics(
            value: busy ? Oito2Localizations.of(context).loading : null,
            child: MouseRegion(
              cursor: busy ? SystemMouseCursors.progress : MouseCursor.defer,
              child: AbsorbPointer(absorbing: busy, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Passes the busy state of an [Oito2BusyButton] to its descendants.
class _BusyScope extends InheritedWidget {
  const _BusyScope({required this.busy, required super.child});

  final bool busy;

  @override
  bool updateShouldNotify(_BusyScope oldWidget) => busy != oldWidget.busy;
}

/// The icon or label of a button that a spinner replaces while the
/// closest [Oito2BusyButton] is busy.
///
/// The [child] stays laid out, hidden, so the button keeps its size, and
/// its text is still read by assistive technologies. The spinner takes
/// the color of the button's icons and stands still when animations are
/// disabled.
class Oito2BusyLabel extends StatelessWidget {
  /// Creates a busy label.
  const Oito2BusyLabel({super.key, required this.child, this.busy});

  /// The icon or label shown while not busy.
  final Widget child;

  /// Whether the spinner shows; defaults to the state of the closest
  /// [Oito2BusyButton].
  final bool? busy;

  @override
  Widget build(BuildContext context) {
    final busy = this.busy ?? Oito2BusyButton.isBusy(context);
    final iconTheme = IconTheme.of(context);
    final size = ((iconTheme.size ?? 18) - 2).clamp(10.0, 20.0);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: busy ? 0 : 1,
          alwaysIncludeSemantics: true,
          child: child,
        ),
        if (busy)
          Positioned.fill(
            child: Center(
              child: OverflowBox(
                maxWidth: size,
                maxHeight: size,
                child: ExcludeSemantics(
                  child: Oito2CircularProgressIndicator(
                    size: size,
                    strokeWidth: 2,
                    color:
                        iconTheme.color ??
                        DefaultTextStyle.of(context).style.color,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
