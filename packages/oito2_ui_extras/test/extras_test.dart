// Copyright (C) 2026  oito2
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

import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// A [width] by [height] PNG: left half red, right half blue.
Future<Uint8List> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..drawRect(
      Rect.fromLTWH(0, 0, width / 2, height.toDouble()),
      Paint()..color = const Color(0xFFFF0000),
    )
    ..drawRect(
      Rect.fromLTWH(width / 2, 0, width / 2, height.toDouble()),
      Paint()..color = const Color(0xFF0000FF),
    );
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  group('Oito2QrCode', () {
    test('modules have the finder patterns and grow with the level', () {
      final low = oito2QrModules('https://oito2.github.io/oito2_ui/');
      expect(low.moduleCount, 29);
      final m = low.modules;
      for (final (r, c) in [
        (0, 0),
        (0, low.moduleCount - 7),
        (low.moduleCount - 7, 0),
      ]) {
        expect(m[r][c], isTrue);
        expect(m[r + 1][c + 1], isFalse);
        expect(m[r + 3][c + 3], isTrue);
      }
      final high = oito2QrModules(
        'https://oito2.github.io/oito2_ui/',
        errorLevel: Oito2QrErrorLevel.high,
      );
      expect(high.moduleCount, greaterThan(low.moduleCount));
      expect(() => oito2QrModules('x' * 8000), throwsArgumentError);
    });

    testWidgets('a rebuild with the same data does not repaint', (
      tester,
    ) async {
      CustomPainter painter() => tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byType(Oito2QrCode),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter!;
      await pumpOito2(tester, const Oito2QrCode(data: 'oito2'));
      final before = painter();
      await pumpOito2(tester, const Oito2QrCode(data: 'oito2', size: 160));
      await pumpOito2(tester, const Oito2QrCode(data: 'oito2'));
      expect(painter().shouldRepaint(before), isFalse);
    });

    testWidgets('paints with a label, or a message when too long', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, const Center(child: Oito2QrCode(data: 'oito2')));
      expect(find.bySemanticsLabel('QR code'), findsOneWidget);
      expect(tester.getSize(find.byType(Oito2QrCode)), const Size.square(160));
      await pumpOito2(tester, Center(child: Oito2QrCode(data: 'x' * 8000)));
      expect(find.text('Too much data for a QR code'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Oito2SignaturePad', () {
    testWidgets('draws, undoes, clears and reports its state', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = Oito2SignatureController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 400,
            child: Oito2SignaturePad(controller: controller),
          ),
        ),
      );
      expect(find.text('Sign here'), findsOneWidget);
      final pad = tester.getRect(find.byType(Oito2SignaturePad));
      await tester.dragFrom(pad.center, const Offset(80, 20));
      await tester.dragFrom(
        pad.center + const Offset(0, 30),
        const Offset(60, 0),
      );
      await tester.pump();
      expect(controller.strokes, hasLength(2));
      expect(find.text('Sign here'), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Signature')),
        isSemantics(value: 'Signed'),
      );
      await tester.tap(find.byTooltip('Undo'));
      await tester.pump();
      expect(controller.strokes, hasLength(1));
      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();
      expect(controller.isEmpty, isTrue);
      handle.dispose();
    });

    test('strokes are read-only copies', () {
      final controller = Oito2SignatureController()
        ..addStroke(const [(position: Offset.zero, width: 2)]);
      addTearDown(controller.dispose);
      expect(
        () => controller.strokes.first.add((position: Offset.zero, width: 1)),
        throwsUnsupportedError,
      );
    });

    testWidgets('draws one stroke at a time, with the primary button', (
      tester,
    ) async {
      final controller = Oito2SignatureController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 400,
            child: Oito2SignaturePad(controller: controller),
          ),
        ),
      );
      final center = tester.getRect(find.byType(Oito2SignaturePad)).center;
      final first = await tester.startGesture(center, pointer: 1);
      final second = await tester.startGesture(
        center + const Offset(0, 40),
        pointer: 2,
      );
      await first.moveBy(const Offset(30, 0));
      await second.moveBy(const Offset(30, 0));
      await first.up();
      await second.up();
      expect(controller.strokes, hasLength(1));
      final stroke = controller.strokes.single;
      expect(
        stroke.every((p) => p.position.dy == stroke.first.position.dy),
        isTrue,
      );

      final right = await tester.startGesture(
        center,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await right.moveBy(const Offset(30, 0));
      await right.up();
      expect(controller.strokes, hasLength(1));
    });

    testWidgets('a drag inside a scroll view draws instead of scrolling', (
      tester,
    ) async {
      final controller = Oito2SignatureController();
      addTearDown(controller.dispose);
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      await pumpOito2(
        tester,
        ListView(
          controller: scroll,
          children: [
            Oito2SignaturePad(controller: controller),
            const SizedBox(height: 2000),
          ],
        ),
      );
      await tester.dragFrom(const Offset(300, 90), const Offset(0, -60));
      await tester.pump();
      expect(scroll.offset, 0);
      expect(controller.isEmpty, isFalse);
    });

    testWidgets('exports SVG and PNG', (tester) async {
      final controller = Oito2SignatureController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: Oito2SignaturePad(controller: controller),
          ),
        ),
      );
      final pad = tester.getRect(find.byType(Oito2SignaturePad));
      await tester.dragFrom(pad.center, const Offset(50, 10));
      await tester.pump();
      final svg = controller.toSvg();
      expect(svg, startsWith('<svg'));
      expect(svg, contains('<path d="M'));
      final png = await tester.runAsync(controller.toPngBytes);
      expect(png, isNotNull);
      expect(png!.sublist(1, 4), 'PNG'.codeUnits);
    });
  });

  group('Oito2ImageCropper', () {
    Future<Oito2CropController> pumpCropper(
      WidgetTester tester, {
      int? maxDecodedDimension = 4096,
    }) async {
      final bytes = (await tester.runAsync(() => _png(400, 200)))!;
      final controller = Oito2CropController();
      addTearDown(controller.dispose);
      final image = MemoryImage(bytes);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Oito2ImageCropper(
                  image: image,
                  controller: controller,
                  maxDecodedDimension: maxDecodedDimension,
                ),
                Oito2CropPreview(controller: controller),
              ],
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await precacheImage(
          image,
          tester.element(find.byType(Oito2ImageCropper)),
        );
      });
      for (var i = 0; i < 5 && controller.image == null; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      return controller;
    }

    testWidgets('loads, zooms, rotates, flips and keeps the box covered', (
      tester,
    ) async {
      final controller = await pumpCropper(tester);
      expect(controller.image, isNotNull);
      expect(controller.boxSize.width, controller.boxSize.height);
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pump();
      expect(controller.zoom, closeTo(1.2, 0.001));
      await tester.tap(find.byTooltip('Rotate right'));
      await tester.tap(find.byTooltip('Flip horizontally'));
      await tester.pump();
      expect(controller.quarterTurns, 1);
      expect(controller.flipped, isTrue);
      controller.panBy(const Offset(5000, 5000));
      expect(controller.offset.dx.abs(), lessThan(5000));
      await tester.tap(find.byTooltip('Reset'));
      await tester.pump();
      expect(controller.zoom, 1);
      expect(controller.quarterTurns, 0);
    });

    testWidgets('keyboard and wheel control it', (tester) async {
      final controller = await pumpCropper(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pump();
      expect(controller.quarterTurns, 1);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      final center = tester.getCenter(find.byType(CustomPaint).first);
      await tester.sendEventToBinding(pointer.hover(center));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -200)));
      await tester.pump();
      expect(controller.zoom, greaterThan(1));
    });

    testWidgets('crops after the cropper is gone', (tester) async {
      final controller = await pumpCropper(tester);
      await pumpOito2(tester, const SizedBox());
      expect(controller.image, isNotNull);
      final image = await tester.runAsync(controller.crop);
      expect(tester.takeException(), isNull);
      expect(image!.width, 200);
      image.dispose();
    });

    testWidgets('decodes large images at the bounded size', (tester) async {
      final controller = await pumpCropper(tester, maxDecodedDimension: 100);
      expect(controller.image!.width, 100);
      expect(controller.image!.height, 50);
    });

    testWidgets('reports an image that fails to load', (tester) async {
      final errors = <Object>[];
      final controller = Oito2CropController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          width: 400,
          child: Oito2ImageCropper(
            image: MemoryImage(Uint8List.fromList([1, 2, 3, 4])),
            controller: controller,
            onError: (error, _) => errors.add(error),
          ),
        ),
      );
      for (var i = 0; i < 10 && errors.isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      expect(errors, isNotEmpty);
      expect(controller.image, isNull);
    });

    testWidgets('a new picture starts with the transform reset', (
      tester,
    ) async {
      final controller = await pumpCropper(tester);
      controller.rotateRight();
      expect(controller.quarterTurns, 1);
      final bytes = (await tester.runAsync(() => _png(300, 300)))!;
      final next = MemoryImage(bytes);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Oito2ImageCropper(
                  image: next,
                  controller: controller,
                  maxDecodedDimension: 4096,
                ),
                Oito2CropPreview(controller: controller),
              ],
            ),
          ),
        ),
      );
      for (var i = 0; i < 10 && controller.image?.width != 300; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      expect(controller.image!.width, 300);
      expect(controller.quarterTurns, 0);
    });

    testWidgets('crops at the image resolution', (tester) async {
      final controller = await pumpCropper(tester);
      final image = await tester.runAsync(controller.crop);
      // The square box covers the 200-pixel image height at zoom 1.
      expect(image!.width, 200);
      expect(image.height, 200);
      image.dispose();
      final small = await tester.runAsync(() => controller.crop(width: 64));
      expect(small!.width, 64);
      small.dispose();
    });
  });

  group('Oito2NavigationMenu', () {
    Future<List<String>> pumpMenu(WidgetTester tester) async {
      final pressed = <String>[];
      await pumpOito2(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: Oito2NavigationMenu(
            selectedIndex: 2,
            items: [
              const Oito2NavigationMenuItem(
                label: 'Products',
                panelBuilder: _productsPanel,
              ),
              const Oito2NavigationMenuItem(
                label: 'Docs',
                panelBuilder: _docsPanel,
              ),
              Oito2NavigationMenuItem(
                label: 'Blog',
                onPressed: () => pressed.add('Blog'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      return pressed;
    }

    testWidgets('a press opens a panel and Escape closes it', (tester) async {
      final pressed = await pumpMenu(tester);
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(find.text('Products panel'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Products panel'), findsNothing);
      await tester.tap(find.text('Blog'));
      expect(pressed, ['Blog']);
    });

    testWidgets('hover opens after a delay and switches at once', (
      tester,
    ) async {
      await pumpMenu(tester);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Products')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Products panel'), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('Products panel'), findsOneWidget);
      await mouse.moveTo(tester.getCenter(find.text('Docs')));
      await tester.pumpAndSettle();
      expect(find.text('Docs panel'), findsOneWidget);
      expect(find.text('Products panel'), findsNothing);
      await mouse.moveTo(const Offset(5, 700));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Docs panel'), findsNothing);
    });

    testWidgets('Down opens a panel with the focus inside', (tester) async {
      await pumpMenu(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('Products panel'), findsOneWidget);
      expect(
        Focus.of(tester.element(find.text('Products panel'))).hasFocus,
        isTrue,
      );
    });

    testWidgets('the line sits under the selected item', (tester) async {
      await pumpMenu(tester);
      final line = tester.getRect(find.byType(AnimatedPositioned));
      final blog = tester.getRect(find.widgetWithText(TextButton, 'Blog'));
      expect(line.center.dx, closeTo(blog.center.dx, 0.5));
      expect(line.bottom, closeTo(blog.bottom, 0.5));
    });
  });
}

Widget _productsPanel(BuildContext context) =>
    TextButton(onPressed: () {}, child: const Text('Products panel'));

Widget _docsPanel(BuildContext context) => const Text('Docs panel');
