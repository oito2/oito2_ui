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

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'drop_target.dart';

/// A dashed box that opens the file chooser when activated and, where the
/// platform supports it, receives files dropped on it.
///
/// The chosen or dropped files go to [onFiles] unchecked; an
/// `Oito2FileUploadController` checks them against its limits. [accept]
/// filters the file chooser. Drops come from [dropTargetBuilder], or from
/// [oito2PlatformDropTarget] (the web only) when it is null.
class Oito2FileDropZone extends StatefulWidget {
  /// Creates a file drop zone.
  const Oito2FileDropZone({
    super.key,
    required this.onFiles,
    this.accept = const [],
    this.multiple = true,
    this.enabled = true,
    this.hint,
    this.dropTargetBuilder,
    this.minHeight = 160,
  });

  /// Receives the chosen or dropped files.
  final ValueChanged<List<XFile>> onFiles;

  /// The file types the file chooser offers; empty offers every file.
  final List<XTypeGroup> accept;

  /// Whether several files can be chosen at once.
  final bool multiple;

  /// Whether the zone opens the chooser and receives drops.
  final bool enabled;

  /// A line under the title, such as the accepted types and sizes.
  final Widget? hint;

  /// The source of dropped files; null uses [oito2PlatformDropTarget].
  final Oito2FileDropTargetBuilder? dropTargetBuilder;

  /// The smallest height of the zone.
  final double minHeight;

  @override
  State<Oito2FileDropZone> createState() => _Oito2FileDropZoneState();
}

class _Oito2FileDropZoneState extends State<Oito2FileDropZone> {
  bool _dragging = false;

  bool get _canDrop => widget.dropTargetBuilder != null || oito2CanDropFiles;

  Future<void> _choose() async {
    final files = widget.multiple
        ? await openFiles(acceptedTypeGroups: widget.accept)
        : [?await openFile(acceptedTypeGroups: widget.accept)];
    if (files.isNotEmpty && mounted) widget.onFiles(files);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final accent =
        theme.extension<Oito2SemanticColors>()?.primaryText ?? scheme.primary;
    final enabled = widget.enabled;
    final active = _dragging && enabled;
    final choose = widget.multiple ? strings.chooseFiles : strings.chooseFile;
    final hint = widget.hint;
    final content = Padding(
      padding: const EdgeInsets.all(Oito2Spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Oito2Spacing.sm,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Oito2Spacing.sm),
              child: Icon(
                LucideIcons.upload,
                color: active ? accent : scheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            _canDrop ? strings.dropFilesHere : choose,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          if (hint != null)
            DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              child: hint,
            ),
          if (_canDrop)
            // The whole zone is the button; this only shows where to click.
            ExcludeSemantics(
              child: IgnorePointer(
                child: OutlinedButton(
                  onPressed: enabled ? () {} : null,
                  child: Text(choose),
                ),
              ),
            ),
        ],
      ),
    );
    Widget zone = CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: active ? accent : scheme.outline,
        radius: Oito2Radius.large,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? _choose : null,
          borderRadius: Oito2Radius.largeAll,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            constraints: BoxConstraints(minHeight: widget.minHeight),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? accent.withValues(alpha: 0.08)
                  : scheme.surfaceContainerLow,
              borderRadius: Oito2Radius.largeAll,
            ),
            child: content,
          ),
        ),
      ),
    );
    zone = Semantics(button: true, label: choose, child: zone);
    if (!enabled) zone = Opacity(opacity: 0.5, child: zone);
    final build = widget.dropTargetBuilder ?? oito2PlatformDropTarget;
    return build(
      enabled: enabled,
      onHover: (dragging) => setState(() => _dragging = dragging),
      onDrop: widget.onFiles,
      child: zone,
    );
  }
}

/// Paints a dashed rounded rectangle along the edges of its box.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 6.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          Radius.circular(radius),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
