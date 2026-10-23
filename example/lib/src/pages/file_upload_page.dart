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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_files/oito2_ui_files.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2FileUpload] with type, size and count limits, and a
/// bare [Oito2FileDropZone].
class FileUploadPage extends StatefulWidget {
  /// Creates the file upload page.
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  // #region images-data
  final _images = Oito2FileUploadController(
    accept: const [
      XTypeGroup(
        label: 'PNG, JPEG, WebP',
        extensions: ['png', 'jpg', 'jpeg', 'webp'],
        mimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
      ),
    ],
    maxFiles: 4,
    maxFileSize: 5 * 1000 * 1000,
  );
  // #endregion
  // #region document-data
  final _document = Oito2FileUploadController(maxFiles: 1);
  // #endregion
  final _locked = Oito2FileUploadController();

  /// The files of the bare zone's last drop or choice, with their sizes,
  /// read once per file.
  List<(XFile, Future<int>)> _received = const [];

  @override
  void dispose() {
    _images.dispose();
    _document.dispose();
    _locked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = Oito2Format.of(context);
    return DocPage(
      title: 'File Upload',
      description:
          'Adds files from the file chooser or a drop, checks their type, '
          'size and count, and lists them with previews and remove buttons.',
      source: 'lib/src/pages/file_upload_page.dart',
      children: [
        ExamplePanel(
          regions: const ['images-data', 'preview'],
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2FileUpload(controller: _images),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'An `Oito2FileUploadController` holds the files and their limits: '
          'the `accept`ed types, `maxFiles` and `maxFileSize` in bytes, '
          'each unlimited when left out. Give it to `Oito2FileUpload`, read '
          'the accepted files from `files`, and dispose of it with its '
          'state.',
        ),
        const DocCode("import 'package:oito2_ui_files/oito2_ui_files.dart';"),
        const DocText(
          '`add` keeps the files that pass the checks and lists the others, '
          'with the reason, in `rejected`, which holds the refusals of the '
          'last addition only. The upload shows those refusals above the '
          'list, and disables its zone once the controller holds `maxFiles` '
          'files. The zone hint defaults to the accepted types and the size '
          'limit.',
        ),
        const DocNote(
          'Files can be dropped on the zone in the web build only. On other '
          'platforms the zone opens the file chooser, unless a '
          '`dropTargetBuilder` brings drops from another source, such as a '
          'desktop drag-and-drop plugin. `oito2CanDropFiles` says whether '
          'the platform receives drops.',
        ),
        const DocHeading('Examples'),
        const DocHeading('One file of any type', level: 3),
        const DocText(
          'With `maxFiles: 1` the file chooser picks one file. '
          '`showPreviews: false` drops the image thumbnails, and '
          '`zoneMinHeight` makes the zone shorter.',
        ),
        ExamplePanel(
          regions: const ['document-data', 'document'],
          child: SizedBox(
            width: 420,
            // #region document
            child: Oito2FileUpload(
              controller: _document,
              showPreviews: false,
              zoneMinHeight: 120,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'With `enabled: false` files can be neither added nor removed, and '
          'the zone fades.',
        ),
        ExamplePanel(
          region: 'disabled',
          child: SizedBox(
            width: 420,
            // #region disabled
            child: Oito2FileUpload(
              controller: _locked,
              enabled: false,
              zoneMinHeight: 120,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Bare drop zone', level: 3),
        const DocText(
          '`Oito2FileDropZone` is the dashed zone alone: it hands the chosen '
          'or dropped files to `onFiles` unchecked, for your own handling. '
          '`accept` filters the file chooser and `multiple` lets it pick '
          'several files.',
        ),
        ExamplePanel(
          region: 'zone',
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Oito2Spacing.sm,
              children: [
                // #region zone
                Oito2FileDropZone(
                  minHeight: 120,
                  hint: Text(
                    oito2CanDropFiles
                        ? 'Drag files from your desktop or click'
                        : 'Dropping files works in the web build',
                  ),
                  onFiles: (files) => setState(
                    () => _received = [
                      for (final file in files) (file, file.length()),
                    ],
                  ),
                ),
                for (final (file, length) in _received)
                  FutureBuilder<int>(
                    future: length,
                    builder: (context, size) => Text(
                      '${file.name} — ${size.hasData ? format.bytes(size.data!) : '…'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The zone is a single button named "Choose files", or "Choose a '
          'file" when it takes one file, and is reported as disabled when '
          'it can\'t take more. Each listed file has a remove button whose '
          'tooltip names the file, and the box of refused files explains '
          'each refusal in text.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the zone and the remove buttons.'],
            [
              '`Enter` / `Space`',
              'Opens the file chooser from the zone, or removes the focused '
                  'file.',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2FileUpload',
          'Oito2FileUploadController',
          'Oito2FileRejection',
          'Oito2RejectedFile',
          'Oito2FileDropZone',
          'Oito2FileDropTargetBuilder',
          'oito2CanDropFiles',
          'oito2PlatformDropTarget',
          'oito2FileMatchesTypes',
        ]),
      ],
    );
  }
}
