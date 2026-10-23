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

/// Pumps [child] under a [Localizations] for [locale], with the
/// [Oito2Localizations] delegate only when [withDelegate] is true.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('pt', 'BR'),
  bool withDelegate = true,
}) {
  return tester.pumpWidget(
    Localizations(
      locale: locale,
      delegates: [
        if (withDelegate) Oito2Localizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      child: Theme(
        data: Oito2Theme.light(),
        child: Material(child: child),
      ),
    ),
  );
}

void main() {
  group('Oito2Localizations', () {
    const all = [Oito2LocalizationsEn(), Oito2LocalizationsPtBr()];

    test('every locale has every string', () {
      for (final l10n in all) {
        for (final value in [
          l10n.minimizeWindow,
          l10n.maximizeWindow,
          l10n.restoreWindow,
          l10n.closeWindow,
          l10n.resizePane,
          l10n.moreOptions,
          l10n.scrollBack,
          l10n.scrollForward,
          l10n.pageOf(2, 5),
          l10n.partOf(1, 3),
        ]) {
          expect(value, isNotEmpty, reason: l10n.localeName);
        }
      }
    });

    test('formats the counted labels', () {
      expect(const Oito2LocalizationsEn().pageOf(2, 5), 'Page 2 of 5');
      expect(const Oito2LocalizationsPtBr().pageOf(2, 5), 'Página 2 de 5');
      expect(const Oito2LocalizationsEn().partOf(1, 3), 'Part 1 of 3');
      expect(const Oito2LocalizationsPtBr().partOf(1, 3), 'Parte 1 de 3');
    });

    test('forLocale picks Portuguese for any pt locale', () {
      expect(
        Oito2Localizations.forLocale(const Locale('pt')),
        isA<Oito2LocalizationsPtBr>(),
      );
      expect(
        Oito2Localizations.forLocale(const Locale('pt', 'PT')),
        isA<Oito2LocalizationsPtBr>(),
      );
      expect(
        Oito2Localizations.forLocale(const Locale('en', 'US')),
        isA<Oito2LocalizationsEn>(),
      );
    });

    test('the delegate supports en and pt and lists both locales', () {
      const delegate = Oito2Localizations.delegate;
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('pt', 'BR')), isTrue);
      expect(delegate.isSupported(const Locale('de')), isFalse);
      expect(Oito2Localizations.supportedLocales, const [
        Locale('en'),
        Locale('pt', 'BR'),
      ]);
    });

    testWidgets('of falls back to English without the delegate', (
      tester,
    ) async {
      late BuildContext context;
      await _pump(
        tester,
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
        withDelegate: false,
      );
      expect(Oito2Localizations.maybeOf(context), isNull);
      expect(Oito2Localizations.of(context), isA<Oito2LocalizationsEn>());
    });
  });

  group('widgets use the localized labels', () {
    testWidgets('page indicator', (tester) async {
      await _pump(tester, const Oito2PageIndicator(length: 3, page: 0));
      expect(find.bySemanticsLabel('Página 1 de 3'), findsOneWidget);
    });

    testWidgets('page indicator keeps an explicit label', (tester) async {
      await _pump(
        tester,
        Oito2PageIndicator(
          length: 3,
          page: 0,
          pageLabel: (page, length) => 'Slide $page',
        ),
      );
      expect(find.bySemanticsLabel('Slide 1'), findsOneWidget);
    });

    testWidgets('split button', (tester) async {
      await _pump(
        tester,
        Oito2SplitButton(
          onPressed: () {},
          menuChildren: const [],
          child: const Text('Save'),
        ),
      );
      expect(find.bySemanticsLabel('Mais opções'), findsOneWidget);
    });

    testWidgets('paned view', (tester) async {
      await _pump(
        tester,
        const Oito2PanedView(pane: SizedBox(), page: SizedBox()),
      );
      expect(find.bySemanticsLabel('Redimensionar painel'), findsOneWidget);
    });

    testWidgets('window control', (tester) async {
      await _pump(
        tester,
        Oito2WindowControl(
          type: Oito2WindowControlType.close,
          style: Oito2WindowControlStyle.gnome,
          onPressed: () {},
        ),
      );
      expect(find.bySemanticsLabel('Fechar'), findsOneWidget);
    });

    testWidgets('English without the delegate', (tester) async {
      await _pump(
        tester,
        Oito2WindowControl(
          type: Oito2WindowControlType.close,
          style: Oito2WindowControlStyle.gnome,
          onPressed: () {},
        ),
        withDelegate: false,
      );
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
    });
  });
}
