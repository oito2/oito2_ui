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

/// Documents [Oito2Tour] over a small toolbar.
class TourPage extends StatefulWidget {
  /// Creates the tour page.
  const TourPage({super.key});

  @override
  State<TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  // #region steps
  final _search = GlobalKey();
  final _create = GlobalKey();
  final _settings = GlobalKey();
  late final _controller = Oito2TourController(
    steps: [
      const Oito2TourStep(
        title: 'Welcome',
        description: 'This short tour shows the toolbar.',
      ),
      Oito2TourStep(
        target: _search,
        title: 'Search',
        description: 'Find any file by name.',
      ),
      Oito2TourStep(
        target: _create,
        title: 'Create',
        description: 'Tap the button to go on.',
        waitForTap: true,
      ),
      Oito2TourStep(
        target: _settings,
        title: 'Settings',
        description: 'Change the theme and the language here.',
        placement: Oito2PopoverPlacement.start,
      ),
    ],
  );
  // #endregion
  String _result = 'Not started';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Tour',
      description:
          'A guided tour that highlights parts of the screen one step at a '
          'time, with a card explaining each.',
      source: 'lib/src/pages/tour_page.dart',
      children: [
        ExamplePanel(
          regions: const ['steps', 'preview'],
          // #region preview
          child: Oito2Tour(
            controller: _controller,
            onFinished: (completed) =>
                setState(() => _result = completed ? 'Completed' : 'Skipped'),
            child: Column(
              spacing: Oito2Spacing.md,
              children: [
                Wrap(
                  spacing: Oito2Spacing.sm,
                  runSpacing: Oito2Spacing.sm,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      key: _search,
                      width: 220,
                      child: const Oito2SearchField(hintText: 'Search files'),
                    ),
                    FilledButton.icon(
                      key: _create,
                      onPressed: () {},
                      icon: const Icon(LucideIcons.plus),
                      label: const Text('Create'),
                    ),
                    Oito2IconButton(
                      key: _settings,
                      tooltip: 'Settings',
                      onPressed: () {},
                      icon: const Icon(LucideIcons.settings),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: _controller.start,
                  child: const Text('Start the tour'),
                ),
                Text('Result: $_result'),
              ],
            ),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Describe the steps in an `Oito2TourController`, give each '
          'highlighted widget a `GlobalKey`, and wrap the content in an '
          '`Oito2Tour` with the controller. `start` runs the tour; '
          '`onFinished` reports `true` when it was completed and `false` when '
          'it was skipped. Dispose of the controller with the state that '
          'owns it.',
        ),
        const DocText(
          'Each step dims the window around its `target`, scrolls it into '
          'view and shows a card with the `title`, the `description`, its '
          'position and back, next and skip buttons. Taps outside the '
          'spotlight are blocked; taps inside reach the target.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Steps without a target', level: 3),
        const DocText(
          'A step with no `target`, such as the "Welcome" step above, shows '
          'its card in the center of the window; so does a step whose target '
          'is not built.',
        ),
        const DocHeading('Waiting for a tap', level: 3),
        const DocText(
          'With `waitForTap`, the step has no next button: the tap reaches '
          'the target, then the tour moves on, as in the "Create" step. '
          'While the target is not on screen, the next button shows instead.',
        ),
        const DocHeading('Placement', level: 3),
        const DocText(
          '`placement` picks the side of the target where the card opens, '
          'below by default, as for `Oito2Popover`. `spotlightPadding` sets '
          'the space around the target inside the spotlight, 6 pixels by '
          'default.',
        ),
        const DocHeading('Moving between steps', level: 3),
        const DocText(
          'The controller moves the tour from code: `start` and `goTo` take '
          'a step index, and `next`, `previous` and `skip` move from the '
          'current one. `index`, `step` and `isActive` describe where it is.',
        ),
        ExamplePanel(
          region: 'go-to',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              // #region go-to
              for (var i = 0; i < _controller.steps.length; i++)
                OutlinedButton(
                  onPressed: () => _controller.start(i),
                  child: Text('Start at ${_controller.steps[i].title}'),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The card takes the focus and is a live region, so assistive '
          'technologies announce each step; the content under the tour is '
          'hidden from them while it runs. The step title is marked as a '
          'header and the close button is labeled "Skip tour". When the tour '
          'ends, the focus returns to where it was before.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Right arrow`',
              'Moves to the next step (the previous one in right-to-left '
                  'layouts).',
            ],
            [
              '`Left arrow`',
              'Moves to the previous step (the next one in right-to-left '
                  'layouts).',
            ],
            ['`Escape`', 'Skips the tour.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2Tour',
          'Oito2TourController',
          'Oito2TourStep',
        ]),
      ],
    );
  }
}
