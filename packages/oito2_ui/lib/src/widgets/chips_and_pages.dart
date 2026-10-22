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

import 'dart:math' as math;

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

/// A bar of [ChoiceChip]s for picking one or more filters.
///
/// In the [Oito2ChoiceChipBarStyle.row] style the chips scroll
/// horizontally, and arrow buttons and a soft edge shadow appear only on
/// the sides with hidden chips.
class Oito2ChoiceChipBar extends StatefulWidget {
  /// Creates a choice chip bar.
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
  }) : assert(labels.length == isSelected.length);

  /// The chip labels, usually [Text]s.
  final List<Widget> labels;

  /// Whether each chip is selected, in the order of [labels].
  final List<bool> isSelected;

  /// Called with the index of the activated chip; null disables the bar.
  final ValueChanged<int>? onSelected;

  /// How chips that don't fit are laid out.
  final Oito2ChoiceChipBarStyle style;

  /// Space between chips.
  final double spacing;

  /// How far one arrow button scrolls.
  final double scrollStep;

  /// The accessibility label of the backward arrow; defaults to
  /// [Oito2Localizations.scrollBack].
  final String? previousLabel;

  /// The accessibility label of the forward arrow; defaults to
  /// [Oito2Localizations.scrollForward].
  final String? nextLabel;

  @override
  State<Oito2ChoiceChipBar> createState() => _Oito2ChoiceChipBarState();
}

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

  List<Widget> _chips() => [
    for (var i = 0; i < widget.labels.length; i++)
      ChoiceChip(
        label: widget.labels[i],
        selected: widget.isSelected[i],
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
  const Oito2PageIndicator({
    super.key,
    required this.length,
    required this.page,
    this.onTap,
    this.dotSize = 8,
    this.spacing = Oito2Spacing.sm,
    this.layout = Oito2PageIndicatorLayout.fixed,
    this.pageLabel,
  }) : assert(page >= 0 && page < length);

  /// The number of pages.
  final int length;

  /// The current page, from 0.
  final int page;

  /// Called with the index of the activated dot.
  final ValueChanged<int>? onTap;

  /// The diameter of the dots.
  final double dotSize;

  /// Space between dots; [layout] may reduce it.
  final double spacing;

  /// How the dots are spaced.
  final Oito2PageIndicatorLayout layout;

  /// Builds the accessibility label of a dot from its 1-based page number
  /// and the page count; defaults to [Oito2Localizations.pageOf].
  final String Function(int page, int length)? pageLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = semanticColorsOf(context).primaryText;
    final pageLabel = this.pageLabel ?? Oito2Localizations.of(context).pageOf;
    final selectedWidth = dotSize * 3;
    final dots = selectedWidth + (length - 1) * dotSize + 16;
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
            math.min(this.spacing, (constraints.maxWidth - dots) / gaps),
          ),
        };
        if (constraints.maxWidth < dots + (length - 1) * spacing) {
          return Semantics(
            label: pageLabel(page + 1, length),
            excludeSemantics: true,
            child: Text(
              '${page + 1} / $length',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: [
            for (var i = 0; i < length; i++)
              Semantics(
                button: onTap != null,
                selected: i == page,
                label: pageLabel(i + 1, length),
                excludeSemantics: true,
                onTap: onTap == null ? null : () => onTap!(i),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap == null ? null : () => onTap!(i),
                  child: MouseRegion(
                    cursor: onTap == null
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: math.max(0, (24 - dotSize) / 2),
                      ),
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
      },
    );
  }
}
