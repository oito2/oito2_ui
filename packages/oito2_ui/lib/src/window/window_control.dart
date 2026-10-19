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

import '../l10n/oito2_localizations.dart';

import 'package:material_ui/material_ui.dart';

import '../foundation/window_button_layout.dart';
import '../tokens/geometry.dart';

/// The action and glyph of a window control button.
enum Oito2WindowControlType {
  /// Minimizes the window.
  minimize,

  /// Maximizes the window.
  maximize,

  /// Restores a maximized window.
  restore,

  /// Closes the window.
  close,
}

/// Accessibility labels of the window control buttons that override the
/// [Oito2Localizations] strings.
///
/// A null label keeps the localized string.
@immutable
class Oito2WindowControlLabels {
  /// Creates window control label overrides.
  const Oito2WindowControlLabels({
    this.minimize,
    this.maximize,
    this.restore,
    this.close,
  });

  /// Label of [Oito2WindowControlType.minimize].
  final String? minimize;

  /// Label of [Oito2WindowControlType.maximize].
  final String? maximize;

  /// Label of [Oito2WindowControlType.restore].
  final String? restore;

  /// Label of [Oito2WindowControlType.close].
  final String? close;

  /// Returns the override for [type], or null when there is none.
  String? of(Oito2WindowControlType type) => switch (type) {
    Oito2WindowControlType.minimize => minimize,
    Oito2WindowControlType.maximize => maximize,
    Oito2WindowControlType.restore => restore,
    Oito2WindowControlType.close => close,
  };

  /// Returns the label for [type]: the override from [labels] when there
  /// is one, otherwise the [Oito2Localizations] string of [context].
  static String resolve(
    BuildContext context,
    Oito2WindowControlType type, [
    Oito2WindowControlLabels? labels,
  ]) {
    final override = labels?.of(type);
    if (override != null) return override;
    final l10n = Oito2Localizations.of(context);
    return switch (type) {
      Oito2WindowControlType.minimize => l10n.minimizeWindow,
      Oito2WindowControlType.maximize => l10n.maximizeWindow,
      Oito2WindowControlType.restore => l10n.restoreWindow,
      Oito2WindowControlType.close => l10n.closeWindow,
    };
  }
}

/// A single window control button drawn in the visual family of [style].
///
/// The button stays out of keyboard focus traversal, as native window
/// buttons do, and exposes its [label] to assistive technologies.
class Oito2WindowControl extends StatefulWidget {
  /// Creates a window control button.
  const Oito2WindowControl({
    super.key,
    required this.type,
    required this.style,
    required this.onPressed,
    this.label,
    this.foregroundColor,
    this.height = Oito2Sizes.titleBarHeight,
    this.isActive = true,
  });

  /// The action and glyph.
  final Oito2WindowControlType type;

  /// The visual family. [Oito2WindowControlStyle.none] draws nothing.
  final Oito2WindowControlStyle style;

  /// Called when the button is activated; null disables it.
  final VoidCallback? onPressed;

  /// The accessibility label; defaults to the English label of [type].
  final String? label;

  /// The glyph color; defaults to the theme's `onSurface`.
  final Color? foregroundColor;

  /// The title bar height, used by the full-height Windows buttons.
  final double height;

  /// Whether the window is active; inactive macOS buttons turn grey.
  final bool isActive;

  /// The width this button takes for [style] at [height].
  static double widthFor(Oito2WindowControlStyle style, double height) {
    return switch (style) {
      Oito2WindowControlStyle.windows => Oito2Sizes.windowsWindowControlWidth,
      Oito2WindowControlStyle.macos => 20,
      Oito2WindowControlStyle.none => 0,
      _ => Oito2Sizes.windowControlSize,
    };
  }

  @override
  State<Oito2WindowControl> createState() => _Oito2WindowControlState();
}

class _Oito2WindowControlState extends State<Oito2WindowControl> {
  bool _hovered = false;
  bool _pressed = false;

  static const _windowsCloseRed = Color(0xFFC42B1C);
  static const _breezeCloseRed = Color(0xFFDA4453);
  static const _macosRed = Color(0xFFFF5F57);
  static const _macosYellow = Color(0xFFFEBC2E);
  static const _macosGreen = Color(0xFF28C840);
  static const _macosInactive = Color(0xFFC8C8C8);
  static const _white = Color(0xFFFFFFFF);

  bool get _isClose => widget.type == Oito2WindowControlType.close;

  /// The background, glyph color and shape of the button in its current
  /// interaction state.
  (Color background, Color glyph, ShapeBorder shape) _appearance(
    Color foreground,
  ) {
    final enabled = widget.onPressed != null;
    final hovered = enabled && _hovered;
    final pressed = enabled && _pressed;
    Color tint(double idle, double hover, double press) => foreground
        .withValues(alpha: pressed ? press : (hovered ? hover : idle));
    const circle = CircleBorder();
    switch (widget.style) {
      case Oito2WindowControlStyle.gnome:
        return (tint(0.10, 0.15, 0.20), foreground, circle);
      case Oito2WindowControlStyle.cosmic:
        return (tint(0, 0.10, 0.16), foreground, circle);
      case Oito2WindowControlStyle.breeze:
        if (_isClose && (hovered || pressed)) {
          return (
            _breezeCloseRed.withValues(alpha: pressed ? 0.8 : 1),
            _white,
            circle,
          );
        }
        return (tint(0, 0.12, 0.18), foreground, circle);
      case Oito2WindowControlStyle.xfwm:
        return (
          tint(0, 0.10, 0.16),
          foreground,
          const RoundedRectangleBorder(borderRadius: Oito2Radius.checkAll),
        );
      case Oito2WindowControlStyle.windows:
        if (_isClose && (hovered || pressed)) {
          return (
            _windowsCloseRed.withValues(alpha: pressed ? 0.85 : 1),
            _white,
            const RoundedRectangleBorder(),
          );
        }
        return (
          tint(0, 0.08, 0.12),
          foreground,
          const RoundedRectangleBorder(),
        );
      case Oito2WindowControlStyle.macos:
        final color = !widget.isActive && !hovered
            ? _macosInactive
            : switch (widget.type) {
                Oito2WindowControlType.close => _macosRed,
                Oito2WindowControlType.minimize => _macosYellow,
                _ => _macosGreen,
              };
        return (
          color,
          hovered ? const Color(0xA6000000) : const Color(0x00000000),
          circle,
        );
      case Oito2WindowControlStyle.none:
        return (const Color(0x00000000), foreground, circle);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.style == Oito2WindowControlStyle.none) {
      return const SizedBox.shrink();
    }
    final foreground =
        widget.foregroundColor ?? Theme.of(context).colorScheme.onSurface;
    final (background, glyph, shape) = _appearance(foreground);
    final isWindows = widget.style == Oito2WindowControlStyle.windows;
    final isMac = widget.style == Oito2WindowControlStyle.macos;
    final buttonSize = isWindows
        ? Size(Oito2Sizes.windowsWindowControlWidth, widget.height)
        : isMac
        ? const Size.square(12)
        : const Size.square(Oito2Sizes.windowControlSize);
    final glyphSize = isWindows ? 10.0 : (isMac ? 6.0 : 8.0);
    final label =
        widget.label ?? Oito2WindowControlLabels.resolve(context, widget.type);

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: label,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: widget.onPressed == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: SizedBox(
            width: Oito2WindowControl.widthFor(widget.style, widget.height),
            height: isWindows ? widget.height : Oito2Sizes.windowControlSize,
            child: Center(
              child: Container(
                width: buttonSize.width,
                height: buttonSize.height,
                decoration: ShapeDecoration(color: background, shape: shape),
                child: CustomPaint(
                  painter: _GlyphPainter(
                    type: widget.type,
                    color: glyph,
                    glyphSize: glyphSize,
                    strokeWidth: isWindows ? 1 : (isMac ? 1.2 : 1.4),
                    plusForMaximize: isMac,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the glyph of a window control centered in its box.
class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.type,
    required this.color,
    required this.glyphSize,
    required this.strokeWidth,
    required this.plusForMaximize,
  });

  final Oito2WindowControlType type;
  final Color color;
  final double glyphSize;
  final double strokeWidth;
  final bool plusForMaximize;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final half = glyphSize / 2;
    final center = size.center(Offset.zero);
    final box = Rect.fromCenter(
      center: center,
      width: glyphSize,
      height: glyphSize,
    );

    switch (type) {
      case Oito2WindowControlType.minimize:
        canvas.drawLine(
          Offset(box.left, center.dy),
          Offset(box.right, center.dy),
          paint,
        );
      case Oito2WindowControlType.maximize when plusForMaximize:
      case Oito2WindowControlType.restore when plusForMaximize:
        canvas
          ..drawLine(
            Offset(box.left, center.dy),
            Offset(box.right, center.dy),
            paint,
          )
          ..drawLine(
            Offset(center.dx, box.top),
            Offset(center.dx, box.bottom),
            paint,
          );
      case Oito2WindowControlType.maximize:
        canvas.drawRect(box, paint);
      case Oito2WindowControlType.restore:
        final inset = glyphSize * 0.25;
        final front = Rect.fromLTRB(
          box.left,
          box.top + inset,
          box.right - inset,
          box.bottom,
        );
        canvas
          ..drawRect(front, paint)
          ..drawPath(
            Path()
              ..moveTo(box.left + inset, front.top)
              ..lineTo(box.left + inset, box.top)
              ..lineTo(box.right, box.top)
              ..lineTo(box.right, front.bottom - inset)
              ..lineTo(front.right, front.bottom - inset),
            paint,
          );
      case Oito2WindowControlType.close:
        canvas
          ..drawLine(
            center.translate(-half, -half),
            center.translate(half, half),
            paint,
          )
          ..drawLine(
            center.translate(half, -half),
            center.translate(-half, half),
            paint,
          );
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.glyphSize != glyphSize ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.plusForMaximize != plusForMaximize;
}
