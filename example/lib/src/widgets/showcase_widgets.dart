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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

/// A titled showcase section that wraps its [children].
class ShowcaseSection extends StatelessWidget {
  /// Creates a section with a [title] above the wrapped [children].
  const ShowcaseSection(this.title, {super.key, required this.children});

  /// The section title.
  final String title;

  /// The widgets laid out in a wrapping row.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: Oito2Spacing.md),
          Wrap(
            spacing: Oito2Spacing.md,
            runSpacing: Oito2Spacing.md,
            children: children,
          ),
        ],
      ),
    );
  }
}

/// A labeled color sample showing its hex value and the contrast ratio
/// between [background] and [foreground].
class Swatch extends StatelessWidget {
  /// Creates a swatch filled with [background] and labeled in
  /// [foreground].
  const Swatch(
    this.label,
    this.background,
    this.foreground, {
    super.key,
    this.border,
  });

  /// The role or token name.
  final String label;

  /// The fill color.
  final Color background;

  /// The label color.
  final Color foreground;

  /// The border color; defaults to the theme's `outlineVariant`.
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final ratio = Oito2Contrast.ratio(background, foreground);
    final hex = background
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
    return Container(
      width: 160,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(Oito2Spacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: Oito2Radius.mediumAll,
        border: Border.all(
          color: border ?? Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: Oito2Spacing.sm),
            Text(
              '#$hex · ${ratio.toStringAsFixed(1)}:1',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// The scrolling body of a showcase page: [children] in a padded list.
class ShowcasePageBody extends StatelessWidget {
  /// Creates a page body.
  const ShowcasePageBody({super.key, required this.children});

  /// The page sections, usually [ShowcaseSection]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: children,
    );
  }
}

/// A bordered frame with a width slider, for layouts that adapt to the
/// space they get.
class ShowcaseFrame extends StatefulWidget {
  /// Creates a frame around [child].
  const ShowcaseFrame({
    super.key,
    required this.child,
    this.initialWidth = 760,
    this.height = 380,
  });

  /// The framed layout.
  final Widget child;

  /// The frame width at start, clamped to the slider range of 360 to 900
  /// pixels.
  final double initialWidth;

  /// The frame height.
  final double height;

  @override
  State<ShowcaseFrame> createState() => _ShowcaseFrameState();
}

class _ShowcaseFrameState extends State<ShowcaseFrame> {
  static const _minWidth = 360.0;
  static const _maxWidth = 900.0;

  // The slider only takes values within its range.
  late double _width = widget.initialWidth.clamp(_minWidth, _maxWidth);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wraps on narrow screens instead of overflowing.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: Slider(
                min: _minWidth,
                max: _maxWidth,
                divisions: 27,
                value: _width,
                label: '${_width.round()}',
                onChanged: (value) => setState(() => _width = value),
              ),
            ),
            Text(
              'Frame width: ${_width.round()} px',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: Oito2Spacing.sm),
        SizedBox(
          width: _width,
          height: widget.height,
          child: Oito2BorderContainer(child: widget.child),
        ),
      ],
    );
  }
}
