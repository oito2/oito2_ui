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

import 'dart:convert';
import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_files/oito2_ui_files.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// A 1x1 PNG image.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

// On the VM, an in-memory file takes its name from its path.
XFile _file(String name, int size, {String? mimeType}) =>
    XFile.fromData(Uint8List(size), path: name, mimeType: mimeType);

const _images = XTypeGroup(
  label: 'Images',
  extensions: ['png', 'jpg'],
  mimeTypes: ['image/*'],
);

/// Answers the file dialogs with [toOpen] and [savePath].
class _FakeFileSelector extends FileSelectorPlatform {
  List<XFile> toOpen = [];
  String? savePath;
  String? suggestedName;
  final List<String> calls = [];

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    calls.add('openFile');
    return toOpen.isEmpty ? null : toOpen.first;
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    calls.add('openFiles');
    return toOpen;
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    calls.add('getSaveLocation');
    suggestedName = options.suggestedName;
    final path = savePath;
    return path == null ? null : FileSaveLocation(path);
  }
}

/// A drop target whose callbacks the test calls, as a drag would.
class _TestDropSource {
  ValueChanged<bool>? hover;
  ValueChanged<List<XFile>>? drop;

  Widget build({
    required Widget child,
    required bool enabled,
    required ValueChanged<bool> onHover,
    required ValueChanged<List<XFile>> onDrop,
  }) {
    hover = enabled ? onHover : null;
    drop = enabled ? onDrop : null;
    return child;
  }
}

void main() {
  late _FakeFileSelector selector;

  setUp(() {
    selector = _FakeFileSelector();
    FileSelectorPlatform.instance = selector;
  });

  group('oito2FileMatchesTypes', () {
    test('matches extensions, MIME types and wildcards', () {
      expect(oito2FileMatchesTypes(_file('a.PNG', 1), [_images]), isTrue);
      expect(
        oito2FileMatchesTypes(_file('a', 1, mimeType: 'image/webp'), [_images]),
        isTrue,
      );
      expect(oito2FileMatchesTypes(_file('a.pdf', 1), [_images]), isFalse);
      expect(
        oito2FileMatchesTypes(_file('a.txt', 1), [
          const XTypeGroup(extensions: ['.TXT']),
        ]),
        isTrue,
      );
    });

    test('no groups, or a group without filters, accept every file', () {
      expect(oito2FileMatchesTypes(_file('a.pdf', 1), const []), isTrue);
      expect(
        oito2FileMatchesTypes(_file('a.pdf', 1), [
          const XTypeGroup(label: 'All'),
        ]),
        isTrue,
      );
    });
  });

  group('Oito2FileUploadController', () {
    test('refuses files by type, size and count', () async {
      final controller = Oito2FileUploadController(
        accept: const [_images],
        maxFiles: 2,
        maxFileSize: 100,
      );
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);
      await controller.add([
        _file('a.png', 10),
        _file('b.pdf', 10),
        _file('c.png', 500),
        _file('d.jpg', 10),
        _file('e.png', 10),
      ]);
      expect(controller.files.map((f) => f.name), ['a.png', 'd.jpg']);
      expect(controller.rejected.map((r) => (r.file.name, r.reason)), [
        ('b.pdf', Oito2FileRejection.type),
        ('c.png', Oito2FileRejection.size),
        ('e.png', Oito2FileRejection.count),
      ]);
      expect(controller.canAddMore, isFalse);
      expect(notified, 1);
    });

    test('remove, clearRejected and clear', () async {
      final controller = Oito2FileUploadController(accept: const [_images]);
      addTearDown(controller.dispose);
      await controller.add([_file('a.png', 1), _file('b.pdf', 1)]);
      controller.remove(controller.files.single);
      expect(controller.files, isEmpty);
      controller.clearRejected();
      expect(controller.rejected, isEmpty);
      await controller.add([_file('c.png', 1), _file('d.pdf', 1)]);
      controller.clear();
      expect(controller.files, isEmpty);
      expect(controller.rejected, isEmpty);
    });

    test('overlapping adds still respect the file limit', () async {
      // The size limit makes each add wait for the file sizes.
      final controller = Oito2FileUploadController(
        maxFiles: 1,
        maxFileSize: 100,
      );
      addTearDown(controller.dispose);
      // The second add starts while the first still reads its files.
      await Future.wait([
        controller.add([_file('a.txt', 1), _file('b.txt', 1)]),
        controller.add([_file('c.txt', 1)]),
      ]);
      expect(controller.files.map((f) => f.name), ['a.txt']);
      expect(controller.rejected.single.file.name, 'c.txt');
    });

    test('a later add replaces the refusals', () async {
      final controller = Oito2FileUploadController(accept: const [_images]);
      addTearDown(controller.dispose);
      await controller.add([_file('b.pdf', 1)]);
      await controller.add([_file('c.png', 1)]);
      expect(controller.rejected, isEmpty);
      expect(controller.files.single.name, 'c.png');
    });
  });

  group('Oito2FileDropZone', () {
    testWidgets('a tap opens the chooser for one or several files', (
      tester,
    ) async {
      final received = <List<XFile>>[];
      var multiple = true;
      selector.toOpen = [_file('a.png', 1), _file('b.png', 1)];
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Oito2FileDropZone(multiple: multiple, onFiles: received.add),
              TextButton(
                onPressed: () => setState(() => multiple = false),
                child: const Text('single'),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Choose files'), findsOneWidget);
      await tester.tap(find.byType(Oito2FileDropZone));
      await tester.pump();
      expect(selector.calls, ['openFiles']);
      expect(received.single, hasLength(2));
      await tester.tap(find.text('single'));
      await tester.pump();
      await tester.tap(find.byType(Oito2FileDropZone));
      await tester.pump();
      expect(selector.calls.last, 'openFile');
      expect(received.last.single.name, 'a.png');
    });

    testWidgets('a disabled zone opens nothing', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        Oito2FileDropZone(enabled: false, onFiles: (_) {}),
      );
      await tester.tap(find.byType(Oito2FileDropZone));
      await tester.pump();
      expect(selector.calls, isEmpty);
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Choose files'))),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('a drop target invites drops and passes them on', (
      tester,
    ) async {
      final source = _TestDropSource();
      final received = <List<XFile>>[];
      await pumpOito2(
        tester,
        Oito2FileDropZone(
          dropTargetBuilder: source.build,
          onFiles: received.add,
        ),
      );
      expect(find.text('Drop files here'), findsOneWidget);
      source.hover!(true);
      await tester.pumpAndSettle();
      final scheme = Theme.of(tester.element(find.byType(Oito2FileDropZone)))
          .colorScheme;
      final box = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(
        (box.decoration! as BoxDecoration).color,
        isNot(scheme.surfaceContainerLow),
      );
      source.drop!([_file('a.png', 1)]);
      expect(received.single.single.name, 'a.png');
    });
  });

  group('Oito2FileUpload', () {
    testWidgets('lists files with size and preview, and removes them', (
      tester,
    ) async {
      final controller = Oito2FileUploadController(
        accept: const [_images],
        maxFileSize: 1000,
      );
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(width: 400, child: Oito2FileUpload(controller: controller)),
      );
      expect(find.text('Accepted: Images · Up to 1 kB each'), findsOneWidget);
      await tester.runAsync(
        () => controller.add([
          XFile.fromData(_png, path: 'dot.png', mimeType: 'image/png'),
          _file('notes.pdf', 10),
        ]),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('dot.png'), findsOneWidget);
      expect(find.text('${_png.length} B'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(
        find.text('notes.pdf: this file type is not accepted'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      expect(controller.rejected, isEmpty);
      await tester.tap(find.byTooltip('Remove dot.png'));
      await tester.pump();
      expect(controller.files, isEmpty);
      expect(find.text('dot.png'), findsNothing);
    });

    testWidgets('the zone is disabled once the upload is full', (tester) async {
      final controller = Oito2FileUploadController(maxFiles: 1);
      addTearDown(controller.dispose);
      selector.toOpen = [_file('a.txt', 1)];
      await pumpOito2(
        tester,
        SizedBox(width: 400, child: Oito2FileUpload(controller: controller)),
      );
      expect(find.text('Choose a file'), findsOneWidget);
      await tester.tap(find.byType(Oito2FileDropZone));
      await tester.pump();
      await tester.pump();
      expect(controller.files.single.name, 'a.txt');
      expect(
        tester
            .widget<Oito2FileDropZone>(find.byType(Oito2FileDropZone))
            .enabled,
        isFalse,
      );
    });
  });

  group('Oito2Downloads', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('oito2_files'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('saves where the dialog says and reports a cancel', () async {
      expect(Oito2Downloads.isSupported, isTrue);
      selector.savePath = '${dir.path}/report.txt';
      final saved = await Oito2Downloads.save(
        fileName: 'report.txt',
        bytes: Uint8List.fromList(utf8.encode('hello')),
        mimeType: 'text/plain',
      );
      expect(saved, isTrue);
      expect(selector.suggestedName, 'report.txt');
      expect(File('${dir.path}/report.txt').readAsStringSync(), 'hello');
      selector.savePath = null;
      expect(
        await Oito2Downloads.save(fileName: 'x', bytes: Uint8List(0)),
        isFalse,
      );
    });

    testWidgets('the trigger saves the built data and reports errors', (
      tester,
    ) async {
      final saves = <bool>[];
      final errors = <Object>[];
      var fail = false;
      selector.savePath = '${dir.path}/data.bin';
      await pumpOito2(
        tester,
        Oito2DownloadTrigger(
          fileName: 'data.bin',
          data: () async {
            if (fail) throw StateError('no data');
            return Uint8List.fromList([1, 2, 3]);
          },
          onSaved: saves.add,
          onError: (error, _) => errors.add(error),
        ),
      );
      expect(find.text('Download'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.byType(Oito2DownloadTrigger));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      expect(saves, [true]);
      expect(File('${dir.path}/data.bin').readAsBytesSync(), [1, 2, 3]);
      fail = true;
      await tester.tap(find.byType(Oito2DownloadTrigger));
      await tester.pump();
      expect(errors.single, isA<StateError>());
      expect(saves, [true]);
    });
  });
}
