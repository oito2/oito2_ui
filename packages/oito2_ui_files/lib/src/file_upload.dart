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
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'drop_target.dart';
import 'file_drop_zone.dart';
import 'file_upload_controller.dart';

/// A file upload: an [Oito2FileDropZone] that adds files to [controller],
/// the files refused by the last addition with the reasons, and the list
/// of accepted files with their size, a preview of images and a remove
/// button.
///
/// The zone hint defaults to the accepted types and the size limit of the
/// controller; the zone is disabled once the controller holds its largest
/// number of files.
class Oito2FileUpload extends StatefulWidget {
  /// Creates a file upload.
  const Oito2FileUpload({
    super.key,
    required this.controller,
    this.hint,
    this.showPreviews = true,
    this.enabled = true,
    this.dropTargetBuilder,
    this.zoneMinHeight = 160,
  });

  /// The controller that holds the files and checks their limits.
  final Oito2FileUploadController controller;

  /// Replaces the default zone hint, which lists the accepted types and
  /// the size limit.
  final Widget? hint;

  /// Whether image files show a thumbnail.
  final bool showPreviews;

  /// Whether files can be added and removed.
  final bool enabled;

  /// The source of dropped files; see [Oito2FileDropZone.dropTargetBuilder].
  final Oito2FileDropTargetBuilder? dropTargetBuilder;

  /// The smallest height of the drop zone, in logical pixels.
  final double zoneMinHeight;

  @override
  State<Oito2FileUpload> createState() => _Oito2FileUploadState();
}

class _Oito2FileUploadState extends State<Oito2FileUpload> {
  final Map<XFile, Future<int>> _sizes = {};
  final Map<XFile, Future<Uint8List>> _previews = {};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(Oito2FileUpload oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
      _onChange();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  /// Rebuilds and forgets the sizes and previews of removed files.
  void _onChange() {
    final files = widget.controller.files.toSet();
    _sizes.removeWhere((file, _) => !files.contains(file));
    _previews.removeWhere((file, _) => !files.contains(file));
    setState(() {});
  }

  /// The localized accepted types and size limit of the controller, or
  /// null when it has neither.
  String? _defaultHint(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final controller = widget.controller;
    final parts = <String>[
      if (controller.accept.isNotEmpty)
        strings.acceptedFileTypes(
          controller.accept
              .map((group) => group.label ?? group.extensions?.join(', '))
              .whereType<String>()
              .join(', '),
        ),
      if (controller.maxFileSize case final max?)
        strings.maxFileSizeHint(Oito2Format.of(context).bytes(max)),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// The localized message that explains why [rejected] was refused.
  String _reason(BuildContext context, Oito2RejectedFile rejected) {
    final strings = Oito2Localizations.of(context);
    final name = rejected.file.name;
    final controller = widget.controller;
    return switch (rejected.reason) {
      Oito2FileRejection.type => strings.fileTypeNotAccepted(name),
      Oito2FileRejection.size => strings.fileTooLarge(
        name,
        Oito2Format.of(context).bytes(controller.maxFileSize ?? 0),
      ),
      Oito2FileRejection.count => strings.tooManyFiles(
        name,
        controller.maxFiles ?? 0,
      ),
      Oito2FileRejection.directory => strings.folderNotAccepted(name),
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final defaultHint = _defaultHint(context);
    final rejected = controller.rejected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: Oito2Spacing.sm,
      children: [
        Oito2FileDropZone(
          onFiles: controller.add,
          accept: controller.accept,
          multiple: controller.maxFiles != 1,
          enabled: widget.enabled && controller.canAddMore,
          hint: widget.hint ?? (defaultHint == null ? null : Text(defaultHint)),
          dropTargetBuilder: widget.dropTargetBuilder,
          minHeight: widget.zoneMinHeight,
        ),
        if (rejected.isNotEmpty)
          Oito2InfoBox(
            type: Oito2InfoType.danger,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final file in rejected) Text(_reason(context, file)),
              ],
            ),
            trailing: IconButton(
              onPressed: controller.clearRejected,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(LucideIcons.x),
            ),
          ),
        for (final file in controller.files)
          _FileRow(
            key: ObjectKey(file),
            file: file,
            size: _sizes.putIfAbsent(file, file.length),
            preview: widget.showPreviews && _isImage(file)
                ? _previews.putIfAbsent(file, file.readAsBytes)
                : null,
            onRemove: widget.enabled ? () => controller.remove(file) : null,
          ),
      ],
    );
  }
}

/// The file extensions of the image formats that get a preview.
const _imageExtensions = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'};

/// Whether [file] is an image Flutter can decode, by MIME type or name.
bool _isImage(XFile file) {
  final mime = file.mimeType;
  if (mime != null) return mime.startsWith('image/') && mime != 'image/svg+xml';
  final name = file.name.toLowerCase();
  final dot = name.lastIndexOf('.');
  return dot >= 0 && _imageExtensions.contains(name.substring(dot + 1));
}

/// A file of the upload list: a thumbnail or file icon, the name and size,
/// and a remove button.
class _FileRow extends StatelessWidget {
  const _FileRow({
    super.key,
    required this.file,
    required this.size,
    required this.preview,
    required this.onRemove,
  });

  final XFile file;
  final Future<int> size;
  final Future<Uint8List>? preview;
  final VoidCallback? onRemove;

  static const _thumbnail = 40.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final icon = Icon(LucideIcons.file, color: scheme.onSurfaceVariant);
    final preview = this.preview;
    final thumbnail = ClipRRect(
      borderRadius: Oito2Radius.smallAll,
      child: Container(
        width: _thumbnail,
        height: _thumbnail,
        color: scheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: preview == null
            ? icon
            : FutureBuilder<Uint8List>(
                future: preview,
                builder: (context, snapshot) {
                  final bytes = snapshot.data;
                  if (bytes == null) return icon;
                  return Image.memory(
                    bytes,
                    width: _thumbnail,
                    height: _thumbnail,
                    fit: BoxFit.cover,
                    cacheWidth:
                        (_thumbnail * MediaQuery.devicePixelRatioOf(context))
                            .round(),
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => icon,
                  );
                },
              ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(Oito2Spacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: Oito2Radius.mediumAll,
      ),
      child: Row(
        spacing: Oito2Spacing.sm,
        children: [
          thumbnail,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                FutureBuilder<int>(
                  future: size,
                  builder: (context, snapshot) => Text(
                    snapshot.hasData
                        ? Oito2Format.of(context).bytes(snapshot.data!)
                        : '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              tooltip: strings.removeItem(file.name),
              icon: const Icon(LucideIcons.x),
            ),
        ],
      ),
    );
  }
}
