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

// Writes the QR code modules oito2_ui_extras encodes for fixed texts at
// every error level, as a JSON fixture for the sibling implementations.

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import 'support.dart';

/// Texts of several lengths and character sets: digits, upper-case
/// alphanumerics, a link, accented and non-Latin text, and a long text.
const texts = [
  '0123456789',
  'HELLO WORLD',
  'https://github.com/oito2/oito2_uikit',
  'Olá, coração! Ação não é ilusão.',
  'こんにちは 🌍',
  'The quick brown fox jumps over the lazy dog. 1234567890 — '
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua.',
];

void main() {
  test('exports the QR code modules', () {
    final file = writeFixture('qr.json', {
      'codes': [
        for (final text in texts)
          for (final level in Oito2QrErrorLevel.values)
            () {
              final qr = oito2QrModules(text, errorLevel: level);
              return {
                'data': text,
                'errorLevel': level.name,
                'moduleCount': qr.moduleCount,
                // One string per row, with 1 for a dark module.
                'rows': [
                  for (final row in qr.modules)
                    row.map((dark) => dark ? '1' : '0').join(),
                ],
              };
            }(),
      ],
      'tooLong': () {
        try {
          oito2QrModules('x' * 3000, errorLevel: Oito2QrErrorLevel.high);
          return false;
        } on ArgumentError {
          return true;
        }
      }(),
    });
    expect(file.existsSync(), isTrue);
  });
}
