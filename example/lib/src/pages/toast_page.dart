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

/// Shows [Oito2Toast]s of each type, with an action and a promise.
class ToastPage extends StatelessWidget {
  /// Creates the toast page.
  const ToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    final toaster = Oito2Toaster.of(context);
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Types',
          children: [
            OutlinedButton(
              onPressed: () => toaster.show(const Oito2Toast(title: 'Plain')),
              child: const Text('Plain'),
            ),
            for (final type in Oito2InfoType.values)
              OutlinedButton(
                onPressed: () => toaster.show(
                  Oito2Toast(
                    title: type.name,
                    description: 'A ${type.name} message.',
                    type: type,
                  ),
                ),
                child: Text(type.name),
              ),
          ],
        ),
        ShowcaseSection(
          'Action, persistent and promise',
          children: [
            OutlinedButton(
              onPressed: () => toaster.show(
                Oito2Toast(
                  title: 'Message deleted',
                  actionLabel: 'Undo',
                  onAction: () =>
                      toaster.show(const Oito2Toast(title: 'Restored')),
                ),
              ),
              child: const Text('With an action'),
            ),
            OutlinedButton(
              onPressed: () => toaster.show(
                const Oito2Toast(
                  title: 'Stays until dismissed',
                  duration: null,
                ),
              ),
              child: const Text('Persistent'),
            ),
            OutlinedButton(
              onPressed: () => toaster.promise<int>(
                Future.delayed(const Duration(seconds: 2), () => 3),
                loading: const Oito2Toast(title: 'Uploading…', loading: true),
                success: (n) => Oito2Toast(
                  title: '$n files uploaded',
                  type: Oito2InfoType.success,
                ),
                error: (_) => const Oito2Toast(
                  title: 'Upload failed',
                  type: Oito2InfoType.danger,
                ),
              ),
              child: const Text('Promise'),
            ),
            TextButton(
              onPressed: toaster.dismissAll,
              child: const Text('Dismiss all'),
            ),
          ],
        ),
      ],
    );
  }
}
