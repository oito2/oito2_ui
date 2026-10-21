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

/// Shows [Oito2CopyButton] and [Oito2CopyField].
class CopyButtonPage extends StatelessWidget {
  /// Creates the copy button page.
  const CopyButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final toaster = Oito2Toaster.maybeOf(context);
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Button',
          children: [
            const Text('flutter pub add oito2_ui'),
            Oito2CopyButton(
              text: 'flutter pub add oito2_ui',
              onCopied: () =>
                  toaster?.show(const Oito2Toast(title: 'Command copied')),
            ),
          ],
        ),
        const ShowcaseSection(
          'Fields',
          children: [
            SizedBox(
              width: 360,
              child: Oito2CopyField(
                labelText: 'Share link',
                value: 'https://oito2.github.io/oito2_ui/',
              ),
            ),
            SizedBox(
              width: 360,
              child: Oito2CopyField(
                labelText: 'API token',
                value: 'not-a-real-token-123456',
                obscure: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
