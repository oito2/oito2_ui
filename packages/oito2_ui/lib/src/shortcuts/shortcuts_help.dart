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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/text_folding.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import '../widgets/highlighted_text.dart';
import '../widgets/icon_buttons.dart';
import '../widgets/search.dart';
import '../widgets/utilities.dart';
import 'commands.dart';
import 'shortcut_widgets.dart';

/// Opens the keyboard shortcuts help over [context]: a dialog titled
/// [title] (the localized "Keyboard shortcuts" by default) with an
/// [Oito2ShortcutsHelpView] of [commands].
///
/// [commands] defaults to the commands available at [context], disabled
/// ones included (see [Oito2Commands.availableAt]). Only commands with a
/// shortcut are listed. The search field has the focus when the dialog
/// opens; Escape on an empty search field or on a row closes the dialog,
/// as does the close button.
///
/// Returns a future that completes when the dialog closes.
Future<void> showOito2ShortcutsHelp(
  BuildContext context, {
  Iterable<Oito2Command>? commands,
  String? title,
}) {
  final listed = List<Oito2Command>.of(
    commands ?? Oito2Commands.availableAt(context, includeDisabled: true),
  );
  return showDialog<void>(
    context: context,
    builder: (context) => _ShortcutsHelpDialog(commands: listed, title: title),
  );
}

/// The dialog of [showOito2ShortcutsHelp].
class _ShortcutsHelpDialog extends StatelessWidget {
  const _ShortcutsHelpDialog({required this.commands, this.title});

  final List<Oito2Command> commands;

  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = title ?? Oito2Localizations.of(context).keyboardShortcuts;
    final narrow =
        MediaQuery.sizeOf(context).width < Oito2ShortcutsHelpView.wideWidth;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: narrow
          ? const EdgeInsets.all(Oito2Spacing.md)
          : const EdgeInsets.symmetric(
              horizontal: Oito2Spacing.xxl,
              vertical: Oito2Spacing.xl,
            ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 600),
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: heading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  Oito2Spacing.lg,
                  Oito2Spacing.sm,
                  Oito2Spacing.sm,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(heading, style: theme.textTheme.titleLarge),
                      ),
                    ),
                    const Oito2CloseButton(),
                  ],
                ),
              ),
              Flexible(
                child: Oito2ShortcutsHelpView(
                  commands: commands,
                  autofocus: true,
                  onEscape: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The searchable list of keyboard shortcuts that
/// [showOito2ShortcutsHelp] shows in a dialog, for embedding in a page
/// such as the app settings.
///
/// Each command with a shortcut is a row with its label, its description
/// and its shortcuts as [Oito2ShortcutLabel]s, under the heading of its
/// [Oito2Command.group]; commands without a group go under the localized
/// "General". Groups follow the order in which they first appear, and
/// rows the order of [commands]. Disabled commands stay in place, dimmed,
/// and assistive technologies read them as disabled. At least
/// [wideWidth] wide, the groups flow into two columns.
///
/// Typing in the search field keeps the commands whose label,
/// description, group, keywords and key names (as shown, such as `Ctrl`
/// or `F1`) contain every typed word, ignoring case and accents, and
/// highlights the matches in the labels and descriptions.
///
/// The Down arrow moves the focus from the search field to the first row
/// and on to the next rows, the Up arrow back to the previous row and to
/// the search field, and Tab through the rows in the same order. Each row
/// reads as its label and shortcuts, such as "Open settings, shortcut
/// Ctrl+,", with the description as its hint.
///
/// With a bounded height the rows scroll below the search field;
/// otherwise the view takes the height of all its rows.
class Oito2ShortcutsHelpView extends StatefulWidget {
  /// Creates a shortcuts help view.
  const Oito2ShortcutsHelpView({
    super.key,
    this.commands,
    this.autofocus = false,
    this.onEscape,
  });

  /// The narrowest width that shows two columns.
  static const double wideWidth = 600;

  /// The commands to list; defaults to those available at the view,
  /// disabled ones included (see [Oito2Commands.availableAt]). Commands
  /// without a shortcut are left out.
  final Iterable<Oito2Command>? commands;

  /// Whether the search field takes the focus when first shown.
  final bool autofocus;

  /// Called when Escape is pressed on an empty search field or on a row.
  final VoidCallback? onEscape;

  @override
  State<Oito2ShortcutsHelpView> createState() => _Oito2ShortcutsHelpViewState();
}

/// A command of the shortcuts help with the labels of its shortcuts and
/// its folded searchable text.
typedef _Entry = ({Oito2Command command, List<String> labels, String text});

class _Oito2ShortcutsHelpViewState extends State<Oito2ShortcutsHelpView> {
  String _query = '';
  final _searchFocus = FocusNode(debugLabel: 'Shortcuts help search');
  final Map<String, FocusNode> _rowNodes = {};

  /// The focus nodes of the shown rows, in reading order.
  List<FocusNode> _order = const [];

  @override
  void dispose() {
    _searchFocus.dispose();
    for (final node in _rowNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  /// Returns the focus node of the row of the command [id], created on
  /// first use.
  FocusNode _nodeFor(String id) =>
      _rowNodes.putIfAbsent(id, () => FocusNode(debugLabel: 'Shortcut $id'));

  /// Returns the listed commands with a shortcut, with their labels on
  /// [platform] and their folded searchable text.
  List<_Entry> _entries(TargetPlatform platform) {
    final source =
        widget.commands ??
        Oito2Commands.availableAt(context, includeDisabled: true);
    return [
      for (final command in source)
        if (command.shortcuts.isNotEmpty)
          (
            command: command,
            labels: [
              for (final shortcut in command.shortcuts)
                shortcut.label(platform),
            ],
            text: foldText(
              [
                command.label,
                command.description ?? '',
                command.group ?? '',
                ...command.keywords,
                for (final shortcut in command.shortcuts) ...[
                  shortcut.label(platform),
                  for (final chord in shortcut.chords) ...chord.parts(platform),
                ],
              ].join(' '),
            ),
          ),
    ];
  }

  /// Moves the focus [step] rows down (or up when negative); from the
  /// search field down to the first row, and from the first row up to
  /// the search field. Returns whether the focus moved.
  bool _move(int step) {
    final current = _order.indexWhere((node) => node.hasPrimaryFocus);
    if (current < 0) {
      if (step < 0 || _order.isEmpty || !_searchFocus.hasFocus) return false;
      _order.first.requestFocus();
      return true;
    }
    final next = current + step;
    if (next < 0) {
      _searchFocus.requestFocus();
    } else if (next < _order.length) {
      _order[next].requestFocus();
    }
    return true;
  }

  /// Handles the arrow keys anywhere in the view, and Escape on a row.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final moved = switch (key) {
      LogicalKeyboardKey.arrowDown => _move(1),
      LogicalKeyboardKey.arrowUp => _move(-1),
      LogicalKeyboardKey.escape
          when widget.onEscape != null &&
              _order.any((node) => node.hasPrimaryFocus) =>
        () {
          widget.onEscape!();
          return true;
        }(),
      _ => false,
    };
    return moved ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = Oito2Localizations.of(context);
    final platform = theme.platform;
    final words = foldText(_query)
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final matches = [
      for (final entry in _entries(platform))
        if (words.every(entry.text.contains)) entry,
    ];
    final groups = <String?, List<_Entry>>{};
    for (final entry in matches) {
      (groups[entry.command.group] ??= []).add(entry);
    }
    final search = Padding(
      padding: const EdgeInsets.all(Oito2Spacing.md),
      child: Oito2SearchField(
        focusNode: _searchFocus,
        autofocus: widget.autofocus,
        hintText: l10n.searchShortcutsHint,
        onChanged: (query) => setState(() => _query = query),
        onEscape: widget.onEscape,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final Widget body;
        if (matches.isEmpty) {
          _order = const [];
          body = Padding(
            padding: const EdgeInsets.all(Oito2Spacing.xl),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.noShortcutsFound,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        } else {
          body = Padding(
            padding: const EdgeInsets.fromLTRB(
              Oito2Spacing.sm,
              0,
              Oito2Spacing.sm,
              Oito2Spacing.md,
            ),
            child: _columns(
              groups,
              theme,
              l10n,
              wide: constraints.maxWidth >= Oito2ShortcutsHelpView.wideWidth,
            ),
          );
        }
        return Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _onKey,
          child: FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                if (constraints.maxHeight.isFinite)
                  Flexible(child: SingleChildScrollView(child: body))
                else
                  body,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Lays out [groups] in one column, or in two when [wide], filling the
  /// first column before the second and keeping each group in one column
  /// unless there is a single group; records the reading order of the
  /// rows in [_order].
  Widget _columns(
    Map<String?, List<_Entry>> groups,
    ThemeData theme,
    Oito2Localizations l10n, {
    required bool wide,
  }) {
    // Headings and rows in reading order; a null command is a heading.
    final items = <(String?, _Entry?)>[
      for (final MapEntry(key: group, value: entries) in groups.entries) ...[
        (group, null),
        for (final entry in entries) (group, entry),
      ],
    ];
    _order = [
      for (final (_, entry) in items)
        if (entry != null) _nodeFor(entry.command.id),
    ];
    Widget build((String?, _Entry?) item) => switch (item) {
      (final group, null) => _heading(group ?? l10n.generalShortcuts, theme),
      (_, final entry?) => _row(entry, theme, l10n),
    };
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final item in items) build(item)],
      );
    }
    // Splits at the group boundary nearest the middle, or in the middle of
    // the rows of a single group.
    var split = (items.length + 1) ~/ 2;
    final boundaries = [
      for (var i = 1; i < items.length; i++)
        if (items[i].$2 == null) i,
    ];
    if (boundaries.isNotEmpty) {
      split = boundaries.reduce(
        (a, b) => (2 * a - items.length).abs() <= (2 * b - items.length).abs()
            ? a
            : b,
      );
    }
    Widget column(Iterable<(String?, _Entry?)> part) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final item in part) build(item)],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Oito2Spacing.lg,
      children: [
        Expanded(child: column(items.take(split))),
        Expanded(child: column(items.skip(split))),
      ],
    );
  }

  /// The heading of a group named [text].
  Widget _heading(String text, ThemeData theme) => Semantics(
    header: true,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        Oito2Spacing.md,
        Oito2Spacing.md,
        Oito2Spacing.md,
        Oito2Spacing.xs,
      ),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );

  /// The row of [entry]: its label and description beside its shortcuts,
  /// focusable, at least a touch target tall.
  Widget _row(_Entry entry, ThemeData theme, Oito2Localizations l10n) {
    final command = entry.command;
    final description = command.description;
    final node = _nodeFor(command.id);
    return Semantics(
      container: true,
      label: l10n.shortcutEntry(command.label, entry.labels),
      hint: description,
      enabled: command.enabled ? null : false,
      child: Oito2FocusBorder(
        borderRadius: Oito2Radius.smallAll,
        child: Focus(
          focusNode: node,
          onFocusChange: (focused) {
            final context = node.context;
            if (focused && context != null) Scrollable.ensureVisible(context);
          },
          child: ExcludeSemantics(
            child: Opacity(
              opacity: command.enabled ? 1 : 0.5,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Oito2Sizes.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Oito2Spacing.md,
                    vertical: Oito2Spacing.xs,
                  ),
                  child: Row(
                    spacing: Oito2Spacing.md,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Oito2HighlightedText(
                              command.label,
                              query: _query,
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (description != null)
                              Oito2HighlightedText(
                                description,
                                query: _query,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Wrap(
                          spacing: Oito2Spacing.sm,
                          runSpacing: Oito2Spacing.xxs,
                          alignment: WrapAlignment.end,
                          children: [
                            for (final shortcut in command.shortcuts)
                              Oito2ShortcutLabel(shortcut),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
