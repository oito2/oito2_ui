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
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// The window edge an [Oito2Sheet] slides in from.
enum Oito2SheetSide {
  /// The reading-order start edge.
  start,

  /// The reading-order end edge.
  end,

  /// The bottom edge.
  bottom,
}

/// Shows a sheet built by [builder] sliding in from [side], usually with
/// an [Oito2Sheet] as its content, and completes with the value it is
/// closed with.
///
/// A [modal] sheet dims the page and keeps the focus and assistive
/// technologies inside it; a tap on the dimmed page closes it when
/// [dismissible]. A non-modal sheet leaves the page usable beside it.
/// Either closes on Escape and, when [dismissible], when dragged toward
/// its edge.
///
/// A side sheet is [size] wide (360 by default). A bottom sheet is as
/// tall as its content, up to 90% of the window, unless [snapPoints]
/// gives the heights it rests at as fractions of the window height,
/// ascending, starting at the [initialSnap] index; its handle then moves
/// between them by drag, by the arrow keys or by Enter.
Future<T?> showOito2Sheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Oito2SheetSide side = Oito2SheetSide.end,
  bool modal = true,
  bool dismissible = true,
  double? size,
  List<double>? snapPoints,
  int initialSnap = 0,
  String? semanticLabel,
}) {
  assert(
    snapPoints == null || side == Oito2SheetSide.bottom,
    'Only bottom sheets have snap points.',
  );
  assert(
    snapPoints == null ||
        (snapPoints.isNotEmpty &&
            initialSnap >= 0 &&
            initialSnap < snapPoints.length),
    'initialSnap must index snapPoints.',
  );
  final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final duration = reduced ? Duration.zero : const Duration(milliseconds: 250);
  final config = _SheetConfig(
    side: side,
    dismissible: dismissible,
    size: size,
    snapPoints: snapPoints,
    initialSnap: initialSnap,
    semanticLabel: semanticLabel,
    modal: modal,
  );
  if (modal) {
    final scheme = Theme.of(context).colorScheme;
    return Navigator.of(context, rootNavigator: true).push(
      _Oito2SheetRoute<T>(
        builder: builder,
        config: config,
        duration: duration,
        barrierColor: scheme.scrim.withValues(alpha: 0.32),
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
      ),
    );
  }
  final completer = Completer<T?>();
  late final OverlayEntry entry;
  void finish(T? result) {
    if (completer.isCompleted) return;
    entry.remove();
    entry.dispose();
    completer.complete(result);
  }

  entry = OverlayEntry(
    builder: (_) => _NonModalSheetHost<T>(
      builder: builder,
      config: config,
      duration: duration,
      onClosed: finish,
      // The overlay went away with the sheet still open, such as when the
      // app's view closes: only the future completes.
      onGone: () {
        if (!completer.isCompleted) completer.complete(null);
      },
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
  // The sheet lives in the root overlay, so it closes when the route that
  // opened it goes away.
  ModalRoute.of(context)?.completed.whenComplete(() => finish(null));
  return completer.future;
}

/// The content of a sheet shown by [showOito2Sheet]: a header with
/// [title], [actions] and a close button, above [child].
class Oito2Sheet extends StatelessWidget {
  /// Creates sheet content.
  const Oito2Sheet({
    super.key,
    this.title,
    required this.child,
    this.actions = const [],
    this.showCloseButton = true,
    this.padding = const EdgeInsets.all(Oito2Spacing.lg),
  });

  /// The heading.
  final Widget? title;

  /// The body; scrollable content goes in a scroll view here.
  final Widget child;

  /// Buttons at the end of the header.
  final List<Widget> actions;

  /// Whether the header shows a close button.
  final bool showCloseButton;

  /// The space around the header and the body.
  final EdgeInsetsGeometry padding;

  /// Closes the closest sheet shown by [showOito2Sheet] with [result].
  static void close<T>(BuildContext context, [T? result]) {
    context.getInheritedWidgetOfExactType<_SheetScope>()?.close(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title;
    final hasHeader = title != null || actions.isNotEmpty || showCloseButton;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Oito2Spacing.md,
        children: [
          if (hasHeader)
            Row(
              spacing: Oito2Spacing.sm,
              children: [
                Expanded(
                  child: title == null
                      ? const SizedBox.shrink()
                      : Semantics(
                          header: true,
                          child: DefaultTextStyle.merge(
                            style: theme.textTheme.titleLarge,
                            child: title,
                          ),
                        ),
                ),
                ...actions,
                if (showCloseButton)
                  FieldIconButton(
                    icon: LucideIcons.x,
                    tooltip: Oito2Localizations.of(context).close,
                    onPressed: () => Oito2Sheet.close<Object?>(context),
                  ),
              ],
            ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _SheetConfig {
  const _SheetConfig({
    required this.side,
    required this.dismissible,
    required this.size,
    required this.snapPoints,
    required this.initialSnap,
    required this.semanticLabel,
    required this.modal,
  });

  final Oito2SheetSide side;
  final bool dismissible;
  final double? size;
  final List<double>? snapPoints;
  final int initialSnap;
  final String? semanticLabel;
  final bool modal;
}

class _SheetScope extends InheritedWidget {
  const _SheetScope({required this.close, required super.child});

  final void Function(Object? result) close;

  @override
  bool updateShouldNotify(_SheetScope oldWidget) => false;
}

class _Oito2SheetRoute<T> extends PopupRoute<T> {
  _Oito2SheetRoute({
    required this.builder,
    required this.config,
    required this.duration,
    required this.barrierColor,
    required this.barrierLabel,
  });

  final WidgetBuilder builder;
  final _SheetConfig config;
  final Duration duration;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => config.dismissible;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _SheetScope(
      close: (result) {
        if (!isActive) return;
        // The current route pops with its exit animation.
        isCurrent
            ? navigator?.pop<T>(result as T?)
            : navigator?.removeRoute(this, result as T?);
      },
      child: _SheetFrame(
        config: config,
        entrance: animation,
        onDismiss: () {
          if (isCurrent) navigator?.pop();
        },
        child: Builder(builder: builder),
      ),
    );
  }
}

class _NonModalSheetHost<T> extends StatefulWidget {
  const _NonModalSheetHost({
    required this.builder,
    required this.config,
    required this.duration,
    required this.onClosed,
    required this.onGone,
  });

  final WidgetBuilder builder;
  final _SheetConfig config;
  final Duration duration;
  final ValueChanged<T?> onClosed;
  final VoidCallback onGone;

  @override
  State<_NonModalSheetHost<T>> createState() => _NonModalSheetHostState<T>();
}

class _NonModalSheetHostState<T> extends State<_NonModalSheetHost<T>>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();
  bool _closing = false;
  bool _closed = false;

  @override
  void dispose() {
    if (!_closed) widget.onGone();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close(Object? result) async {
    if (_closing) return;
    _closing = true;
    try {
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // Disposed during the exit animation; dispose completes the future.
      return;
    }
    _closed = true;
    widget.onClosed(result as T?);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScope(
      close: _close,
      child: _SheetFrame(
        config: widget.config,
        entrance: _controller,
        onDismiss: () => _close(null),
        child: Builder(builder: widget.builder),
      ),
    );
  }
}

/// Positions, decorates and animates a sheet, and handles its drag,
/// snap points and keys.
class _SheetFrame extends StatefulWidget {
  const _SheetFrame({
    required this.config,
    required this.entrance,
    required this.onDismiss,
    required this.child,
  });

  final _SheetConfig config;
  final Animation<double> entrance;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_SheetFrame> createState() => _SheetFrameState();
}

class _SheetFrameState extends State<_SheetFrame>
    with SingleTickerProviderStateMixin {
  late int _snap = widget.config.initialSnap;

  /// The drag distance toward the sheet's edge, in pixels.
  double _drag = 0;
  double _extent = 0;
  late CurvedAnimation _entrance = _curve(widget.entrance);
  late final AnimationController _settle = AnimationController.unbounded(
    vsync: this,
  )..addListener(() => setState(() => _drag = _settle.value));

  _SheetConfig get _config => widget.config;
  bool get _bottom => _config.side == Oito2SheetSide.bottom;
  List<double>? get _snaps => _config.snapPoints;

  static CurvedAnimation _curve(Animation<double> parent) =>
      CurvedAnimation(parent: parent, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(_SheetFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entrance != widget.entrance) {
      _entrance.dispose();
      _entrance = _curve(widget.entrance);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _animateDrag(double to) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) {
      setState(() => _drag = to);
      return;
    }
    _settle
      ..value = _drag
      ..animateTo(
        to,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
  }

  void _setSnap(int index) {
    final snaps = _snaps;
    if (snaps == null) return;
    final clamped = index.clamp(0, snaps.length - 1);
    setState(() => _snap = clamped);
    _animateDrag(0);
  }

  /// The pixel offset of the current snap below the tallest one.
  double _snapOffset(double windowHeight) {
    final snaps = _snaps;
    if (snaps == null) return 0;
    return (snaps.last - snaps[_snap]) * windowHeight;
  }

  void _onDragUpdate(DragUpdateDetails details, bool forward) {
    _settle.stop();
    final delta = _bottom
        ? details.delta.dy
        : details.delta.dx * (forward ? 1 : -1);
    final floor = -_snapOffset(MediaQuery.sizeOf(context).height);
    setState(() => _drag = math.max(floor, _drag + delta));
  }

  void _onDragEnd(DragEndDetails details, bool forward, double windowHeight) {
    final velocity = _bottom
        ? details.velocity.pixelsPerSecond.dy
        : details.velocity.pixelsPerSecond.dx * (forward ? 1 : -1);
    final snaps = _snaps;
    if (snaps != null) {
      // Finds the snap closest to where the drag ends, moved one step by a
      // fling.
      final top = _snapOffset(windowHeight) + _drag;
      var best = 0;
      var bestDistance = double.infinity;
      for (var i = 0; i < snaps.length; i++) {
        final distance = ((snaps.last - snaps[i]) * windowHeight - top).abs();
        if (distance < bestDistance) {
          best = i;
          bestDistance = distance;
        }
      }
      if (velocity > 700) best = math.min(best, _snap - 1);
      if (velocity < -700) best = math.max(best, _snap + 1);
      if (best < 0 ||
          (_config.dismissible &&
              top > (snaps.last - snaps.first / 2) * windowHeight)) {
        if (_config.dismissible) {
          widget.onDismiss();
          return;
        }
        best = 0;
      }
      _snap = best.clamp(0, snaps.length - 1);
      _drag = top - _snapOffset(windowHeight);
      _animateDrag(0);
      return;
    }
    if (_config.dismissible && (_drag > _extent * 0.35 || velocity > 700)) {
      widget.onDismiss();
    } else {
      _animateDrag(0);
    }
  }

  Widget _handle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final snaps = _snaps;
    final pill = Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
    if (snaps == null || snaps.length < 2) {
      return Padding(
        padding: const EdgeInsets.only(top: Oito2Spacing.sm),
        child: Center(child: ExcludeSemantics(child: pill)),
      );
    }
    String percent(int index) => '${(snaps[index] * 100).round()}%';
    void up() => _setSnap(_snap + 1);
    void down() => _setSnap(_snap - 1);
    return Semantics(
      container: true,
      slider: true,
      label: Oito2Localizations.of(context).resizeSheet,
      value: percent(_snap),
      increasedValue: percent(math.min(_snap + 1, snaps.length - 1)),
      decreasedValue: percent(math.max(_snap - 1, 0)),
      onIncrease: _snap < snaps.length - 1 ? up : null,
      onDecrease: _snap > 0 ? down : null,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowUp): up,
          const SingleActivator(LogicalKeyboardKey.arrowDown): down,
          const SingleActivator(LogicalKeyboardKey.enter): () =>
              _setSnap((_snap + 1) % snaps.length),
          const SingleActivator(LogicalKeyboardKey.space): () =>
              _setSnap((_snap + 1) % snaps.length),
        },
        child: Focus(
          child: Builder(
            builder: (context) {
              final focused = Focus.of(context).hasFocus;
              return GestureDetector(
                onTap: () => _setSnap((_snap + 1) % snaps.length),
                child: Container(
                  height: Oito2Spacing.xl,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(Oito2Spacing.xxs),
                    decoration: BoxDecoration(
                      borderRadius: Oito2Radius.smallAll,
                      border: Border.all(
                        width: 2,
                        color: focused
                            ? scheme.primary
                            : const Color(0x00000000),
                      ),
                    ),
                    child: pill,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final window = media.size;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final side = _config.side;
    // Whether dragging toward the sheet's edge is a positive x delta.
    final forward = switch (side) {
      Oito2SheetSide.start => rtl,
      Oito2SheetSide.end => !rtl,
      Oito2SheetSide.bottom => true,
    };
    const radius = Radius.circular(Oito2Radius.window);
    final BorderRadius corners;
    final AlignmentGeometry alignment;
    final BoxConstraints box;
    switch (side) {
      case Oito2SheetSide.bottom:
        corners = const BorderRadius.vertical(top: radius);
        alignment = Alignment.bottomCenter;
        final snaps = _snaps;
        final maxWidth = math.min(window.width, 640.0);
        box = snaps == null
            ? BoxConstraints(maxWidth: maxWidth, maxHeight: window.height * 0.9)
            : BoxConstraints.tightFor(
                width: maxWidth,
                height: window.height * snaps.last,
              );
      case Oito2SheetSide.start || Oito2SheetSide.end:
        final left = forward == false;
        corners = left
            ? const BorderRadius.horizontal(right: radius)
            : const BorderRadius.horizontal(left: radius);
        alignment = left ? Alignment.centerLeft : Alignment.centerRight;
        box = BoxConstraints.tightFor(
          width: math.max(0, math.min(_config.size ?? 360, window.width - 48)),
          height: window.height,
        );
    }

    Widget sheet = Material(
      color: chromeColorsOf(context).dialog,
      shadowColor: theme.colorScheme.shadow,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: corners,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: side != Oito2SheetSide.bottom,
        child: side == Oito2SheetSide.bottom
            ? Column(
                mainAxisSize: _snaps == null
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _handle(context),
                  Flexible(child: widget.child),
                ],
              )
            : widget.child,
      ),
    );
    sheet = ConstrainedBox(constraints: box, child: sheet);
    sheet = GestureDetector(
      onVerticalDragUpdate: _bottom ? (d) => _onDragUpdate(d, forward) : null,
      onVerticalDragEnd: _bottom
          ? (d) => _onDragEnd(d, forward, window.height)
          : null,
      onHorizontalDragUpdate: _bottom ? null : (d) => _onDragUpdate(d, forward),
      onHorizontalDragEnd: _bottom
          ? null
          : (d) => _onDragEnd(d, forward, window.height),
      child: SizeReporter(
        onSize: (size) => _extent = _bottom ? size.height : size.width,
        child: sheet,
      ),
    );
    sheet = Semantics(
      scopesRoute: _config.modal,
      namesRoute: _config.modal,
      explicitChildNodes: true,
      label: _config.semanticLabel,
      child: sheet,
    );
    sheet = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onDismiss,
      },
      child: FocusScope(autofocus: _config.modal, child: sheet),
    );

    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: _entrance,
        builder: (context, child) {
          // The entrance moves by a fraction of the sheet's own size, which
          // needs no measured extent, so the first frame is already hidden.
          final hidden = 1 - _entrance.value;
          final fraction = switch (side) {
            Oito2SheetSide.bottom => Offset(0, hidden),
            _ => Offset(forward ? hidden : -hidden, 0),
          };
          final travel = math.max(0.0, _drag + _snapOffset(window.height));
          final offset = switch (side) {
            Oito2SheetSide.bottom => Offset(0, travel),
            _ => Offset(forward ? travel : -travel, 0),
          };
          return Transform.translate(
            offset: offset,
            child: FractionalTranslation(translation: fraction, child: child),
          );
        },
        child: sheet,
      ),
    );
  }
}
