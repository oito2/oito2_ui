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

/// Documents [Oito2StatusPill]: neutral and semantic colors, icons, the
/// busy variant and tooltips.
class StatusPillPage extends StatelessWidget {
  /// Creates the status pill page.
  const StatusPillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Status Pill',
      description:
          'A compact rounded label for the state of an item, with a dot or '
          'an icon in a semantic color, or a spinner while it is busy.',
      source: 'lib/src/pages/status_pill_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2StatusPill(label: 'Synced', type: Oito2InfoType.success),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2StatusPill` takes a `label` and an optional `type`: an '
          '`Oito2InfoType` for a semantic color, or none for a neutral '
          'pill in the surface tones. A dot shows before the label; `icon` '
          'replaces it.',
        ),
        const DocText(
          'Unlike `Oito2InfoBadge`, which is a plain tinted label for '
          'counters and tags, the pill tells the state of something, can '
          'show progress and has its own accessibility node.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Colors', level: 3),
        const ExamplePanel(
          region: 'colors',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            children: [
              // #region colors
              Oito2StatusPill(label: 'Draft'),
              Oito2StatusPill(label: 'Online', type: Oito2InfoType.success),
              Oito2StatusPill(label: 'Queued', type: Oito2InfoType.information),
              Oito2StatusPill(label: 'Expiring', type: Oito2InfoType.warning),
              Oito2StatusPill(label: 'Failed', type: Oito2InfoType.danger),
              Oito2StatusPill(label: 'Beta', type: Oito2InfoType.important),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Icons', level: 3),
        const ExamplePanel(
          region: 'icons',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            children: [
              // #region icons
              Oito2StatusPill(
                label: 'Offline',
                type: Oito2InfoType.danger,
                icon: Icon(LucideIcons.wifi_off),
              ),
              Oito2StatusPill(label: 'Locked', icon: Icon(LucideIcons.lock)),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Busy and tooltip', level: 3),
        const DocText(
          'With `busy`, a small spinner takes the place of the dot or icon; '
          'it stands still when the system asks to reduce motion. '
          '`tooltip` shows more detail on hover or long press.',
        ),
        const ExamplePanel(
          region: 'busy',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            children: [
              // #region busy
              Oito2StatusPill(
                label: 'Syncing',
                type: Oito2InfoType.information,
                busy: true,
                tooltip: '12 of 40 files',
              ),
              Oito2StatusPill(
                label: 'Last sync 10:42',
                tooltip: 'Every file is up to date',
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The pill is one node read as its `label`, or `semanticLabel` '
          'when the text needs more context, with "Loading" as its value '
          'while busy and the tooltip as its hint. The color is never the '
          'only cue: the label says the state.',
        ),
        ...apiReferenceWidgets(['Oito2StatusPill']),
      ],
    );
  }
}
