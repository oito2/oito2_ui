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

/// Accented and special lowercase Latin letters mapped to their plain
/// ASCII spelling.
const _accents = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'ç': 'c',
  'ć': 'c',
  'č': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ę': 'e',
  'ě': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'ñ': 'n',
  'ń': 'n',
  'ň': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ů': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ś': 's',
  'š': 's',
  'ź': 'z',
  'ż': 'z',
  'ž': 'z',
  'ł': 'l',
  'ř': 'r',
  'ť': 't',
  'ď': 'd',
  'ğ': 'g',
  'ı': 'i',
  'ß': 'ss',
  'æ': 'ae',
  'œ': 'oe',
};

/// Returns [text] in lower case without the accents of Latin letters, with
/// the combining accents of decomposed text removed, and with `ß`, `æ` and
/// `œ` spelled out.
///
/// Used to compare and search text ignoring case and accents, such as
/// "Ação" matching "acao". [foldTextWithOffsets] also maps the result back
/// to [text].
String foldText(String text) => foldTextWithOffsets(text).folded;

/// Folds [text] like [foldText] and returns the folded string with the
/// index in [text] of each folded character: `starts[i]` is where the
/// character that produced `folded[i]` begins, and a final entry holds
/// `text.length`.
///
/// A folded range `start..end` covers `starts[start]..starts[end]` of
/// [text], with the combining accents that follow it.
({String folded, List<int> starts}) foldTextWithOffsets(String text) {
  final buffer = StringBuffer();
  final starts = <int>[];
  for (var i = 0; i < text.length; i++) {
    for (final unit in text[i].toLowerCase().split('')) {
      final code = unit.codeUnitAt(0);
      // Combining diacritical marks.
      if (code >= 0x0300 && code <= 0x036F) continue;
      final folded = _accents[unit] ?? unit;
      buffer.write(folded);
      for (var k = 0; k < folded.length; k++) {
        starts.add(i);
      }
    }
  }
  starts.add(text.length);
  return (folded: buffer.toString(), starts: starts);
}
