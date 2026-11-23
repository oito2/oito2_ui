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

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// The shapes of an [Oito2Skeleton].
enum _SkeletonShape { text, circle, rect }

/// The width a skeleton takes when its width is unbounded.
const double _unboundedWidth = 200;

/// A placeholder shape shown while content loads: lines of text, a
/// circle such as an avatar, or a rectangle such as an image.
///
/// It is filled with the scheme's highest surface container tone and
/// pulses gently; it stands still when animations are disabled. It has
/// no semantics of its own: wrap a group of skeletons in an
/// [Oito2SkeletonSwitcher], which announces "Loading" once for the group
/// and swaps in the content when it is ready.
class Oito2Skeleton extends StatefulWidget {
  /// Creates [lines] lines of text [lineHeight] tall that fill the
  /// available width, 200 pixels when it is unbounded; with more than one
  /// line, the last one takes [lastLineWidthFactor] of the width.
  const Oito2Skeleton.text({
    super.key,
    this.lines = 1,
    this.lineHeight = 12,
    this.lastLineWidthFactor = 0.6,
  }) : assert(lines > 0, 'lines must be positive'),
       _shape = _SkeletonShape.text,
       width = null,
       height = null,
       borderRadius = null;

  /// Creates a circle [size] pixels across, such as an avatar.
  const Oito2Skeleton.circle({super.key, double size = 40})
    : _shape = _SkeletonShape.circle,
      width = size,
      height = size,
      lines = 1,
      lineHeight = 0,
      lastLineWidthFactor = 1,
      borderRadius = null;

  /// Creates a rectangle [width] by [height] with [borderRadius]
  /// corners; without a [width] it fills the available width, 200 pixels
  /// when it is unbounded.
  const Oito2Skeleton.rect({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = Oito2Radius.mediumAll,
  }) : _shape = _SkeletonShape.rect,
       lines = 1,
       lineHeight = 0,
       lastLineWidthFactor = 1;

  final _SkeletonShape _shape;

  /// The number of text lines.
  final int lines;

  /// The height of each text line.
  final double lineHeight;

  /// The fraction of the width the last text line takes when there is
  /// more than one line.
  final double lastLineWidthFactor;

  /// The width of a circle or a rectangle; null fills the available
  /// width.
  final double? width;

  /// The height of a circle or a rectangle.
  final double? height;

  /// The corners of a rectangle.
  final BorderRadiusGeometry? borderRadius;

  @override
  State<Oito2Skeleton> createState() => _Oito2SkeletonState();
}

class _Oito2SkeletonState extends State<Oito2Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: 1,
  );
  late final Animation<double> _opacity = _controller.drive(
    Tween<double>(
      begin: 0.45,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeInOut)),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget block({double? width, required double height, ShapeBorder? shape}) {
      return SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: color,
            shape:
                shape ??
                const RoundedRectangleBorder(
                  borderRadius: Oito2Radius.smallAll,
                ),
          ),
        ),
      );
    }

    final Widget shape = switch (widget._shape) {
      _SkeletonShape.circle => block(
        width: widget.width,
        height: widget.height!,
        shape: const CircleBorder(),
      ),
      _SkeletonShape.rect => LimitedBox(
        maxWidth: _unboundedWidth,
        child: block(
          width: widget.width ?? double.infinity,
          height: widget.height!,
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
          ),
        ),
      ),
      _SkeletonShape.text => LimitedBox(
        maxWidth: _unboundedWidth,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: widget.lineHeight * 0.6,
            children: [
              for (var i = 0; i < widget.lines; i++)
                FractionallySizedBox(
                  widthFactor: i == widget.lines - 1 && widget.lines > 1
                      ? widget.lastLineWidthFactor
                      : 1,
                  child: block(height: widget.lineHeight),
                ),
            ],
          ),
        ),
      ),
    };
    return ExcludeSemantics(
      child: FadeTransition(opacity: _opacity, child: shape),
    );
  }
}

/// Shows [skeleton] while [loading] and [child] once it is not, fading
/// from one to the other; at once when animations are disabled.
///
/// While loading, assistive technologies read the group once as
/// [semanticLabel], "Loading" by default, instead of the placeholder
/// shapes.
class Oito2SkeletonSwitcher extends StatelessWidget {
  /// Creates a skeleton switcher.
  const Oito2SkeletonSwitcher({
    super.key,
    required this.loading,
    required this.skeleton,
    required this.child,
    this.semanticLabel,
  });

  /// Whether the content is still loading.
  final bool loading;

  /// The placeholder, usually a layout of [Oito2Skeleton]s shaped like
  /// [child].
  final Widget skeleton;

  /// The loaded content.
  final Widget child;

  /// The accessibility label of the placeholder; defaults to the
  /// localized "Loading".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: motionDuration(context, const Duration(milliseconds: 200)),
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.topStart,
        children: [...previous, ?current],
      ),
      child: loading
          ? Semantics(
              key: const ValueKey(true),
              container: true,
              label: semanticLabel ?? Oito2Localizations.of(context).loading,
              child: ExcludeSemantics(child: skeleton),
            )
          : KeyedSubtree(key: const ValueKey(false), child: child),
    );
  }
}
