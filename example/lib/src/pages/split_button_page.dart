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

/// Documents [Oito2SplitButton] in every variant and disabled.
class SplitButtonPage extends StatelessWidget {
  /// Creates the split button page.
  const SplitButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Split Button',
      description:
          'A button with a main action and an attached arrow that opens a '
          'menu of related actions.',
      source: 'lib/src/pages/split_button_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2SplitButton(
            onPressed: () {},
            menuChildren: [
              MenuItemButton(onPressed: () {}, child: const Text('Save as…')),
              MenuItemButton(
                onPressed: () {},
                child: const Text('Save a copy'),
              ),
            ],
            child: const Text('Save'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'The main part shows `child` and runs `onPressed`. The arrow part '
          'opens a menu of `menuChildren`, usually `MenuItemButton`s, and '
          'closes it when pressed again. A null `onPressed` disables both '
          'parts.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'Use a split button when one action is the usual choice and a few '
          'variants of it are needed less often. When no action is the '
          'default, a plain menu button is clearer.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Variants', level: 3),
        const DocText(
          '`variant` picks the look of both parts: `elevated`, the default, '
          'a neutral button; `filled`, a primary button; and `outlined`.',
        ),
        ExamplePanel(
          region: 'variants',
          // #region variants
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            children: [
              for (final variant in Oito2SplitButtonVariant.values)
                Oito2SplitButton(
                  variant: variant,
                  onPressed: () {},
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {},
                      child: const Text('Save as…'),
                    ),
                  ],
                  child: Text(variant.name),
                ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText('Without `onPressed`, neither part responds.'),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2SplitButton(
            onPressed: null,
            menuChildren: [],
            child: Text('Save'),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The two parts are separate buttons, each a focus stop. The arrow '
          'part is labeled by `menuLabel`, "More options" by default, '
          'localized.',
        ),
        ...apiReferenceWidgets(['Oito2SplitButton', 'Oito2SplitButtonVariant']),
      ],
    );
  }
}
