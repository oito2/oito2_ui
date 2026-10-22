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

/// The Home section of the Material theme page: a sample app screen made
/// of Material widgets, to judge the theme as a whole.
class ThemeHomeView extends StatelessWidget {
  /// Creates the home section.
  const ThemeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Widget stat(IconData icon, String value, String label) => Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Oito2Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Oito2Spacing.xs,
            children: [
              Icon(icon, color: scheme.primary),
              Text(value, style: textTheme.headlineSmall),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        Text('Good morning, Ana', style: textTheme.headlineMedium),
        const SizedBox(height: Oito2Spacing.xs),
        Text(
          'Three tasks are due this week.',
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Oito2Spacing.lg),
        Row(
          spacing: Oito2Spacing.sm,
          children: [
            stat(LucideIcons.circle_check, '12', 'Done'),
            stat(LucideIcons.clock, '3', 'Due soon'),
            stat(LucideIcons.users, '5', 'Team'),
          ],
        ),
        const SizedBox(height: Oito2Spacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Oito2Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Oito2Spacing.sm,
              children: [
                Text('Release 0.1.0', style: textTheme.titleMedium),
                const LinearProgressIndicator(value: 0.72),
                Text(
                  '72% of the checklist is done',
                  style: textTheme.bodySmall,
                ),
                const Wrap(
                  spacing: Oito2Spacing.sm,
                  runSpacing: Oito2Spacing.sm,
                  children: [
                    Chip(label: Text('Docs')),
                    Chip(label: Text('Goldens')),
                    Chip(label: Text('Publishing')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Oito2Spacing.lg),
        Text('Recent', style: textTheme.titleMedium),
        Card(
          child: Column(
            children: [
              for (final (icon, title, subtitle, badge) in const [
                (LucideIcons.file_text, 'Design review', 'Edited 5 min ago', 2),
                (LucideIcons.image, 'Showcase screenshots', 'Yesterday', 0),
                (LucideIcons.git_branch, 'Release 0.2', 'Merged', 0),
              ])
                ListTile(
                  leading: Icon(icon),
                  title: Text(title),
                  subtitle: Text(subtitle),
                  trailing: badge > 0
                      ? Badge(label: Text('$badge'))
                      : const Icon(LucideIcons.chevron_right),
                  onTap: () {},
                ),
            ],
          ),
        ),
      ],
    );
  }
}
