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

/// Documents [Oito2SelectableContainer] as a style picker.
class SelectableContainerPage extends StatefulWidget {
  /// Creates the selectable container page.
  const SelectableContainerPage({super.key});

  @override
  State<SelectableContainerPage> createState() =>
      _SelectableContainerPageState();
}

class _SelectableContainerPageState extends State<SelectableContainerPage> {
  int _style = 0;
  int _size = 1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Selectable Container',
      description:
          'A clickable container that shows when it is selected, such as an '
          'option in a grid of choices.',
      source: 'lib/src/pages/selectable_container_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: Wrap(
            spacing: Oito2Spacing.md,
            runSpacing: Oito2Spacing.md,
            children: [
              // #region preview
              for (final (index, name) in const [
                'Light',
                'Dark',
                'System',
              ].indexed)
                SizedBox(
                  width: 150,
                  child: Oito2SelectableContainer(
                    selected: _style == index,
                    onTap: () => setState(() => _style = index),
                    child: Column(
                      children: [
                        Oito2BorderContainer(
                          height: 72,
                          color: switch (index) {
                            0 => const Color(0xFFFAFAFA),
                            1 => const Color(0xFF242424),
                            _ => scheme.surfaceContainer,
                          },
                        ),
                        const SizedBox(height: Oito2Spacing.sm),
                        Text(name),
                      ],
                    ),
                  ),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2SelectableContainer` is controlled: give it `selected` and '
          'change it in `onTap`. A selected container takes a tinted '
          'background and a 2-pixel border in the text-safe primary tone. '
          'With `onTap`, hovering shows a thin border; without it the '
          'container doesn\'t respond to taps.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For a card that promotes content, with a visible border at rest, '
          'use `Oito2Banner`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Selection color and shape', level: 3),
        const DocText(
          '`selectionColor` replaces the selected tint, the primary color '
          'at 12% opacity by default. `padding` sets the space around the '
          'content and `borderRadius` the corners.',
        ),
        ExamplePanel(
          region: 'color',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            children: [
              // #region color
              for (final (index, name) in const ['S', 'M', 'L'].indexed)
                Oito2SelectableContainer(
                  selected: _size == index,
                  selectionColor: scheme.tertiary.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Oito2Spacing.lg,
                    vertical: Oito2Spacing.sm,
                  ),
                  borderRadius: Oito2Radius.mediumAll,
                  onTap: () => setState(() => _size = index),
                  child: Text(name),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read the container as a button when it '
          'has `onTap`, and report whether it is selected. With keyboard '
          'focus it shows the focus ring around its border.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next container.'],
            ['`Enter` / `Space`', 'Calls `onTap`.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2SelectableContainer']),
      ],
    );
  }
}
