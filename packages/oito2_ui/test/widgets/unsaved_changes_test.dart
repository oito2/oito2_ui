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

import '../window/fake_window_controller.dart';

/// A fake window controller that also keeps close handlers.
class _ClosingWindow extends FakeWindowController
    implements Oito2WindowCloseGuard {
  final List<Oito2WindowCloseHandler> handlers = [];

  @override
  void addCloseHandler(Oito2WindowCloseHandler handler) =>
      handlers.add(handler);

  @override
  void removeCloseHandler(Oito2WindowCloseHandler handler) =>
      handlers.remove(handler);
}

/// A page with a guarded form of one password field, "Name".
class _EditPage extends StatefulWidget {
  const _EditPage({this.onSave});

  final Future<bool> Function(Oito2FormController form)? onSave;

  @override
  State<_EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<_EditPage> {
  final _form = Oito2FormController();

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSave = widget.onSave;
    return Oito2UnsavedChangesGuard(
      form: _form,
      onSave: onSave == null ? null : () => onSave(_form),
      child: Scaffold(
        body: Oito2Form(
          controller: _form,
          child: const Oito2PasswordField(labelText: 'Name'),
        ),
      ),
    );
  }
}

/// Pumps a home page with an "Open" button that pushes [page].
Future<void> _pumpHome(WidgetTester tester, Widget page) => pumpOito2(
  tester,
  Builder(
    builder: (context) => TextButton(
      onPressed: () =>
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => page)),
      child: const Text('Open'),
    ),
  ),
);

/// Opens the page and types [text] in its field.
Future<void> _openAndType(WidgetTester tester, String? text) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  if (text != null) {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }
}

/// Asks the page route to pop, as a back button does.
Future<void> _back(WidgetTester tester) async {
  await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
  await tester.pumpAndSettle();
}

void main() {
  group('Oito2UnsavedChangesGuard', () {
    testWidgets('pops without asking while there are no changes', (
      tester,
    ) async {
      await _pumpHome(tester, const _EditPage());
      await _openAndType(tester, null);
      await _back(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('asks before popping with changes; keep editing stays', (
      tester,
    ) async {
      await _pumpHome(tester, const _EditPage());
      await _openAndType(tester, 'Ana');
      await _back(tester);
      expect(find.text('Discard unsaved changes?'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Open'), findsNothing);
    });

    testWidgets('discard pops the page', (tester) async {
      await _pumpHome(tester, const _EditPage());
      await _openAndType(tester, 'Ana');
      await _back(tester);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
      expect(find.byType(_EditPage), findsNothing);
    });

    testWidgets('save pops only when it succeeds', (tester) async {
      var succeed = false;
      var saves = 0;
      await _pumpHome(
        tester,
        _EditPage(
          onSave: (form) async {
            saves++;
            if (succeed) form.markClean();
            return succeed;
          },
        ),
      );
      await _openAndType(tester, 'Ana');
      await _back(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saves, 1);
      expect(find.byType(_EditPage), findsOneWidget);

      succeed = true;
      await _back(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saves, 2);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('follows an isDirty listenable', (tester) async {
      final dirty = ValueNotifier(false);
      addTearDown(dirty.dispose);
      await _pumpHome(
        tester,
        Oito2UnsavedChangesGuard(isDirty: dirty, child: const Text('Page')),
      );
      await _openAndType(tester, null);
      dirty.value = true;
      await tester.pump();
      await _back(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      dirty.value = false;
      await tester.pump();
      await _back(tester);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('registers with the window only while there are changes', (
      tester,
    ) async {
      final window = _ClosingWindow();
      await pumpOito2(
        tester,
        Oito2WindowScope(controller: window, child: const _EditPage()),
      );
      expect(window.handlers, isEmpty);
      await tester.enterText(find.byType(TextField), 'Ana');
      await tester.pump();
      expect(window.handlers, hasLength(1));

      // Closing asks; keep editing refuses, discard allows.
      final refused = window.handlers.single();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(await refused, isFalse);
      final allowed = window.handlers.single();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(await allowed, isTrue);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(window.handlers, isEmpty);
    });

    testWidgets('a second request while the dialog is open is refused', (
      tester,
    ) async {
      final window = _ClosingWindow();
      await pumpOito2(
        tester,
        Oito2WindowScope(controller: window, child: const _EditPage()),
      );
      await tester.enterText(find.byType(TextField), 'Ana');
      await tester.pump();
      final first = window.handlers.single();
      await tester.pumpAndSettle();
      expect(await window.handlers.single(), isFalse);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(await first, isTrue);
    });

    testWidgets('leaves the window alone when it is disposed', (tester) async {
      final window = _ClosingWindow();
      await pumpOito2(
        tester,
        Oito2WindowScope(controller: window, child: const _EditPage()),
      );
      await tester.enterText(find.byType(TextField), 'Ana');
      await tester.pump();
      expect(window.handlers, hasLength(1));
      await pumpOito2(tester, const SizedBox());
      expect(window.handlers, isEmpty);
    });

    for (final (name, colors) in [
      ('light', Oito2ColorTheme.light()),
      ('dark', Oito2ColorTheme.dark()),
    ]) {
      testWidgets('the dialog meets the guidelines, $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpOito2(
          tester,
          Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showOito2UnsavedChangesDialog(context, canSave: true),
              child: const Text('Ask'),
            ),
          ),
          colors: colors,
        );
        await tester.tap(find.text('Ask'));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // Keep editing takes the focus, so Enter doesn't drop the changes.
        expect(
          Focus.of(tester.element(find.text('Keep editing'))).hasFocus,
          isTrue,
        );
        semantics.dispose();
      });
    }
  });

  group('Oito2UnsavedChangesScope', () {
    /// Pumps a master-detail page of two items under a scope of
    /// [controller]; the first item holds a guarded form.
    Future<void> pumpMasterDetail(
      WidgetTester tester,
      Oito2UnsavedChangesController controller, {
      bool rail = false,
    }) {
      Widget page(BuildContext context, int index) =>
          index == 0 ? const _EditPage() : const Text('Second page');
      return pumpOito2(
        tester,
        Oito2UnsavedChangesScope(
          controller: controller,
          child: rail
              ? Oito2NavigationPage(
                  items: const [
                    Oito2NavigationItem(icon: Icon(Icons.edit), label: 'Edit'),
                    Oito2NavigationItem(icon: Icon(Icons.info), label: 'Other'),
                  ],
                  pageBuilder: page,
                )
              : Oito2MasterDetailPage(
                  length: 2,
                  initialIndex: 0,
                  tileBuilder: (context, index, selected, width) =>
                      Oito2MasterTile(
                        title: Text(index == 0 ? 'Edit' : 'Other'),
                      ),
                  pageBuilder: page,
                ),
        ),
        size: const Size(1000, 600),
      );
    }

    for (final rail in [false, true]) {
      final name = rail ? 'navigation page' : 'master-detail page';
      testWidgets('the $name asks before switching away from changes', (
        tester,
      ) async {
        final controller = Oito2UnsavedChangesController();
        await pumpMasterDetail(tester, controller, rail: rail);
        expect(controller.hasUnsavedChanges, isFalse);
        await tester.enterText(find.byType(TextField), 'Ana');
        await tester.pump();
        expect(controller.hasUnsavedChanges, isTrue);

        await tester.tap(find.text('Other'));
        await tester.pumpAndSettle();
        expect(find.text('Discard unsaved changes?'), findsOneWidget);
        await tester.tap(find.text('Keep editing'));
        await tester.pumpAndSettle();
        expect(find.text('Second page'), findsNothing);
        expect(find.text('Ana'), findsOneWidget);

        await tester.tap(find.text('Other'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();
        expect(find.text('Second page'), findsOneWidget);
        expect(controller.hasUnsavedChanges, isFalse);
      });
    }

    testWidgets('switches at once without changes', (tester) async {
      final controller = Oito2UnsavedChangesController();
      await pumpMasterDetail(tester, controller);
      await tester.tap(find.text('Other'));
      await tester.pump();
      expect(find.text('Second page'), findsOneWidget);
    });

    test('confirmLeave asks the last handler first and stops at a '
        'refusal', () async {
      final controller = Oito2UnsavedChangesController();
      final asked = <String>[];
      controller
        ..addHandler(() async {
          asked.add('first');
          return true;
        })
        ..addHandler(() async {
          asked.add('second');
          return false;
        });
      expect(await controller.confirmLeave(), isFalse);
      expect(asked, ['second']);
      expect(await Oito2UnsavedChangesController().confirmLeave(), isTrue);
    });
  });
}
