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

/// Shows [Oito2Steps] horizontal and vertical, linear and free.
class StepsPage extends StatefulWidget {
  /// Creates the steps page.
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  int _current = 1;
  int _free = 0;

  List<Oito2Step> get _steps => [
    const Oito2Step(
      title: 'Account',
      description: 'E-mail and password',
      content: Text('Create the account.'),
    ),
    const Oito2Step(
      title: 'Profile',
      description: 'Name and photo',
      content: Text('Tell us about yourself.'),
    ),
    const Oito2Step(title: 'Review', content: Text('Check everything.')),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Linear: only done steps can be revisited',
          children: [
            SizedBox(
              width: 560,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Oito2Spacing.md,
                children: [
                  Oito2Steps(
                    steps: _steps,
                    current: _current,
                    onStepTapped: (i) => setState(() => _current = i),
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
                ],
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Vertical and free, with an error',
          children: [
            SizedBox(
              width: 360,
              child: Oito2Steps(
                axis: Axis.vertical,
                linear: false,
                current: _free,
                onStepTapped: (i) => setState(() => _free = i),
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
            ),
          ],
        ),
      ],
    );
  }
}
