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

/// Encodes a 100 by 100 white PNG with a black square of [blackSide]
/// pixels in its top-left corner.
Future<Uint8List> _png(int blackSide) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder)
    ..drawRect(
      const ui.Rect.fromLTWH(0, 0, 100, 100),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    )
    ..drawRect(
      ui.Rect.fromLTWH(0, 0, blackSide.toDouble(), blackSide.toDouble()),
      ui.Paint()..color = const ui.Color(0xFF000000),
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

  test('an image within the tolerance passes and is not written', () async {
    await writeGolden();
    final modified = file().lastModifiedSync();
    // 4 x 4 = 16 pixels, 0.16% of the image.
    final image = await _png(4);
    for (final enabled in [false, true]) {
      expect(await comparator(enabled: enabled).compare(image, uri), isTrue);
      expect(file().readAsBytesSync(), golden);
      expect(file().lastModifiedSync(), modified);
    }
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
