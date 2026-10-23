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

/// Shows [Oito2SegmentGroup] across, down, with icons and a disabled
/// segment.
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

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Across, with a disabled segment',
          children: [
            Oito2SegmentGroup<String>(
              selected: _framework,
              onChanged: (v) => setState(() => _framework = v),
              segments: const [
                Oito2Segment(value: 'react', label: Text('React')),
                Oito2Segment(value: 'solid', label: Text('Solid')),
                Oito2Segment(value: 'svelte', label: Text('Svelte')),
                Oito2Segment(value: 'vue', label: Text('Vue'), enabled: false),
              ],
            ),
          ],
        ),
        ShowcaseSection(
          'With icons',
          children: [
            Oito2SegmentGroup<String>(
              selected: _view,
              onChanged: (v) => setState(() => _view = v),
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
          ],
        ),
        ShowcaseSection(
          'Down',
          children: [
            Oito2SegmentGroup<String>(
              orientation: Axis.vertical,
              selected: _period,
              onChanged: (v) => setState(() => _period = v),
              segments: const [
                Oito2Segment(value: 'day', label: Text('Today')),
                Oito2Segment(value: 'week', label: Text('This week')),
                Oito2Segment(value: 'month', label: Text('This month')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
