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
import 'package:material_ui/material_ui.dart';

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

  /// The keyboard shortcut, if any.
  final Oito2Shortcut? shortcut;

  /// A longer explanation shown in the command palette.
  final String? description;

  /// The palette group, such as "Navigation" or "View".
  final String? group;

  /// An icon shown in the command palette.
  final IconData? icon;

  /// Extra words the palette search matches.
  final List<String> keywords;

  /// Whether the command can run now; disabled commands neither react to
  /// their shortcut nor appear in the command palette.
  final bool enabled;
}

/// Registers [commands] for the widgets below it: while keyboard focus is
/// inside [child], their shortcuts run them, and the command palette lists
/// them.
///
/// Scopes nest: a shortcut first matches the commands of the innermost
/// scope around the focus, then those of the enclosing scopes, and an
/// inner command replaces an outer one with the same [Oito2Command.id].
/// Sequences such as `G H` wait up to [sequenceTimeout] between chords.
/// Shortcuts without Control, Alt, Command or the primary modifier (such
/// as `G H` or `Shift+/`) don't run while a text field has focus, so they
/// don't steal typing.
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
  static List<Oito2Command> availableAt(BuildContext context) {
    final result = <Oito2Command>[];
    final ids = <String>{};
    var scope = _CommandScope.of(context);
    while (scope != null) {
      for (final command in scope.commands) {
        if (command.enabled && ids.add(command.id)) result.add(command);
      }
      scope = scope.parent;
    }
    return result;
  }

  /// Returns the pairs of [commands] whose shortcuts clash on [platform]
  /// (the current platform by default): the same shortcut, or one that is
  /// a prefix of another (the longer one could never run).
  static List<(Oito2Command, Oito2Command)> conflicts(
    List<Oito2Command> commands, {
    TargetPlatform? platform,
  }) {
    final target = platform ?? defaultTargetPlatform;
    final result = <(Oito2Command, Oito2Command)>[];
    for (var i = 0; i < commands.length; i++) {
      for (var j = i + 1; j < commands.length; j++) {
        final a = commands[i].shortcut;
        final b = commands[j].shortcut;
        if (a == null || b == null) continue;
        if (a.startsWith(b, target) || b.startsWith(a, target)) {
          result.add((commands[i], commands[j]));
        }
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
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        Oito2KeyChord.isModifierKey(event.logicalKey)) {
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

  /// The ids of the commands of the scopes between the focus and this
  /// one, which replace this scope's commands of the same id, even when
  /// they are disabled.
  Set<String> _overriddenIds() {
    final ids = <String>{};
    final focusContext = FocusManager.instance.primaryFocus?.context;
    var scope = focusContext == null ? null : _CommandScope.of(focusContext);
    while (scope != null && !identical(scope.owner, this)) {
      ids.addAll(scope.commands.map((command) => command.id));
      scope = scope.parent;
    }
    return ids;
  }

  /// Runs the command whose shortcut the pending chords plus [chord]
  /// complete, or keeps [chord] pending when it continues a longer
  /// shortcut, until [Oito2Commands.sequenceTimeout] passes.
  KeyEventResult _match(Oito2KeyChord chord) {
    final platform = _platform;
    final typing = _textFieldFocused();
    final sequence = Oito2Shortcut([..._pending, chord]);
    final overridden = _overriddenIds();
    final own = [
      for (final command in widget.commands)
        if (command.enabled &&
            !overridden.contains(command.id) &&
            command.shortcut != null &&
            (!typing || command.shortcut!.chords.first.hasCommandModifier))
          command,
    ];
    for (final command in own) {
      if (command.shortcut!.matches(sequence, platform)) {
        _reset();
        command.onInvoke();
        return KeyEventResult.handled;
      }
    }
    if (own.any((c) => c.shortcut!.startsWith(sequence, platform))) {
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
