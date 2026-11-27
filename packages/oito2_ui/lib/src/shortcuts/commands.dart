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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import 'shortcut.dart';

/// An action the user can run by a keyboard shortcut or from the command
/// palette.
@immutable
class Oito2Command {
  /// Creates a command.
  const Oito2Command({
    required this.id,
    required this.label,
    required this.onInvoke,
    this.shortcut,
    this.alternateShortcuts = const [],
    this.description,
    this.group,
    this.icon,
    this.keywords = const [],
    this.enabled = true,
  });

  /// A unique identifier; an inner [Oito2Commands] scope overrides an
  /// outer command with the same id.
  final String id;

  /// The name shown in the command palette.
  final String label;

  /// Called when the command runs, from its shortcut or the command
  /// palette.
  final VoidCallback onInvoke;

  /// Creates the command that opens the keyboard shortcuts help, bound to
  /// [shortcutsHelpShortcut] (F1) and [shortcutsHelpAlternateShortcut]
  /// (the primary modifier with Shift and `/`, which reads as Ctrl+? or
  /// ⌘? on layouts that type `?` with Shift and the `/` key).
  ///
  /// Nothing is bound until the app adds this command to an
  /// [Oito2Commands] scope. [onInvoke] usually calls
  /// `showOito2ShortcutsHelp`; [label] is usually the localized
  /// [Oito2Localizations.keyboardShortcuts]. The command shows in the
  /// command palette and in the help itself.
  factory Oito2Command.shortcutsHelp({
    required String label,
    required VoidCallback onInvoke,
    String id = shortcutsHelpId,
    String? description,
    String? group,
    IconData? icon = LucideIcons.keyboard,
    List<String> keywords = const [],
    bool enabled = true,
  }) => Oito2Command(
    id: id,
    label: label,
    onInvoke: onInvoke,
    shortcut: shortcutsHelpShortcut,
    alternateShortcuts: [shortcutsHelpAlternateShortcut],
    description: description,
    group: group,
    icon: icon,
    keywords: keywords,
    enabled: enabled,
  );

  /// The default id of [Oito2Command.shortcutsHelp].
  static const String shortcutsHelpId = 'oito2.shortcutsHelp';

  /// The main shortcut of [Oito2Command.shortcutsHelp]: F1.
  static final Oito2Shortcut shortcutsHelpShortcut = Oito2Shortcut(const [
    Oito2KeyChord(LogicalKeyboardKey.f1),
  ]);

  /// The second shortcut of [Oito2Command.shortcutsHelp]: the primary
  /// modifier with Shift and `/` (Ctrl+Shift+/ or ⇧⌘/), which is Ctrl+? or
  /// ⌘? on layouts that type `?` with Shift and the `/` key, such as US
  /// English and Brazilian ABNT2. Shortcuts match the key, not the
  /// character it types, so on layouts where `?` sits elsewhere (such as
  /// German) only F1 opens the help.
  static final Oito2Shortcut shortcutsHelpAlternateShortcut = Oito2Shortcut(
    const [Oito2KeyChord(LogicalKeyboardKey.slash, primary: true, shift: true)],
  );

  /// The keyboard shortcut, if any; the command palette shows it.
  final Oito2Shortcut? shortcut;

  /// More shortcuts that also run the command; the shortcuts help lists
  /// them after [shortcut].
  final List<Oito2Shortcut> alternateShortcuts;

  /// Returns [shortcut], when set, followed by [alternateShortcuts].
  List<Oito2Shortcut> get shortcuts => [?shortcut, ...alternateShortcuts];

  /// A longer explanation shown in the command palette.
  final String? description;

  /// The palette group, such as "Navigation" or "View".
  final String? group;

  /// An icon shown in the command palette.
  final IconData? icon;

  /// Extra words the palette search matches.
  final List<String> keywords;

  /// Whether the command can run now; disabled commands neither react to
  /// their shortcuts nor appear in the command palette, and the shortcuts
  /// help shows them dimmed.
  final bool enabled;
}

/// Registers [commands] for the widgets below it: while keyboard focus is
/// inside [child], their shortcuts run them, and the command palette lists
/// them.
///
/// Scopes nest: a shortcut first matches the commands of the innermost
/// scope around the focus, then those of the enclosing scopes, and an
/// inner command replaces an outer one with the same [Oito2Command.id].
/// The innermost scope matches the shortcuts of the whole chain at once,
/// so an inner sequence such as `G H` doesn't hide an outer `G` or `G J`.
/// Sequences such as `G H` wait up to [sequenceTimeout] between chords.
/// Shortcuts without Control, Alt, Command or the primary modifier (such
/// as `G H` or `Shift+/`) don't run while a text field has focus, so they
/// don't steal typing; those that start with a function key (F1 to F24)
/// still run, since function keys don't type text.
class Oito2Commands extends StatefulWidget {
  /// Creates a command scope.
  const Oito2Commands({
    super.key,
    required this.commands,
    required this.child,
    this.sequenceTimeout = const Duration(seconds: 1),
  });

  /// The commands of this scope.
  final List<Oito2Command> commands;

  /// The widgets the commands apply to.
  final Widget child;

  /// The longest wait between the chords of a sequence.
  final Duration sequenceTimeout;

  /// Returns the enabled commands available at [context]: those of every
  /// enclosing scope, the innermost first, with inner commands replacing
  /// outer ones of the same id.
  ///
  /// When [includeDisabled] is true, the disabled commands are returned
  /// too, and a disabled inner command replaces an outer one of the same
  /// id, as it does for shortcuts.
  static List<Oito2Command> availableAt(
    BuildContext context, {
    bool includeDisabled = false,
  }) {
    final result = <Oito2Command>[];
    final ids = <String>{};
    var scope = _CommandScope.of(context);
    while (scope != null) {
      for (final command in scope.commands) {
        if (includeDisabled) {
          if (ids.add(command.id)) result.add(command);
        } else if (command.enabled && ids.add(command.id)) {
          result.add(command);
        }
      }
      scope = scope.parent;
    }
    return result;
  }

  /// Returns the pairs of [commands] whose shortcuts clash on [platform]
  /// (the current platform by default): the same shortcut, or one that is
  /// a prefix of another (the longer one could never run). Every shortcut
  /// of a command counts, its [Oito2Command.alternateShortcuts] included.
  static List<(Oito2Command, Oito2Command)> conflicts(
    List<Oito2Command> commands, {
    TargetPlatform? platform,
  }) {
    final target = platform ?? defaultTargetPlatform;
    final result = <(Oito2Command, Oito2Command)>[];
    for (var i = 0; i < commands.length; i++) {
      for (var j = i + 1; j < commands.length; j++) {
        final clash = commands[i].shortcuts.any(
          (a) => commands[j].shortcuts.any(
            (b) => a.startsWith(b, target) || b.startsWith(a, target),
          ),
        );
        if (clash) result.add((commands[i], commands[j]));
      }
    }
    return result;
  }

  @override
  State<Oito2Commands> createState() => _Oito2CommandsState();
}

class _Oito2CommandsState extends State<Oito2Commands> {
  final List<Oito2KeyChord> _pending = [];
  Timer? _timer;

  /// The platform whose primary modifier the shortcuts use: the theme's,
  /// like the labels that show them.
  TargetPlatform get _platform => Theme.of(context).platform;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(_debugCheckConflicts());
  }

  @override
  void didUpdateWidget(Oito2Commands oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(_debugCheckConflicts());
  }

  /// Reports the first shortcut clash among the commands of this scope as
  /// a [FlutterError]; returns true so it can run inside an `assert`.
  bool _debugCheckConflicts() {
    final clashes = Oito2Commands.conflicts(
      widget.commands,
      platform: _platform,
    );
    if (clashes.isNotEmpty) {
      final (a, b) = clashes.first;
      // Reported without throwing, so the build that brought the commands
      // still completes.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError(
            'The shortcuts of the commands "${a.id}" and "${b.id}" clash.',
          ),
          library: 'oito2_ui',
        ),
      );
    }
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Drops the pending chords of a sequence.
  void _reset() {
    _timer?.cancel();
    _pending.clear();
  }

  /// The commands of this scope and of the enclosing ones, the innermost
  /// first, with inner commands, disabled ones included, replacing outer
  /// ones of the same id.
  List<Oito2Command> _chainCommands() {
    final result = <Oito2Command>[];
    final ids = <String>{};
    for (final command in widget.commands) {
      if (ids.add(command.id)) result.add(command);
    }
    var scope = _CommandScope.of(context);
    while (scope != null) {
      for (final command in scope.commands) {
        if (ids.add(command.id)) result.add(command);
      }
      scope = scope.parent;
    }
    return result;
  }

  /// Whether the primary focus is in an [EditableText].
  static bool _textFieldFocused() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    return context.widget is EditableText ||
        context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  /// Matches a key press against the commands; when a pending sequence
  /// doesn't continue with it, retries the press as the start of a new
  /// sequence.
  ///
  /// Only the innermost scope around the focus matches, against the
  /// commands of every enclosing scope; the enclosing scopes ignore the
  /// press, so a sequence is followed in one place.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        Oito2KeyChord.isModifierKey(event.logicalKey)) {
      return KeyEventResult.ignored;
    }
    final focusContext = FocusManager.instance.primaryFocus?.context;
    final innermost = focusContext == null
        ? null
        : _CommandScope.of(focusContext)?.owner;
    if (innermost != null && !identical(innermost, this)) {
      return KeyEventResult.ignored;
    }
    final chord = Oito2KeyChord.fromEvent(event);
    final result = _match(chord);
    if (result == KeyEventResult.ignored && _pending.isNotEmpty) {
      _reset();
      return _match(chord);
    }
    return result;
  }

  /// Whether a shortcut starting with [chord] runs while a text field has
  /// focus: one with a command modifier or a function key, which can't be
  /// typed as text.
  static bool _runsWhileTyping(Oito2KeyChord chord) =>
      chord.hasCommandModifier ||
      (chord.key.keyId >= LogicalKeyboardKey.f1.keyId &&
          chord.key.keyId <= LogicalKeyboardKey.f24.keyId);

  /// Runs the command whose shortcut the pending chords plus [chord]
  /// complete, or keeps [chord] pending when it continues a longer
  /// shortcut, until [Oito2Commands.sequenceTimeout] passes.
  KeyEventResult _match(Oito2KeyChord chord) {
    final platform = _platform;
    final typing = _textFieldFocused();
    final sequence = Oito2Shortcut([..._pending, chord]);
    // The commands of this scope and of the enclosing ones, inner first; a
    // disabled inner command still replaces an outer one of the same id.
    final candidates = [
      for (final command in _chainCommands())
        if (command.enabled)
          for (final shortcut in command.shortcuts)
            if (!typing || _runsWhileTyping(shortcut.chords.first))
              (command, shortcut),
    ];
    for (final (command, shortcut) in candidates) {
      if (shortcut.matches(sequence, platform)) {
        _reset();
        command.onInvoke();
        return KeyEventResult.handled;
      }
    }
    if (candidates.any((entry) => entry.$2.startsWith(sequence, platform))) {
      _pending.add(chord);
      _timer?.cancel();
      _timer = Timer(widget.sequenceTimeout, _reset);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: _CommandScope(
        owner: this,
        commands: widget.commands,
        child: widget.child,
      ),
    );
  }
}

/// Exposes the commands of an [Oito2Commands] and its enclosing scope.
class _CommandScope extends InheritedWidget {
  const _CommandScope({
    required this.owner,
    required this.commands,
    required super.child,
  });

  /// The scope nearest above [context], or null outside every scope.
  ///
  /// Looking it up registers no dependency, so callers read the scopes as
  /// they are at that moment.
  static _CommandScope? of(BuildContext context) =>
      context.getElementForInheritedWidgetOfExactType<_CommandScope>()?.widget
          as _CommandScope?;

  /// The [Oito2Commands] state that builds this scope.
  final _Oito2CommandsState owner;

  /// The commands of [owner].
  final List<Oito2Command> commands;

  /// The scope enclosing [owner], looked up from the element tree on each
  /// read, so it reflects the latest commands of that scope even when this
  /// scope's subtree has not been rebuilt since.
  _CommandScope? get parent => owner.mounted ? of(owner.context) : null;

  @override
  bool updateShouldNotify(_CommandScope oldWidget) =>
      !identical(commands, oldWidget.commands);
}
