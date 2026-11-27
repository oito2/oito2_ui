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
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

import 'directories.dart';
import 'drop_hit_test.dart';

/// Files dragged from the desktop can be dropped on the page.
const bool canDropFiles = true;

/// Receives files dropped on [child] through the browser's drag events.
Widget buildDropTarget({
  required Widget child,
  required bool enabled,
  required ValueChanged<bool> onHover,
  required ValueChanged<List<XFile>> onDrop,
}) => _WebDropTarget(
  enabled: enabled,
  onHover: onHover,
  onDrop: onDrop,
  child: child,
);

/// Listens to the page's drag events and reports the files dragged over
/// or dropped inside [child].
class _WebDropTarget extends StatefulWidget {
  const _WebDropTarget({
    required this.child,
    required this.enabled,
    required this.onHover,
    required this.onDrop,
  });

  final Widget child;
  final bool enabled;
  final ValueChanged<bool> onHover;
  final ValueChanged<List<XFile>> onDrop;

  @override
  State<_WebDropTarget> createState() => _WebDropTargetState();
}

class _WebDropTargetState extends State<_WebDropTarget> {
  late final JSFunction _onDragOver = _dragOver.toJS;
  late final JSFunction _onDragLeave = _dragLeave.toJS;
  late final JSFunction _onDrop = _drop.toJS;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    web.document
      ..addEventListener('dragover', _onDragOver)
      ..addEventListener('dragleave', _onDragLeave)
      ..addEventListener('drop', _onDrop);
  }

  @override
  void dispose() {
    web.document
      ..removeEventListener('dragover', _onDragOver)
      ..removeEventListener('dragleave', _onDragLeave)
      ..removeEventListener('drop', _onDrop);
    super.dispose();
  }

  /// Reports a change of the hover state to the widget's `onHover`.
  void _setHovering(bool hovering) {
    if (hovering == _hovering) return;
    _hovering = hovering;
    widget.onHover(hovering);
  }

  /// Whether the drag carries files and points at this widget, with
  /// nothing drawn over it there.
  bool _accepts(web.DragEvent event) {
    if (!widget.enabled || !mounted) return false;
    final types = event.dataTransfer?.types.toDart ?? const <JSString>[];
    if (!types.any((type) => type.toDart == 'Files')) return false;
    // Logical pixels of the Flutter view are CSS pixels; the view may not
    // start at the page origin.
    final view = web.document.querySelector('flutter-view');
    final origin = view?.getBoundingClientRect();
    final point = Offset(
      event.clientX - (origin?.left ?? 0),
      event.clientY - (origin?.top ?? 0),
    );
    return dropReaches(context, point);
  }

  /// Accepts a file drag over this widget as a copy and updates the hover
  /// state.
  void _dragOver(web.DragEvent event) {
    final accepts = _accepts(event);
    if (accepts) {
      event.preventDefault();
      event.dataTransfer?.dropEffect = 'copy';
    }
    _setHovering(accepts);
  }

  /// Clears the hover state when the drag leaves the window.
  void _dragLeave(web.DragEvent event) {
    // Leaving the window has no related target.
    if (event.relatedTarget == null) _setHovering(false);
  }

  /// Takes the items dropped inside this widget and keeps the browser from
  /// opening them; the items must be collected before the event handler
  /// returns.
  void _drop(web.DragEvent event) {
    final accepts = _accepts(event);
    _setHovering(false);
    if (!accepts) return;
    event.preventDefault();
    final list = event.dataTransfer?.items;
    if (list == null) return;
    final items = <_DroppedItem>[];
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (item.kind != 'file') continue;
      final entry = item.webkitGetAsEntry();
      if (entry != null && entry.isDirectory) {
        items.add((name: entry.name, file: null));
      } else if (item.getAsFile() case final file?) {
        items.add((name: file.name, file: file));
      }
    }
    _read(items);
  }

  /// Hands the dropped files over in order with the dropped directories,
  /// which are marked as such.
  ///
  /// The files carry their name, type, size and date from the browser's
  /// metadata and are read into memory only when their bytes are asked
  /// for, so the files a receiver refuses by type, size or count are never
  /// loaded.
  void _read(List<_DroppedItem> items) {
    final read = <XFile>[
      for (final (:name, :file) in items)
        file == null
            ? oito2MarkAsDirectory(XFile.fromData(Uint8List(0), name: name))
            : _DroppedFile(file),
    ];
    if (mounted && read.isNotEmpty) widget.onDrop(read);
  }

  @override
  Widget build(BuildContext context) => dropHitRegion(widget.child);
}

/// A dropped item: a file, or a directory when [file] is null.
typedef _DroppedItem = ({String name, web.File? file});

/// A dropped file that reads its bytes from the browser's [web.File] into
/// memory each time they are asked for, instead of when it is dropped.
///
/// Its name, MIME type, length and date come from the file's metadata. Its
/// [path] is empty: no object URL is created for it. Reading throws when
/// the browser can no longer read the file, such as when it was removed
/// from the disk after the drop.
class _DroppedFile extends XFile {
  _DroppedFile(this._file)
    : super(
        '',
        name: _file.name,
        mimeType: _file.type.isEmpty ? null : _file.type,
        length: _file.size,
        lastModified: DateTime.fromMillisecondsSinceEpoch(_file.lastModified),
      );

  final web.File _file;

  @override
  Future<Uint8List> readAsBytes() async =>
      (await _file.arrayBuffer().toDart).toDart.asUint8List();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async =>
      encoding.decode(await readAsBytes());

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    final slice = _file.slice(start ?? 0, end ?? _file.size);
    yield (await slice.arrayBuffer().toDart).toDart.asUint8List();
  }

  /// Reads the bytes and saves them as an in-memory file would.
  @override
  Future<void> saveTo(String path) async => XFile.fromData(
    await readAsBytes(),
    name: name,
    mimeType: mimeType,
  ).saveTo(path);
}
