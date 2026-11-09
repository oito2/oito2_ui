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

// Writes the expected results of Oito2Format (byte sizes, compact numbers
// and relative times) in English and Brazilian Portuguese as a JSON
// fixture.

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'support.dart';

const byteCases = [
  0,
  1,
  999,
  1000,
  1023,
  1024,
  1536,
  999949,
  999950,
  999999,
  1000000,
  2500000,
  1048575,
  1048576,
  1073741824,
  -2000,
  123456789012,
  1999999999999999,
  5000000000000000000,
];

const compactCases = [
  0,
  7,
  999,
  1000,
  1234,
  12345,
  999999,
  1500000,
  -4321,
  2.5,
];

/// Offsets from now, in seconds, for the relative times.
const relativeCases = [
  0,
  -10,
  44,
  -45,
  -60,
  -89,
  -90,
  -180,
  2699,
  -2700,
  7200,
  -79199,
  -79200,
  -259200,
  -561600,
  -518400,
  -1209600,
  -2591999,
  -2592000,
  2678400,
  -5184000,
  -7776000,
  -31535999,
  -31536000,
  69120000,
];

Map<String, Object> export(Oito2Format format) {
  final now = DateTime.utc(2026, 10, 20, 12);
  return {
    'bytes': [
      for (final units in Oito2ByteUnits.values)
        for (final digits in [0, 1, 2])
          for (final value in byteCases)
            {
              'bytes': value,
              'units': units.name,
              'fractionDigits': digits,
              'result': format.bytes(
                value,
                units: units,
                fractionDigits: digits,
              ),
            },
    ],
    'compactNumber': [
      for (final value in compactCases)
        {'value': value, 'result': format.compactNumber(value)},
    ],
    'relativeTime': [
      for (final seconds in relativeCases)
        {
          'offsetSeconds': seconds,
          'result': format.relativeTime(
            now.add(Duration(seconds: seconds)),
            now: now,
          ),
        },
    ],
  };
}

void main() {
  test('exports the formatting helpers', () {
    final file = writeFixture('format.json', {
      'en': export(Oito2Format()),
      'pt-BR': export(
        Oito2Format(locale: 'pt_BR', strings: const Oito2LocalizationsPtBr()),
      ),
      'xx': export(Oito2Format(locale: 'xx')),
    });
    expect(file.existsSync(), isTrue);
  });
}
