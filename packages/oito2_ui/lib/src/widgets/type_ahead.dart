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

/// Collects the characters typed for a type-ahead search into a prefix
/// that resets after a pause.
class TypeAheadBuffer {
  /// The pause after which the next character starts a new prefix.
  static const resetDelay = Duration(milliseconds: 600);

  String _typed = '';
  Timer? _timer;

  /// Returns whether [character], the character of a key event, can be
  /// typed into the buffer: it is not null, not whitespace and not a
  /// control character.
  static bool accepts(String? character) =>
      character != null &&
      character.trim().isNotEmpty &&
      character.codeUnitAt(0) >= 0x20;

  /// Adds [character] and returns the prefix to search for, and whether
  /// the search starts after the current item.
  ///
  /// Repeating the single character typed before keeps the prefix at that
  /// character, so each repeat moves to its next match. A search starts
  /// after the current item for the first character and for a repeat, and
  /// at the current item while a longer prefix is typed.
  ({String prefix, bool fromNext}) add(String character) {
    _timer?.cancel();
    _timer = Timer(resetDelay, () => _typed = '');
    final repeat = _typed == character;
    _typed = repeat ? character : _typed + character;
    return (prefix: _typed, fromNext: repeat || _typed.length == 1);
  }

  /// Stops the reset timer.
  void dispose() => _timer?.cancel();
}
