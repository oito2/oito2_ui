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

/// Documents [Oito2Commands], [Oito2ShortcutLabel], [Oito2ShortcutRecorder]
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
      // #region commands
      commands: [
        Oito2Command(
          id: 'demo.count',
          label: 'Count one more',
          group: 'This page',
          icon: LucideIcons.plus,
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
          description: 'Sets the count back to zero',
          shortcut: Oito2Shortcut.parse('R R'),
          onInvoke: () => setState(() {
            _count = 0;
            _last = 'Reset the count';
          }),
        ),
      ],
      // #endregion
      child: Builder(
        builder: (context) => DocPage(
          title: 'Commands',
          description:
              'Actions that run from keyboard shortcuts or a searchable '
              'command palette, with shortcut labels, a shortcut recorder '
              'and a keyboard shortcuts help.',
          source: 'lib/src/pages/commands_page.dart',
          children: [
            ExamplePanel(
              regions: const ['commands', 'preview'],
              child: SizedBox(
                width: 360,
                child: Column(
                  spacing: Oito2Spacing.md,
                  children: [
                    Focus(
                      autofocus: true,
                      child: Text(
                        'Count: $_count · last command: $_last. Press the '
                        'shortcut below, or R twice, while this page has '
                        'focus.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // #region preview
                    OutlinedButton.icon(
                      icon: const Icon(LucideIcons.command),
                      label: const Text('Open the command palette'),
                      onPressed: () => showOito2CommandPalette(context),
                    ),
                    // #endregion
                  ],
                ),
              ),
            ),
            const DocHeading('Usage'),
            const DocText(
              'Wrap a part of the app in `Oito2Commands` with a list of '
              '`Oito2Command`s. While the keyboard focus is inside its '
              '`child`, the shortcuts of the enabled commands run their '
              '`onInvoke`, and `showOito2CommandPalette` lists them. Each '
              'command needs a unique `id`, a `label` and `onInvoke`; the '
              '`shortcut`, `group`, `description`, `icon` and `keywords` '
              'are optional.',
            ),
            const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
            const DocText(
              'Scopes nest: a shortcut first matches the commands of the '
              'innermost scope around the focus, then those of the '
              'enclosing scopes, and an inner command replaces an outer one '
              'with the same `id`. A disabled command neither reacts to its '
              'shortcut nor appears in the palette. In debug builds, two '
              'commands of a scope whose shortcuts clash, or where one is a '
              'prefix of the other, are reported as an error.',
            ),
            const DocNote(
              'Shortcuts without Control, Alt, Command or the primary '
              'modifier, such as `R R` or `Shift+/`, don\'t run while a text '
              'field has focus, so they don\'t steal typing. Shortcuts that '
              'start with a function key, such as `F1`, still run.',
            ),
            const DocHeading('Examples'),
            const DocHeading('Shortcuts', level: 3),
            const DocText(
              '`Oito2Shortcut.parse` reads chords separated by spaces and '
              'keys within a chord joined by `+`. `Mod` is the primary '
              'modifier: Command on macOS and iOS, Control elsewhere. A '
              'sequence such as `G H` waits up to `sequenceTimeout`, one '
              'second by default, between chords. `Oito2ShortcutLabel` '
              'shows a shortcut as key caps in the notation of the '
              'platform.',
            ),
            ExamplePanel(
              region: 'labels',
              // #region labels
              child: Wrap(
                spacing: Oito2Spacing.lg,
                runSpacing: Oito2Spacing.sm,
                children: [
                  for (final text in [
                    'Mod+K',
                    'Mod+Shift+P',
                    'Alt+Enter',
                    'G H',
                  ])
                    Oito2ShortcutLabel(Oito2Shortcut.parse(text)),
                ],
              ),
              // #endregion
            ),
            const DocHeading('Platform notation', level: 3),
            const DocText(
              'The label follows the theme platform by default; `platform` '
              'picks another. Apple platforms show the modifiers as symbols '
              'in one cap.',
            ),
            ExamplePanel(
              region: 'platform',
              // #region platform
              child: Wrap(
                spacing: Oito2Spacing.lg,
                runSpacing: Oito2Spacing.sm,
                children: [
                  Oito2ShortcutLabel(
                    Oito2Shortcut.parse('Mod+Shift+K'),
                    platform: TargetPlatform.linux,
                  ),
                  Oito2ShortcutLabel(
                    Oito2Shortcut.parse('Mod+Shift+K'),
                    platform: TargetPlatform.macOS,
                  ),
                ],
              ),
              // #endregion
            ),
            const DocHeading('Recording a shortcut', level: 3),
            const DocText(
              '`Oito2ShortcutRecorder` records a single-chord shortcut, as '
              'in keyboard settings: click it and press the keys. A Command '
              'or Control chord is stored with the primary modifier, so it '
              'reads naturally on every platform. Here it sets the shortcut '
              'of "Count one more"; a null `onChanged` disables it.',
            ),
            ExamplePanel(
              region: 'recorder',
              // #region recorder
              child: Oito2ShortcutRecorder(
                value: shortcut,
                onChanged: (value) => setState(() => _shortcut = value),
              ),
              // #endregion
            ),
            const DocHeading('Command palette', level: 3),
            const DocText(
              '`showOito2CommandPalette` opens a dialog with a search field '
              'above the commands available at the context, or the given '
              '`commands`, each with its group, description and shortcut. '
              'Typing keeps the commands whose label, description, group '
              'and keywords contain every word, ignoring case and accents; '
              'those whose label starts with the first word come first. '
              'Choosing a command closes the palette and runs it.',
            ),
            ExamplePanel(
              region: 'palette',
              // #region palette
              child: OutlinedButton(
                onPressed: () => showOito2CommandPalette(
                  context,
                  commands: Oito2Commands.availableAt(context),
                ),
                child: const Text('Search commands'),
              ),
              // #endregion
            ),
            const DocHeading('Keyboard shortcuts help', level: 3),
            const DocText(
              '`showOito2ShortcutsHelp` opens a dialog that lists the '
              'commands with a shortcut available at the context, or the '
              'given `commands`, under the headings of their groups ("General" '
              'for those without one), in two columns on wide screens. '
              'Disabled commands stay in place, dimmed. The search field '
              'keeps the commands whose label, description, group, keywords '
              'and key names contain every typed word, ignoring case and '
              'accents, and highlights the matches. '
              '`Oito2ShortcutsHelpView` is the same list without the '
              'dialog, for a settings page.',
            ),
            const DocText(
              'Nothing is bound by default. `Oito2Command.shortcutsHelp` '
              'creates the command that opens it on `F1` and on '
              '`Mod+Shift+/` (Ctrl+? or ⌘? on layouts that type `?` with '
              'Shift and the `/` key, such as US English and Brazilian '
              'ABNT2); add it to an `Oito2Commands` scope so it also shows '
              'in the palette and in the help. Shortcuts match keys, not '
              'characters, so on layouts with `?` elsewhere, such as German, '
              'only `F1` opens it. This showcase binds it: press `F1`.',
            ),
            const DocCode(
              'Oito2Command.shortcutsHelp(\n'
              "  label: 'Keyboard shortcuts',\n"
              '  onInvoke: () => showOito2ShortcutsHelp(context),\n'
              ')',
            ),
            ExamplePanel(
              region: 'help',
              child: OutlinedButton.icon(
                icon: const Icon(LucideIcons.keyboard),
                label: const Text('Show keyboard shortcuts'),
                // #region help
                onPressed: () => showOito2ShortcutsHelp(context),
                // #endregion
              ),
            ),
            const DocHeading('Accessibility'),
            const DocText(
              'Assistive technologies read an `Oito2ShortcutLabel` as text, '
              'such as "Ctrl+Shift+K". The recorder is a button whose label '
              'is the current shortcut, "No shortcut", or the prompt to '
              'press one while recording. Each row of the shortcuts help is '
              'focusable and reads as its label and shortcuts, such as '
              '"Open settings, shortcut Ctrl+,", with the description as '
              'its hint; disabled commands read as disabled.',
            ),
            const DocHeading('Keyboard', level: 3),
            const DocTable(
              header: ['Key', 'Action'],
              rows: [
                ['`Enter` / `Space`', 'On the recorder, starts recording.'],
                [
                  'Any key with its modifiers',
                  'While recording, becomes the shortcut.',
                ],
                [
                  '`Esc`',
                  'While recording, cancels. In the palette, closes it.',
                ],
                [
                  '`Backspace` / `Delete`',
                  'While recording, without modifiers, clears the shortcut.',
                ],
                [
                  '`Down arrow` / `Up arrow`',
                  'In the palette, moves the highlight, wrapping around.',
                ],
                [
                  '`Enter`',
                  'In the palette, closes it and runs the highlighted command.',
                ],
                [
                  '`F1` / `Ctrl+Shift+/`',
                  'Where `Oito2Command.shortcutsHelp` is bound, opens the '
                      'shortcuts help.',
                ],
                [
                  '`Down arrow` / `Up arrow`',
                  'In the shortcuts help, moves from the search field '
                      'through the rows and back.',
                ],
                [
                  '`Tab` / `Shift+Tab`',
                  'In the shortcuts help, moves through the rows in reading '
                      'order.',
                ],
                [
                  '`Esc`',
                  'In the shortcuts help, clears the search, then closes it.',
                ],
              ],
            ),
            ...apiReferenceWidgets([
              'Oito2Commands',
              'Oito2Command',
              'Oito2Shortcut',
              'Oito2KeyChord',
              'Oito2ShortcutLabel',
              'Oito2ShortcutRecorder',
              'showOito2CommandPalette',
              'showOito2ShortcutsHelp',
              'Oito2ShortcutsHelpView',
              'oito2UsesCommandKey',
            ]),
          ],
        ),
      ),
    );
  }
}
