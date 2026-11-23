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

/// Documents [Oito2PasswordField]: signing in, a new password with the
/// strength meter, an error and the Caps Lock warning.
class PasswordFieldPage extends StatelessWidget {
  /// Creates the password field page.
  const PasswordFieldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Password Field',
      description:
          'A text field for a password, with a button that shows or hides '
          'it and a warning while Caps Lock is on.',
      source: 'lib/src/pages/password_field_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 300,
            // #region preview
            child: Oito2PasswordField(labelText: 'Password'),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'The field hides its text until the eye button is pressed. Read '
          'the text through `onChanged`, `onSubmitted` or your own '
          '`controller`. Suggestions and autocorrect are off, and '
          '`autofillHints` lets password managers fill it; the default is '
          '`AutofillHints.password`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('New password', level: 3),
        const DocText(
          'For a field that sets a new password, pass '
          '`AutofillHints.newPassword` so password managers can offer to '
          'generate and save one.',
        ),
        const ExamplePanel(
          region: 'new-password',
          child: SizedBox(
            width: 300,
            // #region new-password
            child: Oito2PasswordField(
              labelText: 'New password',
              autofillHints: [AutofillHints.newPassword],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Strength meter', level: 3),
        const DocText(
          'With `showStrength`, a meter below the field rates the password '
          'while it isn\'t empty: four segments from the danger to the '
          'success tone, the level ("Very weak" to "Strong") and the first '
          'suggestion, such as "Avoid sequences". '
          '`Oito2PasswordStrength.estimate` rates it on the device, never '
          'sending it anywhere: it weighs length and kinds of characters '
          'against common passwords, dates, runs such as "abcd" or '
          '"qwerty", repeats and the words of `strengthUserInputs`, such as '
          'the user\'s name and email.',
        ),
        const ExamplePanel(
          region: 'strength',
          child: SizedBox(
            width: 300,
            // #region strength
            child: Oito2PasswordField(
              labelText: 'New password',
              autofillHints: [AutofillHints.newPassword],
              showStrength: true,
              strengthUserInputs: ['Ana Souza', 'ana@example.com'],
            ),
            // #endregion
          ),
        ),
        const DocText(
          '`strengthEstimator` plugs in another estimator, such as a port of '
          'zxcvbn or the server\'s policy, that returns an '
          '`Oito2PasswordStrength`: a level from 0 to 4 and a list of '
          '`Oito2PasswordHint`s.',
        ),
        ExamplePanel(
          region: 'estimator',
          child: SizedBox(
            width: 300,
            // #region estimator
            child: Oito2PasswordField(
              labelText: 'PIN-like password',
              showStrength: true,
              strengthEstimator: (password) => Oito2PasswordStrength(
                (password.length ~/ 4).clamp(0, 4),
                hints: [if (password.length < 16) Oito2PasswordHint.addLength],
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Caps Lock warning', level: 3),
        const DocText(
          'While the field has the focus and Caps Lock is on, a warning '
          'shows below it; with an `errorText`, the warning shows under '
          'the error. Turn on Caps Lock while typing in any field on this '
          'page to see it. Set `showCapsLockWarning` to false to hide it.',
        ),
        const ExamplePanel(
          region: 'error',
          child: SizedBox(
            width: 300,
            // #region error
            child: Oito2PasswordField(
              labelText: 'Password',
              errorText: 'Wrong password',
            ),
            // #endregion
          ),
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'With `enabled` set to false, the field and its eye button '
          'ignore input.',
        ),
        const ExamplePanel(
          region: 'disabled',
          child: SizedBox(
            width: 300,
            // #region disabled
            child: Oito2PasswordField(labelText: 'Password', enabled: false),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The eye button has the tooltip "Show password" or "Hide '
          'password", which also names it for assistive technologies. The '
          'Caps Lock warning is a live region, so screen readers announce '
          'it when it appears. The strength level is a live region too: it '
          'is announced, as "Password strength: Fair", when the level '
          'changes, not on every key.',
        ),
        ...apiReferenceWidgets([
          'Oito2PasswordField',
          'Oito2PasswordStrength',
          'Oito2PasswordHint',
        ]),
      ],
    );
  }
}
