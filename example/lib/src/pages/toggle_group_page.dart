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

/// Shows [Oito2ToggleGroup] with one or several items on.
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
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Several on: text styles',
          children: [
            Oito2ToggleGroup<String>(
              multiple: true,
              selected: _styles,
              onChanged: (v) => setState(() => _styles = v),
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
          ],
        ),
        ShowcaseSection(
          'One on, always: alignment',
          children: [
            Oito2ToggleGroup<String>(
              deselectable: false,
              selected: _align,
              onChanged: (v) => setState(() => _align = v),
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
          ],
        ),
        ShowcaseSection(
          'Text items, down, with a disabled item',
          children: [
            Oito2ToggleGroup<String>(
              orientation: Axis.vertical,
              selected: _view,
              onChanged: (v) => setState(() => _view = v),
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
          ],
        ),
      ],
    );
  }
}
