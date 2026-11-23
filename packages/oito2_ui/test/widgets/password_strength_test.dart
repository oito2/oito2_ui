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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// Rates [password] with [userInputs].
Oito2PasswordStrength _rate(
  String password, {
  List<String> userInputs = const [],
}) => Oito2PasswordStrength.estimate(password, userInputs: userInputs);

void main() {
  group('Oito2PasswordStrength.estimate', () {
    test('an empty password is level 0 without hints', () {
      expect(_rate(''), const Oito2PasswordStrength(0));
    });

    test('rates known samples', () {
      expect(_rate('password').level, 0);
      expect(_rate('123456').level, 0);
      expect(_rate('kdjfhqpw').level, 2);
      expect(_rate('kdjfhqpwmz12').level, 3);
      expect(_rate('hJ7&kL9@pQ2!').level, 4);
      expect(
        _rate('correct horse battery staple').level,
        greaterThanOrEqualTo(3),
      );
    });

    test('a strong password has no hints', () {
      expect(_rate('hJ7&kL9@pQ2!').hints, isEmpty);
    });

    test('caps passwords shorter than 8 characters at weak', () {
      final strength = _rate(r'xK9#mP2');
      expect(strength.level, 1);
      expect(strength.hints.first, Oito2PasswordHint.addLength);
    });

    test('finds common passwords, also with look-alikes and affixes', () {
      for (final password in ['password', 'P@ssw0rd', 'password123!']) {
        final strength = _rate(password);
        expect(strength.level, 0, reason: password);
        expect(
          strength.hints.first,
          Oito2PasswordHint.avoidCommon,
          reason: password,
        );
      }
    });

    test(
      'finds common passwords with leading affixes and both "1" readings',
      () {
        for (final password in [
          'Senha@2024',
          '4dmin',
          '#123mudar',
          'F1amengo10',
        ]) {
          final strength = _rate(password);
          expect(strength.level, 0, reason: password);
          expect(
            strength.hints.first,
            Oito2PasswordHint.avoidCommon,
            reason: password,
          );
        }
      },
    );

    test('a common word with short affixes is at most weak', () {
      for (final password in [
        'Montanha@77',
        'C0rrect!1',
        '!!Borboleta2025',
        'Ônibus#12',
      ]) {
        final strength = _rate(password);
        expect(strength.level, lessThanOrEqualTo(1), reason: password);
        expect(
          strength.hints,
          contains(Oito2PasswordHint.avoidWords),
          reason: password,
        );
      }
      expect(_rate('Tr0ub4dor&3').level, lessThanOrEqualTo(2));
    });

    test('common words inside a password cost little', () {
      final strength = _rate('gatoxkq#chuva');
      expect(strength.level, lessThanOrEqualTo(2));
      expect(strength.hints, contains(Oito2PasswordHint.avoidWords));
      expect(_rate('hJ7&kL9@pQ2!').hints, isEmpty);
    });

    test('random 16-character passwords stay strong', () {
      for (final password in [
        'q8Zr2LmV9xKp4TwB',
        'v#7Nf!2kQz@9Lx^3',
        'mQ9w2ZtR8kL4xV7p',
        'Xk3!pL8@zQ5#wN2&',
      ]) {
        expect(_rate(password).level, 4, reason: password);
      }
    });

    test('suggests avoiding repeats', () {
      expect(_rate('aaaaaaaaaaaa').hints.first, Oito2PasswordHint.avoidRepeats);
      expect(_rate('xyqxyqxyqxyq').hints.first, Oito2PasswordHint.avoidRepeats);
    });

    test('suggests avoiding sequences and keyboard runs', () {
      expect(_rate('abcdefgh').hints.first, Oito2PasswordHint.avoidSequences);
      expect(_rate('98765432').hints.first, Oito2PasswordHint.avoidSequences);
      expect(_rate('asdfghjk').hints.first, Oito2PasswordHint.avoidSequences);
    });

    test('suggests avoiding dates and years', () {
      expect(_rate('14/03/1990').hints.first, Oito2PasswordHint.avoidDates);
      expect(_rate('zkq1987wpx').hints, contains(Oito2PasswordHint.avoidDates));
    });

    test('suggests avoiding the user inputs', () {
      final strength = _rate(
        'velasco_rocks',
        userInputs: ['carlos.velasco@example.com'],
      );
      expect(strength.hints.first, Oito2PasswordHint.avoidPersonalInfo);
      expect(
        _rate('velasco_rocks').hints,
        isNot(contains(Oito2PasswordHint.avoidPersonalInfo)),
      );
    });

    test('suggests length and mixing kinds of characters', () {
      expect(_rate('kdjfhqpw').hints, [
        Oito2PasswordHint.addLength,
        Oito2PasswordHint.mixCharacters,
      ]);
    });

    test('names levels and hints in both languages', () {
      const en = Oito2LocalizationsEn();
      const pt = Oito2LocalizationsPtBr();
      expect(
        [for (var l = 0; l <= 4; l++) Oito2PasswordStrength(l).labelIn(en)],
        ['Very weak', 'Weak', 'Fair', 'Good', 'Strong'],
      );
      expect(const Oito2PasswordStrength(2).labelIn(pt), 'Razoável');
      for (final hint in Oito2PasswordHint.values) {
        expect(hint.labelIn(en), isNotEmpty);
        expect(hint.labelIn(pt), isNot(hint.labelIn(en)));
      }
      expect(Oito2PasswordHint.addLength.labelIn(en), 'Add more characters');
      expect(Oito2PasswordHint.avoidWords.labelIn(en), 'Avoid common words');
      expect(Oito2PasswordHint.avoidWords.labelIn(pt), 'Evite palavras comuns');
    });
  });

  group('Oito2PasswordField strength', () {
    testWidgets('shows no meter unless asked', (tester) async {
      await pumpOito2(tester, const Oito2PasswordField());
      await tester.enterText(find.byType(TextField), 'password');
      await tester.pump();
      expect(find.text('Very weak'), findsNothing);
    });

    testWidgets('the meter follows the text and hides when empty', (
      tester,
    ) async {
      await pumpOito2(tester, const Oito2PasswordField(showStrength: true));
      expect(find.text('Very weak'), findsNothing);
      await tester.enterText(find.byType(TextField), 'password');
      await tester.pump();
      expect(find.text('Very weak'), findsOneWidget);
      expect(find.text('Avoid common passwords'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'hJ7&kL9@pQ2!');
      await tester.pump();
      expect(find.text('Strong'), findsOneWidget);
      expect(find.text('Avoid common passwords'), findsNothing);
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('Strong'), findsNothing);
    });

    testWidgets('the level is a live region read with its label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, const Oito2PasswordField(showStrength: true));
      await tester.enterText(find.byType(TextField), 'kdjfhqpw');
      await tester.pump();
      final node = tester.getSemantics(
        find.bySemanticsLabel('Password strength: Fair'),
      );
      expect(node.flagsCollection.isLiveRegion, isTrue);
      // A new key at the same level keeps the same announcement.
      await tester.enterText(find.byType(TextField), 'kdjfhqpwz');
      await tester.pump();
      expect(find.bySemanticsLabel('Password strength: Fair'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('uses a custom estimator and the user inputs', (tester) async {
      await pumpOito2(
        tester,
        Oito2PasswordField(
          showStrength: true,
          strengthEstimator: (text) => Oito2PasswordStrength(
            text.length >= 3 ? 3 : 0,
            hints: const [Oito2PasswordHint.avoidDates],
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Avoid dates'), findsOneWidget);

      await pumpOito2(
        tester,
        const Oito2PasswordField(
          showStrength: true,
          strengthUserInputs: ['Ana Souza'],
        ),
      );
      await tester.enterText(find.byType(TextField), 'souza#Tree9');
      await tester.pump();
      expect(find.text('Avoid your name or email'), findsOneWidget);
    });

    testWidgets('rates the text of a given controller', (tester) async {
      final controller = TextEditingController(text: 'password');
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Oito2PasswordField(controller: controller, showStrength: true),
      );
      expect(find.text('Very weak'), findsOneWidget);
      controller.text = 'hJ7&kL9@pQ2!';
      await tester.pump();
      expect(find.text('Strong'), findsOneWidget);
    });

    testWidgets('tints the segments by level', (tester) async {
      await pumpOito2(tester, const Oito2PasswordField(showStrength: true));
      await tester.enterText(find.byType(TextField), 'hJ7&kL9@pQ2!');
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Oito2PasswordField));
      final success = semanticColors(context).success;
      final segments = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((c) => (c.decoration! as BoxDecoration).color)
          .toList();
      expect(segments, List.filled(4, success));
    });
  });
}

/// Returns the semantic colors of the theme of [context].
Oito2SemanticColors semanticColors(BuildContext context) =>
    Oito2SemanticColors.maybeOf(context)!;
