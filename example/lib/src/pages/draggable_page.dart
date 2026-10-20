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

/// Shows [Oito2Draggable], moved by pointer or arrow keys.
class DraggablePage extends StatelessWidget {
  /// Creates the draggable page.
  const DraggablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Draggable',
          children: [
            SizedBox(
              width: 420,
              height: 220,
              child: Oito2BorderContainer(
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}
