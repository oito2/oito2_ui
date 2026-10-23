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

/// Documents [Oito2PinEntry]: a one-time code checked on completion, a
/// masked PIN and letters.
class PinEntryPage extends StatefulWidget {
  /// Creates the PIN entry page.
  const PinEntryPage({super.key});

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  String _status = 'Type or paste 6 digits';
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'PIN Entry',
      description:
          'Enters a short code, such as a PIN or a one-time code, in one '
          'cell per character.',
      source: 'lib/src/pages/pin_entry_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2PinEntry(),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`length` sets the number of cells, 6 by default. One text field '
          'sits under the cells, so typing, deleting, pasting a whole code '
          'and one-time code autofill work as in any field; a pasted code '
          'fills the cells in order. `onChanged` reports every change, and '
          'when the last cell is filled the entry calls `onCompleted` and '
          'gives up the focus.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Checking a code', level: 3),
        const DocText(
          'Check the code in `onCompleted` and set `hasError` to draw the '
          'cells with the error border. Here 123456 is the right code; '
          'editing the code clears the error.',
        ),
        ExamplePanel(
          region: 'verify',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.md,
            children: [
              // #region verify
              Oito2PinEntry(
                hasError: _error,
                onChanged: (_) => setState(() => _error = false),
                onCompleted: (code) => setState(() {
                  _error = code != '123456';
                  _status = _error ? 'Wrong code' : 'Verified';
                }),
              ),
              Text(_status),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Masked PIN', level: 3),
        const DocText('With `obscure`, each character shows as a dot.'),
        const ExamplePanel(
          region: 'masked',
          // #region masked
          child: Oito2PinEntry(length: 4, obscure: true),
          // #endregion
        ),
        const DocHeading('Letters and digits', level: 3),
        const DocText(
          'By default only digits are accepted and the numeric keyboard '
          'opens. With `numeric` set to false any character but white '
          'space is accepted.',
        ),
        const ExamplePanel(
          region: 'letters',
          // #region letters
          child: Oito2PinEntry(length: 5, numeric: false),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'With `enabled` set to false the entry ignores input and its '
          'cells fade.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2PinEntry(length: 4, enabled: false),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies see a single text field instead of the '
          'cells. Its label is `semanticLabel`, by default "Code of <length> '
          'characters". The field asks for one-time code autofill.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['A character', 'Fills the next empty cell.'],
            ['`Backspace`', 'Clears the last filled cell.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2PinEntry']),
      ],
    );
  }
}
