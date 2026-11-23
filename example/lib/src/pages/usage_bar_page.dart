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

/// Documents [Oito2UsageBar]: storage of several accounts, thresholds,
/// over quota, fractions and the compact variant in a rail-like column.
class UsageBarPage extends StatelessWidget {
  /// Creates the usage bar page.
  const UsageBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Usage Bar',
      description:
          'A bar that shows how much of a quota is used, such as the storage '
          'of an account, turning to the warning and danger tones as it '
          'fills.',
      source: 'lib/src/pages/usage_bar_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 360,
            // #region preview
            child: Oito2UsageBar.bytes(
              title: Text('Personal'),
              used: 4200000000,
              total: 15000000000,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2UsageBar` fills by `value` over `total`. With the default '
          'total of 1, `value` is a fraction and the label a percentage; '
          'with another total, the label reads "X of Y" with the amounts '
          'formatted by `formatValue`, or as numbers of the locale. '
          '`Oito2UsageBar.bytes` takes byte counts and formats them with '
          '`Oito2Format.bytes`, such as "4.2 GB of 15 GB" or "4,2 GB de '
          '15 GB". `label` replaces the text entirely.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Accounts and thresholds', level: 3),
        const DocText(
          'From `warningAt` (70% by default) the bar and its label turn to '
          'the warning tone, and from `dangerAt` (90%) to the danger tone. '
          'Over quota, the bar stays full in the danger tone and the label '
          'shows the real amount.',
        ),
        const ExamplePanel(
          region: 'accounts',
          child: SizedBox(
            width: 360,
            child: Column(
              spacing: Oito2Spacing.md,
              children: [
                // #region accounts
                Oito2UsageBar.bytes(
                  title: Text('Personal'),
                  used: 4200000000,
                  total: 15000000000,
                ),
                Oito2UsageBar.bytes(
                  title: Text('Work'),
                  used: 11500000000,
                  total: 15000000000,
                ),
                Oito2UsageBar.bytes(
                  title: Text('Shared'),
                  used: 14200000000,
                  total: 15000000000,
                ),
                Oito2UsageBar.bytes(
                  title: Text('Archive'),
                  used: 16800000000,
                  total: 15000000000,
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Fractions and custom labels', level: 3),
        const ExamplePanel(
          region: 'fractions',
          child: SizedBox(
            width: 360,
            child: Column(
              spacing: Oito2Spacing.md,
              children: [
                // #region fractions
                Oito2UsageBar(title: Text('Upload quota'), value: 0.42),
                Oito2UsageBar(
                  title: Text('Seats'),
                  value: 8,
                  total: 10,
                  warningAt: 0.8,
                  dangerAt: 1,
                ),
                Oito2UsageBar(
                  title: Text('Files'),
                  value: 1200,
                  total: 5000,
                  label: Text('3,800 left'),
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Compact', level: 3),
        const DocText(
          'With `compact`, a thin bar sits over one line of small text, '
          'for the bottom of a navigation rail or a side pane.',
        ),
        ExamplePanel(
          region: 'compact',
          child: SizedBox(
            width: 200,
            height: 260,
            child: Oito2BorderContainer(
              borderRadius: Oito2Radius.mediumAll,
              child: Padding(
                padding: const EdgeInsets.all(Oito2Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (icon, label) in const [
                      (LucideIcons.house, 'Home'),
                      (LucideIcons.folder, 'Files'),
                      (LucideIcons.share_2, 'Shared'),
                    ])
                      ListTile(
                        dense: true,
                        leading: Icon(icon, size: 18),
                        title: Text(label),
                        onTap: () {},
                      ),
                    const Spacer(),
                    // #region compact
                    const Oito2UsageBar.bytes(
                      title: Text('Drive'),
                      used: 3100000000,
                      total: 15000000000,
                      compact: true,
                    ),
                    // #endregion
                  ],
                ),
              ),
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The bar is one node that reads the title and the label, with '
          'the used percentage as its value, such as "Personal, 4.2 GB of '
          '15 GB, 28%". `semanticsLabel` replaces the title and label. The '
          'tones are never the only cue: the label tells the amount.',
        ),
        ...apiReferenceWidgets(['Oito2UsageBar']),
      ],
    );
  }
}
