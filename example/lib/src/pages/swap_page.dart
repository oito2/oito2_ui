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

/// Documents [Oito2Swap] with each of its effects and a custom duration.
class SwapPage extends StatefulWidget {
  /// Creates the swap page.
  const SwapPage({super.key});

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  bool _playing = false;
  bool _swapped = false;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Swap',
      description:
          'Animates between two widgets, such as a play button that becomes '
          'pause.',
      source: 'lib/src/pages/swap_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2IconButton(
            tooltip: _playing ? 'Pause' : 'Play',
            onPressed: () => setState(() => _playing = !_playing),
            icon: Oito2Swap(
              swapped: _playing,
              off: const Icon(LucideIcons.play),
              on: const Icon(LucideIcons.pause),
            ),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Swap` shows `on` while `swapped` is true and `off` '
          'otherwise. Change `swapped` and the widgets change with a '
          'transition. The swap only animates: put it inside a button, or '
          'another widget that handles the taps.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Effects', level: 3),
        const DocText(
          '`effect` picks the transition: `fade`, the default, cross-fades '
          'the widgets; `scale` grows the new one in while the old one '
          'shrinks away; `rotate` turns them a quarter turn while fading; '
          'and `flip` flips them around the vertical axis. Tap any icon to '
          'swap them all.',
        ),
        ExamplePanel(
          region: 'effects',
          // #region effects
          child: Wrap(
            spacing: Oito2Spacing.md,
            runSpacing: Oito2Spacing.sm,
            children: [
              for (final effect in Oito2SwapEffect.values)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Oito2IconButton(
                      tooltip: effect.name,
                      onPressed: () => setState(() => _swapped = !_swapped),
                      icon: Oito2Swap(
                        swapped: _swapped,
                        effect: effect,
                        off: const Icon(LucideIcons.play),
                        on: const Icon(LucideIcons.pause),
                      ),
                    ),
                    Text(effect.name),
                  ],
                ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Duration', level: 3),
        const DocText(
          '`duration` sets the length of the transition, 200 milliseconds '
          'by default.',
        ),
        ExamplePanel(
          region: 'duration',
          // #region duration
          child: Oito2IconButton(
            tooltip: 'Dark style',
            isSelected: _dark,
            onPressed: () => setState(() => _dark = !_dark),
            icon: Oito2Swap(
              swapped: _dark,
              effect: Oito2SwapEffect.rotate,
              duration: const Duration(milliseconds: 500),
              off: const Icon(LucideIcons.sun),
              on: const Icon(LucideIcons.moon),
            ),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'When the platform asks to disable animations, the change is '
          'instant. '
          'The swap adds no semantics of its own; label the button around '
          'it, and update the label with the state, as the tooltip of the '
          'preview does.',
        ),
        ...apiReferenceWidgets(['Oito2Swap', 'Oito2SwapEffect']),
      ],
    );
  }
}
