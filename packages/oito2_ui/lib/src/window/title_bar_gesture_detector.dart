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

import 'window_controller.dart';

/// Turns pointer gestures on a title bar into window actions: dragging
/// moves the window, a double click maximizes or restores it, and a
/// secondary click opens the native window menu when available.
///
/// Does nothing when [controller] is null.
class Oito2TitleBarGestureDetector extends StatelessWidget {
  /// Creates a title bar gesture detector around [child].
  const Oito2TitleBarGestureDetector({
    super.key,
    required this.controller,
    required this.child,
  });

  /// The window controller that receives the actions.
  final Oito2WindowController? controller;

  /// The title bar content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => controller.startDrag(),
      onDoubleTap: controller.toggleMaximize,
      onSecondaryTap: () {
        if (controller.state.value.canShowMenu) controller.showMenu();
      },
      child: child,
    );
  }
}
