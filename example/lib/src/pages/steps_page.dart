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

/// Documents [Oito2Steps]: linear steps with buttons, vertical and free
/// steps with an error, and display-only steps.
class StepsPage extends StatefulWidget {
  /// Creates the steps page.
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  int _current = 1;
  int _free = 0;

  // #region steps
  static const _steps = [
    Oito2Step(
      title: 'Account',
      description: 'E-mail and password',
      content: Text('Create the account.'),
    ),
    Oito2Step(
      title: 'Profile',
      description: 'Name and photo',
      content: Text('Tell us about yourself.'),
    ),
    Oito2Step(title: 'Review', content: Text('Check everything.')),
  ];
  // #endregion

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Steps',
      description:
          'Shows the progress through a sequence of steps, such as a sign-up '
          'form, with the content of the current step.',
      source: 'lib/src/pages/steps_page.dart',
      children: [
        ExamplePanel(
          regions: const ['steps', 'preview'],
          child: SizedBox(
            width: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Oito2Spacing.md,
              children: [
                // #region preview
                Oito2Steps(
                  steps: _steps,
                  current: _current,
                  onStepTapped: (index) => setState(() => _current = index),
                ),
                Row(
                  spacing: Oito2Spacing.sm,
                  children: [
                    OutlinedButton(
                      onPressed: _current > 0
                          ? () => setState(() => _current--)
                          : null,
                      child: const Text('Back'),
                    ),
                    FilledButton(
                      onPressed: _current < _steps.length
                          ? () => setState(() => _current++)
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'List the steps as `Oito2Step`s, each with a `title` and an '
          'optional `description` and `content`. `Oito2Steps` is '
          'controlled: pass the `current` index, and change it from your '
          'own buttons or in `onStepTapped`. The steps before `current` show '
          'as completed with a check mark; set `current` to the number of '
          'steps when all are done.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'In the default `linear` mode only the completed steps and the '
          'current one can be tapped, so the user can go back but not skip '
          'ahead. In a row, long titles and descriptions wrap to two lines '
          'and end with an ellipsis.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Vertical and free, with an error', level: 3),
        const DocText(
          'With `axis: Axis.vertical` the steps run in a column and the '
          'content shows under the current step. With `linear: false` any '
          'step can be tapped. `hasError` marks a step with a cross and the '
          'error color.',
        ),
        ExamplePanel(
          region: 'vertical',
          child: SizedBox(
            width: 360,
            // #region vertical
            child: Oito2Steps(
              axis: Axis.vertical,
              linear: false,
              current: _free,
              onStepTapped: (index) => setState(() => _free = index),
              steps: [
                ..._steps.take(2),
                const Oito2Step(
                  title: 'Payment',
                  description: 'Card declined',
                  hasError: true,
                  content: Text('Try another card.'),
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Display only', level: 3),
        const DocText(
          'Without `onStepTapped`, the steps only show the progress and '
          'cannot be tapped.',
        ),
        const ExamplePanel(
          region: 'display',
          child: SizedBox(
            width: 560,
            // #region display
            child: Oito2Steps(steps: _steps, current: 2),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each step reads as its title, its position and its state, such '
          'as "Profile, Step 2 of 3, Current", with the description as a '
          'hint. The current step is reported as selected, and the steps '
          'that can be reached are buttons that show the focus ring when '
          'reached with the keyboard.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next step that can be reached.'],
            ['`Enter` / `Space`', 'Moves to the focused step.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Steps', 'Oito2Step']),
      ],
    );
  }
}
