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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_files/oito2_ui_files.dart';

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2FileUpload] with type, size and count limits, and a bare
/// [Oito2FileDropZone].
class FileUploadPage extends StatefulWidget {
  /// Creates the file upload page.
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
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
  final _document = Oito2FileUploadController(maxFiles: 1);
  List<XFile> _received = const [];

  @override
  void dispose() {
    _images.dispose();
    _document.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = Oito2Format.of(context);
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Images: up to 4, 5 MB each, with previews',
          children: [
            SizedBox(width: 420, child: Oito2FileUpload(controller: _images)),
          ],
        ),
        ShowcaseSection(
          'One file of any type',
          children: [
            SizedBox(
              width: 420,
              child: Oito2FileUpload(
                controller: _document,
                showPreviews: false,
                zoneMinHeight: 120,
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'A bare drop zone; files are dropped on the web only',
          children: [
            SizedBox(
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Oito2Spacing.sm,
                children: [
                  Oito2FileDropZone(
                    minHeight: 120,
                    hint: Text(
                      oito2CanDropFiles
                          ? 'Drag files from your desktop or click'
                          : 'Dropping files works in the web build',
                    ),
                    onFiles: (files) => setState(() => _received = files),
                  ),
                  for (final file in _received)
                    FutureBuilder<int>(
                      future: file.length(),
                      builder: (context, size) => Text(
                        '${file.name} — ${size.hasData ? format.bytes(size.data!) : '…'}',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
