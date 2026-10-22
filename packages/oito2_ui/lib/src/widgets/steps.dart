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

import 'package:flutter_lucide/flutter_lucide.dart';

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// One step of an [Oito2Steps].
@immutable
class Oito2Step {
  /// Creates a step.
  const Oito2Step({
    required this.title,
    this.description,
    this.content,
    this.hasError = false,
  });

  /// The step name.
  final String title;

  /// A short second line.
  final String? description;

  /// The content shown while the step is current.
  final Widget? content;

  /// Whether the step shows the error state.
  final bool hasError;
}

/// A step indicator: [steps] in order, those before [current] completed,
/// with the content of the current step.
///
/// A step is tapped to move to it through [onStepTapped]. With [linear]
/// only the completed steps and the current one can be reached; otherwise
/// any step can. The steps run in a row with the content below, or in a
/// column with the content under the current step.
class Oito2Steps extends StatelessWidget {
  /// Creates a step indicator.
  const Oito2Steps({
    super.key,
    required this.steps,
    required this.current,
    this.onStepTapped,
    this.axis = Axis.horizontal,
    this.linear = true,
  }) : assert(current >= 0);

  /// The steps.
  final List<Oito2Step> steps;

  /// The index of the current step; [steps].length when all are done.
  final int current;

  /// Called with the index of a tapped step that can be reached.
  final ValueChanged<int>? onStepTapped;

  /// Whether the steps run in a row or a column.
  final Axis axis;

  /// Whether only completed steps and the current one can be reached.
  final bool linear;

  bool _reachable(int index) => !linear || index <= current;

  @override
  Widget build(BuildContext context) {
    final content = current < steps.length ? steps[current].content : null;
    if (axis == Axis.horizontal) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Oito2Spacing.lg,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Each header gets at most an equal share of the width, so
              // long titles wrap and fade instead of overflowing.
              final headerWidth = math.min(
                _maxHeaderWidth,
                constraints.maxWidth / steps.length,
              );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    if (i > 0)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 14,
                            left: Oito2Spacing.sm,
                            right: Oito2Spacing.sm,
                          ),
                          child: _Connector(
                            done: i <= current,
                            vertical: false,
                          ),
                        ),
                      ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: headerWidth),
                      child: _StepHeader(
                        index: i,
                        steps: this,
                        vertical: false,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          ?content,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++)
          Stack(
            children: [
              if (i < steps.length - 1)
                PositionedDirectional(
                  start: 0,
                  width: _indicatorSize,
                  top: _indicatorSize + Oito2Spacing.xs,
                  bottom: Oito2Spacing.xs,
                  child: _Connector(done: i < current, vertical: true),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Indicator(index: i, steps: this),
                  const SizedBox(width: Oito2Spacing.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: Oito2Spacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Oito2Spacing.sm,
                        children: [
                          _StepHeader(index: i, steps: this, vertical: true),
                          if (i == current && steps[i].content != null)
                            steps[i].content!,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

const _indicatorSize = 28.0;
const _maxHeaderWidth = 160.0;

enum _StepState { upcoming, current, completed, error }

_StepState _stateOf(Oito2Steps steps, int index) {
  if (steps.steps[index].hasError) return _StepState.error;
  if (index < steps.current) return _StepState.completed;
  if (index == steps.current) return _StepState.current;
  return _StepState.upcoming;
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.index, required this.steps});

  final int index;
  final Oito2Steps steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = semanticColorsOf(context);
    final fill = selectedFillOf(context);
    final state = _stateOf(steps, index);
    final (background, border, foreground) = switch (state) {
      _StepState.completed => (fill.fill, fill.fill, fill.onFill),
      _StepState.current => (null, semantic.primaryText, semantic.primaryText),
      _StepState.error => (null, semantic.errorText, semantic.errorText),
      _StepState.upcoming => (null, scheme.outline, scheme.onSurfaceVariant),
    };
    return Container(
      width: _indicatorSize,
      height: _indicatorSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(
          color: border,
          width: state == _StepState.current ? 2 : 1.5,
        ),
      ),
      child: switch (state) {
        _StepState.completed => Icon(
          LucideIcons.check,
          size: 16,
          color: foreground,
        ),
        _StepState.error => Icon(LucideIcons.x, size: 16, color: foreground),
        _ => Text(
          '${index + 1}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      },
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.done, required this.vertical});

  final bool done;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? selectedFillOf(context).fill
        : Theme.of(context).colorScheme.outlineVariant;
    return Center(
      child: Container(
        width: vertical ? 2 : double.infinity,
        height: vertical ? double.infinity : 2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.index,
    required this.steps,
    required this.vertical,
  });

  final int index;
  final Oito2Steps steps;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final step = steps.steps[index];
    final state = _stateOf(steps, index);
    final reachable = steps._reachable(index) && steps.onStepTapped != null;
    final description = step.description;
    final text = Column(
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          step.title,
          textAlign: vertical ? TextAlign.start : TextAlign.center,
          maxLines: vertical ? null : 2,
          overflow: vertical ? null : TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: state == _StepState.upcoming
                ? scheme.onSurfaceVariant
                : state == _StepState.error
                ? semanticColorsOf(context).errorText
                : scheme.onSurface,
          ),
        ),
        if (description != null)
          Text(
            description,
            textAlign: vertical ? TextAlign.start : TextAlign.center,
            maxLines: vertical ? null : 2,
            overflow: vertical ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
      ],
    );
    final header = vertical
        ? Padding(padding: const EdgeInsets.only(top: 4), child: text)
        : Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.xs,
            children: [
              _Indicator(index: index, steps: steps),
              text,
            ],
          );
    final stateLabel = switch (state) {
      _StepState.completed => strings.stepCompleted,
      _StepState.current => strings.stepCurrent,
      _StepState.error => strings.stepError,
      _StepState.upcoming => null,
    };
    final label = [
      step.title,
      strings.stepOf(index + 1, steps.steps.length),
      ?stateLabel,
    ].join(', ');
    return Semantics(
      button: reachable,
      selected: state == _StepState.current,
      label: label,
      excludeSemantics: true,
      onTap: reachable ? () => steps.onStepTapped!(index) : null,
      child: Oito2FocusBorder(
        borderRadius: Oito2Radius.smallAll,
        child: InkWell(
          onTap: reachable ? () => steps.onStepTapped!(index) : null,
          borderRadius: Oito2Radius.smallAll,
          child: Padding(
            padding: const EdgeInsets.all(Oito2Spacing.xxs),
            child: header,
          ),
        ),
      ),
    );
  }
}
