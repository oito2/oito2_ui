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

/// Shows [Oito2SegmentedEntry] as an IPv4 address entry.
class SegmentedEntryPage extends StatefulWidget {
  /// Creates the segmented entry page.
  const SegmentedEntryPage({super.key});

  @override
  State<SegmentedEntryPage> createState() => _SegmentedEntryPageState();
}

class _SegmentedEntryPageState extends State<SegmentedEntryPage> {
  String _address = '';

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'IPv4 address',
          children: [
            Oito2SegmentedEntry(
              segments: const [
                Oito2EntrySegment(length: 3, hint: '192'),
                Oito2EntrySegment(length: 3, hint: '168'),
                Oito2EntrySegment(length: 3, hint: '0'),
                Oito2EntrySegment(length: 3, hint: '1'),
              ],
              onChanged: (v) => setState(() => _address = v.join('.')),
            ),
            Text(
              'Address: $_address',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
