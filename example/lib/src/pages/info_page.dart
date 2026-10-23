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

/// Documents [Oito2InfoBox] and [Oito2InfoBadge] in every [Oito2InfoType].
class InfoPage extends StatelessWidget {
  /// Creates the info page.
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Info',
      description:
          'Message boxes and small status badges tinted by their kind: '
          'information, success, warning, danger or important.',
      source: 'lib/src/pages/info_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 380,
            // #region preview
            child: Oito2InfoBox(
              type: Oito2InfoType.warning,
              title: Text('Low disk space'),
              subtitle: Text('Free up space to keep receiving updates.'),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2InfoBox` takes a `type` and any of a `title`, a `subtitle`, '
          'extra content as `child` and a `trailing` widget. The type picks '
          'the icon and the tint; the title takes the type color, adjusted '
          'to stay readable on the tinted background.',
        ),
        const DocText(
          '`Oito2InfoBadge` is a pill-shaped `label` tinted by its `type`, '
          'for statuses and counters.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Types', level: 3),
        const DocText(
          'Each `Oito2InfoType` has its own icon and color: `information`, '
          '`success`, `warning`, `danger`, and `important` in the accent '
          'color.',
        ),
        ExamplePanel(
          region: 'types',
          child: SizedBox(
            width: 380,
            child: Column(
              spacing: Oito2Spacing.sm,
              children: [
                // #region types
                for (final type in Oito2InfoType.values)
                  Oito2InfoBox(
                    type: type,
                    title: Text(
                      '${type.name[0].toUpperCase()}${type.name.substring(1)}',
                    ),
                    subtitle: const Text(
                      'A short message explaining the state.',
                    ),
                  ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Actions and custom icon', level: 3),
        const DocText(
          '`child` adds content under the subtitle, such as buttons, and '
          '`trailing` puts a widget at the end, such as a close button. '
          '`icon` replaces the type icon.',
        ),
        ExamplePanel(
          region: 'actions',
          child: SizedBox(
            width: 380,
            // #region actions
            child: Oito2InfoBox(
              type: Oito2InfoType.information,
              icon: const Icon(LucideIcons.refresh_cw),
              title: const Text('Update available'),
              subtitle: const Text('Version 2.0 is ready to install.'),
              trailing: IconButton(
                tooltip: 'Dismiss',
                icon: const Icon(LucideIcons.x),
                onPressed: () {},
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Restart now'),
                ),
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Badges', level: 3),
        const DocText('`Oito2InfoBadge` takes the same types.'),
        ExamplePanel(
          region: 'badges',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            children: [
              // #region badges
              for (final type in Oito2InfoType.values)
                Oito2InfoBadge(type: type, label: Text(type.name)),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The kind of an info box is not shown by color alone: its icon '
          'carries the localized name of the type, such as "Warning", for '
          'assistive technologies. A custom `icon` carries no such label, '
          'so say the kind in the title when you replace it.',
        ),
        const DocText(
          'Boxes of the `warning` and `danger` types are live regions, so '
          'screen readers announce them when they appear or change. The '
          'badge has no label of its own: its text is what is read.',
        ),
        ...apiReferenceWidgets([
          'Oito2InfoBox',
          'Oito2InfoBadge',
          'Oito2InfoType',
        ]),
      ],
    );
  }
}
