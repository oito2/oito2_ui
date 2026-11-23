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

/// Records the progress of every frame an animated icon paints.
class _Recorder {
  final frames = <double>[];

  late final data = Oito2AnimatedIconData(
    (canvas, progress, paint) => frames.add(progress),
    duration: const Duration(milliseconds: 500),
  );
}

void main() {
  group('Oito2FreedesktopIcons', () {
    test('finds icons by name, with or without -symbolic', () {
      expect(
        Oito2FreedesktopIcons.byName('document-open'),
        Oito2FreedesktopIcons.documentOpen,
      );
      expect(
        Oito2FreedesktopIcons.byName('document-open-symbolic'),
        Oito2FreedesktopIcons.documentOpen,
      );
      expect(Oito2FreedesktopIcons.byName('no-such-icon'), isNull);
      expect(
        Oito2FreedesktopIcons.byName('go-next-rtl-symbolic'),
        Oito2FreedesktopIcons.byName('go-next'),
      );
      expect(
        Oito2FreedesktopIcons.byName('document-save-as-template'),
        Oito2FreedesktopIcons.byName('document-save-as'),
      );
    });

    test('names are unique freedesktop names', () {
      final names = Oito2FreedesktopIcons.values.map((i) => i.iconName);
      expect(names.toSet(), hasLength(Oito2FreedesktopIcons.values.length));
      for (final name in names) {
        expect(name, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')));
      }
    });

    test('every value maps back to itself by name', () {
      for (final icon in Oito2FreedesktopIcons.values) {
        expect(Oito2FreedesktopIcons.byName(icon.iconName), icon);
      }
    });

    test('every value draws a Lucide glyph', () {
      const lucide = LucideIcons.file;
      for (final icon in Oito2FreedesktopIcons.values) {
        expect(icon.icon.fontFamily, lucide.fontFamily, reason: icon.name);
        expect(icon.icon.fontPackage, lucide.fontPackage, reason: icon.name);
        // Lucide glyphs live in the Unicode private use area.
        expect(icon.icon.codePoint, inInclusiveRange(0xE000, 0xF8FF));
      }
    });

    test('includes the MIME type icons of the specification', () {
      for (final name in [
        'application-x-executable',
        'audio-x-generic',
        'font-x-generic',
        'image-x-generic',
        'package-x-generic',
        'text-html',
        'text-x-generic',
        'text-x-generic-template',
        'text-x-script',
        'video-x-generic',
        'x-office-address-book',
        'x-office-calendar',
        'x-office-document',
        'x-office-document-template',
        'x-office-drawing',
        'x-office-drawing-template',
        'x-office-presentation',
        'x-office-presentation-template',
        'x-office-spreadsheet',
        'x-office-spreadsheet-template',
      ]) {
        expect(
          Oito2FreedesktopIcons.values.map((i) => i.iconName),
          contains(name),
        );
      }
    });

    test('forMimeType maps MIME types to icons', () {
      const cases = {
        'application/pdf': Oito2FreedesktopIcons.xOfficeDocument,
        'application/msword': Oito2FreedesktopIcons.xOfficeDocument,
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
            Oito2FreedesktopIcons.xOfficeDocument,
        'application/vnd.oasis.opendocument.text':
            Oito2FreedesktopIcons.xOfficeDocument,
        'application/vnd.oasis.opendocument.text-template':
            Oito2FreedesktopIcons.xOfficeDocumentTemplate,
        'application/vnd.oasis.opendocument.spreadsheet':
            Oito2FreedesktopIcons.xOfficeSpreadsheet,
        'application/vnd.ms-excel': Oito2FreedesktopIcons.xOfficeSpreadsheet,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
            Oito2FreedesktopIcons.xOfficeSpreadsheet,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.template':
            Oito2FreedesktopIcons.xOfficeSpreadsheetTemplate,
        'text/csv': Oito2FreedesktopIcons.xOfficeSpreadsheet,
        'application/vnd.ms-powerpoint':
            Oito2FreedesktopIcons.xOfficePresentation,
        'application/vnd.openxmlformats-officedocument.presentationml.presentation':
            Oito2FreedesktopIcons.xOfficePresentation,
        'application/vnd.oasis.opendocument.presentation-template':
            Oito2FreedesktopIcons.xOfficePresentationTemplate,
        'application/vnd.oasis.opendocument.graphics':
            Oito2FreedesktopIcons.xOfficeDrawing,
        'text/calendar': Oito2FreedesktopIcons.xOfficeCalendar,
        'text/vcard': Oito2FreedesktopIcons.xOfficeAddressBook,
        'image/png': Oito2FreedesktopIcons.imageXGeneric,
        'image/svg+xml': Oito2FreedesktopIcons.imageXGeneric,
        'audio/ogg': Oito2FreedesktopIcons.audioXGeneric,
        'video/mp4': Oito2FreedesktopIcons.videoXGeneric,
        'font/woff2': Oito2FreedesktopIcons.fontXGeneric,
        'application/x-font-ttf': Oito2FreedesktopIcons.fontXGeneric,
        'text/html': Oito2FreedesktopIcons.textHtml,
        'text/plain': Oito2FreedesktopIcons.textXGeneric,
        'text/x-csrc': Oito2FreedesktopIcons.textXGeneric,
        'application/json': Oito2FreedesktopIcons.textXGeneric,
        'application/ld+json': Oito2FreedesktopIcons.textXGeneric,
        'text/x-python': Oito2FreedesktopIcons.textXScript,
        'application/x-shellscript': Oito2FreedesktopIcons.textXScript,
        'text/javascript': Oito2FreedesktopIcons.textXScript,
        'application/zip': Oito2FreedesktopIcons.packageXGeneric,
        'application/x-tar': Oito2FreedesktopIcons.packageXGeneric,
        'application/gzip': Oito2FreedesktopIcons.packageXGeneric,
        'application/x-7z-compressed': Oito2FreedesktopIcons.packageXGeneric,
        'application/vnd.rar': Oito2FreedesktopIcons.packageXGeneric,
        'application/x-executable':
            Oito2FreedesktopIcons.applicationXExecutable,
        'inode/directory': Oito2FreedesktopIcons.folder,
        'application/octet-stream': Oito2FreedesktopIcons.applicationXGeneric,
        'model/gltf+json': Oito2FreedesktopIcons.applicationXGeneric,
        'nonsense': Oito2FreedesktopIcons.applicationXGeneric,
        '': Oito2FreedesktopIcons.applicationXGeneric,
      };
      for (final MapEntry(key: mime, value: icon) in cases.entries) {
        expect(Oito2FreedesktopIcons.forMimeType(mime), icon, reason: mime);
      }
    });

    test('forMimeType ignores the case and parameters', () {
      expect(
        Oito2FreedesktopIcons.forMimeType('Text/HTML; charset=utf-8'),
        Oito2FreedesktopIcons.textHtml,
      );
    });
  });

  group('Oito2AnimatedIcon', () {
    testWidgets('once plays to the end and stops', (tester) async {
      final recorder = _Recorder();
      await pumpOito2(tester, Oito2AnimatedIcon(recorder.data));
      expect(recorder.frames.first, 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(recorder.frames.last, closeTo(0.5, 0.01));
      await tester.pumpAndSettle();
      expect(recorder.frames.last, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('repeat keeps playing', (tester) async {
      final recorder = _Recorder();
      await pumpOito2(
        tester,
        Oito2AnimatedIcon(recorder.data, mode: Oito2AnimationMode.repeat),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(recorder.frames.last, closeTo(0.2, 0.01));
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('still and disabled animations show the final frame', (
      tester,
    ) async {
      final still = _Recorder();
      await pumpOito2(
        tester,
        Oito2AnimatedIcon(still.data, mode: Oito2AnimationMode.still),
      );
      expect(still.frames, [1]);

      final reduced = _Recorder();
      await pumpOito2(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Oito2AnimatedIcon(
            reduced.data,
            mode: Oito2AnimationMode.repeat,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(reduced.frames, everyElement(1));
    });

    testWidgets('new data plays again', (tester) async {
      final first = _Recorder();
      final second = _Recorder();
      await pumpOito2(tester, Oito2AnimatedIcon(first.data));
      await tester.pumpAndSettle();
      await pumpOito2(tester, Oito2AnimatedIcon(second.data));
      expect(second.frames.first, 0);
      await tester.pumpAndSettle();
      expect(second.frames.last, 1);
    });

    testWidgets('size and color default to the icon theme', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: IconTheme(
            data: IconThemeData(size: 40),
            child: Oito2AnimatedIcon(Oito2AnimatedIcons.ok),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(Oito2AnimatedIcon)),
        const Size.square(40),
      );
    });

    testWidgets('a label makes it an image for assistive technologies', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const Column(
          children: [
            Oito2AnimatedIcon(Oito2AnimatedIcons.star, semanticLabel: 'Saved'),
            Oito2AnimatedIcon(Oito2AnimatedIcons.heart),
          ],
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Saved')),
        matchesSemantics(label: 'Saved', isImage: true),
      );
      expect(find.bySemanticsLabel(RegExp('.+')), findsOneWidget);
      handle.dispose();
    });
  });

  group('Oito2PlaceholderIcon', () {
    testWidgets('has the given size and no semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const Center(child: Oito2PlaceholderIcon(size: 64)),
      );
      expect(
        tester.getSize(find.byType(Oito2PlaceholderIcon)),
        const Size.square(64),
      );
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      handle.dispose();
    });
  });
}
