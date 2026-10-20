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

/// Shows [Oito2CheckButton]: two-state, tri-state and disabled.
class CheckButtonPage extends StatefulWidget {
  /// Creates the check button page.
  const CheckButtonPage({super.key});

  @override
  State<CheckButtonPage> createState() => _CheckButtonPageState();
}

class _CheckButtonPageState extends State<CheckButtonPage> {
  bool? _hidden = false;
  bool _symlinks = true;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Check buttons',
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Oito2CheckButton(
                  value: _hidden,
                  tristate: true,
                  onChanged: (v) => setState(() => _hidden = v),
                  title: const Text('Show hidden files'),
                  subtitle: const Text('Tri-state: checked, mixed, unchecked'),
                ),
                Oito2CheckButton(
                  value: _symlinks,
                  onChanged: (v) => setState(() => _symlinks = v ?? false),
                  title: const Text('Follow symbolic links'),
                ),
                const Oito2CheckButton(
                  value: true,
                  onChanged: null,
                  title: Text('Disabled option'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
