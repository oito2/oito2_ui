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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether [platform] uses Command, rather than Control, as the primary
/// shortcut modifier: macOS and iOS.
bool oito2UsesCommandKey(TargetPlatform platform) =>
    platform == TargetPlatform.macOS || platform == TargetPlatform.iOS;

/// One key press of a shortcut: a [key] with modifiers.
///
/// [primary] stands for the platform's main shortcut modifier: Command on
/// macOS and iOS, Control elsewhere. Shortcuts written with it, such as
/// `Mod+K`, read naturally on every platform.
@immutable
class Oito2KeyChord {
  /// Creates a chord.
  const Oito2KeyChord(
    this.key, {
    this.primary = false,
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  /// The chord pressed by [event] with the modifiers held now.
  factory Oito2KeyChord.fromEvent(KeyEvent event) {
    final keyboard = HardwareKeyboard.instance;
    return Oito2KeyChord(
      _normalized(event.logicalKey),
      control: keyboard.isControlPressed,
      shift: keyboard.isShiftPressed,
      alt: keyboard.isAltPressed,
      meta: keyboard.isMetaPressed,
    );
  }

  /// The key, without modifiers.
  final LogicalKeyboardKey key;

  /// Whether the platform's primary modifier is held.
  final bool primary;

  /// Whether Control is held.
  final bool control;

  /// Whether Shift is held.
  final bool shift;

  /// Whether Alt (Option on Apple keyboards) is held.
  final bool alt;

  /// Whether Meta (Command on Apple keyboards, Super elsewhere) is held.
  final bool meta;

  /// Whether the chord holds a modifier other than Shift, so it can't be
  /// typed as text.
  bool get hasCommandModifier => primary || control || alt || meta;

  /// The chord with [primary] turned into Command or Control for
  /// [platform].
  Oito2KeyChord resolve(TargetPlatform platform) {
    if (!primary) return this;
    final apple = oito2UsesCommandKey(platform);
    return Oito2KeyChord(
      key,
      control: control || !apple,
      shift: shift,
      alt: alt,
      meta: meta || apple,
    );
  }

  /// Whether this chord, resolved for [platform], is [other].
  bool matches(Oito2KeyChord other, TargetPlatform platform) =>
      resolve(platform) == other.resolve(platform);

  /// The display parts of the chord on [platform]: the modifier names or
  /// symbols, in the platform order, then the key.
  List<String> parts(TargetPlatform platform) {
    final chord = resolve(platform);
    final apple = oito2UsesCommandKey(platform);
    return [
      if (chord.control) apple ? '⌃' : 'Ctrl',
      if (chord.alt) apple ? '⌥' : 'Alt',
      if (chord.shift) apple ? '⇧' : 'Shift',
      if (chord.meta) apple ? '⌘' : 'Super',
      keyLabel(key, platform),
    ];
  }

  /// The chord as text on [platform], such as `Ctrl+Shift+K` or `⇧⌘K`.
  String label(TargetPlatform platform) =>
      parts(platform).join(oito2UsesCommandKey(platform) ? '' : '+');

  /// The display name of [key] on [platform].
  static String keyLabel(LogicalKeyboardKey key, TargetPlatform platform) {
    final special = _specialLabels[key];
    if (special != null) {
      return oito2UsesCommandKey(platform) ? special.$2 : special.$1;
    }
    final label = key.keyLabel;
    return label.length == 1 ? label.toUpperCase() : label;
  }

  /// The labels of keys named differently than their key label: the text
  /// form and the Apple symbol.
  static final Map<LogicalKeyboardKey, (String, String)> _specialLabels = {
    LogicalKeyboardKey.enter: ('Enter', '↩'),
    LogicalKeyboardKey.escape: ('Esc', '⎋'),
    LogicalKeyboardKey.backspace: ('Backspace', '⌫'),
    LogicalKeyboardKey.delete: ('Delete', '⌦'),
    LogicalKeyboardKey.tab: ('Tab', '⇥'),
    LogicalKeyboardKey.space: ('Space', 'Space'),
    LogicalKeyboardKey.arrowUp: ('↑', '↑'),
    LogicalKeyboardKey.arrowDown: ('↓', '↓'),
    LogicalKeyboardKey.arrowLeft: ('←', '←'),
    LogicalKeyboardKey.arrowRight: ('→', '→'),
    LogicalKeyboardKey.pageUp: ('PgUp', '⇞'),
    LogicalKeyboardKey.pageDown: ('PgDn', '⇟'),
    LogicalKeyboardKey.home: ('Home', '↖'),
    LogicalKeyboardKey.end: ('End', '↘'),
  };

  static final Map<LogicalKeyboardKey, LogicalKeyboardKey> _sided = {
    LogicalKeyboardKey.numpadEnter: LogicalKeyboardKey.enter,
  };

  static LogicalKeyboardKey _normalized(LogicalKeyboardKey key) =>
      _sided[key] ?? key;

  /// Whether [key] is a modifier key on its own.
  static bool isModifierKey(LogicalKeyboardKey key) =>
      LogicalKeyboardKey.collapseSynonyms({key}).any(_modifierKeys.contains) ||
      key == LogicalKeyboardKey.capsLock ||
      key == LogicalKeyboardKey.fn;

  static final Set<LogicalKeyboardKey> _modifierKeys = {
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.meta,
  };

  @override
  bool operator ==(Object other) =>
      other is Oito2KeyChord &&
      other.key == key &&
      other.primary == primary &&
      other.control == control &&
      other.shift == shift &&
      other.alt == alt &&
      other.meta == meta;

  @override
  int get hashCode => Object.hash(key, primary, control, shift, alt, meta);

  @override
  String toString() => label(TargetPlatform.linux);
}

/// A keyboard shortcut: one [Oito2KeyChord], or a sequence of chords
/// pressed one after the other, such as `G` then `H`.
@immutable
class Oito2Shortcut {
  /// Creates a shortcut from [chords].
  const Oito2Shortcut(this.chords) : assert(chords.length > 0);

  /// A single-chord shortcut of [key] with the platform's primary modifier
  /// (Command on Apple platforms, Control elsewhere).
  Oito2Shortcut.primary(
    LogicalKeyboardKey key, {
    bool shift = false,
    bool alt = false,
  }) : chords = [Oito2KeyChord(key, primary: true, shift: shift, alt: alt)];

  /// Parses a shortcut such as `Mod+K`, `Ctrl+Shift+P`, `Alt+Enter` or the
  /// sequence `G H`: chords are separated by spaces and keys within a
  /// chord by `+`.
  ///
  /// Modifier names: `Mod`/`Primary` (Command on Apple platforms, Control
  /// elsewhere), `Ctrl`/`Control`, `Shift`, `Alt`/`Option`,
  /// `Meta`/`Cmd`/`Command`/`Super`. Keys: letters, digits, `F1`–`F12`,
  /// `Enter`, `Esc`, `Space`, `Tab`, `Backspace`, `Delete`, `Up`, `Down`,
  /// `Left`, `Right`, `Home`, `End`, `PageUp`, `PageDown` and the
  /// punctuation `,` `.` `/` `;` `-` `=` `[` `]`.
  factory Oito2Shortcut.parse(String text) {
    final chords = <Oito2KeyChord>[];
    for (final chord in text.trim().split(RegExp(r'\s+'))) {
      final parts = chord.split('+');
      final keyName = parts.removeLast();
      final names = {for (final p in parts) p.toLowerCase()};
      final key = _keyNamed(keyName);
      if (key == null) throw FormatException('Unknown key "$keyName"', text);
      const known = {
        'mod',
        'primary',
        'ctrl',
        'control',
        'shift',
        'alt',
        'option',
        'meta',
        'cmd',
        'command',
        'super',
      };
      final unknown = names.difference(known);
      if (unknown.isNotEmpty) {
        throw FormatException('Unknown modifier "${unknown.first}"', text);
      }
      chords.add(
        Oito2KeyChord(
          key,
          primary: names.contains('mod') || names.contains('primary'),
          control: names.contains('ctrl') || names.contains('control'),
          shift: names.contains('shift'),
          alt: names.contains('alt') || names.contains('option'),
          meta: names.any({'meta', 'cmd', 'command', 'super'}.contains),
        ),
      );
    }
    return Oito2Shortcut(chords);
  }

  static LogicalKeyboardKey? _keyNamed(String name) {
    final lower = name.toLowerCase();
    if (RegExp(r'^[a-z]$').hasMatch(lower)) {
      return LogicalKeyboardKey(
        LogicalKeyboardKey.keyA.keyId + lower.codeUnitAt(0) - 0x61,
      );
    }
    if (RegExp(r'^[0-9]$').hasMatch(lower)) {
      return LogicalKeyboardKey(
        LogicalKeyboardKey.digit0.keyId + lower.codeUnitAt(0) - 0x30,
      );
    }
    final function = RegExp(r'^f([0-9]{1,2})$').firstMatch(lower);
    if (function != null) {
      final n = int.parse(function.group(1)!);
      if (n >= 1 && n <= 12) {
        return LogicalKeyboardKey(LogicalKeyboardKey.f1.keyId + n - 1);
      }
    }
    return const {
      'enter': LogicalKeyboardKey.enter,
      'return': LogicalKeyboardKey.enter,
      'esc': LogicalKeyboardKey.escape,
      'escape': LogicalKeyboardKey.escape,
      'space': LogicalKeyboardKey.space,
      'tab': LogicalKeyboardKey.tab,
      'backspace': LogicalKeyboardKey.backspace,
      'delete': LogicalKeyboardKey.delete,
      'up': LogicalKeyboardKey.arrowUp,
      'down': LogicalKeyboardKey.arrowDown,
      'left': LogicalKeyboardKey.arrowLeft,
      'right': LogicalKeyboardKey.arrowRight,
      'home': LogicalKeyboardKey.home,
      'end': LogicalKeyboardKey.end,
      'pageup': LogicalKeyboardKey.pageUp,
      'pagedown': LogicalKeyboardKey.pageDown,
      ',': LogicalKeyboardKey.comma,
      '.': LogicalKeyboardKey.period,
      '/': LogicalKeyboardKey.slash,
      ';': LogicalKeyboardKey.semicolon,
      '-': LogicalKeyboardKey.minus,
      '=': LogicalKeyboardKey.equal,
      '[': LogicalKeyboardKey.bracketLeft,
      ']': LogicalKeyboardKey.bracketRight,
    }[lower];
  }

  /// The chords, pressed in order.
  final List<Oito2KeyChord> chords;

  /// Whether every chord, resolved for [platform], matches [other]'s.
  bool matches(Oito2Shortcut other, TargetPlatform platform) =>
      chords.length == other.chords.length && startsWith(other, platform);

  /// Whether this shortcut begins with every chord of [prefix], resolved
  /// for [platform].
  bool startsWith(Oito2Shortcut prefix, TargetPlatform platform) {
    if (prefix.chords.length > chords.length) return false;
    for (var i = 0; i < prefix.chords.length; i++) {
      if (!chords[i].matches(prefix.chords[i], platform)) return false;
    }
    return true;
  }

  /// The shortcut as text on [platform], such as `Ctrl+K` or `G H`.
  String label(TargetPlatform platform) =>
      [for (final chord in chords) chord.label(platform)].join(' ');

  @override
  bool operator ==(Object other) =>
      other is Oito2Shortcut && listEquals(other.chords, chords);

  @override
  int get hashCode => Object.hashAll(chords);

  @override
  String toString() => label(TargetPlatform.linux);
}
