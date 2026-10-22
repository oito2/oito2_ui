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

import 'dart:ui' show PathMetric;

import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// The duration of the toggle state animations.
const _toggleDuration = Duration(milliseconds: 150);

/// Whether [theme] targets touch input, which the oito2 theme marks with
/// padded tap targets.
bool _isTouch(ThemeData theme) =>
    theme.materialTapTargetSize == MaterialTapTargetSize.padded;

/// The colors a painted toggle uses in its current [Theme].
@immutable
class _ToggleColors {
  factory _ToggleColors.of(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (:fill, :onFill) = selectedFillOf(context);
    return _ToggleColors._(
      fill: fill,
      onFill: onFill,
      focus: semanticColorsOf(context).primaryText,
      outline: scheme.outline,
      surface: scheme.surfaceContainerLowest,
      track: scheme.surfaceContainerHighest,
      onSurface: scheme.onSurface,
      offThumb: theme.brightness == Brightness.dark
          ? scheme.onSurfaceVariant
          : scheme.surfaceContainerLowest,
    );
  }

  const _ToggleColors._({
    required this.fill,
    required this.onFill,
    required this.focus,
    required this.outline,
    required this.surface,
    required this.track,
    required this.onSurface,
    required this.offThumb,
  });

  /// The fill of selected boxes, rings and tracks.
  final Color fill;

  /// The mark drawn on [fill].
  final Color onFill;

  /// The keyboard focus ring.
  final Color focus;

  /// The border of unselected boxes, rings and tracks.
  final Color outline;

  /// The fill of unselected boxes and rings.
  final Color surface;

  /// The fill of an off switch track.
  final Color track;

  /// The tone blended in on hover and press.
  final Color onSurface;

  /// The thumb of an off switch.
  final Color offThumb;

  @override
  bool operator ==(Object other) =>
      other is _ToggleColors &&
      other.fill == fill &&
      other.onFill == onFill &&
      other.focus == focus &&
      other.outline == outline &&
      other.surface == surface &&
      other.track == track &&
      other.onSurface == onSurface &&
      other.offThumb == offThumb;

  @override
  int get hashCode => Object.hash(
    fill,
    onFill,
    focus,
    outline,
    surface,
    track,
    onSurface,
    offThumb,
  );
}

/// The interaction state passed to a toggle painter.
@immutable
class _ToggleState {
  const _ToggleState({
    required this.progress,
    required this.hovered,
    required this.pressed,
    required this.focused,
  });

  /// The selection animation, from 0 (off) to 1 (on).
  final double progress;

  /// Whether a pointer hovers the toggle.
  final bool hovered;

  /// Whether a pointer presses the toggle.
  final bool pressed;

  /// Whether the toggle shows its keyboard focus ring.
  final bool focused;

  /// The opacity of the hover and press overlay.
  double get overlay => pressed ? 0.16 : (hovered ? 0.08 : 0);

  @override
  bool operator ==(Object other) =>
      other is _ToggleState &&
      other.progress == progress &&
      other.hovered == hovered &&
      other.pressed == pressed &&
      other.focused == focused;

  @override
  int get hashCode => Object.hash(progress, hovered, pressed, focused);
}

/// Paints a ring of [width] around [rrect], [gap] pixels away from it, as
/// a filled shape.
void _paintRing(
  Canvas canvas,
  RRect rrect,
  Color color, {
  double gap = 2,
  double width = Oito2Sizes.focusBorderWidth,
}) {
  canvas.drawDRRect(
    rrect.inflate(gap + width),
    rrect.inflate(gap),
    Paint()..color = color,
  );
}

/// The interactive core shared by [Oito2Checkbox], [Oito2Radio] and
/// [Oito2Switch]: focus, hover and press tracking, Space and Enter
/// activation, the selection animation and the disabled look.
class _Toggle extends StatefulWidget {
  const _Toggle({
    required this.selected,
    required this.enabled,
    required this.onActivate,
    required this.size,
    required this.painter,
    required this.semantics,
    this.focusNode,
    this.autofocus = false,
  });

  final bool selected;
  final bool enabled;
  final VoidCallback onActivate;
  final Size size;
  final CustomPainter Function(_ToggleState state) painter;
  final SemanticsProperties semantics;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<_Toggle> createState() => _ToggleWidgetState();
}

class _ToggleWidgetState extends State<_Toggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: _toggleDuration,
    value: widget.selected ? 1 : 0,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _position,
    curve: Curves.easeInOut,
  );
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  void didUpdateWidget(_Toggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;
    final target = widget.selected ? 1.0 : 0.0;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _position.value = target;
    } else {
      _position.animateTo(target);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _position.dispose();
    super.dispose();
  }

  void _activate() {
    if (widget.enabled) widget.onActivate();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    Widget toggle = AnimatedBuilder(
      animation: _curve,
      builder: (context, _) => CustomPaint(
        size: widget.size,
        painter: widget.painter(
          _ToggleState(
            progress: _curve.value,
            hovered: enabled && _hovered,
            pressed: enabled && _pressed,
            focused: enabled && _focused,
          ),
        ),
      ),
    );
    if (!enabled) toggle = Opacity(opacity: 0.38, child: toggle);
    return FocusableActionDetector(
      enabled: enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => _activate(),
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: enabled ? _activate : null,
        child: Semantics.fromProperties(
          container: true,
          properties: widget.semantics,
          // The tap action joins the node that carries the state.
          child: Semantics(onTap: enabled ? _activate : null, child: toggle),
        ),
      ),
    );
  }
}

/// A check box painted in the oito2 style.
///
/// The box has a 1.5-pixel `outline` border while unchecked and fills with
/// the text-safe primary tone when checked, drawing the check mark as it
/// fills. With [tristate], a null [value] shows a dash (the mixed state)
/// and a tap cycles unchecked → checked → mixed. Space and Enter toggle it
/// while focused, and the focus ring shows in keyboard navigation.
///
/// The box is 20 pixels on pointer platforms, in a 34-pixel target, and
/// 24 pixels on touch platforms, in a 48-pixel target.
class Oito2Checkbox extends StatelessWidget {
  /// Creates a check box.
  const Oito2Checkbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  }) : assert(tristate || value != null);

  /// Whether the box is checked; null is the mixed state of a [tristate]
  /// box.
  final bool? value;

  /// Called with the next value; null disables the box.
  final ValueChanged<bool?>? onChanged;

  /// Whether a tap cycles through the mixed state.
  final bool tristate;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the box takes focus when first shown.
  final bool autofocus;

  /// The accessibility label, when no surrounding label provides one.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final touch = _isTouch(Theme.of(context));
    final colors = _ToggleColors.of(context);
    final box = touch ? 24.0 : 20.0;
    final target = touch ? Oito2Sizes.minTouchTarget : Oito2Sizes.buttonHeight;
    return _Toggle(
      selected: value != false,
      enabled: onChanged != null,
      onActivate: () => onChanged!(nextCheckValue(value, tristate: tristate)),
      size: Size.square(target),
      focusNode: focusNode,
      autofocus: autofocus,
      semantics: SemanticsProperties(
        checked: value ?? false,
        mixed: tristate && value == null,
        enabled: onChanged != null,
        label: semanticLabel,
      ),
      painter: (state) => _CheckboxPainter(
        state: state,
        colors: colors,
        box: box,
        mixed: value == null,
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  _CheckboxPainter({
    required this.state,
    required this.colors,
    required this.box,
    required this.mixed,
  });

  final _ToggleState state;
  final _ToggleColors colors;
  final double box;
  final bool mixed;

  @override
  void paint(Canvas canvas, Size size) {
    final t = state.progress;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: box,
      height: box,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(Oito2Radius.check),
    );
    final overlay = colors.onSurface.withValues(alpha: state.overlay);

    // Unchecked: the surface fill inside the outline border.
    canvas.drawRRect(
      rrect,
      Paint()..color = Color.alphaBlend(overlay, colors.surface),
    );
    canvas.drawDRRect(
      rrect,
      rrect.deflate(1.5),
      Paint()..color = colors.outline,
    );

    // Checked: the indicator fill fades in over the box.
    if (t > 0) {
      final fill = Color.alphaBlend(
        colors.onFill.withValues(alpha: state.overlay),
        colors.fill,
      );
      canvas.drawRRect(rrect, Paint()..color = fill.withValues(alpha: t));
      if (mixed) {
        final bar = Rect.fromCenter(
          center: rect.center,
          width: box * 0.5 * t,
          height: box * 0.1,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bar, Radius.circular(box * 0.05)),
          Paint()..color = colors.onFill,
        );
      } else {
        final check = Path()
          ..moveTo(rect.left + box * 0.24, rect.top + box * 0.52)
          ..lineTo(rect.left + box * 0.42, rect.top + box * 0.70)
          ..lineTo(rect.left + box * 0.77, rect.top + box * 0.32);
        final metric = check.computeMetrics().first;
        canvas.drawPath(
          _partial(metric, t),
          Paint()
            ..color = colors.onFill
            ..style = PaintingStyle.stroke
            ..strokeWidth = box * 0.11
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    if (state.focused) _paintRing(canvas, rrect, colors.focus);
  }

  static Path _partial(PathMetric metric, double t) =>
      metric.extractPath(0, metric.length * t);

  @override
  bool shouldRepaint(_CheckboxPainter old) =>
      old.state != state ||
      old.mixed != mixed ||
      old.box != box ||
      old.colors != colors;
}

/// A radio button painted in the oito2 style.
///
/// It is selected when [value] equals [groupValue]. The ring has a
/// 1.5-pixel `outline` border while unselected and fills with the
/// primary tone when selected, with a dot in its on-color. With
/// [toggleable], tapping the selected radio clears the group (calls
/// [onChanged] with null). Space and Enter select it while focused.
///
/// The ring is 20 pixels on pointer platforms and 24 on touch platforms.
class Oito2Radio<T> extends StatelessWidget {
  /// Creates a radio button.
  const Oito2Radio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.toggleable = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// The value this radio represents.
  final T value;

  /// The currently selected value of the group.
  final T? groupValue;

  /// Called with [value] when selected, or null when a [toggleable] radio
  /// is cleared; null disables the radio.
  final ValueChanged<T?>? onChanged;

  /// Whether tapping the selected radio clears the group.
  final bool toggleable;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the radio takes focus when first shown.
  final bool autofocus;

  /// The accessibility label, when no surrounding label provides one.
  final String? semanticLabel;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final touch = _isTouch(Theme.of(context));
    final colors = _ToggleColors.of(context);
    final ring = touch ? 24.0 : 20.0;
    final target = touch ? Oito2Sizes.minTouchTarget : Oito2Sizes.buttonHeight;
    return _Toggle(
      selected: _selected,
      enabled: onChanged != null,
      onActivate: () =>
          activateRadio(value, groupValue, onChanged!, toggleable: toggleable),
      size: Size.square(target),
      focusNode: focusNode,
      autofocus: autofocus,
      semantics: SemanticsProperties(
        checked: _selected,
        inMutuallyExclusiveGroup: true,
        enabled: onChanged != null,
        label: semanticLabel,
      ),
      painter: (state) =>
          _RadioPainter(state: state, colors: colors, ring: ring),
    );
  }
}

class _RadioPainter extends CustomPainter {
  _RadioPainter({
    required this.state,
    required this.colors,
    required this.ring,
  });

  final _ToggleState state;
  final _ToggleColors colors;
  final double ring;

  @override
  void paint(Canvas canvas, Size size) {
    final t = state.progress;
    final center = size.center(Offset.zero);
    final circle = RRect.fromRectAndRadius(
      Rect.fromCircle(center: center, radius: ring / 2),
      Radius.circular(ring / 2),
    );
    final overlay = colors.onSurface.withValues(alpha: state.overlay);
    canvas.drawRRect(
      circle,
      Paint()..color = Color.alphaBlend(overlay, colors.surface),
    );
    canvas.drawDRRect(
      circle,
      circle.deflate(1.5),
      Paint()..color = colors.outline,
    );
    if (t > 0) {
      final fill = Color.alphaBlend(
        colors.onFill.withValues(alpha: state.overlay),
        colors.fill,
      );
      canvas.drawRRect(circle, Paint()..color = fill.withValues(alpha: t));
      canvas.drawCircle(center, ring * 0.2 * t, Paint()..color = colors.onFill);
    }
    if (state.focused) _paintRing(canvas, circle, colors.focus);
  }

  @override
  bool shouldRepaint(_RadioPainter old) =>
      old.state != state || old.ring != ring || old.colors != colors;
}

/// A switch painted in the oito2 style.
///
/// The track is the highest surface container with an `outline` border
/// while off and the primary tone while on; the thumb slides to
/// the end side (the right in left-to-right layouts). With [onOffShapes],
/// the track also shows an "I" while on and an "O" while off, so the state
/// doesn't rely on color. Space and Enter toggle it while focused.
///
/// The track is 42 × 24 pixels on pointer platforms and 52 × 30 on touch
/// platforms.
class Oito2Switch extends StatelessWidget {
  /// Creates a switch.
  const Oito2Switch({
    super.key,
    required this.value,
    required this.onChanged,
    this.onOffShapes = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value; null disables the switch.
  final ValueChanged<bool>? onChanged;

  /// Whether the track marks the on and off states with shapes.
  final bool onOffShapes;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the switch takes focus when first shown.
  final bool autofocus;

  /// The accessibility label, when no surrounding label provides one.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final touch = _isTouch(Theme.of(context));
    final colors = _ToggleColors.of(context);
    final track = touch ? const Size(52, 30) : const Size(42, 24);
    final target = touch ? Oito2Sizes.minTouchTarget : Oito2Sizes.buttonHeight;
    return _Toggle(
      selected: value,
      enabled: onChanged != null,
      onActivate: () => onChanged!(!value),
      size: Size(track.width + Oito2Spacing.sm, target),
      focusNode: focusNode,
      autofocus: autofocus,
      semantics: SemanticsProperties(
        toggled: value,
        enabled: onChanged != null,
        label: semanticLabel,
      ),
      painter: (state) => _SwitchPainter(
        state: state,
        colors: colors,
        track: track,
        onOffShapes: onOffShapes,
        textDirection: Directionality.of(context),
      ),
    );
  }
}

class _SwitchPainter extends CustomPainter {
  _SwitchPainter({
    required this.state,
    required this.colors,
    required this.track,
    required this.onOffShapes,
    required this.textDirection,
  });

  final _ToggleState state;
  final _ToggleColors colors;
  final Size track;
  final bool onOffShapes;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final t = state.progress;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: track.width,
      height: track.height,
    );
    final radius = Radius.circular(track.height / 2);
    final rrect = RRect.fromRectAndRadius(rect, radius);
    final overlay = colors.onSurface.withValues(alpha: state.overlay);

    final off = Color.alphaBlend(overlay, colors.track);
    final on = Color.alphaBlend(
      colors.onFill.withValues(alpha: state.overlay),
      colors.fill,
    );
    canvas.drawRRect(rrect, Paint()..color = Color.lerp(off, on, t)!);
    if (t < 1) {
      canvas.drawDRRect(
        rrect,
        rrect.deflate(1.5),
        Paint()..color = colors.outline.withValues(alpha: 1 - t),
      );
    }

    final inset = track.height * 0.125;
    final thumbRadius = track.height / 2 - inset;
    final start = rect.left + inset + thumbRadius;
    final end = rect.right - inset - thumbRadius;
    final ltr = textDirection == TextDirection.ltr;
    final x = ltr ? start + (end - start) * t : end - (end - start) * t;

    if (onOffShapes) {
      final mark = track.height * 0.36;
      // "I" on the side the thumb leaves when on.
      final iX = ltr ? start : end;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(iX, rect.center.dy),
            width: track.height * 0.08,
            height: mark,
          ),
          const Radius.circular(1),
        ),
        Paint()..color = colors.onFill.withValues(alpha: t),
      );
      // "O" on the side the thumb leaves when off.
      final oX = ltr ? end : start;
      final o = RRect.fromRectAndRadius(
        Rect.fromCircle(center: Offset(oX, rect.center.dy), radius: mark / 2),
        Radius.circular(mark / 2),
      );
      canvas.drawDRRect(
        o,
        o.deflate(track.height * 0.07),
        Paint()..color = colors.outline.withValues(alpha: 1 - t),
      );
    }

    canvas.drawCircle(
      Offset(x, rect.center.dy),
      thumbRadius,
      Paint()..color = Color.lerp(colors.offThumb, colors.onFill, t)!,
    );

    if (state.focused) _paintRing(canvas, rrect, colors.focus);
  }

  @override
  bool shouldRepaint(_SwitchPainter old) =>
      old.state != state ||
      old.track != track ||
      old.onOffShapes != onOffShapes ||
      old.textDirection != textDirection ||
      old.colors != colors;
}

/// A compact row with a toggle [control] and a clickable [title] and
/// [subtitle], as GNOME check and switch buttons.
///
/// Clicking anywhere on the row, or pressing Space or Enter while it has
/// focus, calls [onToggled]. The row takes keyboard focus as a whole (the
/// [control] itself is kept out of focus traversal), shows the focus ring
/// around itself and reads as one element to assistive technologies.
/// [Oito2CheckButton], [Oito2RadioButton] and [Oito2SwitchButton] are
/// built on it.
class Oito2ToggleButton extends StatelessWidget {
  /// Creates a toggle button.
  const Oito2ToggleButton({
    super.key,
    required this.control,
    required this.title,
    this.subtitle,
    this.onToggled,
    this.controlAtEnd = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Oito2Spacing.xs,
      vertical: Oito2Spacing.xxs,
    ),
    this.focusNode,
    this.autofocus = false,
  });

  /// The toggle, such as an [Oito2Checkbox], [Oito2Radio] or
  /// [Oito2Switch].
  final Widget control;

  /// The label.
  final Widget title;

  /// Secondary text below the label.
  final Widget? subtitle;

  /// Called when the row is activated; null disables the row.
  final VoidCallback? onToggled;

  /// Whether [control] follows the text instead of preceding it.
  final bool controlAtEnd;

  /// Space around the row content.
  final EdgeInsetsGeometry padding;

  /// The focus node of the row; one is created when null.
  final FocusNode? focusNode;

  /// Whether the row takes focus when first shown.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onToggled != null;
    final foreground = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);
    final subtitle = this.subtitle;
    final text = Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            child: title,
          ),
          if (subtitle != null)
            DefaultTextStyle.merge(
              style: theme.textTheme.bodySmall?.copyWith(
                color: enabled
                    ? theme.colorScheme.onSurfaceVariant
                    : foreground,
              ),
              child: subtitle,
            ),
        ],
      ),
    );
    final control = ExcludeFocus(child: this.control);
    return MergeSemantics(
      child: Oito2FocusBorder(
        borderRadius: Oito2Radius.smallAll,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onToggled,
            focusNode: focusNode,
            autofocus: autofocus,
            focusColor: const Color(0x00000000),
            borderRadius: Oito2Radius.smallAll,
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Oito2Spacing.sm,
                children: controlAtEnd ? [text, control] : [control, text],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Where the control of a toggle list tile sits.
enum Oito2ControlAffinity {
  /// Before the title.
  leading,

  /// After the title.
  trailing,

  /// The usual side of the control: leading for check boxes and radios,
  /// trailing for switches.
  platform,
}

/// The shared layout of [Oito2CheckboxListTile], [Oito2RadioListTile] and
/// [Oito2SwitchListTile]: a [ListTile] whose tap activates the control,
/// with an optional [secondary] widget on the other side.
class _ToggleListTile extends StatelessWidget {
  const _ToggleListTile({
    required this.control,
    required this.controlLeading,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.secondary,
    required this.contentPadding,
    required this.focusNode,
    required this.autofocus,
  });

  final Widget control;
  final bool controlLeading;
  final VoidCallback? onTap;
  final Widget? title;
  final Widget? subtitle;
  final Widget? secondary;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final control = ExcludeFocus(child: this.control);
    return MergeSemantics(
      child: ListTile(
        leading: controlLeading ? control : secondary,
        trailing: controlLeading ? secondary : control,
        title: title,
        subtitle: subtitle,
        enabled: onTap != null,
        onTap: onTap,
        contentPadding: contentPadding,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}

/// A [ListTile] with an [Oito2Checkbox]; tapping the tile toggles it.
class Oito2CheckboxListTile extends StatelessWidget {
  /// Creates a check box list tile.
  const Oito2CheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.secondary,
    this.tristate = false,
    this.controlAffinity = Oito2ControlAffinity.platform,
    this.contentPadding,
    this.focusNode,
    this.autofocus = false,
  });

  /// Whether the box is checked; null is the mixed state of a [tristate]
  /// box.
  final bool? value;

  /// Called with the next value; null disables the tile.
  final ValueChanged<bool?>? onChanged;

  /// The primary text.
  final Widget? title;

  /// The secondary text.
  final Widget? subtitle;

  /// A widget on the side opposite the check box, such as an icon.
  final Widget? secondary;

  /// Whether a tap cycles through the mixed state.
  final bool tristate;

  /// Where the check box sits; [Oito2ControlAffinity.platform] is leading.
  final Oito2ControlAffinity controlAffinity;

  /// Space around the tile content.
  final EdgeInsetsGeometry? contentPadding;

  /// The focus node of the tile.
  final FocusNode? focusNode;

  /// Whether the tile takes focus when first shown.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final checkbox = Oito2Checkbox(
      value: value,
      tristate: tristate,
      onChanged: onChanged,
    );
    return _ToggleListTile(
      control: checkbox,
      controlLeading: controlAffinity != Oito2ControlAffinity.trailing,
      onTap: onChanged == null
          ? null
          : () => onChanged(
              nextCheckValue(checkbox.value, tristate: checkbox.tristate),
            ),
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      contentPadding: contentPadding,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}

/// A [ListTile] with an [Oito2Radio]; tapping the tile selects it.
class Oito2RadioListTile<T> extends StatelessWidget {
  /// Creates a radio list tile.
  const Oito2RadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.secondary,
    this.toggleable = false,
    this.controlAffinity = Oito2ControlAffinity.platform,
    this.contentPadding,
    this.focusNode,
    this.autofocus = false,
  });

  /// The value this tile represents.
  final T value;

  /// The currently selected value of the group.
  final T? groupValue;

  /// Called with [value] when selected, or null when a [toggleable] tile
  /// is cleared; null disables the tile.
  final ValueChanged<T?>? onChanged;

  /// The primary text.
  final Widget? title;

  /// The secondary text.
  final Widget? subtitle;

  /// A widget on the side opposite the radio, such as an icon.
  final Widget? secondary;

  /// Whether tapping the selected tile clears the group.
  final bool toggleable;

  /// Where the radio sits; [Oito2ControlAffinity.platform] is leading.
  final Oito2ControlAffinity controlAffinity;

  /// Space around the tile content.
  final EdgeInsetsGeometry? contentPadding;

  /// The focus node of the tile.
  final FocusNode? focusNode;

  /// Whether the tile takes focus when first shown.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return _ToggleListTile(
      control: Oito2Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        toggleable: toggleable,
      ),
      controlLeading: controlAffinity != Oito2ControlAffinity.trailing,
      onTap: onChanged == null
          ? null
          : () => activateRadio(
              value,
              groupValue,
              onChanged,
              toggleable: toggleable,
            ),
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      contentPadding: contentPadding,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}

/// A [ListTile] with an [Oito2Switch]; tapping the tile toggles it.
class Oito2SwitchListTile extends StatelessWidget {
  /// Creates a switch list tile.
  const Oito2SwitchListTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.secondary,
    this.onOffShapes = false,
    this.controlAffinity = Oito2ControlAffinity.platform,
    this.contentPadding,
    this.focusNode,
    this.autofocus = false,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value; null disables the tile.
  final ValueChanged<bool>? onChanged;

  /// The primary text.
  final Widget? title;

  /// The secondary text.
  final Widget? subtitle;

  /// A widget on the side opposite the switch, such as an icon.
  final Widget? secondary;

  /// Whether the switch track marks its states with shapes.
  final bool onOffShapes;

  /// Where the switch sits; [Oito2ControlAffinity.platform] is trailing.
  final Oito2ControlAffinity controlAffinity;

  /// Space around the tile content.
  final EdgeInsetsGeometry? contentPadding;

  /// The focus node of the tile.
  final FocusNode? focusNode;

  /// Whether the tile takes focus when first shown.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return _ToggleListTile(
      control: Oito2Switch(
        value: value,
        onChanged: onChanged,
        onOffShapes: onOffShapes,
      ),
      controlLeading: controlAffinity == Oito2ControlAffinity.leading,
      onTap: onChanged == null ? null : () => onChanged(!value),
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      contentPadding: contentPadding,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}
