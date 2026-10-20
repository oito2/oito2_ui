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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/text_folding.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import '../widgets/highlighted_text.dart';
import '../widgets/search.dart';
import 'commands.dart';
import 'shortcut_widgets.dart';

/// Opens the command palette over [context]: a search field above the
/// commands available at [context] (or [commands] when given), each with
/// its shortcut.
///
/// Typing filters the commands by label, description, group and
/// keywords, ignoring case and accents; labels that start with the query
/// come first. The arrow keys move the highlight, Enter or a click runs a
/// command after the palette closes, and Escape closes it.
Future<void> showOito2CommandPalette(
  BuildContext context, {
  List<Oito2Command>? commands,
}) {
  final available = commands ?? Oito2Commands.availableAt(context);
  return showDialog<void>(
    context: context,
    builder: (context) => _CommandPalette(commands: available),
  );
}

class _CommandPalette extends StatefulWidget {
  const _CommandPalette({required this.commands});

  final List<Oito2Command> commands;

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  String _query = '';
  int _highlight = 0;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<Oito2Command> get _matches {
    final words = foldText(_query)
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final scored = <(int, Oito2Command)>[];
    for (final command in widget.commands) {
      final label = foldText(command.label);
      final text = foldText(
        [
          command.label,
          command.description ?? '',
          command.group ?? '',
          ...command.keywords,
        ].join(' '),
      );
      if (!words.every(text.contains)) continue;
      final score = words.isEmpty
          ? 1
          : label.startsWith(words.first)
          ? 0
          : words.every(label.contains)
          ? 1
          : 2;
      scored.add((score, command));
    }
    final ordered = [...scored];
    ordered.sort((a, b) => a.$1 - b.$1);
    return [for (final (_, command) in ordered) command];
  }

  void _run(Oito2Command command) {
    Navigator.of(context).pop();
    command.onInvoke();
  }

  void _move(int step, int count) {
    if (count == 0) return;
    setState(() => _highlight = (_highlight + step) % count);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = Oito2Localizations.of(context);
    final matches = _matches;
    if (_highlight >= matches.length) _highlight = 0;
    return Align(
      alignment: const Alignment(0, -0.6),
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 440),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _move(1, matches.length),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _move(-1, matches.length),
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Oito2Spacing.md),
                  child: Oito2SearchField(
                    autofocus: true,
                    hintText: l10n.commandPaletteHint,
                    onChanged: (query) => setState(() {
                      _query = query;
                      _highlight = 0;
                    }),
                    onSubmitted: (_) {
                      if (matches.isNotEmpty) _run(matches[_highlight]);
                    },
                    onEscape: () => Navigator.of(context).pop(),
                  ),
                ),
                if (matches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(Oito2Spacing.xl),
                    child: Text(
                      l10n.noCommandsFound,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      controller: _scroll,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: Oito2Spacing.sm),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final command = matches[index];
                        final shortcut = command.shortcut;
                        final description = command.description;
                        final group = command.group;
                        final subtitle = [?group, ?description].join(' · ');
                        return ListTile(
                          selected: index == _highlight,
                          leading: command.icon == null
                              ? null
                              : Icon(command.icon),
                          title: Oito2HighlightedText(
                            command.label,
                            query: _query,
                          ),
                          subtitle: subtitle.isEmpty ? null : Text(subtitle),
                          trailing: shortcut == null
                              ? null
                              : Oito2ShortcutLabel(shortcut),
                          onTap: () => _run(command),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
