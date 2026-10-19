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

import 'package:material_ui/material_ui.dart';

/// A desktop page transition: the incoming page fades in while sliding a
/// short distance from the end side, and the outgoing page fades out.
class Oito2DesktopPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Creates the desktop page transition builder.
  const Oito2DesktopPageTransitionsBuilder();

  /// The fraction of the page width the incoming page travels.
  static const double slideFraction = 0.04;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final direction = Directionality.of(context) == TextDirection.rtl
        ? -1.0
        : 1.0;
    return FadeTransition(
      opacity: ReverseAnimation(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
      ),
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(slideFraction * direction, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      ),
    );
  }
}

/// Page transitions for every platform: [Oito2DesktopPageTransitionsBuilder]
/// on Linux and Windows, and the Material defaults elsewhere (Cupertino
/// transitions on iOS and macOS, predictive back on Android).
PageTransitionsTheme oito2PageTransitionsTheme() {
  return PageTransitionsTheme(
    builders: {
      ...const PageTransitionsTheme().builders,
      TargetPlatform.linux: const Oito2DesktopPageTransitionsBuilder(),
      TargetPlatform.windows: const Oito2DesktopPageTransitionsBuilder(),
    },
  );
}
