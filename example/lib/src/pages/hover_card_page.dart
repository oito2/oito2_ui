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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2HoverCard] previewing a profile and a link.
class HoverCardPage extends StatelessWidget {
  /// Creates the hover card page.
  const HoverCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Hover or focus the names',
          children: [
            for (final (name, role) in [
              ('Ana Souza', 'Maintainer'),
              ('Bruno Lima', 'Designer'),
            ])
              Oito2HoverCard(
                cardBuilder: (context) => Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Oito2Spacing.md,
                  children: [
                    const Oito2PlaceholderIcon(
                      size: 48,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.titleMedium),
                        Text(role),
                      ],
                    ),
                  ],
                ),
                child: TextButton(onPressed: () {}, child: Text(name)),
              ),
          ],
        ),
        ShowcaseSection(
          'Above, without an arrow',
          children: [
            Oito2HoverCard(
              placement: Oito2PopoverPlacement.top,
              showArrow: false,
              cardBuilder: (context) => const Text('github.com/oito2/oito2_ui'),
              child: TextButton(
                onPressed: () {},
                child: const Text('Repository'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
