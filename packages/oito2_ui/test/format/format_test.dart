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

void main() {
  final en = Oito2Format();
  final pt = Oito2Format(
    locale: 'pt_BR',
    strings: const Oito2LocalizationsPtBr(),
  );

  group('bytes', () {
    test('uses SI units with locale decimals', () {
      expect(en.bytes(0), '0 B');
      expect(en.bytes(999), '999 B');
      expect(en.bytes(1536), '1.5 kB');
      expect(en.bytes(2500000), '2.5 MB');
      expect(pt.bytes(1536), '1,5 kB');
      expect(en.bytes(-2000), '-2 kB');
      // Rounding that reaches the base moves to the next unit.
      expect(en.bytes(999999), '1 MB');
      expect(en.bytes(999949), '999.9 kB');
    });

    test('uses IEC units on request', () {
      expect(en.bytes(1024, units: Oito2ByteUnits.iec), '1 KiB');
      expect(en.bytes(1048575, units: Oito2ByteUnits.iec), '1 MiB');
      expect(
        en.bytes(1536 * 1024, units: Oito2ByteUnits.iec, fractionDigits: 2),
        '1.5 MiB',
      );
    });
  });

  test('compact numbers follow the locale', () {
    expect(en.compactNumber(1234), '1.23K');
    // intl separates the Portuguese suffix with a no-break space.
    expect(pt.compactNumber(1234), '1,23\u00A0mil');
  });

  group('relative time', () {
    final now = DateTime(2026, 10, 20, 12);

    test('six and a half days read as a week', () {
      expect(
        en.relativeTime(
          now.subtract(const Duration(days: 6, hours: 12)),
          now: now,
        ),
        en.relativeTime(now.subtract(const Duration(days: 7)), now: now),
      );
      expect(
        en.relativeTime(now.subtract(const Duration(days: 6)), now: now),
        isNot(en.relativeTime(now.subtract(const Duration(days: 7)), now: now)),
      );
    });

    test('picks the largest fitting unit', () {
      expect(
        en.relativeTime(now.subtract(const Duration(seconds: 10)), now: now),
        'now',
      );
      expect(
        en.relativeTime(now.subtract(const Duration(minutes: 1)), now: now),
        '1 minute ago',
      );
      expect(
        en.relativeTime(now.subtract(const Duration(minutes: 3)), now: now),
        '3 minutes ago',
      );
      expect(
        en.relativeTime(now.add(const Duration(hours: 2)), now: now),
        'in 2 hours',
      );
      expect(
        en.relativeTime(now.subtract(const Duration(days: 3)), now: now),
        '3 days ago',
      );
      expect(
        en.relativeTime(now.subtract(const Duration(days: 14)), now: now),
        '2 weeks ago',
      );
      expect(
        en.relativeTime(now.subtract(const Duration(days: 90)), now: now),
        '3 months ago',
      );
      expect(
        en.relativeTime(now.add(const Duration(days: 800)), now: now),
        'in 2 years',
      );
    });

    test('is localized', () {
      expect(
        pt.relativeTime(now.subtract(const Duration(minutes: 3)), now: now),
        'há 3 minutos',
      );
      expect(
        pt.relativeTime(now.add(const Duration(days: 31)), now: now),
        'em 1 mês',
      );
      expect(
        pt.relativeTime(now.subtract(const Duration(days: 60)), now: now),
        'há 2 meses',
      );
      expect(pt.relativeTime(now, now: now), 'agora');
    });
  });

  test('unknown locales fall back to English numbers', () {
    expect(Oito2Format(locale: 'xx').bytes(1500), '1.5 kB');
  });

  testWidgets('of takes the locale and strings from the context', (
    tester,
  ) async {
    late Oito2Format format;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('pt', 'BR'),
        delegates: const [
          Oito2Localizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            format = Oito2Format.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(format.bytes(1536), '1,5 kB');
    expect(format.strings, isA<Oito2LocalizationsPtBr>());
  });

  group('Oito2HighlightedText', () {
    test('matches every word ignoring case and accents', () {
      final ranges = Oito2HighlightedText.matches(
        'Configurações de ação',
        'acao CONFIG',
      );
      expect(ranges, const [
        TextRange(start: 0, end: 6),
        TextRange(start: 17, end: 21),
      ]);
    });

    test('matches decomposed accents, ß and dotted capitals in place', () {
      // "ação" with combining accents, as macOS stores file names.
      const decomposed = 'ac\u0327a\u0303o';
      expect(Oito2HighlightedText.matches(decomposed, 'acao'), const [
        TextRange(start: 0, end: 6),
      ]);
      expect(Oito2HighlightedText.matches('Straße', 'strasse'), const [
        TextRange(start: 0, end: 6),
      ]);
      expect(Oito2HighlightedText.matches('İstanbul', 'stan'), const [
        TextRange(start: 1, end: 5),
      ]);
    });

    test('matches several queries, phrases, case and whole words', () {
      const text = 'Ark UI builds UI kits; the ark sails';
      expect(
        Oito2HighlightedText.matches(text, 'ark', queries: ['kits']),
        const [
          TextRange(start: 0, end: 3),
          TextRange(start: 17, end: 21),
          TextRange(start: 27, end: 30),
        ],
      );
      expect(
        Oito2HighlightedText.matches(text, 'ark', ignoreCase: false),
        const [TextRange(start: 27, end: 30)],
      );
      expect(Oito2HighlightedText.matches(text, 'ark', matchAll: false), const [
        TextRange(start: 0, end: 3),
      ]);
      expect(Oito2HighlightedText.matches(text, 'ui', wholeWords: true), const [
        TextRange(start: 4, end: 6),
        TextRange(start: 14, end: 16),
      ]);
      expect(
        Oito2HighlightedText.matches(text, 'build', wholeWords: true),
        isEmpty,
      );
      expect(
        Oito2HighlightedText.matches(text, 'ui kits', splitWords: false),
        const [TextRange(start: 14, end: 21)],
      );
    });

    test('merges overlapping matches', () {
      expect(Oito2HighlightedText.matches('banana', 'ana nan'), const [
        TextRange(start: 1, end: 6),
      ]);
      expect(Oito2HighlightedText.matches('text', ''), isEmpty);
    });

    testWidgets('renders the matches in the highlight style', (tester) async {
      await pumpOito2(
        tester,
        const Oito2HighlightedText('Show hidden files', query: 'hid'),
      );
      final text = tester.widget<RichText>(
        find.descendant(
          of: find.byType(Oito2HighlightedText),
          matching: find.byType(RichText),
        ),
      );
      final spans = (text.text as TextSpan).children!.first as TextSpan;
      final children = spans.children!.cast<TextSpan>();
      expect([for (final s in children) s.text], ['Show ', 'hid', 'den files']);
      expect(children[1].style?.fontWeight, FontWeight.w700);
    });
  });

  group('Oito2Swap', () {
    testWidgets('shows on or off and animates between them', (tester) async {
      var swapped = false;
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => GestureDetector(
            onTap: () => setState(() => swapped = !swapped),
            child: Oito2Swap(
              swapped: swapped,
              effect: Oito2SwapEffect.rotate,
              off: const Icon(LucideIcons.copy),
              on: const Icon(LucideIcons.check),
            ),
          ),
        ),
      );
      expect(find.byIcon(LucideIcons.copy), findsOneWidget);
      await tester.tap(find.byType(Oito2Swap));
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
      expect(find.byIcon(LucideIcons.copy), findsNothing);
    });

    testWidgets('changes instantly when animations are disabled', (
      tester,
    ) async {
      for (final swapped in [false, true]) {
        await pumpOito2(
          tester,
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Oito2Swap(
              swapped: swapped,
              off: const Text('off'),
              on: const Text('on'),
            ),
          ),
        );
      }
      await tester.pump();
      expect(find.text('on'), findsOneWidget);
      expect(find.text('off'), findsNothing);
    });
  });
}
