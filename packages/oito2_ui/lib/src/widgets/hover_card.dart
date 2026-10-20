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

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'popover.dart';

/// A card of extra detail that opens over [child] while the pointer
/// rests on it or the keyboard focus is inside it, such as a profile
/// preview on a user name.
///
/// The card opens after [openDelay] and closes [closeDelay] after the
/// pointer leaves both the child and the card, or the focus leaves the
/// child. A long press opens it on touch screens; Escape and a tap
/// outside close it. The card doesn't take the focus, so its content
/// must only repeat or preview what the child leads to.
class Oito2HoverCard extends StatefulWidget {
  /// Creates a hover card.
  const Oito2HoverCard({
    super.key,
    required this.child,
    required this.cardBuilder,
    this.openDelay = const Duration(milliseconds: 500),
    this.closeDelay = const Duration(milliseconds: 300),
    this.placement = Oito2PopoverPlacement.bottom,
    this.alignment = Oito2PopoverAlignment.center,
    this.showArrow = true,
    this.maxWidth = 320,
  });

  /// The widget that opens the card.
  final Widget child;

  /// Builds the card content.
  final WidgetBuilder cardBuilder;

  /// The wait before the card opens.
  final Duration openDelay;

  /// The wait before the card closes.
  final Duration closeDelay;

  /// The preferred side of the child.
  final Oito2PopoverPlacement placement;

  /// The alignment along the child's edge.
  final Oito2PopoverAlignment alignment;

  /// Whether the card points at the child with an arrow.
  final bool showArrow;

  /// The largest card width.
  final double maxWidth;

  @override
  State<Oito2HoverCard> createState() => _Oito2HoverCardState();
}

class _Oito2HoverCardState extends State<Oito2HoverCard> {
  final _controller = Oito2PopoverController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _schedule(bool open) {
    _timer?.cancel();
    if (_controller.isOpen == open) return;
    _timer = Timer(
      open ? widget.openDelay : widget.closeDelay,
      open ? _controller.open : _controller.close,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Oito2Popover(
      controller: _controller,
      placement: widget.placement,
      alignment: widget.alignment,
      showArrow: widget.showArrow,
      maxWidth: widget.maxWidth,
      focusOnOpen: false,
      onOpenChanged: (_) => _timer?.cancel(),
      popoverBuilder: (context, _) => MouseRegion(
        onEnter: (_) => _timer?.cancel(),
        onExit: (_) => _schedule(false),
        child: widget.cardBuilder(context),
      ),
      builder: (context, controller) => MouseRegion(
        onEnter: (_) => _schedule(true),
        onExit: (_) => _schedule(false),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: _schedule,
          child: GestureDetector(
            onLongPress: controller.open,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
