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

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'anchored_panel.dart';

/// One step of an [Oito2Tour].
@immutable
class Oito2TourStep {
  /// Creates a tour step.
  const Oito2TourStep({
    required this.title,
    this.target,
    this.description,
    this.placement = Oito2PopoverPlacement.bottom,
    this.waitForTap = false,
    this.spotlightPadding = 6,
  });

  /// The heading of the step card.
  final String title;

  /// The key of the widget the step points at; the card is centered in
  /// the tour layer when null or when the widget isn't built.
  final GlobalKey? target;

  /// The body text of the step card, below [title].
  final String? description;

  /// The side of the target where the card opens.
  final Oito2PopoverPlacement placement;

  /// Whether the step waits for a tap on the target instead of offering
  /// a next button. The tap reaches the target, then the tour moves on.
  /// While the target isn't on screen, the next button shows instead.
  final bool waitForTap;

  /// The space around the target inside the spotlight, in logical
  /// pixels.
  final double spotlightPadding;
}

/// Runs an [Oito2Tour] through its [steps], notifying its listeners on
/// every step change and when the tour ends.
class Oito2TourController extends ChangeNotifier {
  /// Creates a tour controller that isn't running yet.
  ///
  /// Throws an [AssertionError] in debug builds when [steps] is empty.
  Oito2TourController({required this.steps}) : assert(steps.isNotEmpty);

  /// The steps, in order.
  final List<Oito2TourStep> steps;

  int? _index;
  bool _completed = false;

  /// The index of the current step, or null when the tour isn't running.
  int? get index => _index;

  /// The current step, or null when the tour isn't running.
  Oito2TourStep? get step => _index == null ? null : steps[_index!];

  /// Whether the tour is running.
  bool get isActive => _index != null;

  /// Whether the last run reached the end, rather than being skipped;
  /// false while a run is in progress.
  bool get completed => _completed;

  /// Starts the tour, or restarts it, at the step at [index].
  ///
  /// Throws an [AssertionError] in debug builds when [index] is out of
  /// range.
  void start([int index = 0]) => goTo(index);

  /// Shows the step at [index], starting the tour when it isn't running.
  ///
  /// Throws an [AssertionError] in debug builds when [index] is out of
  /// range.
  void goTo(int index) {
    assert(index >= 0 && index < steps.length);
    _index = index;
    _completed = false;
    notifyListeners();
  }

  /// Moves to the next step, or completes the tour after the last; does
  /// nothing when the tour isn't running.
  void next() {
    final index = _index;
    if (index == null) return;
    if (index + 1 < steps.length) {
      goTo(index + 1);
    } else {
      _finish(completed: true);
    }
  }

  /// Moves to the previous step; does nothing on the first step or when
  /// the tour isn't running.
  void previous() {
    final index = _index;
    if (index != null && index > 0) goTo(index - 1);
  }

  /// Ends the tour without completing it; does nothing when it isn't
  /// running.
  void skip() => _finish(completed: false);

  /// Stops the running tour, recording whether it was [completed].
  void _finish({required bool completed}) {
    if (_index == null) return;
    _index = null;
    _completed = completed;
    notifyListeners();
  }
}

/// A guided tour over [child]: each step of the [controller] dims the
/// window around its target, scrolls it into view and shows a card with
/// the step text, its position, and back, next and skip buttons.
///
/// The card takes the focus and is announced to assistive technologies;
/// when the tour ends, the focus returns to where it was before. While the
/// card has focus, the arrow keys move between steps and Escape skips the
/// tour. Taps outside the spotlight are blocked; taps inside reach the
/// target, which moves a [Oito2TourStep.waitForTap] step on.
class Oito2Tour extends StatefulWidget {
  /// Creates a tour.
  const Oito2Tour({
    super.key,
    required this.controller,
    required this.child,
    this.onFinished,
  });

  /// The steps and the current position.
  final Oito2TourController controller;

  /// The content the tour runs over.
  final Widget child;

  /// Called when the tour ends, with true when it was completed and false
  /// when it was skipped.
  final ValueChanged<bool>? onFinished;

  @override
  State<Oito2Tour> createState() => _Oito2TourState();
}

class _Oito2TourState extends State<Oito2Tour> with TickerProviderStateMixin {
  final _portal = OverlayPortalController();
  bool _watching = false;
  int _watchRun = 0;
  late final AnimationController _move = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  final _layerKey = GlobalKey();
  Rect? _target;
  Rect? _from;
  int? _shownIndex;
  FocusNode? _previousFocus;

  Oito2TourController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_sync);
    if (_controller.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void didUpdateWidget(Oito2Tour oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
      // Showing or hiding the overlay isn't allowed during a build.
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _move.dispose();
    super.dispose();
  }

  /// Shows, moves or hides the tour layer to match the controller.
  void _sync() {
    if (!mounted) return;
    final index = _controller.index;
    if (index == null) {
      if (_portal.isShowing) {
        _portal.hide();
        _watching = false;
        _shownIndex = null;
        setState(() {});
        // The focus goes back to where it was before the tour.
        final previous = _previousFocus;
        _previousFocus = null;
        if (previous?.context?.mounted ?? false) previous!.requestFocus();
        widget.onFinished?.call(_controller.completed);
      }
      return;
    }
    if (index == _shownIndex) return;
    _shownIndex = index;
    _from = _displayed;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _move.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 250);
    _move.forward(from: 0);
    final targetContext = _controller.steps[index].target?.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.5,
        duration: _move.duration!,
      );
    }
    if (!_portal.isShowing) {
      _previousFocus = FocusManager.instance.primaryFocus;
      _portal.show();
    }
    if (!_watching) {
      _watching = true;
      _watch(++_watchRun);
    }
    _track();
    setState(() {});
  }

  /// Tracks the target after every frame while the tour runs, without
  /// asking for frames itself.
  void _watch(int run) {
    if (!mounted || !_watching || run != _watchRun) return;
    _track();
    SchedulerBinding.instance.addPostFrameCallback((_) => _watch(run));
  }

  /// Reads the target rectangle in the tour layer's coordinates.
  void _track() {
    final step = _controller.step;
    final targetBox = step?.target?.currentContext?.findRenderObject();
    final layerBox = _layerKey.currentContext?.findRenderObject();
    Rect? rect;
    if (step != null &&
        targetBox is RenderBox &&
        targetBox.attached &&
        targetBox.hasSize &&
        layerBox is RenderBox &&
        layerBox.attached) {
      final topLeft = targetBox.localToGlobal(Offset.zero, ancestor: layerBox);
      rect = (topLeft & targetBox.size).inflate(step.spotlightPadding);
    }
    if (rect != _target) setState(() => _target = rect);
  }

  /// The spotlight between the previous and the current target.
  Rect? get _displayed {
    final target = _target;
    final from = _from;
    if (target == null || from == null || _move.isCompleted) return target;
    return Rect.lerp(from, target, Curves.easeOutCubic.transform(_move.value));
  }

  /// Moves a [Oito2TourStep.waitForTap] step on when [event] lands inside
  /// the target.
  void _onPointerUp(PointerUpEvent event) {
    final step = _controller.step;
    final target = _target;
    if (step == null || !step.waitForTap || target == null) return;
    if (!target.contains(event.localPosition)) return;
    final index = _controller.index;
    // Moves on after the tap has reached the target.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.index == index) _controller.next();
    });
  }

  /// Builds the content of the card of [step], the step at [index].
  Widget _buildCard(BuildContext context, int index, Oito2TourStep step) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final last = index == _controller.steps.length - 1;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final description = step.description;
    // A step waits for a tap only while its target is on screen to tap.
    final waits = step.waitForTap && _target != null;
    return FocusScope(
      key: ValueKey(index),
      autofocus: true,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _controller.skip,
          const SingleActivator(LogicalKeyboardKey.arrowRight): rtl
              ? _controller.previous
              : _controller.next,
          const SingleActivator(LogicalKeyboardKey.arrowLeft): rtl
              ? _controller.next
              : _controller.previous,
        },
        child: Semantics(
          container: true,
          liveRegion: true,
          explicitChildNodes: true,
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                Oito2Spacing.lg,
                Oito2Spacing.sm,
                Oito2Spacing.sm,
                Oito2Spacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Oito2Spacing.xs,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            step.title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: strings.tourSkip,
                        onPressed: _controller.skip,
                        autofocus: waits,
                        icon: const Icon(LucideIcons.x, size: 16),
                      ),
                    ],
                  ),
                  if (description != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: Oito2Spacing.sm,
                      ),
                      child: Text(description),
                    ),
                  const SizedBox(height: Oito2Spacing.xs),
                  Row(
                    spacing: Oito2Spacing.sm,
                    children: [
                      Expanded(
                        child: Text(
                          strings.tourProgress(
                            index + 1,
                            _controller.steps.length,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (index > 0)
                        TextButton(
                          onPressed: _controller.previous,
                          child: Text(strings.tourBack),
                        ),
                      if (!waits)
                        FilledButton(
                          autofocus: true,
                          onPressed: _controller.next,
                          child: Text(
                            last ? strings.tourDone : strings.tourNext,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the overlay with the dimmed backdrop, the spotlight and the
  /// card of the current step.
  Widget _buildLayer(BuildContext context) {
    final index = _controller.index;
    if (index == null) return const SizedBox.shrink();
    final step = _controller.steps[index];
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final card = DefaultTextStyle.merge(
      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      child: _buildCard(context, index, step),
    );
    // The content under the tour is hidden from assistive technologies.
    return BlockSemantics(
      child: AnimatedBuilder(
        key: _layerKey,
        animation: _move,
        builder: (context, _) {
          final hole = _displayed;
          final target = _target;
          return Stack(
            fit: StackFit.expand,
            children: [
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerUp: _onPointerUp,
                child: CustomPaint(
                  painter: _SpotlightPainter(
                    hole: hole,
                    color: scheme.scrim.withValues(alpha: 0.5),
                  ),
                ),
              ),
              if (target == null)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Material(
                      color: scheme.surfaceContainer,
                      elevation: 4,
                      shadowColor: scheme.shadow,
                      shape: RoundedRectangleBorder(
                        borderRadius: Oito2Radius.mediumAll,
                        side: BorderSide(color: scheme.outlineVariant),
                      ),
                      child: card,
                    ),
                  ),
                )
              else
                AnchoredPanel(
                  anchor: target,
                  placement: step.placement,
                  alignment: Oito2PopoverAlignment.center,
                  textDirection: Directionality.of(context),
                  color: scheme.surfaceContainer,
                  borderColor: scheme.outlineVariant,
                  shadowColor: scheme.shadow,
                  gap: 2,
                  arrowSize: const Size(14, 7),
                  maxWidth: 320,
                  radius: Oito2Radius.medium,
                  child: card,
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: _buildLayer,
      child: widget.child,
    );
  }
}

/// Dims everything but [hole], and takes the pointer events outside it.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.hole, required this.color});

  final Rect? hole;
  final Color color;

  /// The rounded spotlight shape, or null when there is no hole.
  RRect? get _hole {
    final hole = this.hole;
    return hole == null
        ? null
        : RRect.fromRectAndRadius(
            hole,
            const Radius.circular(Oito2Radius.medium),
          );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    final hole = _hole;
    if (hole != null) path.addRRect(hole);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool hitTest(Offset position) => !(_hole?.contains(position) ?? false);

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.color != color;
}
