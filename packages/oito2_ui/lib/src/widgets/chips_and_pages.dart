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

import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// How an [Oito2ChoiceChipBar] lays out chips that don't fit.
enum Oito2ChoiceChipBarStyle {
  /// One scrollable row with arrow buttons at the edges that overflow.
  row,

  /// Several rows that wrap.
  wrap,
}

/// A bar of [ChoiceChip]s for picking one or more filters, shaped by the
/// chip theme unless [shape] is given.
///
/// A selected chip shows the secondary container fill and, with
/// [showCheckmark], a check mark before its label.
///
/// In the [Oito2ChoiceChipBarStyle.row] style the chips scroll
/// horizontally, and arrow buttons and a soft edge shadow appear only on
/// the sides with hidden chips.
class Oito2ChoiceChipBar extends StatefulWidget {
  /// Creates a choice chip bar.
  ///
  /// Throws an [AssertionError] in debug builds when [labels] and
  /// [isSelected] differ in length.
  const Oito2ChoiceChipBar({
    super.key,
    required this.labels,
    required this.isSelected,
    required this.onSelected,
    this.style = Oito2ChoiceChipBarStyle.row,
    this.spacing = Oito2Spacing.sm,
    this.scrollStep = 200,
    this.previousLabel,
    this.nextLabel,
    this.showCheckmark = true,
    this.shape,
  }) : assert(labels.length == isSelected.length);

  /// The chip labels, usually [Text]s.
  final List<Widget> labels;

  /// Whether each chip is selected, in the order of [labels].
  final List<bool> isSelected;

  /// Called with the index of the activated chip; null disables the bar.
  final ValueChanged<int>? onSelected;

  /// How chips that don't fit are laid out.
  final Oito2ChoiceChipBarStyle style;

  /// The space between chips, and between rows in the wrap style.
  final double spacing;

  /// The distance, in logical pixels, one arrow button press scrolls.
  final double scrollStep;

  /// The tooltip and accessibility label of the backward arrow; defaults
  /// to [Oito2Localizations.scrollBack].
  final String? previousLabel;

  /// The tooltip and accessibility label of the forward arrow; defaults
  /// to [Oito2Localizations.scrollForward].
  final String? nextLabel;

  /// Whether a selected chip shows a check mark; without it only the fill
  /// marks the selection.
  final bool showCheckmark;

  /// The outline of the chips, such as a `StadiumBorder` for pills; the
  /// chip theme's rounded rectangle when null.
  final OutlinedBorder? shape;

  @override
  State<Oito2ChoiceChipBar> createState() => _Oito2ChoiceChipBarState();
}

/// Tracks which edges of the [Oito2ChoiceChipBar] row hide chips, to show
/// the matching arrow buttons.
class _Oito2ChoiceChipBarState extends State<Oito2ChoiceChipBar> {
  final _controller = ScrollController();
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Recomputes whether chips are hidden before or after the visible
  /// part and rebuilds when that changes.
  void _update() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final back = position.pixels > position.minScrollExtent;
    final forward = position.pixels < position.maxScrollExtent;
    if (back != _canGoBack || forward != _canGoForward) {
      setState(() {
        _canGoBack = back;
        _canGoForward = forward;
      });
    }
  }

  /// Scrolls the row by [delta], within its extent, animating unless
  /// animations are disabled.
  void _scrollBy(double delta) {
    final position = _controller.position;
    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    final duration = motionDuration(context, const Duration(milliseconds: 200));
    duration == Duration.zero
        ? _controller.jumpTo(target)
        : _controller.animateTo(
            target,
            duration: duration,
            curve: Curves.easeOut,
          );
  }

  /// Builds one [ChoiceChip] per label.
  List<Widget> _chips() => [
    for (var i = 0; i < widget.labels.length; i++)
      ChoiceChip(
        label: widget.labels[i],
        selected: widget.isSelected[i],
        showCheckmark: widget.showCheckmark,
        shape: widget.shape,
        mouseCursor: WidgetStateMouseCursor.clickable,
        onSelected: widget.onSelected == null
            ? null
            : (_) => widget.onSelected!(i),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.style == Oito2ChoiceChipBarStyle.wrap) {
      return Wrap(
        spacing: widget.spacing,
        runSpacing: widget.spacing,
        children: _chips(),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _update();
    });
    Widget arrow(bool forward) => IconButton(
      tooltip: forward
          ? widget.nextLabel ?? Oito2Localizations.of(context).scrollForward
          : widget.previousLabel ?? Oito2Localizations.of(context).scrollBack,
      onPressed: () =>
          _scrollBy(forward ? widget.scrollStep : -widget.scrollStep),
      icon: Icon(directionalChevron(context, forward: forward)),
    );
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _update();
        return false;
      },
      child: Row(
        children: [
          if (_canGoBack) arrow(false),
          Expanded(
            child: Oito2ScrollViewUndershoot(
              child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                child: Row(spacing: widget.spacing, children: _chips()),
              ),
            ),
          ),
          if (_canGoForward) arrow(true),
        ],
      ),
    );
  }
}

/// How an [Oito2PageIndicator] spaces its dots.
enum Oito2PageIndicatorLayout {
  /// Always [Oito2PageIndicator.spacing] apart.
  fixed,

  /// Closer together as pages are added: the full spacing up to 5 pages,
  /// three quarters up to 10 and half beyond.
  stepped,

  /// The full spacing when it fits, otherwise as close as needed to fit
  /// the width, down to half the dot size.
  bounded,
}

/// Dots showing the current page of a carousel or a paged view.
///
/// The current page is a wider pill in the text-safe primary tone. Each
/// dot is a button when [onTap] is given. When the dots don't fit the
/// available width, the indicator shows "page / length" text instead.
class Oito2PageIndicator extends StatelessWidget {
  /// Creates a page indicator.
  ///
  /// Throws an [AssertionError] in debug builds when [page] is not
  /// between 0 and [length] - 1.
  const Oito2PageIndicator({
    super.key,
    required this.length,
    required this.page,
    this.onTap,
    this.dotSize = 8,
    this.spacing = Oito2Spacing.sm,
    this.layout = Oito2PageIndicatorLayout.fixed,
    this.pageLabel,
    this.minTargetSize = 24,
  }) : assert(page >= 0 && page < length),
       assert(minTargetSize >= 0);

  /// The number of pages.
  final int length;

  /// The current page, from 0.
  final int page;

  /// Called with the index of the activated dot; the dots are not
  /// interactive when null.
  final ValueChanged<int>? onTap;

  /// The diameter of the dots.
  final double dotSize;

  /// The space between dots; [layout] may reduce it.
  final double spacing;

  /// How the dots are spaced.
  final Oito2PageIndicatorLayout layout;

  /// Builds the accessibility label of a dot from its 1-based page number
  /// and the page count; defaults to [Oito2Localizations.pageOf].
  final String Function(int page, int length)? pageLabel;

  /// The smallest width and height of an interactive dot's target; the
  /// spacing between dots absorbs as much of it as it can.
  ///
  /// Defaults to 24 logical pixels. A smaller value, down to 0 for targets
  /// the size of the dots, suits an indicator whose pages another control,
  /// such as previous and next buttons, also reaches.
  final double minTargetSize;

  /// Moves to the page the arrow, Home or End key of [event] points at.
  KeyEventResult _onKey(BuildContext context, KeyEvent event) {
    final onTap = this.onTap;
    if (onTap == null || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final (:back, :forward) = readingArrowsOf(context);
    final key = event.logicalKey;
    final int target;
    if (key == back) {
      target = page - 1;
    } else if (key == forward) {
      target = page + 1;
    } else if (key == LogicalKeyboardKey.home) {
      target = 0;
    } else if (key == LogicalKeyboardKey.end) {
      target = length - 1;
    } else {
      return KeyEventResult.ignored;
    }
    if (target >= 0 && target < length && target != page) onTap(target);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = semanticColorsOf(context).primaryText;
    final pageLabel = this.pageLabel ?? Oito2Localizations.of(context).pageOf;
    final interactive = onTap != null;
    final selectedWidth = dotSize * 3;
    // Interactive dots sit in boxes at least minTargetSize wide, which the
    // spacing between them absorbs as far as it can.
    double boxWidth(double width) =>
        interactive ? math.max(width, minTargetSize) : width;
    final boxes = boxWidth(selectedWidth) + (length - 1) * boxWidth(dotSize);
    final absorbed = boxWidth(dotSize) - dotSize;
    final gaps = math.max(1, length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = switch (layout) {
          Oito2PageIndicatorLayout.fixed => this.spacing,
          Oito2PageIndicatorLayout.stepped =>
            length <= 5
                ? this.spacing
                : length <= 10
                ? this.spacing * 0.75
                : this.spacing * 0.5,
          Oito2PageIndicatorLayout.bounded => math.max(
            dotSize / 2,
            math.min(
              this.spacing,
              (constraints.maxWidth - boxes) / gaps + absorbed,
            ),
          ),
        };
        final gap = math.max(0.0, spacing - absorbed);
        if (constraints.maxWidth < boxes + (length - 1) * gap) {
          return Semantics(
            label: pageLabel(page + 1, length),
            excludeSemantics: true,
            child: Text(
              '${page + 1} / $length',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          );
        }
        Widget dots = Row(
          mainAxisSize: MainAxisSize.min,
          spacing: gap,
          children: [
            for (var i = 0; i < length; i++)
              Semantics(
                button: interactive,
                selected: i == page,
                label: pageLabel(i + 1, length),
                excludeSemantics: true,
                onTap: interactive ? () => onTap!(i) : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: interactive ? () => onTap!(i) : null,
                  child: MouseRegion(
                    cursor: interactive
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    child: Container(
                      width: boxWidth(i == page ? selectedWidth : dotSize),
                      height: math.max(minTargetSize, dotSize),
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: motionDuration(
                          context,
                          const Duration(milliseconds: 200),
                        ),
                        curve: Curves.easeOut,
                        width: i == page ? selectedWidth : dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: i == page ? active : scheme.outline,
                          borderRadius: BorderRadius.circular(dotSize / 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
        if (interactive) {
          // The dots are one stop in keyboard navigation; the arrow keys,
          // Home and End change the page.
          dots = Oito2FocusBorder(
            borderRadius: Oito2Radius.smallAll,
            child: Focus(
              onKeyEvent: (_, event) => _onKey(context, event),
              child: dots,
            ),
          );
        }
        return dots;
      },
    );
  }
}
