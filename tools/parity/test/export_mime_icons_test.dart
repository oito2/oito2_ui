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

// Writes the freedesktop icon name Oito2FreedesktopIcons.forMimeType picks
// for a fixed table of MIME types as a JSON fixture.

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'support.dart';

/// MIME types covering every branch of the lookup.
const mimeTypes = [
  // Empty, malformed and unknown.
  '',
  'nonsense',
  'application/octet-stream',
  'chemical/x-pdb',
  'model/gltf+json',
  'x-unknown/thing',
  // Case and parameters.
  'Text/HTML; charset=utf-8',
  'APPLICATION/PDF',
  'text/plain;charset=UTF-8',
  ' image/png ',
  // Directories.
  'inode/directory',
  'inode/mount-point',
  'inode/symlink',
  // Documents.
  'text/html',
  'application/xhtml+xml',
  'application/pdf',
  'application/rtf',
  'text/rtf',
  'application/epub+zip',
  'application/msword',
  'application/vnd.ms-word.document.macroenabled.12',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
  'application/vnd.oasis.opendocument.text',
  'application/vnd.oasis.opendocument.text-template',
  'application/vnd.sun.xml.writer',
  // Spreadsheets.
  'text/csv',
  'text/tab-separated-values',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
  'application/vnd.oasis.opendocument.spreadsheet',
  'application/vnd.oasis.opendocument.spreadsheet-template',
  'application/vnd.sun.xml.calc',
  // Presentations.
  'application/vnd.ms-powerpoint',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'application/vnd.openxmlformats-officedocument.presentationml.template',
  'application/vnd.oasis.opendocument.presentation',
  'application/vnd.oasis.opendocument.presentation-template',
  'application/vnd.sun.xml.impress',
  // Drawings.
  'application/vnd.oasis.opendocument.graphics',
  'application/vnd.oasis.opendocument.graphics-template',
  'application/vnd.visio',
  'application/vnd.sun.xml.draw',
  'image/vnd.dxf',
  // Calendars and contacts.
  'text/calendar',
  'application/ics',
  'text/vcard',
  'text/x-vcard',
  'text/directory',
  // Structured text.
  'application/json',
  'application/ld+json',
  'application/geo+json',
  'application/xml',
  'application/atom+xml',
  'text/xml',
  'application/yaml',
  'application/toml',
  'application/sql',
  'text/markdown',
  'text/x-csrc',
  'text/plain',
  'text/x-template',
  // Scripts.
  'text/x-python',
  'text/x-python3',
  'application/x-shellscript',
  'application/x-sh',
  'text/javascript',
  'application/javascript',
  'application/ecmascript',
  'text/x-perl',
  'application/x-php',
  'text/x-lua',
  'application/x-ruby',
  'application/x-powershell',
  'text/x-r',
  // Archives and packages.
  'application/zip',
  'application/x-zip-compressed',
  'application/gzip',
  'application/x-gzip',
  'application/x-tar',
  'application/x-compressed-tar',
  'application/x-xz-compressed-tar',
  'application/x-7z-compressed',
  'application/vnd.rar',
  'application/x-rar',
  'application/zstd',
  'application/java-archive',
  'application/vnd.debian.binary-package',
  'application/x-rpm',
  'application/vnd.android.package-archive',
  'application/vnd.flatpak',
  'application/vnd.snap',
  // Programs.
  'application/x-executable',
  'application/x-elf',
  'application/x-pie-executable',
  'application/x-sharedlib',
  'application/x-msdownload',
  'application/x-msi',
  'application/x-mach-binary',
  'application/vnd.microsoft.portable-executable',
  'application/vnd.appimage',
  // Fonts.
  'font/ttf',
  'font/woff2',
  'application/x-font-ttf',
  'application/font-woff',
  'application/vnd.ms-fontobject',
  // Media.
  'image/png',
  'image/svg+xml',
  'image/x-icon',
  'audio/ogg',
  'audio/mpeg',
  'video/mp4',
  'video/x-matroska',
  'text/x-shellscript',
  'audio/x-template',
];

void main() {
  test('exports the MIME type icons', () {
    final file = writeFixture('mime_icons.json', {
      'forMimeType': [
        for (final mimeType in mimeTypes)
          {
            'mimeType': mimeType,
            'iconName': Oito2FreedesktopIcons.forMimeType(mimeType).iconName,
          },
      ],
    });
    expect(file.existsSync(), isTrue);
  });
}
