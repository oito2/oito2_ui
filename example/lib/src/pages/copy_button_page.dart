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

/// Documents [Oito2CopyButton] and [Oito2CopyField].
class CopyButtonPage extends StatelessWidget {
  /// Creates the copy button page.
  const CopyButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final toaster = Oito2Toaster.maybeOf(context);
    return DocPage(
      title: 'Copy Button',
      description:
          'Copies a text to the clipboard and confirms it with a check '
          'mark, or shows why it could not.',
      source: 'lib/src/pages/copy_button_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.sm,
            children: [
              Flexible(
                child: Text(
                  'git clone https://github.com/oito2/oito2_ui.git',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Oito2CopyButton(
                text: 'git clone https://github.com/oito2/oito2_ui.git',
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2CopyButton` the `text` to copy. After a copy, the icon '
          'turns into a check mark and the tooltip into "Copied" for '
          '`feedbackDuration`; assistive technologies hear the change.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Reacting to a copy', level: 3),
        const DocText(
          '`onCopied` runs after each copy, for example to show a toast. '
          'When the platform refuses the copy, such as a browser without '
          'clipboard permission, the button shows a cross and "Couldn\'t '
          'copy", and `onError` receives the error.',
        ),
        ExamplePanel(
          region: 'callback',
          // #region callback
          child: Oito2CopyButton(
            text: 'oito2_ui',
            onCopied: () =>
                toaster?.show(const Oito2Toast(title: 'Name copied')),
            onError: (error) => toaster?.show(
              const Oito2Toast(
                title: 'Could not copy',
                type: Oito2InfoType.danger,
              ),
            ),
          ),
          // #endregion
        ),
        const DocHeading('Copy field', level: 3),
        const DocText(
          '`Oito2CopyField` shows a read-only value, such as a link, with a '
          'copy button at its end.',
        ),
        const ExamplePanel(
          region: 'field',
          child: SizedBox(
            width: 360,
            // #region field
            child: Oito2CopyField(
              labelText: 'Share link',
              value: 'https://oito2.github.io/oito2_ui/',
            ),
            // #endregion
          ),
        ),
        const DocHeading('Secret values', level: 3),
        const DocText(
          'With `obscure`, the field shows dots instead of the value, which '
          'the button still copies.',
        ),
        const ExamplePanel(
          region: 'obscure',
          child: SizedBox(
            width: 360,
            // #region obscure
            child: Oito2CopyField(
              labelText: 'API token',
              value: 'not-a-real-token-123456',
              obscure: true,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The button is labeled by its tooltip, "Copy" by default. The '
          'result of a copy is announced as a live region, so screen '
          'readers report "Copied" or "Couldn\'t copy" without moving the '
          'focus.',
        ),
        ...apiReferenceWidgets(['Oito2CopyButton', 'Oito2CopyField']),
      ],
    );
  }
}
