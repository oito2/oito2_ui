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

/// Documents [Oito2Section]: a headline with actions above a bordered
/// container.
class SectionPage extends StatelessWidget {
  /// Creates the section page.
  const SectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Section',
      description:
          'Groups related content under a headline, with optional actions '
          'beside it, in a bordered container.',
      source: 'lib/src/pages/section_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2Section(
              headline: const Text('Storage'),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Clean up')),
              ],
              child: const Text(
                'A section groups related content under a headline, with '
                'optional actions beside it.',
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2Section` its content as `child`, an optional '
          '`headline`, usually a `Text`, and optional `actions`. The '
          'headline takes the medium title style and the actions sit at the '
          'end of its row. The content goes inside an `Oito2BorderContainer` '
          'with `padding` around it, 16 pixels by default.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Without a headline', level: 3),
        const DocText(
          'Without a `headline` and `actions` the headline row is left out, '
          'and only the bordered container shows.',
        ),
        const ExamplePanel(
          region: 'plain',
          child: SizedBox(
            width: 420,
            // #region plain
            child: Oito2Section(
              child: Text('Only the content, in its bordered container.'),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Padding and margin', level: 3),
        const DocText(
          '`padding` sets the space inside the container, and `margin` the '
          'space around the whole section, headline included.',
        ),
        ExamplePanel(
          region: 'padding',
          child: SizedBox(
            width: 420,
            // #region padding
            child: Oito2Section(
              headline: const Text('Account'),
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.all(Oito2Spacing.sm),
              child: Oito2ListTile.square(
                leading: const Icon(LucideIcons.user_round),
                titleText: 'Profile',
                onTap: () {},
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The headline is exposed as a header to assistive technologies, '
          'so screen reader users can jump between sections.',
        ),
        ...apiReferenceWidgets(['Oito2Section']),
      ],
    );
  }
}
