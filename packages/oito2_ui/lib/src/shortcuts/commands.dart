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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  /// Runs the command.
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

  /// Whether the command can run now.
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

  /// The enabled commands available at [context]: those of every
  /// enclosing scope, the innermost first, with inner commands replacing
  /// outer ones of the same id.
  static List<Oito2Command> availableAt(BuildContext context) {
    final result = <Oito2Command>[];
    final ids = <String>{};
    var scope =
        context.getElementForInheritedWidgetOfExactType<_CommandScope>()?.widget
            as _CommandScope?;
    while (scope != null) {
      for (final command in scope.commands) {
        if (command.enabled && ids.add(command.id)) result.add(command);
      }
      scope = scope.parent;
    }
    return result;
  }

  /// The pairs of [commands] whose shortcuts clash on [platform]: the same
  /// shortcut, or one that is a prefix of another (the longer one could
  /// never run).
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

  @override
  void initState() {
    super.initState();
    assert(() {
      final clashes = Oito2Commands.conflicts(widget.commands);
      if (clashes.isNotEmpty) {
        final (a, b) = clashes.first;
        throw FlutterError(
          'The shortcuts of the commands "${a.id}" and "${b.id}" clash.',
        );
      }
      return true;
    }());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reset() {
    _timer?.cancel();
    _pending.clear();
  }

  static bool _textFieldFocused() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    return context.widget is EditableText ||
        context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

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

  KeyEventResult _match(Oito2KeyChord chord) {
    final platform = defaultTargetPlatform;
    final typing = _textFieldFocused();
    final sequence = Oito2Shortcut([..._pending, chord]);
    final own = [
      for (final command in widget.commands)
        if (command.enabled &&
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
    final parent =
        context.getElementForInheritedWidgetOfExactType<_CommandScope>()?.widget
            as _CommandScope?;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: _CommandScope(
        commands: widget.commands,
        parent: parent,
        child: widget.child,
      ),
    );
  }
}

class _CommandScope extends InheritedWidget {
  const _CommandScope({
    required this.commands,
    required this.parent,
    required super.child,
  });

  final List<Oito2Command> commands;
  final _CommandScope? parent;

  @override
  bool updateShouldNotify(_CommandScope oldWidget) =>
      !identical(commands, oldWidget.commands) || parent != oldWidget.parent;
}
