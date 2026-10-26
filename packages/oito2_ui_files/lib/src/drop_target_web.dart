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

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

import 'directories.dart';

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

  /// Whether the drag carries files and points inside this widget.
  bool _accepts(web.DragEvent event) {
    if (!widget.enabled || !mounted) return false;
    final types = event.dataTransfer?.types.toDart ?? const <JSString>[];
    if (!types.any((type) => type.toDart == 'Files')) return false;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return false;
    // Logical pixels of the Flutter view are CSS pixels; the view may not
    // start at the page origin.
    final view = web.document.querySelector('flutter-view');
    final origin = view?.getBoundingClientRect();
    final point = Offset(
      event.clientX - (origin?.left ?? 0),
      event.clientY - (origin?.top ?? 0),
    );
    return (box.localToGlobal(Offset.zero) & box.size).contains(point);
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

  /// Reads the dropped files into memory, so they don't depend on blob
  /// URLs, and hands them over in order with the dropped directories,
  /// which are marked as such; files the browser can't read are skipped.
  Future<void> _read(List<_DroppedItem> items) async {
    final read = <XFile>[];
    for (final (:name, :file) in items) {
      if (file == null) {
        read.add(markAsDirectory(XFile.fromData(Uint8List(0), name: name)));
        continue;
      }
      final JSArrayBuffer buffer;
      try {
        buffer = await file.arrayBuffer().toDart;
      } catch (_) {
        continue;
      }
      read.add(
        XFile.fromData(
          buffer.toDart.asUint8List(),
          name: file.name,
          mimeType: file.type.isEmpty ? null : file.type,
          length: file.size,
          lastModified: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
        ),
      );
    }
    if (mounted && read.isNotEmpty) widget.onDrop(read);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A dropped item: a file, or a directory when [file] is null.
typedef _DroppedItem = ({String name, web.File? file});
