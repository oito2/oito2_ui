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

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// Wraps [child] so that [dropReaches] sees every point of its area,
/// including those where nothing of [child] takes pointer input, without
/// hiding what is behind it from hit testing.
Widget dropHitRegion(Widget child) =>
    MetaData(behavior: HitTestBehavior.translucent, child: child);

/// Whether a drop at [global], in logical pixels of the view of [context],
/// lands on the widget of [context]: the hit test of the view at that
/// point reaches its render box, so nothing drawn over it, such as a
/// dialog, a menu or another drop zone, takes the drop.
///
/// The widget of [context] should start with [dropHitRegion]. Returns
/// false while it isn't laid out.
bool dropReaches(BuildContext context, Offset global) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return false;
  final result = HitTestResult();
  WidgetsBinding.instance.hitTestInView(
    result,
    global,
    View.of(context).viewId,
  );
  return result.path.any((entry) => identical(entry.target, box));
}
