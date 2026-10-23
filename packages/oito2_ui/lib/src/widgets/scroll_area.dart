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

import 'utilities.dart';

/// The directions an [Oito2ScrollArea] scrolls in.
enum Oito2ScrollDirection {
  /// Up and down.
  vertical,

  /// Left and right.
  horizontal,

  /// Both ways, with a scroll bar on each axis.
  both,
}

/// A scrollable box for a [child] larger than it, with the themed scroll
/// bars on the axes it scrolls in.
///
/// The bars show while scrolling or, with [thumbVisibility], all the time.
/// With [undershoot], an [Oito2ScrollViewUndershoot] shadow marks the
/// edges with more content beyond them; when scrolling [Oito2ScrollDirection.both]
/// ways, the shadows follow the vertical axis.
class Oito2ScrollArea extends StatefulWidget {
  /// Creates a scroll area.
  const Oito2ScrollArea({
    super.key,
    required this.child,
    this.direction = Oito2ScrollDirection.vertical,
    this.verticalController,
    this.horizontalController,
    this.thumbVisibility,
    this.undershoot = false,
    this.padding,
  });

  /// The content.
  final Widget child;

  /// The directions the content scrolls in.
  final Oito2ScrollDirection direction;

  /// The controller of the vertical scroll position; one is created when
  /// null.
  final ScrollController? verticalController;

  /// The controller of the horizontal scroll position; one is created when
  /// null.
  final ScrollController? horizontalController;

  /// Whether the scroll bars always show; null follows the scroll bar
  /// theme.
  final bool? thumbVisibility;

  /// Whether a soft shadow marks the edges with more content beyond them.
  final bool undershoot;

  /// The space around [child], inside the scrolled content.
  final EdgeInsetsGeometry? padding;

  @override
  State<Oito2ScrollArea> createState() => _Oito2ScrollAreaState();
}

class _Oito2ScrollAreaState extends State<Oito2ScrollArea> {
  ScrollController? _ownedVertical;
  ScrollController? _ownedHorizontal;

  ScrollController get _vertical =>
      widget.verticalController ?? (_ownedVertical ??= ScrollController());

  ScrollController get _horizontal =>
      widget.horizontalController ?? (_ownedHorizontal ??= ScrollController());

  @override
  void dispose() {
    _ownedVertical?.dispose();
    _ownedHorizontal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The scroll bars come from this widget, so the platform's automatic
    // ones are turned off for its scroll views; the content keeps the
    // ambient behavior.
    final ambient = ScrollConfiguration.of(context);
    final content = ScrollConfiguration(behavior: ambient, child: widget.child);
    Widget scroller(Axis axis, Widget child, {EdgeInsetsGeometry? padding}) {
      return SingleChildScrollView(
        controller: axis == Axis.vertical ? _vertical : _horizontal,
        scrollDirection: axis,
        padding: padding,
        child: child,
      );
    }

    Widget area;
    switch (widget.direction) {
      case Oito2ScrollDirection.vertical || Oito2ScrollDirection.horizontal:
        final axis = widget.direction == Oito2ScrollDirection.vertical
            ? Axis.vertical
            : Axis.horizontal;
        final controller = axis == Axis.vertical ? _vertical : _horizontal;
        Widget view = scroller(axis, content, padding: widget.padding);
        if (widget.undershoot) view = Oito2ScrollViewUndershoot(child: view);
        area = Scrollbar(
          controller: controller,
          thumbVisibility: widget.thumbVisibility,
          child: view,
        );
      case Oito2ScrollDirection.both:
        Widget view = scroller(
          Axis.vertical,
          scroller(Axis.horizontal, content, padding: widget.padding),
        );
        if (widget.undershoot) view = Oito2ScrollViewUndershoot(child: view);
        area = Scrollbar(
          controller: _vertical,
          thumbVisibility: widget.thumbVisibility,
          child: Scrollbar(
            controller: _horizontal,
            thumbVisibility: widget.thumbVisibility,
            // The horizontal view sits inside the vertical one.
            notificationPredicate: (notification) => notification.depth == 1,
            child: view,
          ),
        );
    }
    return ScrollConfiguration(
      behavior: ambient.copyWith(scrollbars: false),
      child: area,
    );
  }
}
