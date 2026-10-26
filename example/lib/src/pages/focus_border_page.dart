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

/// Documents [Oito2FocusBorder] around custom focusable content.
class FocusBorderPage extends StatelessWidget {
  /// Creates the focus border page.
  const FocusBorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Focus Border',
      description:
          'Draws the oito2 focus ring around custom content while a widget '
          'inside it has keyboard focus.',
      source: 'lib/src/pages/focus_border_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.md,
            children: [
              Wrap(
                spacing: Oito2Spacing.md,
                runSpacing: Oito2Spacing.md,
                children: [
                  // #region preview
                  for (final label in ['First', 'Second', 'Third'])
                    Oito2FocusBorder(
                      child: Focus(
                        child: Builder(
                          builder: (context) => MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Focus.of(context).requestFocus(),
                              child: Oito2BorderContainer(
                                width: 140,
                                height: 72,
                                child: Center(child: Text(label)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // #endregion
                ],
              ),
              Text(
                'Press Tab to move the focus ring between the boxes.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Wrap the content in `Oito2FocusBorder`. While any widget inside '
          'it has the focus, it draws a 2-pixel ring in the text-safe '
          'primary tone outside the content, with the corners of '
          '`borderRadius`. The ring is painted over the content and takes '
          'no space, so the layout doesn\'t move when it appears.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The ring follows the keyboard: it shows when the focus arrives '
          'in keyboard navigation, and not after a pointer click. The '
          'border itself never takes the focus; the content must hold a '
          'focusable widget, such as a `Focus` or a button.',
        ),
        const DocNote(
          'Use it for custom controls that draw their own surface. The '
          'oito2 components, such as `Oito2ListTile`, already include it.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Forced on', level: 3),
        const DocText(
          '`focused` overrides the focus: `true` always shows the ring and '
          '`false` never does, for example to mirror a selection kept '
          'elsewhere. Null, the default, follows the keyboard focus.',
        ),
        const ExamplePanel(
          region: 'forced',
          // #region forced
          child: Oito2FocusBorder(
            focused: true,
            borderRadius: Oito2Radius.largeAll,
            child: Oito2BorderContainer(
              width: 140,
              height: 72,
              child: Center(child: Text('Always on')),
            ),
          ),
          // #endregion
        ),
        ...apiReferenceWidgets(['Oito2FocusBorder']),
      ],
    );
  }
}
