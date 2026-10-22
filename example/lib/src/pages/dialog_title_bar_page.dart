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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2DialogTitleBar] on a dialog.
class DialogTitleBarPage extends StatelessWidget {
  /// Creates the dialog title bar page.
  const DialogTitleBarPage({super.key});

  void _openDialog(BuildContext context, {Widget? leading, String? title}) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Oito2DialogTitleBar(
                leading: leading,
                title: Text(title ?? 'Preferences'),
              ),
              Padding(
                padding: const EdgeInsets.all(Oito2Spacing.xl),
                child: Text(
                  'The close button follows the system button style and '
                  'side, and pops the dialog.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Dialog title bar',
          children: [
            OutlinedButton(
              onPressed: () => _openDialog(context),
              child: const Text('Open dialog'),
            ),
            OutlinedButton(
              onPressed: () => _openDialog(
                context,
                leading: const Icon(LucideIcons.settings),
                title: 'Settings',
              ),
              child: const Text('With an icon'),
            ),
            OutlinedButton(
              onPressed: () => _openDialog(
                context,
                leading: const Oito2AnimatedIcon(Oito2AnimatedIcons.ok),
                title: 'Saved',
              ),
              child: const Text('With an animated icon'),
            ),
          ],
        ),
      ],
    );
  }
}
