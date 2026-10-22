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
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'chips_and_pages.dart';
import 'icon_buttons.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// Controls an [Oito2Carousel]: the current page, page changes and
/// automatic scrolling.
///
/// With [autoScroll], the carousel moves to the next page every
/// [autoScrollInterval], wrapping to the first, while no pointer hovers it
/// and nothing inside it has focus. It never scrolls by itself when
/// animations are disabled.
class Oito2CarouselController extends PageController {
  /// Creates a carousel controller.
  Oito2CarouselController({
    super.initialPage,
    super.viewportFraction,
    this.autoScroll = false,
    this.autoScrollInterval = const Duration(seconds: 4),
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeInOutCubic,
  });

  /// Whether the carousel advances by itself.
  final bool autoScroll;

  /// The time each page stays before the next one when [autoScroll].
  final Duration autoScrollInterval;

  /// The duration of page changes.
  final Duration animationDuration;

  /// The curve of page changes.
  final Curve animationCurve;

  /// The current page, rounded; 0 before the carousel is shown.
  int get currentPage => hasClients ? (page ?? 0).round() : initialPage;

  /// Animates to [index], or jumps there when [animate] is false.
  Future<void> goTo(int index, {bool animate = true}) async {
    if (!hasClients) return;
    if (animate) {
      await animateToPage(
        index,
        duration: animationDuration,
        curve: animationCurve,
      );
    } else {
      jumpToPage(index);
    }
  }
}

/// A row of pages shown one at a time, with previous and next buttons and
/// an [Oito2PageIndicator] below.
///
/// Pages change by the buttons, the dots, the Left and Right arrow keys
/// while the carousel has focus (it takes focus as a whole and shows the
/// focus ring), or a swipe (also with a mouse). The
/// buttons and arrows wrap around when [loop] is true, jumping straight
/// to the other end. Automatic
/// scrolling comes from an [Oito2CarouselController].
class Oito2Carousel extends StatefulWidget {
  /// Creates a carousel.
  const Oito2Carousel({
    super.key,
    required this.children,
    this.controller,
    this.height = 240,
    this.navigationControls = true,
    this.pageIndicator = true,
    this.loop = true,
    this.onPageChanged,
  });

  /// The pages.
  final List<Widget> children;

  /// The controller; one without automatic scrolling is created when null.
  final Oito2CarouselController? controller;

  /// The height of the pages.
  final double height;

  /// Whether previous and next buttons sit over the pages.
  final bool navigationControls;

  /// Whether an [Oito2PageIndicator] sits below the pages.
  final bool pageIndicator;

  /// Whether going past the last page returns to the first, and back.
  final bool loop;

  /// Called with the new page index.
  final ValueChanged<int>? onPageChanged;

  @override
  State<Oito2Carousel> createState() => _Oito2CarouselState();
}

class _Oito2CarouselState extends State<Oito2Carousel>
    with OwnedControllerMixin<Oito2Carousel, Oito2CarouselController> {
  Timer? _timer;
  bool _hovered = false;
  bool _focused = false;
  late int _page = _controller.initialPage;

  @override
  Oito2CarouselController? get widgetController => widget.controller;

  @override
  Oito2CarouselController createOwnedController() => Oito2CarouselController();

  Oito2CarouselController get _controller => effectiveController;

  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced != _reduced) {
      _reduced = reduced;
      _schedule();
    }
  }

  /// Restarts the timer only when what it depends on changes, so a parent
  /// that rebuilds often doesn't keep postponing the next page.
  @override
  void didUpdateWidget(Oito2Carousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.children.length < 2) != (widget.children.length < 2)) {
      _schedule();
    }
  }

  @override
  void didChangeController(Oito2CarouselController previous) {
    _page = _controller.currentPage;
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Restarts the automatic scrolling timer when it should run.
  void _schedule() {
    _timer?.cancel();
    final controller = _controller;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!controller.autoScroll ||
        reduced ||
        _hovered ||
        _focused ||
        widget.children.length < 2) {
      return;
    }
    _timer = Timer.periodic(controller.autoScrollInterval, (_) {
      if (mounted) _step(1, loop: true);
    });
  }

  void _step(int step, {bool? loop}) {
    final count = widget.children.length;
    if (count == 0) return;
    var target = _page + step;
    var wraps = false;
    if (loop ?? widget.loop) {
      wraps = target < 0 || target >= count;
      target %= count;
    } else {
      target = target.clamp(0, count - 1);
    }
    if (target == _page) return;
    // Wrapping around jumps, instead of sliding through every page.
    unawaited(_controller.goTo(target, animate: !wraps));
  }

  void _setHovered(bool value) {
    _hovered = value;
    _schedule();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final localizations = MaterialLocalizations.of(context);
    final canBack = widget.loop || _page > 0;
    final canForward = widget.loop || _page < count - 1;
    final scheme = Theme.of(context).colorScheme;

    Widget navButton(IconData icon, String tooltip, int step, bool enabled) =>
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.85),
            borderRadius: Oito2Radius.mediumAll,
          ),
          child: Oito2IconButton(
            icon: Icon(icon),
            tooltip: tooltip,
            onPressed: enabled && count > 1 ? () => _step(step) : null,
          ),
        );

    final pages = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      child: PageView(
        controller: _controller,
        onPageChanged: (page) {
          setState(() => _page = page);
          widget.onPageChanged?.call(page);
          _schedule();
        },
        children: widget.children,
      ),
    );

    return Oito2FocusBorder(
      borderRadius: Oito2Radius.largeAll,
      child: Focus(
        onFocusChange: (value) {
          _focused = value;
          _schedule();
        },
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final forward = rtl
              ? LogicalKeyboardKey.arrowLeft
              : LogicalKeyboardKey.arrowRight;
          final back = rtl
              ? LogicalKeyboardKey.arrowRight
              : LogicalKeyboardKey.arrowLeft;
          if (event.logicalKey == forward) {
            _step(1);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == back) {
            _step(-1);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: widget.height,
                child: Stack(
                  children: [
                    Positioned.fill(child: pages),
                    if (widget.navigationControls) ...[
                      PositionedDirectional(
                        start: Oito2Spacing.sm,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: navButton(
                            rtl
                                ? LucideIcons.chevron_right
                                : LucideIcons.chevron_left,
                            localizations.previousPageTooltip,
                            -1,
                            canBack,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        end: Oito2Spacing.sm,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: navButton(
                            rtl
                                ? LucideIcons.chevron_left
                                : LucideIcons.chevron_right,
                            localizations.nextPageTooltip,
                            1,
                            canForward,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.pageIndicator && count > 1)
                Padding(
                  padding: const EdgeInsets.only(top: Oito2Spacing.sm),
                  child: Oito2PageIndicator(
                    length: count,
                    page: _page.clamp(0, count - 1),
                    layout: Oito2PageIndicatorLayout.bounded,
                    onTap: (page) => unawaited(_controller.goTo(page)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
