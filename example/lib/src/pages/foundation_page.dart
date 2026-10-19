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

/// Shows the platform and system settings the showcase runs with.
class FoundationPage extends StatelessWidget {
  /// Creates the foundation page.
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Oito2SystemScope.of(context);
    final platform = settings.platform;
    final layout = settings.windowButtonLayout;
    String names(List<Oito2WindowButton> buttons) =>
        buttons.isEmpty ? '—' : buttons.map((b) => b.name).join(', ');

    final rows = {
      'Target platform': platform.targetPlatform.name,
      'Web': '${platform.isWeb}',
      'Native desktop': '${platform.isDesktopNative}',
      'Native touch': '${platform.isTouch}',
      'Web on touch host': '${platform.isWebTouch}',
      'Visual density': platform.usesTouchInput ? 'standard' : 'comfortable',
      'Desktop environment': settings.desktopEnvironment?.name ?? '—',
      'Window control style': settings.windowControlStyle.name,
      'Leading window buttons': names(layout.leading),
      'Trailing window buttons': names(layout.trailing),
      'High contrast': '${settings.highContrast}',
    };

    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        Text(
          'System settings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: Oito2Spacing.sm),
        Text(
          'Values derived from the platform. The desktop environment and '
          'window button layout come from the system once '
          'oito2_ui_settings is connected.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Oito2Spacing.lg),
        Table(
          columnWidths: const {0: IntrinsicColumnWidth()},
          children: [
            for (final MapEntry(:key, :value) in rows.entries)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: Oito2Spacing.xl,
                      bottom: Oito2Spacing.sm,
                    ),
                    child: Text(
                      key,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  SelectableText(value),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
