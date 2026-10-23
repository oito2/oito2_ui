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

/// A desktop page transition: the incoming page fades in while sliding a
/// short distance from the end side, and the outgoing page fades out.
class Oito2DesktopPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Creates the desktop page transition builder.
  const Oito2DesktopPageTransitionsBuilder();

  /// The fraction of the page width the incoming page travels; it moves
  /// toward the start side, so it comes from the right in left-to-right
  /// text and from the left in right-to-left text.
  static const double slideFraction = 0.04;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _DesktopPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Builds [Oito2DesktopPageTransitionsBuilder]'s transition, creating its
/// curves once and disposing them with the route.
class _DesktopPageTransition extends StatefulWidget {
  const _DesktopPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  State<_DesktopPageTransition> createState() => _DesktopPageTransitionState();
}

class _DesktopPageTransitionState extends State<_DesktopPageTransition> {
  late CurvedAnimation _incoming;
  late CurvedAnimation _outgoing;

  @override
  void initState() {
    super.initState();
    _curve();
  }

  @override
  void didUpdateWidget(_DesktopPageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.secondaryAnimation != widget.secondaryAnimation) {
      _dispose();
      _curve();
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  /// Creates the incoming and outgoing curves for the current animations.
  void _curve() {
    _incoming = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _outgoing = CurvedAnimation(
      parent: widget.secondaryAnimation,
      curve: Curves.easeIn,
    );
  }

  /// Disposes the curves created by [_curve].
  void _dispose() {
    _incoming.dispose();
    _outgoing.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context) == TextDirection.rtl
        ? -1.0
        : 1.0;
    return FadeTransition(
      opacity: ReverseAnimation(_outgoing),
      child: FadeTransition(
        opacity: _incoming,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(
              Oito2DesktopPageTransitionsBuilder.slideFraction * direction,
              0,
            ),
            end: Offset.zero,
          ).animate(_incoming),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Returns the page transitions for every platform:
/// [Oito2DesktopPageTransitionsBuilder] on Linux and Windows, and the
/// Material defaults elsewhere (Cupertino transitions on iOS and macOS,
/// predictive back on Android).
PageTransitionsTheme oito2PageTransitionsTheme() {
  return PageTransitionsTheme(
    builders: {
      ...const PageTransitionsTheme().builders,
      TargetPlatform.linux: const Oito2DesktopPageTransitionsBuilder(),
      TargetPlatform.windows: const Oito2DesktopPageTransitionsBuilder(),
    },
  );
}
