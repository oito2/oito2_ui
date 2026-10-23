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

/// Documents [Oito2EditableLabel]: renaming items in place, a heading and
/// a read-only label.
class EditableLabelPage extends StatefulWidget {
  /// Creates the editable label page.
  const EditableLabelPage({super.key});

  @override
  State<EditableLabelPage> createState() => _EditableLabelPageState();
}

class _EditableLabelPageState extends State<EditableLabelPage> {
  String _name = 'Holiday photos';
  final _names = ['Budget 2026', 'Reading list', ''];
  String _title = 'Quarterly report';

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Editable Label',
      description:
          'A text label that turns into a field to rename something in '
          'place.',
      source: 'lib/src/pages/editable_label_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2EditableLabel(
            text: _name,
            onSubmitted: (text) => setState(() => _name = text),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give the label its `text` and replace it in `onSubmitted`. A '
          'double click, or Enter or F2 on the focused label, starts '
          'editing with the whole text selected. Enter or leaving the '
          'field keeps the change, and Escape restores the text. '
          '`onSubmitted` is called with the trimmed text only when it '
          'changed and isn\'t empty.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Placeholder', level: 3),
        const DocText(
          'While `text` is empty the label shows the `placeholder` in a '
          'muted color. Here the last item has no name yet.',
        ),
        ExamplePanel(
          region: 'placeholder',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // #region placeholder
              for (var i = 0; i < _names.length; i++)
                Oito2EditableLabel(
                  text: _names[i],
                  placeholder: 'Untitled',
                  onSubmitted: (text) => setState(() => _names[i] = text),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('As a heading', level: 3),
        const DocText(
          '`style` is merged over `bodyLarge` and applies to both the '
          'label and the field, so a heading keeps its size while edited.',
        ),
        ExamplePanel(
          region: 'heading',
          // #region heading
          child: Oito2EditableLabel(
            text: _title,
            style: Theme.of(context).textTheme.headlineSmall,
            onSubmitted: (text) => setState(() => _title = text),
          ),
          // #endregion
        ),
        const DocHeading('Read-only', level: 3),
        const DocText(
          'A null `onSubmitted` makes the label read-only: it can\'t be '
          'edited or focused.',
        ),
        const ExamplePanel(
          region: 'read-only',
          // #region read-only
          child: Oito2EditableLabel(text: 'Shared folder', onSubmitted: null),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read the text, or the placeholder while '
          'it is empty, with the hint "Press Enter to edit", and can start '
          'editing with a tap action. The focused label shows a focus '
          'ring.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Enter` / `F2` on the label', 'Starts editing.'],
            ['`Enter` in the field', 'Keeps the change.'],
            ['`Escape` in the field', 'Restores the text.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2EditableLabel']),
      ],
    );
  }
}
