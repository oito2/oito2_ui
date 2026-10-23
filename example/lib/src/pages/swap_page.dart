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

/// Shows [Oito2Swap] with each of its effects.
class SwapPage extends StatefulWidget {
  /// Creates the swap page.
  const SwapPage({super.key});

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  bool _swapped = false;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Effects: tap any icon',
          children: [
            for (final effect in Oito2SwapEffect.values)
              Column(
                children: [
                  Oito2IconButton(
                    tooltip: effect.name,
                    onPressed: () => setState(() => _swapped = !_swapped),
                    icon: Oito2Swap(
                      swapped: _swapped,
                      effect: effect,
                      off: const Icon(LucideIcons.play),
                      on: const Icon(LucideIcons.pause),
                    ),
                  ),
                  Text(effect.name),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
