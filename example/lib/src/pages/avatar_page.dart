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

import '../docs/doc_widgets.dart';

// #region people
const _people = [
  'Ana Souza',
  'Bruno Lima',
  'Carla Dias',
  'Diego Rocha',
  'Elisa Prado',
  'Fábio Nunes',
];
// #endregion

/// Documents [Oito2Avatar] sizes, shapes, statuses and fallbacks, and
/// [Oito2AvatarGroup].
class AvatarPage extends StatelessWidget {
  /// Creates the avatar page.
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Avatar',
      description:
          'A picture of a person or thing, falling back to initials or an '
          'icon, with an optional presence status.',
      source: 'lib/src/pages/avatar_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2Avatar(
            name: 'Ana Souza',
            status: Oito2AvatarStatus.online,
            size: 56,
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Avatar` shows `image` once it loads. Until then, and if it '
          'fails, it shows the initials of `name`, the first letters of its '
          'first and last words, on a color picked from the name, so the '
          'same name always gets the same color. Without a name it shows '
          '`icon` on a neutral surface. `size` sets the width and height, '
          '40 pixels by default.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Statuses and sizes', level: 3),
        const DocText(
          'A `status` adds a presence dot at the bottom end: `online`, '
          '`away`, `busy` or `offline`. The dot grows with the avatar.',
        ),
        ExamplePanel(
          regions: const ['people', 'statuses'],
          child: Wrap(
            spacing: Oito2Spacing.md,
            runSpacing: Oito2Spacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // #region statuses
              for (final (i, status) in Oito2AvatarStatus.values.indexed)
                Oito2Avatar(
                  name: _people[i],
                  status: status,
                  size: 32.0 + i * 8,
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Shape and fallbacks', level: 3),
        const DocText(
          '`shape: Oito2AvatarShape.square` rounds the corners instead of '
          'making a circle. Without a name the avatar shows its `icon`, and '
          'an image that fails to load falls back to the initials.',
        ),
        ExamplePanel(
          region: 'fallbacks',
          child: Wrap(
            spacing: Oito2Spacing.md,
            runSpacing: Oito2Spacing.md,
            children: [
              // #region fallbacks
              const Oito2Avatar(
                name: 'Grupo oito2',
                shape: Oito2AvatarShape.square,
              ),
              const Oito2Avatar(),
              Oito2Avatar(
                name: 'Helena Costa',
                image: MemoryImage(Uint8List(0)),
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Group', level: 3),
        const DocText(
          '`Oito2AvatarGroup` overlaps its `avatars` in a row, each with a '
          'ring in the background color, and shows at most `max`, four by '
          'default, followed by a "+N" bubble for the rest. Give it the '
          '`size` and `shape` of the avatars.',
        ),
        ExamplePanel(
          regions: const ['people', 'group'],
          // #region group
          child: Oito2AvatarGroup(
            semanticLabel: 'Project members',
            avatars: [
              for (final name in _people) Oito2Avatar(name: name, size: 32),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read an avatar as an image labeled with '
          'its `name` and the localized status, such as "Ana Souza, '
          'Online". The "+N" bubble of a group reads as "N more", and '
          '`semanticLabel` names the whole group.',
        ),
        ...apiReferenceWidgets([
          'Oito2Avatar',
          'Oito2AvatarGroup',
          'Oito2AvatarStatus',
          'Oito2AvatarShape',
          'oito2Initials',
        ]),
      ],
    );
  }
}
