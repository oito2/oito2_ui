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

/// Documents [Oito2Draggable], moved by pointer, arrow keys or
/// assistive technologies, and its move reports.
class DraggablePage extends StatefulWidget {
  /// Creates the draggable page.
  const DraggablePage({super.key});

  @override
  State<DraggablePage> createState() => _DraggablePageState();
}

class _DraggablePageState extends State<DraggablePage> {
  Offset _position = const Offset(24, 24);
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Draggable',
      description:
          'A widget the user can move inside a stack with the pointer, the '
          'arrow keys or assistive technologies.',
      source: 'lib/src/pages/draggable_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            height: 220,
            child: Oito2BorderContainer(
              // #region preview
              child: Stack(
                children: [
                  Oito2Draggable(
                    initialPosition: const Offset(24, 40),
                    child: Chip(
                      avatar: const Icon(LucideIcons.move, size: 18),
                      label: const Text('Drag me or use arrows'),
                    ),
                  ),
                ],
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Put `Oito2Draggable` directly in a `Stack`; it positions itself '
          'at `initialPosition` from the top-left corner of the stack, also '
          'in right-to-left layouts. The widget keeps its own position, so '
          'later changes to `initialPosition` are ignored.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'The position is not limited to the stack: the widget can be '
          'moved past its edges, where the stack clips it. Use `onMoved` to '
          'keep track of where it is.',
          type: Oito2InfoType.warning,
        ),
        const DocHeading('Examples'),
        const DocHeading('Reporting moves', level: 3),
        const DocText(
          '`onMoved` receives each new position, after a pointer or a '
          'keyboard move. `onDragStart` and `onDragEnd` mark a pointer drag. '
          '`keyboardStep` sets how far one arrow key press moves the '
          'widget, 8 pixels by default, and `semanticLabel` names it for '
          'assistive technologies.',
        ),
        ExamplePanel(
          region: 'callbacks',
          child: SizedBox(
            width: 420,
            height: 220,
            child: Oito2BorderContainer(
              // #region callbacks
              child: Stack(
                children: [
                  Oito2Draggable(
                    initialPosition: const Offset(24, 24),
                    keyboardStep: 16,
                    semanticLabel: 'Note',
                    onMoved: (position) => setState(() => _position = position),
                    onDragStart: () => setState(() => _dragging = true),
                    onDragEnd: () => setState(() => _dragging = false),
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(Oito2Spacing.md),
                        child: Text('Note'),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: Oito2Spacing.sm,
                    bottom: Oito2Spacing.sm,
                    child: Text(
                      '${_position.dx.round()}, ${_position.dy.round()}'
                      '${_dragging ? ' · dragging' : ''}',
                    ),
                  ),
                ],
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read the widget by `semanticLabel`, with '
          'the hint "Use the arrow keys to move it", and offer four actions, '
          '"Move up", "Move down", "Move left" and "Move right", that each '
          'move it by `keyboardStep`. The widget shows the focus ring when '
          'reached with the keyboard.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the widget.'],
            [
              'Arrow keys',
              'Move the widget by `keyboardStep` in the direction of the '
                  'arrow; holding a key repeats the move.',
            ],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Draggable']),
      ],
    );
  }
}
