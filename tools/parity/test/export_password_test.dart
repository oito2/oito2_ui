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

// Writes the level and hints Oito2PasswordStrength.estimate gives a fixed
// sample of passwords, with and without user inputs, as a JSON fixture.

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'support.dart';

/// Passwords rated without user inputs, covering every hint.
const samples = [
  '',
  'a',
  'abc',
  'Ab1!',
  'abcdefg',
  '123456',
  '12345678',
  'password',
  'Password1',
  'P@ssw0rd',
  'p4\$\$w0rd',
  'senha',
  'senha123',
  'Senha@2024',
  '!!Senha2024##',
  'iloveyou',
  'dragon',
  'monkey123!',
  'qwerty',
  'qwertyuiop',
  'asdfghjkl',
  'zxcvbnm123',
  'abcdefgh',
  'zyxwvuts',
  '987654321',
  'aaaaaaaa',
  'aaaaaaaaaaaaaaaa',
  'abababab',
  'abcabcabcabc',
  '1111111111',
  'montanha',
  'Montanha@77',
  'M0nt4nh4',
  'coração',
  'Coração2024!',
  'C0r@ç@o',
  'açaí',
  'São Paulo',
  'ÁÉÍÓÚáéíóú',
  'café com leite',
  'sunshine',
  'Sunshine!',
  'Tr0ub4dor&3',
  'correct horse battery staple',
  'Correct-Horse-Battery-Staple-42',
  'chuva forte no fim da tarde',
  'the quick brown fox jumps',
  '1987',
  '19/03/1987',
  '2024-11-24',
  '25121990',
  'nascido em 1990',
  'a1b2c3d4',
  'hello world',
  'helloworld2023',
  'Zx9#qL2!vB7\$',
  'k8Jq2vN7pX4m',
  'xK9#mP2\$vL5@nQ8&',
  'q7w!Rz',
  'GHJKLQWERTY',
  'mñöüß',
  '🔒🔑segredo',
  '密码密码密码',
  'Пароль2024',
  '        ',
];

/// The inputs the user-input samples are rated with: a name and an email.
const userInputs = ['Maria Silva', 'maria.silva@example.com'];

/// Passwords rated with [userInputs].
const userInputSamples = [
  'maria',
  'maria1990',
  'MariaSilva!',
  'silva@2024',
  'M4r1@S1lv4',
  'example123',
  'mariasilvaexample',
  'Correct-Horse-Battery-Staple-42',
  'Zx9#qL2!vB7\$',
  'montanha',
];

/// Returns the rating of [password] with [inputs] as a JSON object.
Map<String, Object> rate(String password, [List<String> inputs = const []]) {
  final strength = Oito2PasswordStrength.estimate(password, userInputs: inputs);
  return {
    'password': password,
    'userInputs': inputs,
    'level': strength.level,
    'hints': [for (final hint in strength.hints) hint.name],
  };
}

void main() {
  test('exports the password strength estimates', () {
    final file = writeFixture('password_strength.json', {
      'hints': [for (final hint in Oito2PasswordHint.values) hint.name],
      'samples': [
        for (final password in samples) rate(password),
        for (final password in userInputSamples) rate(password, userInputs),
      ],
    });
    expect(file.existsSync(), isTrue);
  });
}
