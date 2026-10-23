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

import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../widgets/showcase_widgets.dart';

const _people = [
  'Ana Souza',
  'Bruno Lima',
  'Carla Dias',
  'Diego Rocha',
  'Elisa Prado',
  'Fábio Nunes',
];

/// Shows [Oito2Avatar] sizes, shapes, statuses and fallbacks, and
/// [Oito2AvatarGroup].
class AvatarPage extends StatelessWidget {
  /// Creates the avatar page.
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Initials, statuses and sizes',
          children: [
            for (final (i, status) in Oito2AvatarStatus.values.indexed)
              Oito2Avatar(name: _people[i], status: status, size: 32.0 + i * 8),
          ],
        ),
        ShowcaseSection(
          'Square, no name, and an image that fails falling back to initials',
          children: [
            const Oito2Avatar(
              name: 'Grupo oito2',
              shape: Oito2AvatarShape.square,
            ),
            const Oito2Avatar(),
            Oito2Avatar(name: 'Helena Costa', image: MemoryImage(Uint8List(0))),
          ],
        ),
        ShowcaseSection(
          'Group of six, four shown',
          children: [
            Oito2AvatarGroup(
              avatars: [
                for (final name in _people) Oito2Avatar(name: name, size: 32),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
