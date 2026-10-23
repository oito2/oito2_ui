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

import '../docs/doc_widgets.dart';

const _icons = {
  'ok': Oito2AnimatedIcons.ok,
  'okFilled': Oito2AnimatedIcons.okFilled,
  'heart': Oito2AnimatedIcons.heart,
  'heartFilled': Oito2AnimatedIcons.heartFilled,
  'star': Oito2AnimatedIcons.star,
  'starFilled': Oito2AnimatedIcons.starFilled,
  'starHalfFilled': Oito2AnimatedIcons.starHalfFilled,
  'compass': Oito2AnimatedIcons.compass,
  'compassFilled': Oito2AnimatedIcons.compassFilled,
  'noNetwork': Oito2AnimatedIcons.noNetwork,
};

// #region custom-data
/// Draws a ring that grows from the center of the 24 × 24 grid.
void _paintRing(Canvas canvas, double progress, Paint paint) {
  canvas.drawCircle(
    const Offset(12, 12),
    2 + 8 * Curves.easeOut.transform(progress),
    Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
}

const _ring = Oito2AnimatedIconData(
  _paintRing,
  duration: Duration(milliseconds: 900),
);
// #endregion

/// Documents [Oito2AnimatedIcon]: the [Oito2AnimatedIcons] set, the
/// [Oito2AnimationMode]s, use in a button and custom icons.
class AnimatedIconPage extends StatefulWidget {
  /// Creates the animated icon page.
  const AnimatedIconPage({super.key});

  @override
  State<AnimatedIconPage> createState() => _AnimatedIconPageState();
}

class _AnimatedIconPageState extends State<AnimatedIconPage> {
  Oito2AnimationMode _mode = Oito2AnimationMode.once;
  int _replays = 0;
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Animated Icon',
      description:
          'An icon that draws itself when it appears, plays in a loop, or '
          'shows its final frame, in the stroke style of the Lucide icons.',
      source: 'lib/src/pages/animated_icon_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: Column(
            spacing: Oito2Spacing.md,
            children: [
              // #region preview
              Oito2AnimatedIcon(
                Oito2AnimatedIcons.ok,
                key: ValueKey(_replays),
                size: 48,
              ),
              // #endregion
              OutlinedButton.icon(
                onPressed: () => setState(() => _replays++),
                icon: const Icon(LucideIcons.rotate_ccw),
                label: const Text('Replay'),
              ),
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2AnimatedIcon` one of the `Oito2AnimatedIcons`. Like '
          '`Icon`, it takes its `size` and `color` from the icon theme '
          'unless you set them, so it fits in buttons and list tiles. By '
          'default it plays once, when it first shows and again whenever '
          'its icon or mode changes.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'A new `key` creates a new icon state, which plays the animation '
          'from the start; the Replay buttons on this page work that way.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Icons and modes', level: 3),
        const DocText(
          '`mode` sets how the animation plays: `once`, `repeat` over and '
          'over, or `still`, which shows the final frame. The `filled` '
          'variants cut their inner mark out of the fill, so the '
          'background shows through it.',
        ),
        ExamplePanel(
          region: 'gallery',
          child: Column(
            spacing: Oito2Spacing.md,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Oito2Spacing.md,
                runSpacing: Oito2Spacing.sm,
                children: [
                  SizedBox(
                    width: 300,
                    child: Oito2ChoiceChipBar(
                      style: Oito2ChoiceChipBarStyle.wrap,
                      labels: [
                        for (final mode in Oito2AnimationMode.values)
                          Text(mode.name),
                      ],
                      isSelected: [
                        for (final mode in Oito2AnimationMode.values)
                          mode == _mode,
                      ],
                      onSelected: (i) =>
                          setState(() => _mode = Oito2AnimationMode.values[i]),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _replays++),
                    icon: const Icon(LucideIcons.rotate_ccw),
                    label: const Text('Replay'),
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Oito2Spacing.sm,
                runSpacing: Oito2Spacing.md,
                children: [
                  for (final MapEntry(key: name, value: data) in _icons.entries)
                    SizedBox(
                      width: 112,
                      child: Column(
                        spacing: Oito2Spacing.sm,
                        children: [
                          // #region gallery
                          Oito2AnimatedIcon(
                            data,
                            key: ValueKey((name, _replays)),
                            size: 40,
                            mode: _mode,
                          ),
                          // #endregion
                          Text(
                            name,
                            style: textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const DocTable(
          header: ['Icon', 'Animation'],
          rows: [
            ['`ok`', 'A circle that draws itself, then a check mark.'],
            [
              '`okFilled`',
              'A filled circle that pops in, then a check mark cut out of it.',
            ],
            ['`heart`', 'A heart outline that draws itself, then beats.'],
            ['`heartFilled`', 'A filled heart that pops in.'],
            ['`star`', 'A star outline that draws itself.'],
            ['`starFilled`', 'A filled star that spins and pops in.'],
            ['`starHalfFilled`', 'A star outline whose left half fills.'],
            [
              '`compass`',
              'A compass whose needle, with a filled north half, swings and '
                  'settles north.',
            ],
            [
              '`compassFilled`',
              'A filled compass whose cut-out needle swings and settles '
                  'north.',
            ],
            [
              '`noNetwork`',
              'Wi-Fi waves that appear one by one, then a slash across them.',
            ],
          ],
        ),
        const DocHeading('In a button', level: 3),
        const DocText(
          'Swap the icon on a state change to play it as feedback. Here the '
          'outline heart is `still`, and the filled heart pops in when the '
          'button is selected.',
        ),
        ExamplePanel(
          region: 'button',
          // #region button
          child: Oito2IconButton(
            tooltip: _liked ? 'Unlike' : 'Like',
            isSelected: _liked,
            onPressed: () => setState(() => _liked = !_liked),
            icon: _liked
                ? const Oito2AnimatedIcon(Oito2AnimatedIcons.heartFilled)
                : const Oito2AnimatedIcon(
                    Oito2AnimatedIcons.heart,
                    mode: Oito2AnimationMode.still,
                  ),
          ),
          // #endregion
        ),
        const DocHeading('Color and duration', level: 3),
        const DocText(
          '`color` and `size` override the icon theme, and `duration` the '
          'length of one play, which otherwise comes from the icon data.',
        ),
        ExamplePanel(
          region: 'color',
          // #region color
          child: Oito2AnimatedIcon(
            Oito2AnimatedIcons.compass,
            size: 56,
            color: scheme.primary,
            duration: const Duration(seconds: 3),
            mode: Oito2AnimationMode.repeat,
          ),
          // #endregion
        ),
        const DocHeading('Custom icon', level: 3),
        const DocText(
          'An `Oito2AnimatedIconData` pairs a painter with the length of one '
          'play. The painter draws one frame on a 24 × 24 grid, scaled to '
          'the icon size, for a `progress` from 0 to 1, with a `paint` that '
          'carries the icon color.',
        ),
        ExamplePanel(
          regions: const ['custom-data', 'custom'],
          // #region custom
          child: const Oito2AnimatedIcon(
            _ring,
            size: 48,
            mode: Oito2AnimationMode.repeat,
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Without a `semanticLabel` the icon is decorative and hidden from '
          'assistive technologies, as next to a text or inside a button '
          'with a tooltip. With one, it is announced as an image with that '
          'label.',
        ),
        const DocText(
          'When the platform asks to disable animations, the icon shows its '
          'final frame in every mode.',
        ),
        ...apiReferenceWidgets([
          'Oito2AnimatedIcon',
          'Oito2AnimatedIcons',
          'Oito2AnimationMode',
          'Oito2AnimatedIconData',
          'Oito2AnimatedIconPainter',
        ]),
      ],
    );
  }
}
