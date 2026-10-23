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
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
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
}
