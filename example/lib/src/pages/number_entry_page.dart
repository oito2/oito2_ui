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

/// Shows [Oito2NumberEntry] with whole and decimal steps.
class NumberEntryPage extends StatefulWidget {
  /// Creates the number entry page.
  const NumberEntryPage({super.key});

  @override
  State<NumberEntryPage> createState() => _NumberEntryPageState();
}

class _NumberEntryPageState extends State<NumberEntryPage> {
  double _copies = 1;
  double _scale = 1.5;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Whole numbers from 1 to 99: arrows, Page Up/Down, wheel or drag '
          'the buttons sideways',
          children: [
            SizedBox(
              width: 200,
              child: Oito2NumberEntry(
                value: _copies,
                min: 1,
                max: 99,
                labelText: 'Copies',
                onChanged: (v) => setState(() => _copies = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Two decimals, step 0.25',
          children: [
            SizedBox(
              width: 200,
              child: Oito2NumberEntry(
                value: _scale,
                min: 0.25,
                max: 4,
                step: 0.25,
                decimals: 2,
                labelText: 'Scale',
                onChanged: (v) => setState(() => _scale = v),
              ),
            ),
            const SizedBox(
              width: 200,
              child: Oito2NumberEntry(
                value: 42,
                onChanged: null,
                labelText: 'Read-only',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
