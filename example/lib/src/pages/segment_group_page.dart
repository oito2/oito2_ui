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

/// Documents [Oito2SegmentGroup]: across, down, with icons and with a
/// disabled segment.
class SegmentGroupPage extends StatefulWidget {
  /// Creates the segment group page.
  const SegmentGroupPage({super.key});

  @override
  State<SegmentGroupPage> createState() => _SegmentGroupPageState();
}

class _SegmentGroupPageState extends State<SegmentGroupPage> {
  String _framework = 'react';
  String _view = 'grid';
  String _period = 'week';
  String _plan = 'pro';

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Segment Group',
      description:
          'Picks one of a few options on a recessed track, with a raised '
          'marker that slides to the selected one.',
      source: 'lib/src/pages/segment_group_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2SegmentGroup<String>(
            selected: _framework,
            onChanged: (value) => setState(() => _framework = value),
            segments: const [
              Oito2Segment(value: 'react', label: Text('React')),
              Oito2Segment(value: 'solid', label: Text('Solid')),
              Oito2Segment(value: 'svelte', label: Text('Svelte')),
              Oito2Segment(value: 'vue', label: Text('Vue')),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'List the choices as `Oito2Segment`s, each with a `value` and a '
          '`label`. The group is controlled: pass the `selected` value and '
          'update it in `onChanged`. A null `onChanged` disables the group.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'Use a segment group for two to five short, mutually exclusive '
          'options that change a view, such as a period or a layout. For '
          'tabs with their own content, use `Oito2TabBar`; for options that '
          'turn on and off, `Oito2ToggleGroup`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('With icons', level: 3),
        const DocText('A segment takes an `icon` before its label.'),
        ExamplePanel(
          region: 'icons',
          // #region icons
          child: Oito2SegmentGroup<String>(
            selected: _view,
            onChanged: (value) => setState(() => _view = value),
            segments: const [
              Oito2Segment(
                value: 'grid',
                icon: Icon(LucideIcons.layout_grid),
                label: Text('Grid'),
              ),
              Oito2Segment(
                value: 'list',
                icon: Icon(LucideIcons.list),
                label: Text('List'),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Vertical', level: 3),
        const DocText(
          'With `orientation: Axis.vertical` the segments stack, as wide as '
          'the widest one, with their labels at the start.',
        ),
        ExamplePanel(
          region: 'vertical',
          // #region vertical
          child: Oito2SegmentGroup<String>(
            orientation: Axis.vertical,
            selected: _period,
            onChanged: (value) => setState(() => _period = value),
            segments: const [
              Oito2Segment(value: 'day', label: Text('Today')),
              Oito2Segment(value: 'week', label: Text('This week')),
              Oito2Segment(value: 'month', label: Text('This month')),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Disabled segment', level: 3),
        const DocText(
          'A segment with `enabled: false` stays visible but can\'t be '
          'picked, and the arrow keys skip it.',
        ),
        ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2SegmentGroup<String>(
            selected: _plan,
            onChanged: (value) => setState(() => _plan = value),
            segments: const [
              Oito2Segment(value: 'free', label: Text('Free')),
              Oito2Segment(value: 'pro', label: Text('Pro')),
              Oito2Segment(value: 'team', label: Text('Team'), enabled: false),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read the segments as a group of '
          'mutually exclusive choices, each checked or not. The group is a '
          'single stop in keyboard navigation: the focus lands on the '
          'selected segment, or the first enabled one.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus into the group, and out of it.'],
            [
              '`Right arrow` / `Left arrow`',
              'Selects the next or previous enabled segment, wrapping '
                  'around; reversed in right-to-left layouts.',
            ],
            ['`Down arrow` / `Up arrow`', 'The same in a vertical group.'],
            ['`Space` / `Enter`', 'Selects the focused segment.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2SegmentGroup', 'Oito2Segment']),
      ],
    );
  }
}
