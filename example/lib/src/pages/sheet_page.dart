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

/// Documents [showOito2Sheet] and [Oito2Sheet]: each side, modal and not,
/// with snap points and a result.
class SheetPage extends StatefulWidget {
  /// Creates the sheet page.
  const SheetPage({super.key});

  @override
  State<SheetPage> createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  String _last = 'Nothing yet';

  // #region open
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
  // #endregion

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Sheet',
      description:
          'A panel that slides in from an edge of the window, for details, '
          'filters or a secondary task.',
      source: 'lib/src/pages/sheet_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          regions: const ['open'],
          // #region preview
          child: OutlinedButton(
            onPressed: () => _open(Oito2SheetSide.end),
            child: const Text('Open sheet'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Call `showOito2Sheet` with a `builder`, usually returning an '
          '`Oito2Sheet`: a header with the `title`, optional `actions` and a '
          'close button, above the `child`. Scrollable content goes in a '
          'scroll view inside `child`. The future completes with the value '
          'given to `Oito2Sheet.close`, or null when the sheet is dismissed.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For a short question that needs an answer before going on, use a '
          'dialog; a sheet suits longer content kept beside the page.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Sides', level: 3),
        const DocText(
          '`side` picks the edge: `start` and `end` follow the text '
          'direction, and `bottom` slides up. A side sheet is `size` wide, '
          '360 by default. A bottom sheet is as tall as its content, up to '
          '90% of the window, and at most 640 pixels wide.',
        ),
        ExamplePanel(
          region: 'sides',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              // #region sides
              for (final side in Oito2SheetSide.values)
                OutlinedButton(
                  onPressed: () => _open(side),
                  child: Text(side.name),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Snap points', level: 3),
        const DocText(
          '`snapPoints` gives a bottom sheet the heights it rests at, as '
          'ascending fractions of the window height, starting at the '
          '`initialSnap` index. Its handle then moves between them by drag, '
          'by the arrow keys, or by a tap, Enter or Space, which cycle to '
          'the next height. Only bottom sheets take snap points.',
        ),
        ExamplePanel(
          region: 'snap',
          // #region snap
          child: OutlinedButton(
            onPressed: () =>
                _open(Oito2SheetSide.bottom, snapPoints: const [0.35, 0.85]),
            child: const Text('35% and 85%'),
          ),
          // #endregion
        ),
        const DocHeading('Non-modal', level: 3),
        const DocText(
          'A modal sheet, the default, dims the page and keeps the focus and '
          'assistive technologies inside it. With `modal: false` the page '
          'stays usable beside the sheet, which still closes when the route '
          'that opened it goes away.',
        ),
        ExamplePanel(
          region: 'non-modal',
          // #region non-modal
          child: OutlinedButton(
            onPressed: () => _open(Oito2SheetSide.end, modal: false),
            child: const Text('Non-modal end'),
          ),
          // #endregion
        ),
        const DocHeading('Result', level: 3),
        const DocText(
          'The sheets above complete with "Applied" from their button, or '
          'with null when closed any other way.',
        ),
        ExamplePanel(
          region: 'result',
          minHeight: 60,
          // #region result
          child: Text('Last result: $_last'),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'A modal sheet scopes and names its route for assistive '
          'technologies, labeled by `semanticLabel`, and takes the focus. '
          'The title is marked as a header, and the close button is labeled '
          '"Close". The handle of a bottom sheet with snap points is an '
          'adjustable slider whose value is the current height. Animations '
          'are skipped when the platform asks to reduce motion.',
        ),
        const DocText(
          'With `dismissible: false`, a tap on the dimmed page and a drag '
          'toward the edge no longer close the sheet; Escape and the close '
          'button still do.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Escape`', 'Closes the sheet.'],
            [
              '`Up arrow` / `Down arrow`',
              'On the handle of a bottom sheet with snap points, moves to the '
                  'next taller or shorter height.',
            ],
            ['`Enter` / `Space`', 'On that handle, cycles to the next height.'],
          ],
        ),
        ...apiReferenceWidgets([
          'showOito2Sheet',
          'Oito2Sheet',
          'Oito2SheetSide',
        ]),
      ],
    );
  }
}
