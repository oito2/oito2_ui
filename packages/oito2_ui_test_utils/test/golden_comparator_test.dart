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

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// Encodes a 100 by 100 white PNG with a square of [blackSide] pixels in
/// its top-left corner, black or of [color].
Future<Uint8List> _png(
  int blackSide, {
  ui.Color color = const ui.Color(0xFF000000),
}) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder)
    ..drawRect(
      const ui.Rect.fromLTWH(0, 0, 100, 100),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    )
    ..drawRect(
      ui.Rect.fromLTWH(0, 0, blackSide.toDouble(), blackSide.toDouble()),
      ui.Paint()..color = color,
    );
  final image = await recorder.endRecording().toImage(100, 100);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  late Directory dir;
  late Uint8List golden;
  final uri = Uri.parse('goldens/sample.png');

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('oito2_golden_');
    golden = await _png(0);
  });

  tearDown(() => dir.delete(recursive: true));

  File file() => File('${dir.path}/goldens/sample.png');

  /// Creates a comparator for the temporary directory, with the selective
  /// update [enabled] or not.
  TolerantGoldenComparator comparator({required bool enabled}) =>
      TolerantGoldenComparator(Uri.directory(dir.path), updateFailed: enabled);

  /// Writes the all-white image as the golden.
  Future<void> writeGolden() async {
    await file().create(recursive: true);
    await file().writeAsBytes(golden);
  }

  test('many pixels with a small change pass and are not written', () async {
    await writeGolden();
    final modified = file().lastModifiedSync();
    // 7 x 7 = 49 pixels, 0.49% of the image, each channel off by 40.
    final image = await _png(7, color: const ui.Color(0xFFD7D7D7));
    for (final enabled in [false, true]) {
      expect(await comparator(enabled: enabled).compare(image, uri), isTrue);
      expect(file().readAsBytesSync(), golden);
      expect(file().lastModifiedSync(), modified);
    }
  });

  test('a single pixel with a large change passes', () async {
    await writeGolden();
    // 1 pixel, 0.01% of the image.
    expect(
      await comparator(enabled: false).compare(await _png(1), uri),
      isTrue,
    );
  });

  test('a few pixels with a large change fail', () async {
    await writeGolden();
    // 2 x 2 = 4 pixels, 0.04% of the image, and 4 x 4 = 16 pixels, 0.16%.
    for (final side in [2, 4]) {
      await expectLater(
        comparator(enabled: false).compare(await _png(side), uri),
        throwsA(
          isA<FlutterError>().having(
            (error) => error.message,
            'message',
            contains('by more than $goldenStrongDelta'),
          ),
        ),
      );
    }
    expect(file().readAsBytesSync(), golden);
  });

  test('too many pixels with a small change fail', () async {
    await writeGolden();
    // 8 x 8 = 64 pixels, 0.64% of the image, each channel off by 40.
    await expectLater(
      comparator(enabled: false)
          .compare(await _png(8, color: const ui.Color(0xFFD7D7D7)), uri),
      throwsA(isA<FlutterError>()),
    );
  });

  test('measureGoldenDiff counts the differing and the strongly differing '
      'pixels', () async {
    final faint = await measureGoldenDiff(
      await _png(3, color: const ui.Color(0xFFD7D7D7)),
      golden,
    );
    expect(faint, (pixels: 10000, differing: 9, strong: 0, maxDelta: 40));
    expect(isWithinGoldenTolerance(faint!), isTrue);
    final dark = await measureGoldenDiff(await _png(3), golden);
    expect(dark, (pixels: 10000, differing: 9, strong: 9, maxDelta: 255));
    expect(isWithinGoldenTolerance(dark!), isFalse);
  });

  test('an image beyond the tolerance fails when the mode is off', () async {
    await writeGolden();
    // 20 x 20 = 400 pixels, 4% of the image.
    final image = await _png(20);
    await expectLater(
      comparator(enabled: false).compare(image, uri),
      throwsA(isA<FlutterError>()),
    );
    expect(file().readAsBytesSync(), golden);
  });

  test('a missing golden fails when the mode is off', () async {
    await expectLater(
      comparator(enabled: false).compare(await _png(0), uri),
      throwsA(isA<TestFailure>()),
    );
    expect(file().existsSync(), isFalse);
  });

  test(
    'an image beyond the tolerance is written when the mode is on',
    () async {
      await writeGolden();
      final image = await _png(20);
      final printed = <String?>[];
      final previous = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message);
      addTearDown(() => debugPrint = previous);
      expect(await comparator(enabled: true).compare(image, uri), isTrue);
      expect(file().readAsBytesSync(), image);
      expect(printed.single, contains('goldens/sample.png'));
    },
  );

  test('a missing golden is written when the mode is on', () async {
    final image = await _png(20);
    final previous = debugPrint;
    debugPrint = (message, {wrapWidth}) {};
    addTearDown(() => debugPrint = previous);
    expect(await comparator(enabled: true).compare(image, uri), isTrue);
    expect(file().readAsBytesSync(), image);
  });
}
