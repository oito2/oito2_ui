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

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'copy.dart';
import 'widget_helpers.dart';

/// The least height of a property row, which fits its copy button.
const double _rowHeight = 28;

/// A label and its value in an [Oito2PropertyList], such as "Size" and
/// "2.4 MB".
@immutable
class Oito2Property {
  /// Creates a property shown as the text [value].
  ///
  /// With [copyable], a copy button copies [value].
  const Oito2Property({
    required this.label,
    required String this.value,
    this.copyable = false,
  }) : child = null,
       copyText = null;

  /// Creates a property shown as [child], such as a link or a status
  /// pill; with [copyText], a copy button copies that text.
  const Oito2Property.widget({
    required this.label,
    required Widget this.child,
    this.copyText,
  }) : value = null,
       copyable = copyText != null;

  /// The label, such as "Size".
  final String label;

  /// The value as text, or null when [child] shows it.
  final String? value;

  /// The value as a widget, or null when [value] shows it.
  final Widget? child;

  /// Whether a copy button copies the value.
  final bool copyable;

  /// The text a property made with [Oito2Property.widget] copies.
  final String? copyText;

  /// The text the copy button copies, if any.
  String? get _copied => copyable ? (copyText ?? value) : null;
}

/// A group of [properties] in an [Oito2PropertyList], under an optional
/// [heading].
@immutable
class Oito2PropertyGroup {
  /// Creates a property group.
  const Oito2PropertyGroup({this.heading, required this.properties});

  /// The group heading, such as "General".
  final String? heading;

  /// The properties of the group.
  final List<Oito2Property> properties;
}

/// Labels and values in two aligned columns, such as the details of a
/// file or an account.
///
/// Labels are muted and aligned by [labelAlign]; their column is as wide
/// as the widest label, up to 40% of the width. Text values can be
/// selected. A copyable property shows an [Oito2CopyButton] while the
/// pointer is over its row or the button has the focus, and always when
/// no mouse is connected. Narrower than [stackedBelow], each label sits
/// above its value.
///
/// Assistive technologies read each property as "label: value".
class Oito2PropertyList extends StatelessWidget {
  /// Creates a list of [properties] without groups.
  Oito2PropertyList({
    super.key,
    required List<Oito2Property> properties,
    this.labelAlign = TextAlign.start,
    this.stackedBelow = 360,
  }) : groups = [Oito2PropertyGroup(properties: properties)];

  /// Creates a list of [groups], each under its optional heading.
  const Oito2PropertyList.grouped({
    super.key,
    required this.groups,
    this.labelAlign = TextAlign.start,
    this.stackedBelow = 360,
  });

  /// The groups of properties.
  final List<Oito2PropertyGroup> groups;

  /// How labels align in their column: [TextAlign.start] or
  /// [TextAlign.end].
  final TextAlign labelAlign;

  /// The width below which labels stack above their values.
  final double stackedBelow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final textScaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : double.infinity;
        final stacked = width < stackedBelow;
        var labelWidth = 0.0;
        if (!stacked) {
          for (final group in groups) {
            for (final property in group.properties) {
              final painter = TextPainter(
                text: TextSpan(text: property.label, style: labelStyle),
                textDirection: Directionality.of(context),
                textScaler: textScaler,
                maxLines: 1,
              )..layout();
              labelWidth = math.max(labelWidth, painter.width);
              painter.dispose();
            }
          }
          labelWidth = math.min(labelWidth.ceilToDouble() + 1, width * 0.4);
        }
        return SelectionArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, group) in groups.indexed) ...[
                if (group.heading case final heading?)
                  SelectionContainer.disabled(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0 : Oito2Spacing.md,
                        bottom: Oito2Spacing.xs,
                      ),
                      child: Semantics(
                        header: true,
                        child: Text(heading, style: theme.textTheme.titleSmall),
                      ),
                    ),
                  )
                else if (index > 0)
                  const SizedBox(height: Oito2Spacing.md),
                for (final property in group.properties)
                  _PropertyRow(
                    property: property,
                    labelStyle: labelStyle,
                    labelAlign: labelAlign,
                    labelWidth: stacked ? null : labelWidth,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// One property: its label beside the value at [labelWidth], or above it
/// when [labelWidth] is null, and its copy button.
class _PropertyRow extends StatefulWidget {
  const _PropertyRow({
    required this.property,
    required this.labelStyle,
    required this.labelAlign,
    required this.labelWidth,
  });

  final Oito2Property property;
  final TextStyle labelStyle;
  final TextAlign labelAlign;
  final double? labelWidth;

  @override
  State<_PropertyRow> createState() => _PropertyRowState();
}

/// Tracks whether the pointer is over the row or its copy button has the
/// focus, which shows the button.
class _PropertyRowState extends State<_PropertyRow> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final value = property.value;
    final copied = property._copied;
    final label = SelectionContainer.disabled(
      child: Text(
        property.label,
        style: widget.labelStyle,
        textAlign: widget.labelWidth == null
            ? TextAlign.start
            : widget.labelAlign,
      ),
    );
    final Widget valueWidget = value != null
        ? Text(value)
        : property.child ?? const SizedBox.shrink();
    final labelled = Semantics(
      container: true,
      label: value == null ? '${property.label}:' : '${property.label}: $value',
      excludeSemantics: value != null,
      child: widget.labelWidth == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Oito2Spacing.xxs,
              children: [
                ExcludeSemantics(child: label),
                valueWidget,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Oito2Spacing.md,
              children: [
                SizedBox(
                  width: widget.labelWidth,
                  child: ExcludeSemantics(child: label),
                ),
                Expanded(child: valueWidget),
              ],
            ),
    );
    Widget row = labelled;
    if (copied != null) {
      final mouse = RendererBinding.instance.mouseTracker.mouseIsConnected;
      final shown = _hovered || _focused || !mouse;
      row = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: labelled),
            Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onFocusChange: (focused) => setState(() => _focused = focused),
              child: AnimatedOpacity(
                opacity: shown ? 1 : 0,
                duration: motionDuration(
                  context,
                  const Duration(milliseconds: 120),
                ),
                child: SelectionContainer.disabled(
                  child: IconButtonTheme(
                    data: IconButtonThemeData(
                      style: IconButton.styleFrom(
                        minimumSize: const Size.square(_rowHeight),
                        fixedSize: const Size.square(_rowHeight),
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    child: Oito2CopyButton(text: copied),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      padding: const EdgeInsets.symmetric(vertical: Oito2Spacing.xxs),
      alignment: AlignmentDirectional.centerStart,
      child: row,
    );
  }
}
