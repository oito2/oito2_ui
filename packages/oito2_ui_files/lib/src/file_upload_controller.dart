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

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

/// Why an [Oito2FileUploadController] refused a file.
enum Oito2FileRejection {
  /// The file type is not one of the accepted types.
  type,

  /// The file is larger than the size limit.
  size,

  /// The upload already holds the largest number of files.
  count,
}

/// A file an [Oito2FileUploadController] refused, with the reason.
@immutable
class Oito2RejectedFile {
  /// Creates a record of [file] refused for [reason].
  const Oito2RejectedFile(this.file, this.reason);

  /// The refused file.
  final XFile file;

  /// Why it was refused.
  final Oito2FileRejection reason;
}

/// Whether [file] is one of the [accept]ed types.
///
/// A type group matches when the file name ends with one of its
/// `extensions` (ignoring case and a leading dot), or when the file's MIME
/// type is one of its `mimeTypes` or `webWildCards`, where `image/*`
/// matches every image type. No groups, or a group with none of those
/// lists, accept every file.
bool oito2FileMatchesTypes(XFile file, List<XTypeGroup> accept) {
  if (accept.isEmpty) return true;
  final name = file.name.toLowerCase();
  final dot = name.lastIndexOf('.');
  final extension = dot < 0 ? null : name.substring(dot + 1);
  final mime = file.mimeType?.toLowerCase();
  bool mimeMatches(String pattern) {
    final wanted = pattern.toLowerCase();
    if (mime == null) return false;
    if (wanted.endsWith('/*')) {
      return mime.startsWith(wanted.substring(0, wanted.length - 1));
    }
    return mime == wanted;
  }

  for (final group in accept) {
    final extensions = group.extensions ?? const [];
    final mimeTypes = [...?group.mimeTypes, ...?group.webWildCards];
    if (extensions.isEmpty && mimeTypes.isEmpty) return true;
    for (final wanted in extensions) {
      final clean = wanted.toLowerCase().replaceFirst(RegExp(r'^\.'), '');
      if (clean == extension) return true;
    }
    if (mimeTypes.any(mimeMatches)) return true;
  }
  return false;
}

/// The files of a file upload, checked against the [accept]ed types,
/// [maxFileSize] and [maxFiles] as they are added.
///
/// [add] keeps the files that pass the checks and lists the others in
/// [rejected], which holds the refusals of the last [add] only.
class Oito2FileUploadController extends ChangeNotifier {
  /// Creates a controller holding [files] at first, unchecked.
  ///
  /// Asserts that [maxFiles] and [maxFileSize], when given, are positive.
  Oito2FileUploadController({
    this.accept = const [],
    this.maxFiles,
    this.maxFileSize,
    Iterable<XFile> files = const [],
  }) : assert(maxFiles == null || maxFiles > 0),
       assert(maxFileSize == null || maxFileSize > 0),
       _files = [...files];

  /// The accepted file types; empty accepts every file.
  final List<XTypeGroup> accept;

  /// The largest number of files, or null for no limit.
  final int? maxFiles;

  /// The largest file size, in bytes, or null for no limit.
  final int? maxFileSize;

  final List<XFile> _files;
  List<Oito2RejectedFile> _rejected = const [];
  bool _disposed = false;

  /// The last queued [add], which the next one waits for.
  Future<void> _queue = Future.value();

  /// The accepted files, in the order they were added.
  List<XFile> get files => List.unmodifiable(_files);

  /// The files refused by the last [add].
  List<Oito2RejectedFile> get rejected => _rejected;

  /// Whether more files can be added.
  bool get canAddMore => maxFiles == null || _files.length < maxFiles!;

  /// Adds the files of [incoming] that pass the checks, in order, and
  /// lists the others in [rejected].
  ///
  /// Reading the size of each file can take a moment, so this completes
  /// once every file is checked. Nothing changes when the controller is
  /// disposed meanwhile. A call made before an earlier one completes waits
  /// for it, so the limits hold across both.
  Future<void> add(Iterable<XFile> incoming) {
    final files = incoming.toList(growable: false);
    final next = _queue.then((_) => _add(files));
    _queue = next.catchError((Object _) {});
    return next;
  }

  /// Checks and adds [incoming] for [add], once earlier calls are done.
  Future<void> _add(List<XFile> incoming) async {
    final added = <XFile>[];
    final rejected = <Oito2RejectedFile>[];
    for (final file in incoming) {
      final Oito2FileRejection? reason;
      if (!oito2FileMatchesTypes(file, accept)) {
        reason = Oito2FileRejection.type;
      } else if (maxFileSize != null && await file.length() > maxFileSize!) {
        reason = Oito2FileRejection.size;
      } else if (maxFiles != null &&
          _files.length + added.length >= maxFiles!) {
        reason = Oito2FileRejection.count;
      } else {
        reason = null;
      }
      if (reason == null) {
        added.add(file);
      } else {
        rejected.add(Oito2RejectedFile(file, reason));
      }
    }
    if (_disposed) return;
    _files.addAll(added);
    _rejected = List.unmodifiable(rejected);
    notifyListeners();
  }

  /// Removes [file], if the controller holds it.
  void remove(XFile file) {
    if (_files.remove(file)) notifyListeners();
  }

  /// Removes every file and refusal.
  void clear() {
    if (_files.isEmpty && _rejected.isEmpty) return;
    _files.clear();
    _rejected = const [];
    notifyListeners();
  }

  /// Forgets the refusals of the last [add].
  void clearRejected() {
    if (_rejected.isEmpty) return;
    _rejected = const [];
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
