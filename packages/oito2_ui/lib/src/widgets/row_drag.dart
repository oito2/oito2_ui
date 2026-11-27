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
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// How far a mouse moves with its button down, in logical pixels, before
/// a row drag starts, so that a click with a small jitter stays a click.
const double kRowDragThreshold = 6;

/// The pointer kinds that start a row drag after a long press instead of
/// at once, outside a drag handle.
const Set<PointerDeviceKind> _touchKinds = {
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

/// Recognizes a drag once the pointer moves more than [threshold] logical
/// pixels from where it went down, or the framework's hit slop when
/// [threshold] is null.
class _ThresholdDragRecognizer extends ImmediateMultiDragGestureRecognizer {
  _ThresholdDragRecognizer({this.threshold, super.supportedDevices});

  final double? threshold;

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) =>
      _ThresholdPointerState(
        event.position,
        event.kind,
        gestureSettings,
        threshold,
      );
}

/// The state of one pointer of a [_ThresholdDragRecognizer]: accepted once
/// it moves farther than its threshold.
class _ThresholdPointerState extends MultiDragPointerState {
  _ThresholdPointerState(
    super.initialPosition,
    super.kind,
    super.gestureSettings,
    this.threshold,
  );

  final double? threshold;

  @override
  void checkForResolutionAfterMove() {
    final slop = math.max(
      threshold ?? 0,
      computeHitSlop(kind, gestureSettings),
    );
    if (pendingDelta!.distance > slop) resolve(GestureDisposition.accepted);
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) =>
      starter(initialPosition);
}

/// Starts a row drag on [child] through [onStart], which returns the drag
/// that follows the pointer, or null to not start one.
///
/// In a [handle], any pointer starts the drag once it moves past the hit
/// slop. Elsewhere a mouse starts it once it moves [kRowDragThreshold]
/// pixels, and a touch, a stylus or an unknown pointer after a long press
/// when [longPress] is true, or never otherwise. Only the primary button
/// starts a drag. Nothing is recognized while [onStart] is null.
class RowDragDetector extends StatelessWidget {
  /// Creates a row drag detector around [child].
  const RowDragDetector({
    super.key,
    required this.onStart,
    this.handle = false,
    this.longPress = true,
    required this.child,
  });

  /// Starts the drag at a global position, returning it, or null to not
  /// start one; null recognizes nothing.
  final Drag? Function(Offset globalPosition)? onStart;

  /// Whether [child] is a drag handle, which any pointer drags at once.
  final bool handle;

  /// Whether a long press starts the drag of a touch pointer outside a
  /// handle.
  final bool longPress;

  /// The row or the handle.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = onStart;
    if (start == null) return child;
    return RawGestureDetector(
      behavior: handle ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      gestures: {
        _ThresholdDragRecognizer:
            GestureRecognizerFactoryWithHandlers<_ThresholdDragRecognizer>(
              () => _ThresholdDragRecognizer(
                threshold: handle ? null : kRowDragThreshold,
                supportedDevices: handle ? null : {PointerDeviceKind.mouse},
              ),
              (recognizer) => recognizer.onStart = start,
            ),
        if (!handle && longPress)
          DelayedMultiDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                DelayedMultiDragGestureRecognizer
              >(
                () => DelayedMultiDragGestureRecognizer(
                  supportedDevices: _touchKinds,
                ),
                (recognizer) => recognizer.onStart = start,
              ),
      },
      child: child,
    );
  }
}

/// A row drag in progress: [onUpdate] receives each global pointer
/// position and [onEnd] whether the pointer was released (true) or the
/// drag was cancelled (false).
class RowDrag implements Drag {
  /// Creates a row drag.
  RowDrag({required this.onUpdate, required this.onEnd});

  /// Called with each new global pointer position.
  final ValueChanged<Offset> onUpdate;

  /// Called once when the drag ends: true on release, false on cancel.
  final ValueChanged<bool> onEnd;

  bool _ended = false;

  @override
  void update(DragUpdateDetails details) {
    if (!_ended) onUpdate(details.globalPosition);
  }

  @override
  void end(DragEndDetails details) => _finish(true);

  @override
  void cancel() => _finish(false);

  /// Reports the end of the drag the first time only.
  void _finish(bool dropped) {
    if (_ended) return;
    _ended = true;
    onEnd(dropped);
  }
}

/// Scrolls a scroll position while a dragged pointer is near an edge of
/// its viewport along the scroll axis, faster the closer it gets, and
/// calls [onScrolled] after every step.
class DragAutoScroller {
  /// Creates an auto-scroller that calls [onScrolled] after each step.
  DragAutoScroller(this.onScrolled);

  /// Called after each scroll step, such as to update the drop target.
  final VoidCallback onScrolled;

  /// The time between two scroll steps.
  static const interval = Duration(milliseconds: 16);

  /// The largest step, in logical pixels.
  static const maxStep = 12.0;

  Timer? _timer;
  ScrollPosition? _position;
  double _step = 0;

  /// Whether the position is scrolling.
  bool get isScrolling => _timer != null;

  /// Starts, adjusts or stops the scrolling of [position] for a pointer at
  /// [global] over [viewport]: within [edge] pixels of an edge along
  /// [axis], or beyond it, it scrolls toward that edge.
  ///
  /// With [axis] horizontal, [leadingInset] and [trailingInset] move the
  /// left and the right edge inward by that many pixels, such as past
  /// columns that don't scroll.
  void update(
    Offset global,
    RenderBox? viewport,
    ScrollPosition? position, {
    double edge = 32,
    Axis axis = Axis.vertical,
    double leadingInset = 0,
    double trailingInset = 0,
  }) {
    if (viewport == null || !viewport.hasSize || position == null) {
      stop();
      return;
    }
    final local = viewport.globalToLocal(global);
    final vertical = axis == Axis.vertical;
    final along = (vertical ? local.dy : local.dx) - leadingInset;
    final across = vertical ? local.dx : local.dy;
    final length = math.max(
      0.0,
      (vertical ? viewport.size.height : viewport.size.width) -
          leadingInset -
          trailingInset,
    );
    final breadth = vertical ? viewport.size.width : viewport.size.height;
    final zone = math.min(edge, length / 4);
    double step;
    if (across < 0 || across > breadth || zone <= 0) {
      step = 0;
    } else if (along < zone) {
      step = -maxStep * ((zone - along) / zone).clamp(0.2, 1.0);
    } else if (along > length - zone) {
      step = maxStep * ((along - (length - zone)) / zone).clamp(0.2, 1.0);
    } else {
      step = 0;
    }
    if (axisDirectionIsReversed(position.axisDirection)) step = -step;
    _position = position;
    _step = step;
    if (step == 0) {
      stop();
    } else {
      _timer ??= Timer.periodic(interval, (_) => _tick());
    }
  }

  /// Scrolls one step, stopping at either end.
  void _tick() {
    final position = _position;
    if (position == null || !position.hasPixels) {
      stop();
      return;
    }
    final target = (position.pixels + _step).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return;
    position.jumpTo(target);
    onScrolled();
  }

  /// Stops scrolling.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

/// The floating label that follows the pointer during a row drag, shown in
/// the overlay above the app.
class DragFeedback {
  OverlayEntry? _entry;
  final _position = ValueNotifier<Offset>(Offset.zero);
  final _allowed = ValueNotifier<bool>(true);

  /// Whether the label shows.
  bool get isShowing => _entry != null;

  /// Shows [label] next to the global position [global], in the overlay of
  /// [context] with its theme.
  void show(BuildContext context, String label, Offset global) {
    hide();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final themes = InheritedTheme.capture(from: context, to: overlay.context);
    _allowed.value = true;
    final entry = OverlayEntry(
      builder: (overlayContext) {
        final box = overlay.context.findRenderObject() as RenderBox?;
        return ValueListenableBuilder<Offset>(
          valueListenable: _position,
          builder: (context, global, child) {
            final local = box == null ? global : box.globalToLocal(global);
            return Positioned(
              left: local.dx + 12,
              top: local.dy + 8,
              child: child!,
            );
          },
          child: IgnorePointer(
            child: themes.wrap(
              ValueListenableBuilder<bool>(
                valueListenable: _allowed,
                builder: (context, allowed, _) =>
                    _FeedbackChip(label: label, allowed: allowed),
              ),
            ),
          ),
        );
      },
    );
    _position.value = global;
    _entry = entry;
    overlay.insert(entry);
  }

  /// Moves the label next to the global position [global].
  void move(Offset global) => _position.value = global;

  /// Shows whether the pointer is over a place where the drop is allowed.
  set allowed(bool value) => _allowed.value = value;

  /// Removes the label.
  void hide() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  /// Removes the label and releases its notifiers.
  void dispose() {
    hide();
    _position.dispose();
    _allowed.dispose();
  }
}

/// The content of a [DragFeedback]: the dragged label, with a "no drop"
/// sign when [allowed] is false.
class _FeedbackChip extends StatelessWidget {
  const _FeedbackChip({required this.label, required this.allowed});

  final String label;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: Oito2Radius.smallAll,
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Oito2Spacing.sm,
            vertical: Oito2Spacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.xs,
            children: [
              if (!allowed)
                Icon(
                  LucideIcons.ban,
                  key: const ValueKey('oito2-drag-no-drop'),
                  size: 14,
                  color: scheme.error,
                ),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Where a drop lands relative to a row: before it, inside it or after it.
enum DropPlacement {
  /// Above the row.
  before,

  /// Into the row, a branch.
  inside,

  /// Below the row.
  after,
}

/// The line that marks a drop before or after a row, starting [start]
/// pixels from the row's start edge, drawn over the row.
class DropLine extends StatelessWidget {
  /// Creates the drop line of [placement], [DropPlacement.before] or
  /// [DropPlacement.after].
  const DropLine({super.key, required this.placement, this.start = 0});

  /// Whether the line is at the top or the bottom of the row.
  final DropPlacement placement;

  /// The distance from the row's start edge to the line.
  final double start;

  @override
  Widget build(BuildContext context) {
    final color = semanticColorsOf(context).primaryText;
    return PositionedDirectional(
      start: start,
      end: 0,
      top: placement == DropPlacement.before ? 0 : null,
      bottom: placement == DropPlacement.after ? 0 : null,
      height: 2,
      child: IgnorePointer(
        child: ColoredBox(key: const ValueKey('oito2-drop-line'), color: color),
      ),
    );
  }
}

/// The frame that marks a row as the branch a drop goes into, drawn over
/// the row.
class DropInsideFrame extends StatelessWidget {
  /// Creates the frame of a drop into a row, inset by [margin].
  const DropInsideFrame({super.key, this.margin = EdgeInsets.zero});

  /// The space between the row's edges and the frame.
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final color = semanticColorsOf(context).primaryText;
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          key: const ValueKey('oito2-drop-inside'),
          margin: margin,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: Oito2Radius.smallAll,
            border: Border.all(color: color, width: 2),
          ),
        ),
      ),
    );
  }
}

/// The drag handle of a reorderable row: a grip that shows the grab
/// cursor, or the grabbing one while [dragging], with a "Drag to reorder"
/// tooltip, and starts the drag through [onStart].
class RowDragHandle extends StatelessWidget {
  /// Creates a drag handle.
  const RowDragHandle({
    super.key,
    required this.onStart,
    required this.dragging,
  });

  /// Starts the drag; null disables the handle.
  final Drag? Function(Offset globalPosition)? onStart;

  /// Whether a drag is in progress.
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: MouseRegion(
        cursor: onStart == null
            ? MouseCursor.defer
            : dragging
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.grab,
        child: RowDragDetector(
          onStart: onStart,
          handle: true,
          child: Tooltip(
            message: Oito2Localizations.of(context).dragToReorder,
            child: SizedBox(
              key: const ValueKey('oito2-drag-handle'),
              width: padsTapTargets(context) ? Oito2Sizes.minTouchTarget : 24,
              height: padsTapTargets(context) ? Oito2Sizes.minTouchTarget : 24,
              child: const Icon(LucideIcons.grip_vertical, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}

/// Announces [message] to assistive technologies in the view of
/// [context], in its reading direction.
void announceTo(BuildContext context, String message) {
  unawaited(
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    ),
  );
}

/// Returns the index an item at [from] ends at when it is dropped into
/// the gap [gap], counted before the item is taken out: the gap itself
/// when it is before the item, one less when it is after.
int reorderIndex(int from, int gap) => gap > from ? gap - 1 : gap;
