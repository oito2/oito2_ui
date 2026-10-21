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

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_helpers.dart';

/// Scrolls [child] continuously when it is longer than the space it has,
/// such as a news ticker or a long song title.
///
/// The child moves toward the start (up when vertical), or the other way
/// with [reverse], at [speed] logical pixels per second, followed by a
/// copy after [gap]. It stops while the pointer or the focus is on it, and
/// stays still at its start when animations are disabled. [fadeEdges]
/// fades the content at both ends. A child that fits doesn't move.
/// Assistive technologies read the child once.
class Oito2Marquee extends StatefulWidget {
  /// Creates a marquee.
  const Oito2Marquee({
    super.key,
    required this.child,
    this.axis = Axis.horizontal,
    this.reverse = false,
    this.speed = 40,
    this.gap = 32,
    this.pauseOnHover = true,
    this.fadeEdges = true,
    this.fadeExtent = 24,
  }) : assert(speed > 0);

  /// The scrolling content.
  final Widget child;

  /// The direction of the scroll.
  final Axis axis;

  /// Whether the content moves toward the end (down when vertical).
  final bool reverse;

  /// The speed in logical pixels per second.
  final double speed;

  /// The space between the content and its copy.
  final double gap;

  /// Whether the pointer or the focus stops the scroll.
  final bool pauseOnHover;

  /// Whether the content fades at both ends.
  final bool fadeEdges;

  /// The length of the fades.
  final double fadeExtent;

  @override
  State<Oito2Marquee> createState() => _Oito2MarqueeState();
}

class _Oito2MarqueeState extends State<Oito2Marquee>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;
  double _offset = 0;
  double _extent = 0;
  double _viewport = 0;
  bool _hovered = false;
  bool _focused = false;

  bool get _horizontal => widget.axis == Axis.horizontal;

  bool get _overflows => _extent > _viewport && _viewport > 0;

  bool get _shouldRun {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final paused = widget.pauseOnHover && (_hovered || _focused);
    return _overflows && !reduced && !paused;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _sync() {
    if (_shouldRun && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!_shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
    if (!_overflows ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      _offset = 0;
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final period = _extent + widget.gap;
    setState(() => _offset = (_offset + widget.speed * dt) % period);
  }

  void _onSize(Size size) {
    final extent = _horizontal ? size.width : size.height;
    if (extent == _extent) return;
    _extent = extent;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(_sync);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = _horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        if (viewport != _viewport) {
          _viewport = viewport;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(_sync);
          });
        }
        final overflows = _overflows;
        final measured = SizeReporter(onSize: _onSize, child: widget.child);
        final strip = Flex(
          direction: widget.axis,
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            measured,
            if (overflows) ...[
              SizedBox(
                width: _horizontal ? widget.gap : null,
                height: _horizontal ? null : widget.gap,
              ),
              ExcludeSemantics(child: widget.child),
            ],
          ],
        );
        // Toward the start in the reading direction unless reversed.
        final towardNegative = _horizontal
            ? (rtl == widget.reverse)
            : !widget.reverse;
        final period = _extent + widget.gap;
        final shift = !overflows
            ? 0.0
            : towardNegative
            ? -_offset
            : _offset - period;
        final startAligned = _horizontal && rtl && !overflows
            ? Alignment.centerRight
            : _horizontal
            ? Alignment.centerLeft
            : Alignment.topCenter;
        Widget content = UnconstrainedBox(
          constrainedAxis: _horizontal ? Axis.vertical : Axis.horizontal,
          alignment: startAligned,
          clipBehavior: Clip.hardEdge,
          child: Transform.translate(
            offset: _horizontal ? Offset(shift, 0) : Offset(0, shift),
            child: strip,
          ),
        );
        if (widget.fadeEdges && overflows && viewport.isFinite) {
          final stop = (widget.fadeExtent / viewport).clamp(0.0, 0.5);
          content = ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => LinearGradient(
              begin: _horizontal ? Alignment.centerLeft : Alignment.topCenter,
              end: _horizontal ? Alignment.centerRight : Alignment.bottomCenter,
              colors: const [
                Color(0x00000000),
                Color(0xFF000000),
                Color(0xFF000000),
                Color(0x00000000),
              ],
              stops: [0, stop, 1 - stop, 1],
            ).createShader(rect),
            child: content,
          );
        }
        return MouseRegion(
          onEnter: (_) => setState(() {
            _hovered = true;
            _sync();
          }),
          onExit: (_) => setState(() {
            _hovered = false;
            _sync();
          }),
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (focused) => setState(() {
              _focused = focused;
              _sync();
            }),
            child: content,
          ),
        );
      },
    );
  }
}
