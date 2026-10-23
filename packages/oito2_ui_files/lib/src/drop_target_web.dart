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

import 'dart:js_interop';

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

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

  void _dragOver(web.DragEvent event) {
    final accepts = _accepts(event);
    if (accepts) {
      event.preventDefault();
      event.dataTransfer?.dropEffect = 'copy';
    }
    _setHovering(accepts);
  }

  void _dragLeave(web.DragEvent event) {
    // Leaving the window has no related target.
    if (event.relatedTarget == null) _setHovering(false);
  }

  void _drop(web.DragEvent event) {
    final accepts = _accepts(event);
    _setHovering(false);
    if (!accepts) return;
    event.preventDefault();
    final list = event.dataTransfer?.files;
    if (list == null) return;
    final files = [for (var i = 0; i < list.length; i++) ?list.item(i)];
    _read(files);
  }

  /// Reads the dropped files into memory, so they don't depend on blob
  /// URLs, and hands them over.
  Future<void> _read(List<web.File> files) async {
    final read = <XFile>[];
    for (final file in files) {
      final buffer = await file.arrayBuffer().toDart;
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
