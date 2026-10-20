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

/// Shows [Oito2InfoBox] and [Oito2InfoBadge] in every [Oito2InfoType].
class InfoPage extends StatelessWidget {
  /// Creates the info page.
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Info boxes',
          children: [
            for (final type in Oito2InfoType.values)
              SizedBox(
                width: 340,
                child: Oito2InfoBox(
                  type: type,
                  title: Text(
                    '${type.name[0].toUpperCase()}${type.name.substring(1)}',
                  ),
                  subtitle: const Text('A short message explaining the state.'),
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'Info badges',
          children: [
            for (final type in Oito2InfoType.values)
              Oito2InfoBadge(type: type, label: Text(type.name)),
          ],
        ),
      ],
    );
  }
}
