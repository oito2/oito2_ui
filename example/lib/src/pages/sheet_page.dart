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

import '../widgets/showcase_widgets.dart';

/// Shows [showOito2Sheet] from each side, modal and not, with snap points.
class SheetPage extends StatefulWidget {
  /// Creates the sheet page.
  const SheetPage({super.key});

  @override
  State<SheetPage> createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  String _last = 'Nothing yet';

  /// Opens a sheet from [side] and shows its result, or "Dismissed" when
  /// it closes without one.
  Future<void> _open(
    Oito2SheetSide side, {
    bool modal = true,
    List<double>? snapPoints,
  }) async {
    final result = await showOito2Sheet<String>(
      context,
      side: side,
      modal: modal,
      snapPoints: snapPoints,
      builder: (context) => Oito2Sheet(
        title: Text('${side.name} sheet'),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Oito2Spacing.sm,
            children: [
              Text(
                modal
                    ? 'Drag toward the edge, press Escape or tap outside to '
                          'close.'
                    : 'The page beside stays usable.',
              ),
              FilledButton(
                onPressed: () => Oito2Sheet.close(context, 'Applied'),
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() => _last = result ?? 'Dismissed');
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Modal',
          children: [
            for (final side in Oito2SheetSide.values)
              OutlinedButton(
                onPressed: () => _open(side),
                child: Text(side.name),
              ),
          ],
        ),
        ShowcaseSection(
          'Bottom with snap points and non-modal',
          children: [
            OutlinedButton(
              onPressed: () =>
                  _open(Oito2SheetSide.bottom, snapPoints: const [0.35, 0.85]),
              child: const Text('35% and 85%'),
            ),
            OutlinedButton(
              onPressed: () => _open(Oito2SheetSide.end, modal: false),
              child: const Text('Non-modal end'),
            ),
          ],
        ),
        ShowcaseSection('Last result', children: [Text(_last)]),
      ],
    );
  }
}
