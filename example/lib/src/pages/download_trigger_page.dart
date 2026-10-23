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

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_files/oito2_ui_files.dart';

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2DownloadTrigger] saving text built on demand, and slowly.
class DownloadTriggerPage extends StatefulWidget {
  /// Creates the download trigger page.
  const DownloadTriggerPage({super.key});

  @override
  State<DownloadTriggerPage> createState() => _DownloadTriggerPageState();
}

class _DownloadTriggerPageState extends State<DownloadTriggerPage> {
  final _controller = TextEditingController(text: 'Hello from oito2_ui_files!');
  String _status = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Shows whether the file was [saved] or the save was canceled.
  void _report(bool saved) =>
      setState(() => _status = saved ? 'Saved.' : 'Canceled.');

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          Oito2Downloads.isSupported
              ? 'Save the text as a file'
              : 'Saving files is not available on this platform',
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ),
            Oito2DownloadTrigger(
              fileName: 'hello.txt',
              mimeType: 'text/plain',
              data: () async =>
                  Uint8List.fromList(utf8.encode(_controller.text)),
              onSaved: _report,
            ),
          ],
        ),
        ShowcaseSection(
          'Data built slowly, with a custom label',
          children: [
            Oito2DownloadTrigger(
              fileName: 'report.csv',
              mimeType: 'text/csv',
              label: const Text('Export CSV'),
              data: () async {
                await Future<void>.delayed(const Duration(seconds: 2));
                return Uint8List.fromList(
                  utf8.encode('name,size\nalpha,1\nbeta,2\n'),
                );
              },
              onSaved: _report,
              onError: (error, _) => setState(() => _status = '$error'),
            ),
            if (_status.isNotEmpty) Text(_status),
          ],
        ),
      ],
    );
  }
}
