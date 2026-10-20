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

/// Shows [Oito2PasswordField] for signing in and for a new password.
class PasswordFieldPage extends StatelessWidget {
  /// Creates the password field page.
  const PasswordFieldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Turn on Caps Lock while typing to see the warning',
          children: [
            SizedBox(
              width: 280,
              child: Oito2PasswordField(labelText: 'Password'),
            ),
            SizedBox(
              width: 280,
              child: Oito2PasswordField(
                labelText: 'New password',
                autofillHints: [AutofillHints.newPassword],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
