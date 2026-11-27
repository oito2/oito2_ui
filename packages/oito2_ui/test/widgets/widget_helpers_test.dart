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
import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'dart:async';

import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui/src/collections/text_folding.dart';
import 'package:oito2_ui/src/widgets/type_ahead.dart';
import 'package:oito2_ui/src/widgets/widget_helpers.dart';

/// Shows whether its node has focus and counts its controller's changes.
class _Probe extends StatefulWidget {
  const _Probe({this.focusNode, this.controller});

  final FocusNode? focusNode;
  final ValueNotifier<int>? controller;

  @override
  State<_Probe> createState() => _ProbeState();
}

/// Counts focus and controller notifications and records each controller
/// replaced by a new one.
class _ProbeState extends State<_Probe>
    with OwnedFocusNodeMixin, OwnedControllerMixin<_Probe, ValueNotifier<int>> {
  int focusChanges = 0;
  int controllerChanges = 0;
  final List<ValueNotifier<int>> swappedFrom = [];

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  ValueNotifier<int>? get widgetController => widget.controller;

  @override
  ValueNotifier<int> createOwnedController() => ValueNotifier(0);

  @override
  void onEffectiveFocusChange() => focusChanges++;

  @override
  void onControllerChange() => controllerChanges++;

  @override
  void didChangeController(ValueNotifier<int> previous) =>
      swappedFrom.add(previous);

  @override
  Widget build(BuildContext context) =>
      Focus(focusNode: effectiveFocusNode, child: const SizedBox());
}

/// A notifier that tells whether anyone listens to it.
class _Notifier extends ValueNotifier<int> {
  _Notifier() : super(0);

  bool get listened => hasListeners;
}

void main() {
  _ProbeState probe(WidgetTester tester) => tester.state(find.byType(_Probe));

  testWidgets('the focus listener follows the node in use', (tester) async {
    final given = FocusNode();
    addTearDown(given.dispose);
    await tester.pumpWidget(const _Probe());
    final owned = probe(tester).effectiveFocusNode;
    await tester.pumpWidget(_Probe(focusNode: given));
    expect(probe(tester).effectiveFocusNode, same(given));
    given.requestFocus();
    await tester.pump();
    expect(probe(tester).focusChanges, 1);
    // The replaced owned node is disposed after the frame.
    expect(() => owned.addListener(() {}), throwsFlutterError);
    await tester.pumpWidget(const _Probe());
    given.unfocus();
    await tester.pump();
    expect(probe(tester).focusChanges, 1);
  });

  testWidgets('the controller listener follows the controller in use', (
    tester,
  ) async {
    final given = _Notifier();
    addTearDown(given.dispose);
    await tester.pumpWidget(const _Probe());
    final owned = probe(tester).effectiveController;
    owned.value = 1;
    expect(probe(tester).controllerChanges, 1);
    await tester.pumpWidget(_Probe(controller: given));
    expect(probe(tester).swappedFrom, [owned]);
    given.value = 1;
    expect(probe(tester).controllerChanges, 2);
    expect(() => owned.addListener(() {}), throwsFlutterError);
    await tester.pumpWidget(const SizedBox());
    expect(given.listened, isFalse);
  });

  for (final direction in TextDirection.values) {
    testWidgets('direction helpers follow $direction', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        Directionality(
          textDirection: direction,
          child: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      final rtl = direction == TextDirection.rtl;
      expect(
        directionalChevron(context, forward: true),
        rtl ? LucideIcons.chevron_left : LucideIcons.chevron_right,
      );
      expect(
        directionalChevron(context, forward: false),
        rtl ? LucideIcons.chevron_right : LucideIcons.chevron_left,
      );
      final (:back, :forward) = readingArrowsOf(context);
      expect(
        back,
        rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft,
      );
      expect(
        forward,
        rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight,
      );
    });
  }

  group('DoubleClickDetector', () {
    testWidgets('pairs two clicks on one target within the timeout', (
      tester,
    ) async {
      final clicks = DoubleClickDetector();
      expect(clicks.click('a'), isFalse);
      expect(clicks.click('a'), isTrue);
      // A third click starts over.
      expect(clicks.click('a'), isFalse);
      await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 10));
      expect(clicks.click('a'), isFalse);
      expect(clicks.click('b'), isFalse);
      expect(clicks.click('a'), isFalse);
      clicks.cancel();
    });
  });

  testWidgets('SizeReporter reports the child size after each layout', (
    tester,
  ) async {
    final sizes = <Size>[];
    Widget build(double width) => Center(
      child: SizeReporter(
        onSize: sizes.add,
        child: SizedBox(width: width, height: 20),
      ),
    );
    await tester.pumpWidget(build(100));
    await tester.pumpWidget(build(150));
    expect(sizes, const [Size(100, 20), Size(150, 20)]);
  });

  test('avatarStatusLabel names every status in each language', () {
    final en = Oito2LocalizationsEn();
    final pt = Oito2LocalizationsPtBr();
    expect(
      [for (final s in Oito2AvatarStatus.values) avatarStatusLabel(en, s)],
      [en.statusOnline, en.statusAway, en.statusBusy, en.statusOffline],
    );
    expect(avatarStatusLabel(pt, Oito2AvatarStatus.busy), pt.statusBusy);
  });

  test('foldWords folds the query and drops empty words', () {
    expect(foldWords('  Ação   Rápida '), ['acao', 'rapida']);
    expect(foldWords('   '), isEmpty);
    expect(foldWords(''), isEmpty);
  });

  group('TypeAheadBuffer', () {
    test('accepts printable characters only', () {
      expect(TypeAheadBuffer.accepts('a'), isTrue);
      expect(TypeAheadBuffer.accepts('é'), isTrue);
      expect(TypeAheadBuffer.accepts(null), isFalse);
      expect(TypeAheadBuffer.accepts(' '), isFalse);
      expect(TypeAheadBuffer.accepts('\t'), isFalse);
      expect(TypeAheadBuffer.accepts('\u{7}'), isFalse);
    });

    testWidgets('grows the prefix, cycles on a repeat and resets after a '
        'pause', (tester) async {
      final buffer = TypeAheadBuffer();
      addTearDown(buffer.dispose);
      expect(buffer.add('d'), (prefix: 'd', fromNext: true));
      expect(buffer.add('o'), (prefix: 'do', fromNext: false));
      expect(buffer.add('c'), (prefix: 'doc', fromNext: false));
      await tester.pump(TypeAheadBuffer.resetDelay);
      expect(buffer.add('a'), (prefix: 'a', fromNext: true));
      expect(buffer.add('a'), (prefix: 'a', fromNext: true));
      expect(buffer.add('a'), (prefix: 'a', fromNext: true));
      expect(buffer.add('b'), (prefix: 'ab', fromNext: false));
      await tester.pump(
        TypeAheadBuffer.resetDelay - const Duration(milliseconds: 1),
      );
      expect(buffer.add('c'), (prefix: 'abc', fromNext: false));
    });
  });

  group('runGuardedSwitch', () {
    /// Pumps a probe under a scope of [controller] and returns its
    /// context.
    Future<BuildContext> pumpScope(
      WidgetTester tester,
      Oito2UnsavedChangesController? controller,
    ) async {
      final key = GlobalKey();
      Widget child = SizedBox(key: key);
      if (controller != null) {
        child = Oito2UnsavedChangesScope(controller: controller, child: child);
      }
      await tester.pumpWidget(child);
      return key.currentContext!;
    }

    testWidgets('applies at once without a scope or pending changes', (
      tester,
    ) async {
      var applied = 0;
      runGuardedSwitch(
        await pumpScope(tester, null),
        isCurrent: false,
        apply: () => applied++,
      );
      runGuardedSwitch(
        await pumpScope(tester, Oito2UnsavedChangesController()),
        isCurrent: false,
        apply: () => applied++,
      );
      expect(applied, 2);
    });

    testWidgets('applies at once for the current item, without asking', (
      tester,
    ) async {
      var asked = 0;
      final controller = Oito2UnsavedChangesController()
        ..addHandler(() async {
          asked++;
          return false;
        });
      var applied = 0;
      runGuardedSwitch(
        await pumpScope(tester, controller),
        isCurrent: true,
        apply: () => applied++,
      );
      expect((applied, asked), (1, 0));
    });

    testWidgets('waits for the confirmation and applies only when leaving '
        'is confirmed', (tester) async {
      final answer = Completer<bool>();
      final controller = Oito2UnsavedChangesController()
        ..addHandler(() => answer.future);
      var applied = 0;
      final context = await pumpScope(tester, controller);
      runGuardedSwitch(context, isCurrent: false, apply: () => applied++);
      await tester.pump();
      expect(applied, 0);
      answer.complete(true);
      await tester.pump();
      expect(applied, 1);

      final refused = Oito2UnsavedChangesController()
        ..addHandler(() async => false);
      runGuardedSwitch(
        await pumpScope(tester, refused),
        isCurrent: false,
        apply: () => applied++,
      );
      await tester.pump();
      expect(applied, 1);
    });

    testWidgets('does not apply after the context is unmounted', (
      tester,
    ) async {
      final answer = Completer<bool>();
      final controller = Oito2UnsavedChangesController()
        ..addHandler(() => answer.future);
      var applied = 0;
      runGuardedSwitch(
        await pumpScope(tester, controller),
        isCurrent: false,
        apply: () => applied++,
      );
      await tester.pumpWidget(const SizedBox());
      answer.complete(true);
      await tester.pump();
      expect(applied, 0);
    });
  });
}
