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

/// Shows [Oito2ToggleButton] with a custom control: the whole row is
/// clickable and takes keyboard focus as one element.
class ToggleButtonPage extends StatefulWidget {
  /// Creates the toggle button page.
  const ToggleButtonPage({super.key});

  @override
  State<ToggleButtonPage> createState() => _ToggleButtonPageState();
}

class _ToggleButtonPageState extends State<ToggleButtonPage> {
  bool _sync = true;
  bool _notify = false;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Toggle buttons',
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Oito2ToggleButton(
                  control: Oito2Checkbox(
                    value: _sync,
                    onChanged: (v) => setState(() => _sync = v ?? false),
                  ),
                  title: const Text('Sync files'),
                  subtitle: const Text('Control before the text'),
                  onToggled: () => setState(() => _sync = !_sync),
                ),
                Oito2ToggleButton(
                  control: Oito2Switch(
                    value: _notify,
                    onChanged: (v) => setState(() => _notify = v),
                  ),
                  controlAtEnd: true,
                  title: const Text('Notify me'),
                  subtitle: const Text('Control after the text'),
                  onToggled: () => setState(() => _notify = !_notify),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
