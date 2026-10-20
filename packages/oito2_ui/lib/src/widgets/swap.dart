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

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// How an [Oito2Swap] changes between its two widgets.
enum Oito2SwapEffect {
  /// A cross-fade.
  fade,

  /// The new widget grows in while the old one shrinks away.
  scale,

  /// The widgets turn a quarter turn while fading.
  rotate,

  /// The widgets flip around the vertical axis.
  flip,
}

/// Animates between two visual states, such as a copy icon that turns
/// into a check mark or a play button that becomes pause.
///
/// It shows [on] while [swapped] and [off] otherwise, changing with
/// [effect]; when animations are disabled the change is instant.
class Oito2Swap extends StatelessWidget {
  /// Creates a swap.
  const Oito2Swap({
    super.key,
    required this.swapped,
    required this.off,
    required this.on,
    this.effect = Oito2SwapEffect.fade,
    this.duration = const Duration(milliseconds: 200),
  });

  /// Whether [on] is shown.
  final bool swapped;

  /// The widget shown while not [swapped].
  final Widget off;

  /// The widget shown while [swapped].
  final Widget on;

  /// The transition between the widgets.
  final Oito2SwapEffect effect;

  /// The transition duration.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final instant = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return AnimatedSwitcher(
      duration: instant ? Duration.zero : duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => switch (effect) {
        Oito2SwapEffect.fade => FadeTransition(
          opacity: animation,
          child: child,
        ),
        Oito2SwapEffect.scale => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        Oito2SwapEffect.rotate => FadeTransition(
          opacity: animation,
          child: RotationTransition(
            turns: Tween(begin: -0.25, end: 0.0).animate(animation),
            child: child,
          ),
        ),
        Oito2SwapEffect.flip => AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) => Opacity(
            opacity: animation.value < 0.5 ? 0 : 1,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY((1 - animation.value) * math.pi),
              child: child,
            ),
          ),
        ),
      },
      child: KeyedSubtree(key: ValueKey(swapped), child: swapped ? on : off),
    );
  }
}
