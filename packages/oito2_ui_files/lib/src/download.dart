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

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'download_io.dart'
    if (dart.library.js_interop) 'download_web.dart'
    as platform;

/// Saves bytes as a file on the device: a download on the web, the
/// "Save as" dialog on Linux, Windows and macOS.
abstract final class Oito2Downloads {
  /// Whether this platform can save files: the web and desktop platforms,
  /// not Android or iOS.
  static bool get isSupported => platform.canSaveFiles;

  /// Saves [bytes] as [fileName], typed as [mimeType] when given.
  ///
  /// Returns false when the user cancels the "Save as" dialog, and true
  /// otherwise; a web download always returns true. Throws an
  /// [UnsupportedError] when not [isSupported].
  static Future<bool> save({
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
  }) => platform.saveFile(fileName: fileName, bytes: bytes, mimeType: mimeType);
}

/// A button that saves a file built on demand with [Oito2Downloads].
///
/// A tap awaits [data], showing a spinner, and saves the bytes as
/// [fileName]. [onSaved] reports whether the file was saved, and [onError]
/// receives a failure of [data] or of saving. On platforms that can't
/// save files, the button is disabled and its tooltip says why.
class Oito2DownloadTrigger extends StatefulWidget {
  /// Creates a download trigger.
  const Oito2DownloadTrigger({
    super.key,
    required this.fileName,
    required this.data,
    this.mimeType,
    this.label,
    this.onSaved,
    this.onError,
    this.enabled = true,
  });

  /// The suggested file name.
  final String fileName;

  /// Builds the file content when the button is activated.
  final Future<Uint8List> Function() data;

  /// The MIME type of the file, or null for a generic binary file.
  final String? mimeType;

  /// The button label; defaults to the localized "Download".
  final Widget? label;

  /// Called after a save with whether the file was saved.
  final ValueChanged<bool>? onSaved;

  /// Called when building or saving the file fails; without it the error
  /// is rethrown as an unhandled asynchronous error.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Whether the button can be activated.
  final bool enabled;

  @override
  State<Oito2DownloadTrigger> createState() => _Oito2DownloadTriggerState();
}

class _Oito2DownloadTriggerState extends State<Oito2DownloadTrigger> {
  bool _busy = false;

  /// Builds and saves the file, showing the spinner meanwhile.
  Future<void> _download() async {
    setState(() => _busy = true);
    try {
      final bytes = await widget.data();
      final saved = await Oito2Downloads.save(
        fileName: widget.fileName,
        bytes: bytes,
        mimeType: widget.mimeType,
      );
      widget.onSaved?.call(saved);
    } catch (error, stackTrace) {
      final onError = widget.onError;
      if (onError == null) rethrow;
      onError(error, stackTrace);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final supported = Oito2Downloads.isSupported;
    final button = OutlinedButton.icon(
      onPressed: supported && widget.enabled && !_busy ? _download : null,
      icon: _busy
          ? const Oito2CircularProgressIndicator(size: Oito2Sizes.iconSize)
          : const Icon(LucideIcons.download),
      label: widget.label ?? Text(strings.download),
    );
    return supported
        ? button
        : Tooltip(message: strings.downloadUnavailable, child: button);
  }
}
