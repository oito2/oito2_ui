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

/// Documents [Oito2OptionButton] with icons, with a color and disabled.
class OptionButtonPage extends StatefulWidget {
  /// Creates the option button page.
  const OptionButtonPage({super.key});

  @override
  State<OptionButtonPage> createState() => _OptionButtonPageState();
}

class _OptionButtonPageState extends State<OptionButtonPage> {
  int _accent = 0;

  @override
  Widget build(BuildContext context) {
    final accent = Oito2AccentColor.values[_accent];
    return DocPage(
      title: 'Option Button',
      description:
          'A small square outlined button for secondary options, such as '
          'the buttons next to a list.',
      source: 'lib/src/pages/option_button_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.xs,
            children: [
              Oito2OptionButton(
                onPressed: () {},
                label: 'Add',
                child: const Icon(LucideIcons.plus),
              ),
              Oito2OptionButton(
                onPressed: () {},
                label: 'Remove',
                child: const Icon(LucideIcons.minus),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2OptionButton` a `child`, usually an `Icon`, and an '
          '`onPressed`. The `label` is both the tooltip and the name '
          'assistive technologies read. A null `onPressed` disables the '
          'button.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'An icon alone has no name, so an `Icon` child needs a `label`: '
          'without one, debug builds fail an assertion.',
          type: Oito2InfoType.warning,
        ),
        const DocHeading('Examples'),
        const DocHeading('Color swatch', level: 3),
        const DocText(
          '`Oito2OptionButton.color` shows a swatch of `color` instead of a '
          'child, and requires a `label` that names it. This one cycles '
          'through the accent colors.',
        ),
        ExamplePanel(
          region: 'color',
          // #region color
          child: Oito2OptionButton.color(
            onPressed: () => setState(
              () => _accent = (_accent + 1) % Oito2AccentColor.values.length,
            ),
            color: accent.color,
            label: 'Accent color: ${accent.name}',
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText('Without `onPressed`, the button is dimmed.'),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2OptionButton(
            onPressed: null,
            label: 'Remove',
            child: Icon(LucideIcons.minus),
          ),
          // #endregion
        ),
        ...apiReferenceWidgets(['Oito2OptionButton']),
      ],
    );
  }
}
