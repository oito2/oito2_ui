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

import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_settings/oito2_ui_settings.dart';

void main() {
  group('iniValue', () {
    const kwinrc = '''
# KWin settings
[Desktops]
Number=4

[org.kde.kdecoration2]
BorderSize=Normal
ButtonsOnLeft = XIA
ButtonsOnRight=M
library=org.kde.breeze

[Windows][Rules]
ButtonsOnLeft=ignored
''';

    test('reads a key in its group and trims spaces', () {
      expect(
        Oito2ConfigParsers.iniValue(
          kwinrc,
          'org.kde.kdecoration2',
          'ButtonsOnLeft',
        ),
        'XIA',
      );
      expect(
        Oito2ConfigParsers.iniValue(
          kwinrc,
          'org.kde.kdecoration2',
          'ButtonsOnRight',
        ),
        'M',
      );
    });

    test('keeps groups apart and supports nested KDE groups', () {
      expect(Oito2ConfigParsers.iniValue(kwinrc, 'Desktops', 'Number'), '4');
      expect(
        Oito2ConfigParsers.iniValue(kwinrc, 'Windows][Rules', 'ButtonsOnLeft'),
        'ignored',
      );
    });

    test('returns null for missing groups, keys and comments', () {
      expect(Oito2ConfigParsers.iniValue(kwinrc, 'Nope', 'Number'), isNull);
      expect(
        Oito2ConfigParsers.iniValue(kwinrc, 'Desktops', 'Missing'),
        isNull,
      );
      expect(Oito2ConfigParsers.iniValue('', 'Desktops', 'Number'), isNull);
    });
  });

  group('xfconfProperty', () {
    const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="box_move" type="bool" value="false"/>
    <property name="button_layout" type="string" value="CHM|O"/>
    <property name="title_font" type="string" value="Sans &amp; Serif Bold 9"/>
  </property>
</channel>
''';

    test('reads a property value', () {
      expect(Oito2ConfigParsers.xfconfProperty(xml, 'button_layout'), 'CHM|O');
    });

    test('unescapes XML entities', () {
      expect(
        Oito2ConfigParsers.xfconfProperty(xml, 'title_font'),
        'Sans & Serif Bold 9',
      );
    });

    test('returns null for a missing property', () {
      expect(Oito2ConfigParsers.xfconfProperty(xml, 'missing'), isNull);
    });
  });

  test('cosmicBool parses true and false only', () {
    expect(Oito2ConfigParsers.cosmicBool('true\n'), isTrue);
    expect(Oito2ConfigParsers.cosmicBool(' false '), isFalse);
    expect(Oito2ConfigParsers.cosmicBool('maybe'), isNull);
  });

  test('kdeColor parses r,g,b triples', () {
    expect(Oito2ConfigParsers.kdeColor('61,174,233'), const Color(0xFF3DAEE9));
    expect(Oito2ConfigParsers.kdeColor(' 1, 2, 3 '), const Color(0xFF010203));
    expect(Oito2ConfigParsers.kdeColor('256,0,0'), isNull);
    expect(Oito2ConfigParsers.kdeColor('1,2'), isNull);
    expect(Oito2ConfigParsers.kdeColor('red'), isNull);
  });
}
