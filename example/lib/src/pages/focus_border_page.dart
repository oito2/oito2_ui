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

/// Shows [Oito2FocusBorder] around custom focusable content.
class FocusBorderPage extends StatelessWidget {
  /// Creates the focus border page.
  const FocusBorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Focus border',
          children: [
            for (final label in ['First', 'Second', 'Third'])
              Oito2FocusBorder(
                child: Focus(
                  child: Builder(
                    builder: (context) => GestureDetector(
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
            Text(
              'Press Tab to move the focus ring between the boxes.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
