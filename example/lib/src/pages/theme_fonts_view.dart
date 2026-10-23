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

/// The Fonts section of the Material theme page: every style of the
/// oito2 text theme.
class ThemeFontsView extends StatelessWidget {
  /// Creates the fonts section.
  const ThemeFontsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final styles = {
      'displayLarge': theme.displayLarge,
      'displayMedium': theme.displayMedium,
      'displaySmall': theme.displaySmall,
      'headlineLarge': theme.headlineLarge,
      'headlineMedium': theme.headlineMedium,
      'headlineSmall': theme.headlineSmall,
      'titleLarge': theme.titleLarge,
      'titleMedium': theme.titleMedium,
      'titleSmall': theme.titleSmall,
      'bodyLarge': theme.bodyLarge,
      'bodyMedium': theme.bodyMedium,
      'bodySmall': theme.bodySmall,
      'labelLarge': theme.labelLarge,
      'labelMedium': theme.labelMedium,
      'labelSmall': theme.labelSmall,
    };

    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        for (final MapEntry(key: name, value: style) in styles.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: Oito2Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name · ${style!.fontSize!.toStringAsFixed(0)} · '
                  'w${style.fontWeight?.value ?? 400}',
                  style: theme.labelSmall?.copyWith(
                    color: Oito2NeutralPalette.of(Theme.of(context).brightness)
                        .onSurfaceVariant,
                  ),
                ),
                Text(
                  'The quick brown fox jumps over the lazy dog',
                  style: style,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
