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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'controls.dart';
import 'popover.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// The text format of an [Oito2ColorPicker]'s fields.
enum Oito2ColorFormat {
  /// One hexadecimal field, such as `#3584E4`.
  hex,

  /// Red, green and blue fields from 0 to 255.
  rgb,

  /// Hue, saturation and lightness fields.
  hsl,
}

/// Formats [color] as `#RRGGBB`, or `#RRGGBBAA` when it is translucent and
/// [withAlpha] is set.
String oito2ColorToHex(Color color, {bool withAlpha = true}) {
  String part(double channel) =>
      (channel * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
  final hex = '#${part(color.r)}${part(color.g)}${part(color.b)}';
  return withAlpha && color.a < 1 ? '$hex${part(color.a)}' : hex;
}

/// Reads `#RGB`, `#RRGGBB` or `#RRGGBBAA`, with or without `#`; null when
/// [text] isn't one of them.
Color? oito2ColorFromHex(String text) {
  var hex = text.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) return null;
  if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
  if (hex.length == 6) hex = '${hex}FF';
  if (hex.length != 8) return null;
  final rgba = int.parse(hex, radix: 16);
  return Color(((rgba & 0xFF) << 24) | (rgba >> 8));
}

/// A color picker: a saturation and brightness area, a hue slider, an
/// optional opacity slider, text fields in a chosen [Oito2ColorFormat]
/// and optional [swatches].
///
/// Every part works by pointer and by keyboard: the arrow keys move the
/// area and the sliders by 1%, or 10% with Shift, and the fields apply
/// on Enter or when they lose focus. Use [Oito2ColorPickerButton] to show
/// it in a popover.
class Oito2ColorPicker extends StatefulWidget {
  /// Creates a color picker.
  const Oito2ColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.showAlpha = true,
    this.swatches = const [],
    this.initialFormat = Oito2ColorFormat.hex,
    this.width = 264,
  });

  /// The current color.
  final Color value;

  /// Called with each new color.
  final ValueChanged<Color> onChanged;

  /// Whether the opacity can change.
  final bool showAlpha;

  /// Preset colors offered below the fields.
  final List<Color> swatches;

  /// The field format shown first.
  final Oito2ColorFormat initialFormat;

  /// The picker width.
  final double width;

  @override
  State<Oito2ColorPicker> createState() => _Oito2ColorPickerState();
}

class _Oito2ColorPickerState extends State<Oito2ColorPicker> {
  late HSVColor _hsv = HSVColor.fromColor(widget.value);
  late Oito2ColorFormat _format = widget.initialFormat;

  @override
  void didUpdateWidget(Oito2ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _hsv.toColor()) {
      final next = HSVColor.fromColor(widget.value);
      // Keeps the hue when the new color is gray, where it has none.
      _hsv = next.saturation == 0 || next.value == 0
          ? next.withHue(_hsv.hue)
          : next;
    }
  }

  /// Shows and reports [hsv]; a field committed after the picker closed
  /// still reports its color.
  void _set(HSVColor hsv) {
    if (mounted) setState(() => _hsv = hsv);
    widget.onChanged(hsv.toColor());
  }

  /// Sets [color], keeping the current hue, or [hue] when given, for grays,
  /// which have no hue of their own.
  void _setColor(Color color, {double? hue}) {
    final next = HSVColor.fromColor(color);
    final gray = next.saturation == 0 || next.value == 0;
    _set(gray ? next.withHue(hue ?? _hsv.hue) : next);
  }

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final color = _hsv.toColor();
    final opaque = color.withValues(alpha: 1);
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Oito2Spacing.md,
        children: [
          _SaturationArea(hsv: _hsv, onChanged: _set),
          _ChannelSlider(
            label: strings.hue,
            value: _hsv.hue / 360,
            format: (v) => '${(v * 360).round()}°',
            colors: [
              for (var h = 0; h <= 360; h += 60)
                HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
            ],
            thumb: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
            onChanged: (v) => _set(_hsv.withHue((v * 360).clamp(0, 360))),
          ),
          if (widget.showAlpha)
            _ChannelSlider(
              label: strings.opacity,
              value: _hsv.alpha,
              format: (v) => '${(v * 100).round()}%',
              colors: [opaque.withValues(alpha: 0), opaque],
              checkerboard: true,
              thumb: color,
              onChanged: (v) => _set(_hsv.withAlpha(v)),
            ),
          Row(
            spacing: Oito2Spacing.sm,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: Oito2Radius.smallAll,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: Oito2Radius.smallAll,
                  child: CustomPaint(
                    painter: _CheckerPainter(),
                    child: ColoredBox(color: color),
                  ),
                ),
              ),
              Expanded(
                child: _ColorFields(
                  color: color,
                  hsv: _hsv,
                  format: _format,
                  showAlpha: widget.showAlpha,
                  onColor: _setColor,
                ),
              ),
            ],
          ),
          SegmentedButton<Oito2ColorFormat>(
            showSelectedIcon: false,
            segments: [
              for (final format in Oito2ColorFormat.values)
                ButtonSegment(
                  value: format,
                  label: Text(format.name.toUpperCase()),
                ),
            ],
            selected: {_format},
            onSelectionChanged: (s) => setState(() => _format = s.first),
          ),
          if (widget.swatches.isNotEmpty)
            Wrap(
              spacing: Oito2Spacing.xxs,
              runSpacing: Oito2Spacing.xxs,
              children: [
                for (final swatch in widget.swatches)
                  Oito2ColorDisk(
                    color: swatch,
                    size: 20,
                    selected: swatch.toARGB32() == color.toARGB32(),
                    label: oito2ColorToHex(swatch),
                    onPressed: () => _setColor(swatch),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// The 2D saturation (across) and brightness (up) area.
class _SaturationArea extends StatelessWidget {
  const _SaturationArea({required this.hsv, required this.onChanged});

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final s = hsv.saturation;
    final v = hsv.value;
    void move(double ds, double dv) => onChanged(
      hsv
          .withSaturation((s + ds).clamp(0.0, 1.0))
          .withValue((v + dv).clamp(0.0, 1.0)),
    );
    String label(double brightness) =>
        '${strings.saturation} ${(s * 100).round()}%, '
        '${(brightness.clamp(0.0, 1.0) * 100).round()}%';
    return Semantics(
      slider: true,
      label: strings.saturationAndBrightness,
      value: label(v),
      increasedValue: label(v + 0.01),
      decreasedValue: label(v - 0.01),
      onIncrease: () => move(0, 0.01),
      onDecrease: () => move(0, -0.01),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              move(0.01, 0),
          const SingleActivator(
            LogicalKeyboardKey.arrowRight,
            shift: true,
          ): () =>
              move(0.1, 0),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              move(-0.01, 0),
          const SingleActivator(
            LogicalKeyboardKey.arrowLeft,
            shift: true,
          ): () =>
              move(-0.1, 0),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
              move(0, 0.01),
          const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): () =>
              move(0, 0.1),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
              move(0, -0.01),
          const SingleActivator(
            LogicalKeyboardKey.arrowDown,
            shift: true,
          ): () =>
              move(0, -0.1),
        },
        child: Oito2FocusBorder(
          child: Focus(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, 150);
                void pick(Offset p) => onChanged(
                  hsv
                      .withSaturation((p.dx / size.width).clamp(0.0, 1.0))
                      .withValue((1 - p.dy / size.height).clamp(0.0, 1.0)),
                );
                return GestureDetector(
                  onTapDown: (d) => pick(d.localPosition),
                  onPanStart: (d) => pick(d.localPosition),
                  onPanUpdate: (d) => pick(d.localPosition),
                  child: ExcludeSemantics(
                    child: CustomPaint(size: size, painter: _AreaPainter(hsv)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AreaPainter extends CustomPainter {
  _AreaPainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(Oito2Radius.medium),
    );
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRect(
        rect,
        Paint()..color = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
      )
      ..drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          ).createShader(rect),
      )
      ..drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0xFF000000)],
          ).createShader(rect),
      )
      ..restore();
    final thumb = Offset(
      hsv.saturation * size.width,
      (1 - hsv.value) * size.height,
    );
    _drawThumb(canvas, thumb, hsv.toColor().withValues(alpha: 1));
  }

  @override
  bool shouldRepaint(_AreaPainter old) => old.hsv != hsv;
}

/// Draws a round thumb filled with [color], with a white ring and a dark
/// outline so it shows on any background.
void _drawThumb(Canvas canvas, Offset center, Color color) {
  canvas
    ..drawCircle(center, 9, Paint()..color = const Color(0x66000000))
    ..drawCircle(center, 8, Paint()..color = const Color(0xFFFFFFFF))
    ..drawCircle(center, 6, Paint()..color = color);
}

/// A horizontal slider over a gradient of [colors], for one channel.
class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.label,
    required this.value,
    required this.format,
    required this.colors,
    required this.thumb,
    required this.onChanged,
    this.checkerboard = false,
  });

  final String label;
  final double value;
  final String Function(double value) format;
  final List<Color> colors;
  final Color thumb;
  final ValueChanged<double> onChanged;
  final bool checkerboard;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    void by(double delta) => onChanged((value + delta).clamp(0.0, 1.0));
    final (:back, :forward) = readingArrowsOf(context);
    return Semantics(
      slider: true,
      label: label,
      value: format(value),
      increasedValue: format((value + 0.01).clamp(0.0, 1.0)),
      decreasedValue: format((value - 0.01).clamp(0.0, 1.0)),
      onIncrease: () => by(0.01),
      onDecrease: () => by(-0.01),
      child: CallbackShortcuts(
        bindings: {
          SingleActivator(forward): () => by(0.01),
          SingleActivator(forward, shift: true): () => by(0.1),
          SingleActivator(back): () => by(-0.01),
          SingleActivator(back, shift: true): () => by(-0.1),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => by(0.01),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => by(-0.01),
        },
        child: Oito2FocusBorder(
          borderRadius: BorderRadius.circular(9),
          child: Focus(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                void pick(Offset p) {
                  final x = ((p.dx - 9) / (width - 18)).clamp(0.0, 1.0);
                  onChanged(rtl ? 1 - x : x);
                }

                return GestureDetector(
                  onTapDown: (d) => pick(d.localPosition),
                  onHorizontalDragStart: (d) => pick(d.localPosition),
                  onHorizontalDragUpdate: (d) => pick(d.localPosition),
                  child: ExcludeSemantics(
                    child: CustomPaint(
                      size: Size(width, 18),
                      painter: _SliderPainter(
                        value: rtl ? 1 - value : value,
                        colors: rtl ? colors.reversed.toList() : colors,
                        thumb: thumb,
                        checkerboard: checkerboard,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  _SliderPainter({
    required this.value,
    required this.colors,
    required this.thumb,
    required this.checkerboard,
  });

  final double value;
  final List<Color> colors;
  final Color thumb;
  final bool checkerboard;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Rect.fromLTWH(0, 3, size.width, size.height - 6);
    final rrect = RRect.fromRectAndRadius(track, const Radius.circular(6));
    canvas.save();
    canvas.clipRRect(rrect);
    if (checkerboard) _CheckerPainter().paint(canvas, size);
    canvas.drawRect(
      track,
      Paint()..shader = LinearGradient(colors: colors).createShader(track),
    );
    canvas.restore();
    _drawThumb(
      canvas,
      Offset(9 + value * (size.width - 18), size.height / 2),
      thumb,
    );
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.value != value ||
      old.thumb != thumb ||
      old.checkerboard != checkerboard ||
      !listEquals(old.colors, colors);
}

/// Gray and white squares that show through translucent colors.
class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    final gray = Paint()..color = const Color(0xFFCCCCCC);
    const cell = 6.0;
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = 0; x * cell < size.width; x++) {
        if ((x + y).isEven) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), gray);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => false;
}

/// The text fields of the color picker in one format.
class _ColorFields extends StatelessWidget {
  const _ColorFields({
    required this.color,
    required this.hsv,
    required this.format,
    required this.showAlpha,
    required this.onColor,
  });

  final Color color;
  final HSVColor hsv;
  final Oito2ColorFormat format;
  final bool showAlpha;
  final void Function(Color color, {double? hue}) onColor;

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    switch (format) {
      case Oito2ColorFormat.hex:
        return _CommitField(
          key: const ValueKey('Hex'),
          label: Oito2Localizations.of(context).hexColor,
          text: oito2ColorToHex(color, withAlpha: showAlpha),
          onCommit: (text) {
            final parsed = oito2ColorFromHex(text);
            if (parsed == null) return false;
            onColor(showAlpha ? parsed : parsed.withValues(alpha: color.a));
            return true;
          },
        );
      case Oito2ColorFormat.rgb:
        int channel(double c) => (c * 255).round();
        Widget field(String label, String semantic, int value, int index) =>
            Expanded(
              child: _CommitField(
                // One element per channel, so switching formats replaces
                // the field and applies its pending text.
                key: ValueKey(label),
                label: label,
                semanticLabel: semantic,
                text: '$value',
                numeric: true,
                onCommit: (text) {
                  final n = int.tryParse(text);
                  if (n == null) return false;
                  final v = n.clamp(0, 255) / 255;
                  onColor(
                    Color.from(
                      alpha: color.a,
                      red: index == 0 ? v : color.r,
                      green: index == 1 ? v : color.g,
                      blue: index == 2 ? v : color.b,
                    ),
                  );
                  return true;
                },
              ),
            );
        return Row(
          spacing: Oito2Spacing.xs,
          children: [
            field('R', strings.red, channel(color.r), 0),
            field('G', strings.green, channel(color.g), 1),
            field('B', strings.blue, channel(color.b), 2),
          ],
        );
      case Oito2ColorFormat.hsl:
        final hsl = HSLColor.fromColor(color);
        final hue = hsv.hue;
        Widget field(
          String label,
          String semantic,
          int value,
          int max,
          HSLColor Function(double) apply, {
          bool hueField = false,
        }) => Expanded(
          child: _CommitField(
            key: ValueKey(label),
            label: label,
            semanticLabel: semantic,
            text: '$value',
            numeric: true,
            onCommit: (text) {
              final n = int.tryParse(text);
              if (n == null) return false;
              final value = n.clamp(0, max).toDouble();
              onColor(apply(value).toColor(), hue: hueField ? value : hue);
              return true;
            },
          ),
        );
        return Row(
          spacing: Oito2Spacing.xs,
          children: [
            field(
              'H',
              strings.hue,
              hue.round(),
              360,
              hsl.withHue,
              hueField: true,
            ),
            field(
              'S',
              strings.saturation,
              (hsl.saturation * 100).round(),
              100,
              (v) => hsl.withHue(hue).withSaturation(v / 100),
            ),
            field(
              'L',
              strings.lightness,
              (hsl.lightness * 100).round(),
              100,
              (v) => hsl.withHue(hue).withLightness(v / 100),
            ),
          ],
        );
    }
  }
}

/// A small field that applies its text on Enter or when it loses focus,
/// and shows [text] again when [onCommit] rejects it.
class _CommitField extends StatefulWidget {
  const _CommitField({
    super.key,
    required this.label,
    required this.text,
    required this.onCommit,
    this.semanticLabel,
    this.numeric = false,
  });

  final String label;
  final String? semanticLabel;
  final String text;
  final bool Function(String text) onCommit;
  final bool numeric;

  @override
  State<_CommitField> createState() => _CommitFieldState();
}

class _CommitFieldState extends State<_CommitField> {
  late final _controller = TextEditingController(text: widget.text);
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(_CommitField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && _controller.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  /// Applies text typed without Enter when the field goes away, such as
  /// when the format changes or the popover closes, after the frame that
  /// removes it.
  @override
  void deactivate() {
    final text = _controller.text;
    if (_focusNode.hasFocus && text != widget.text) {
      final commit = widget.onCommit;
      WidgetsBinding.instance.addPostFrameCallback((_) => commit(text));
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    if (_controller.text == widget.text) return;
    if (!widget.onCommit(_controller.text)) _controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: widget.numeric ? TextInputType.number : null,
        inputFormatters: [
          if (widget.numeric) FilteringTextInputFormatter.digitsOnly,
        ],
        onSubmitted: (_) => _commit(),
        decoration: InputDecoration(
          prefixText: '${widget.label} ',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Oito2Spacing.sm,
          ),
        ),
      ),
    );
  }
}

/// A button showing a color swatch and its hex value that opens an
/// [Oito2ColorPicker] in a popover.
class Oito2ColorPickerButton extends StatelessWidget {
  /// Creates a color picker button.
  const Oito2ColorPickerButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.showAlpha = true,
    this.swatches = const [],
    this.semanticLabel,
  });

  /// The current color.
  final Color value;

  /// Called with each new color; the button is disabled when null.
  final ValueChanged<Color>? onChanged;

  /// Whether the opacity can change.
  final bool showAlpha;

  /// Preset colors offered in the picker.
  final List<Color> swatches;

  /// The accessibility label, such as what the color is for.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final scheme = Theme.of(context).colorScheme;
    final hex = oito2ColorToHex(value, withAlpha: showAlpha);
    return Oito2Popover(
      semanticLabel: semanticLabel,
      builder: (context, controller) => Semantics(
        label: semanticLabel,
        child: OutlinedButton(
          onPressed: onChanged == null ? null : controller.toggle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.sm,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: Oito2Radius.checkAll,
                  border: Border.all(color: scheme.outline),
                ),
                child: ClipRRect(
                  borderRadius: Oito2Radius.checkAll,
                  child: CustomPaint(
                    painter: _CheckerPainter(),
                    child: ColoredBox(color: value),
                  ),
                ),
              ),
              Text(hex),
            ],
          ),
        ),
      ),
      popoverBuilder: (context, _) => Oito2ColorPicker(
        value: value,
        onChanged: onChanged ?? (_) {},
        showAlpha: showAlpha,
        swatches: swatches,
      ),
    );
  }
}
