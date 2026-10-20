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

/// Shows [Oito2EditableLabel] renaming items in place.
class EditableLabelPage extends StatefulWidget {
  /// Creates the editable label page.
  const EditableLabelPage({super.key});

  @override
  State<EditableLabelPage> createState() => _EditableLabelPageState();
}

class _EditableLabelPageState extends State<EditableLabelPage> {
  final _names = ['Holiday photos', 'Budget 2026', ''];

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Double-click, or focus and press Enter or F2',
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _names.length; i++)
                  Oito2EditableLabel(
                    text: _names[i],
                    placeholder: 'Untitled',
                    onSubmitted: (v) => setState(() => _names[i] = v),
                  ),
              ],
            ),
          ],
        ),
        ShowcaseSection(
          'As a heading',
          children: [
            Oito2EditableLabel(
              text: 'Quarterly report',
              style: Theme.of(context).textTheme.headlineSmall,
              onSubmitted: (_) {},
            ),
          ],
        ),
      ],
    );
  }
}
