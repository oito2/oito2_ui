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
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_files/oito2_ui_files.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2DownloadTrigger] and [Oito2Downloads]: saving bytes
/// built on demand, slow data with a custom label, and a disabled button.
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
    return DocPage(
      title: 'Download Trigger',
      description:
          'A button that builds a file on demand and saves it: a download '
          'on the web, the "Save as" dialog on desktop.',
      source: 'lib/src/pages/download_trigger_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                Align(
                  // #region preview
                  child: Oito2DownloadTrigger(
                    fileName: 'hello.txt',
                    mimeType: 'text/plain',
                    data: () async =>
                        Uint8List.fromList(utf8.encode(_controller.text)),
                    onSaved: _report,
                  ),
                  // #endregion
                ),
                if (_status.isNotEmpty)
                  Text(_status, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give the trigger the suggested `fileName` and a `data` function '
          'that returns the bytes; it runs only when the button is '
          'activated. `mimeType` types the file, a generic binary file when '
          'null. `onSaved` reports whether the file was saved, and is false '
          'when the user cancels the "Save as" dialog; a web download '
          'always reports true.',
        ),
        const DocCode("import 'package:oito2_ui_files/oito2_ui_files.dart';"),
        const DocNote(
          'Saving works on the web, Linux, Windows and macOS, not on Android '
          'or iOS. `Oito2Downloads.isSupported` tells which; where it is '
          'false the trigger is disabled and its tooltip says why. To save '
          'bytes without a button, call `Oito2Downloads.save`.',
        ),
        Text(
          Oito2Downloads.isSupported
              ? 'This platform can save files.'
              : 'Saving files is not available on this platform.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Slow data and a custom label', level: 3),
        const DocText(
          'While `data` runs the button shows a spinner and ignores taps. '
          '`label` replaces the localized "Download" text. `onError` '
          'receives a failure of `data` or of saving; without it the error '
          'is rethrown as an unhandled asynchronous error.',
        ),
        ExamplePanel(
          region: 'slow',
          // #region slow
          child: Oito2DownloadTrigger(
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
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText('With `enabled: false` the button can\'t be activated.'),
        ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2DownloadTrigger(
            fileName: 'empty.txt',
            enabled: false,
            data: () async => Uint8List(0),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The trigger is an outlined button with a download icon and a '
          'text label, so assistive technologies read the label. Report '
          'the outcome in `onSaved` and `onError` in a way that does not '
          'rely on sight alone, such as a status text or a toast.',
        ),
        ...apiReferenceWidgets(['Oito2DownloadTrigger', 'Oito2Downloads']),
      ],
    );
  }
}
