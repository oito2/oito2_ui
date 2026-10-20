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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../widgets/showcase_widgets.dart';

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

/// Shows every [Oito2AnimatedIcons] icon in each [Oito2AnimationMode].
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
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Mode',
          children: [
            SizedBox(
              width: 360,
              child: Oito2ChoiceChipBar(
                style: Oito2ChoiceChipBarStyle.wrap,
                labels: [
                  for (final mode in Oito2AnimationMode.values) Text(mode.name),
                ],
                isSelected: [
                  for (final mode in Oito2AnimationMode.values) mode == _mode,
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
        ShowcaseSection(
          'Icons',
          children: [
            for (final MapEntry(key: name, value: data) in _icons.entries)
              SizedBox(
                width: 112,
                child: Column(
                  spacing: Oito2Spacing.sm,
                  children: [
                    Oito2AnimatedIcon(
                      data,
                      key: ValueKey((name, _replays)),
                      size: 40,
                      mode: _mode,
                    ),
                    Text(name, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'In a button: tap the heart',
          children: [
            Oito2IconButton(
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
          ],
        ),
      ],
    );
  }
}
