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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2BorderContainer] with its default and custom colors, the
/// tinted variations in the status colors, and how they grow with long
/// text.
class BorderContainerPage extends StatefulWidget {
  /// Creates the border container page.
  const BorderContainerPage({super.key});

  @override
  State<BorderContainerPage> createState() => _BorderContainerPageState();
}

class _BorderContainerPageState extends State<BorderContainerPage> {
  /// How many characters of the sample text the containers show.
  double _length = 80;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = Oito2SemanticColors.maybeOf(context);
    final text = Text(_lorem.characters.take(_length.round()).toString());
    final tints = [
      ('Accent', scheme.primary),
      ('Success', semantic?.success ?? scheme.primary),
      ('Warning', semantic?.warning ?? scheme.primary),
      ('Error', scheme.error),
      ('Info', semantic?.info ?? scheme.primary),
    ];
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Border containers',
          children: [
            const Oito2BorderContainer(
              width: 200,
              height: 120,
              padding: EdgeInsets.all(Oito2Spacing.md),
              child: Text('Default surface'),
            ),
            Oito2BorderContainer(
              width: 200,
              height: 120,
              padding: const EdgeInsets.all(Oito2Spacing.md),
              color: scheme.surfaceContainerHigh,
              child: const Text('surfaceContainerHigh'),
            ),
          ],
        ),
        ShowcaseSection(
          'Tinted, with growing text',
          children: [
            SizedBox(
              width: 560,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Oito2Spacing.md,
                children: [
                  Row(
                    children: [
                      const Text('Text length'),
                      Expanded(
                        child: Slider(
                          min: 1,
                          max: _lorem.length.toDouble(),
                          value: _length,
                          label: '${_length.round()}',
                          onChanged: (value) => setState(() => _length = value),
                        ),
                      ),
                    ],
                  ),
                  Oito2BorderContainer(
                    padding: const EdgeInsets.all(Oito2Spacing.md),
                    child: text,
                  ),
                  for (final (name, tint) in tints)
                    Oito2BorderContainer.tinted(
                      tint: tint,
                      padding: const EdgeInsets.all(Oito2Spacing.md),
                      child: Text('$name: ${text.data}'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const _lorem =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
    'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
    'ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut '
    'aliquip ex ea commodo consequat. Duis aute irure dolor in '
    'reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla '
    'pariatur. Excepteur sint occaecat cupidatat non proident, sunt in '
    'culpa qui officia deserunt mollit anim id est laborum.';
