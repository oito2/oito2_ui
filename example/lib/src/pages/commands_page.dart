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

/// Shows [Oito2Commands], [Oito2ShortcutLabel], [Oito2ShortcutRecorder]
/// and the command palette.
class CommandsPage extends StatefulWidget {
  /// Creates the commands page.
  const CommandsPage({super.key});

  @override
  State<CommandsPage> createState() => _CommandsPageState();
}

class _CommandsPageState extends State<CommandsPage> {
  Oito2Shortcut? _shortcut = Oito2Shortcut.parse('Mod+J');
  int _count = 0;
  String _last = '—';

  @override
  Widget build(BuildContext context) {
    final shortcut = _shortcut;
    return Oito2Commands(
      commands: [
        Oito2Command(
          id: 'demo.count',
          label: 'Count one more',
          group: 'This page',
          shortcut: shortcut,
          onInvoke: () => setState(() {
            _count++;
            _last = 'Count one more';
          }),
        ),
        Oito2Command(
          id: 'demo.reset',
          label: 'Reset the count',
          group: 'This page',
          shortcut: Oito2Shortcut.parse('R R'),
          onInvoke: () => setState(() {
            _count = 0;
            _last = 'Reset the count';
          }),
        ),
      ],
      child: Builder(
        builder: (context) => ShowcasePageBody(
          children: [
            ShowcaseSection(
              'Shortcut labels',
              children: [
                for (final text in ['Mod+K', 'Mod+Shift+P', 'Alt+Enter', 'G H'])
                  Oito2ShortcutLabel(Oito2Shortcut.parse(text)),
              ],
            ),
            ShowcaseSection(
              'Record the shortcut of "Count one more"',
              children: [
                Oito2ShortcutRecorder(
                  value: shortcut,
                  onChanged: (value) => setState(() => _shortcut = value),
                ),
              ],
            ),
            ShowcaseSection(
              'Commands of this page',
              children: [
                Focus(
                  autofocus: true,
                  child: Text(
                    'Count: $_count · last command: $_last. Press the shortcut '
                    'above, or R twice, while this page has focus.',
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.command),
                  label: const Text('Open the command palette'),
                  onPressed: () => showOito2CommandPalette(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
