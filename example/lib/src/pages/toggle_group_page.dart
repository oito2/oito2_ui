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

/// Documents [Oito2ToggleGroup] with one or several items on, down, and
/// disabled.
class ToggleGroupPage extends StatefulWidget {
  /// Creates the toggle group page.
  const ToggleGroupPage({super.key});

  @override
  State<ToggleGroupPage> createState() => _ToggleGroupPageState();
}

class _ToggleGroupPageState extends State<ToggleGroupPage> {
  Set<String> _styles = {'bold'};
  Set<String> _align = {'start'};
  Set<String> _view = {'week'};

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Toggle Group',
      description:
          'A joined row of buttons that turn on and off, such as text '
          'formatting or alignment buttons.',
      source: 'lib/src/pages/toggle_group_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2ToggleGroup<String>(
            multiple: true,
            selected: _styles,
            onChanged: (values) => setState(() => _styles = values),
            items: const [
              Oito2ToggleItem(
                value: 'bold',
                tooltip: 'Bold',
                child: Icon(LucideIcons.bold),
              ),
              Oito2ToggleItem(
                value: 'italic',
                tooltip: 'Italic',
                child: Icon(LucideIcons.italic),
              ),
              Oito2ToggleItem(
                value: 'underline',
                tooltip: 'Underline',
                child: Icon(LucideIcons.underline),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'The group is controlled: `selected` holds the values of the '
          'items that are on, and `onChanged` receives the new set. Each '
          '`Oito2ToggleItem` has a `value` and a `child`, an icon, a text '
          'or both; give icon-only items a `tooltip`, which also names them '
          'for assistive technologies. Items that are on are raised from '
          'the track. A null `onChanged` disables the group.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'With `multiple`, as above, each item turns on and off by itself. '
          'Without it, turning one item on turns the others off.',
        ),
        const DocNote(
          'Use a toggle group for options that turn on and off. For two to '
          'five mutually exclusive options that change a view, '
          '`Oito2SegmentGroup` is clearer.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Always one on', level: 3),
        const DocText(
          'In a single group the item that is on turns off when pressed '
          'again, leaving none on. With `deselectable` set to false it '
          'stays on, so one item is always on.',
        ),
        ExamplePanel(
          region: 'single',
          // #region single
          child: Oito2ToggleGroup<String>(
            deselectable: false,
            selected: _align,
            onChanged: (values) => setState(() => _align = values),
            items: const [
              Oito2ToggleItem(
                value: 'start',
                tooltip: 'Align left',
                child: Icon(LucideIcons.text_align_start),
              ),
              Oito2ToggleItem(
                value: 'center',
                tooltip: 'Center',
                child: Icon(LucideIcons.text_align_center),
              ),
              Oito2ToggleItem(
                value: 'end',
                tooltip: 'Align right',
                child: Icon(LucideIcons.text_align_end),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Text items, down, with a disabled item', level: 3),
        const DocText(
          '`orientation: Axis.vertical` stacks the items, all as wide as '
          'the widest. An item with `enabled` set to false is dimmed and '
          'can\'t be toggled or focused.',
        ),
        ExamplePanel(
          region: 'vertical',
          // #region vertical
          child: Oito2ToggleGroup<String>(
            orientation: Axis.vertical,
            selected: _view,
            onChanged: (values) => setState(() => _view = values),
            items: const [
              Oito2ToggleItem(value: 'day', child: Text('Day')),
              Oito2ToggleItem(value: 'week', child: Text('Week')),
              Oito2ToggleItem(
                value: 'year',
                enabled: false,
                child: Text('Year'),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'A null `onChanged` disables every item; the items that are on '
          'still show raised.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2ToggleGroup<String>(
            selected: {'grid'},
            onChanged: null,
            items: [
              Oito2ToggleItem(
                value: 'list',
                tooltip: 'List',
                child: Icon(LucideIcons.list),
              ),
              Oito2ToggleItem(
                value: 'grid',
                tooltip: 'Grid',
                child: Icon(LucideIcons.layout_grid),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each item is a toggle button for assistive technologies, which '
          'report whether it is on, and is named by its `tooltip` or its '
          'text. The focused item shows the focus ring.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocText(
          'The group is one stop in keyboard navigation: `Tab` reaches the '
          'last focused item, or the first enabled one.',
        ),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Left arrow` / `Right arrow`',
              'Moves to the previous or next enabled item, wrapping at the '
                  'ends (mirrored in right-to-left layouts). `Up arrow` and '
                  '`Down arrow` in a vertical group.',
            ],
            ['`Space` / `Enter`', 'Turns the focused item on or off.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2ToggleGroup', 'Oito2ToggleItem']),
      ],
    );
  }
}
