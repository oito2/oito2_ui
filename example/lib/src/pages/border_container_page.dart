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

/// Documents [Oito2BorderContainer] with its default and custom colors,
/// ink effects inside it, and the tinted variations in the status colors
/// as they grow with long text.
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
    final text = _lorem.characters.take(_length.round()).toString();
    // #region tints
    final tints = [
      ('Accent', scheme.primary),
      ('Success', semantic?.success ?? scheme.primary),
      ('Warning', semantic?.warning ?? scheme.primary),
      ('Error', scheme.error),
      ('Info', semantic?.info ?? scheme.primary),
    ];
    // #endregion
    return DocPage(
      title: 'Border Container',
      description:
          'A surface with a thin border and large rounded corners, the '
          'basic card of oito2 layouts.',
      source: 'lib/src/pages/border_container_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2BorderContainer(
            width: 200,
            height: 120,
            padding: EdgeInsets.all(Oito2Spacing.md),
            child: Text('Default surface'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2BorderContainer` draws its `child` on the scheme `surface` '
          'with a 1-pixel `outlineVariant` border and the large corner '
          'radius, and clips the child to the rounded shape. Without '
          '`width` and `height` it sizes to its content; `padding` adds '
          'space inside the border and `margin` outside it.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Custom color', level: 3),
        const DocText(
          '`color` replaces the background, `borderColor` the border, and '
          '`borderRadius` the corners.',
        ),
        ExamplePanel(
          region: 'color',
          // #region color
          child: Oito2BorderContainer(
            width: 200,
            height: 120,
            padding: const EdgeInsets.all(Oito2Spacing.md),
            color: scheme.surfaceContainerHigh,
            borderRadius: Oito2Radius.mediumAll,
            child: const Text('surfaceContainerHigh'),
          ),
          // #endregion
        ),
        const DocHeading('Ink effects inside', level: 3),
        const DocText(
          'The container paints on a `Material`, so hover highlights and '
          'splashes of widgets inside it, such as a `ListTile`, show on its '
          'surface and stay inside the rounded corners.',
        ),
        ExamplePanel(
          region: 'ink',
          child: SizedBox(
            width: 320,
            // #region ink
            child: Oito2BorderContainer(
              child: ListTile(
                leading: const Icon(LucideIcons.folder),
                title: const Text('Open folder'),
                onTap: () {},
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Tinted', level: 3),
        const DocText(
          '`Oito2BorderContainer.tinted` uses a color, such as a status '
          'color, for the border and, at `opacity` (10% by default), for '
          'the fill. Like every container, it grows with its content: drag '
          'the slider to change the text length.',
        ),
        ExamplePanel(
          regions: const ['tints', 'tinted'],
          child: SizedBox(
            width: 480,
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
                  child: Text(text),
                ),
                // #region tinted
                for (final (name, tint) in tints)
                  Oito2BorderContainer.tinted(
                    tint: tint,
                    padding: const EdgeInsets.all(Oito2Spacing.md),
                    child: Text('$name: $text'),
                  ),
                // #endregion
              ],
            ),
          ),
        ),
        ...apiReferenceWidgets(['Oito2BorderContainer']),
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
