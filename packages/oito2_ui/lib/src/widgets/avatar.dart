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

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/contrast.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/colors.dart';
import 'widget_helpers.dart';

/// A presence status shown as a dot on an [Oito2Avatar].
enum Oito2AvatarStatus {
  /// Available.
  online,

  /// Away from the device.
  away,

  /// Not to be disturbed.
  busy,

  /// Not connected.
  offline,
}

/// The outline of an [Oito2Avatar].
enum Oito2AvatarShape {
  /// A circle.
  circle,

  /// A rounded square.
  square,
}

/// The initials of [name]: the first letters of its first and last words,
/// in upper case. A letter is a whole user-perceived character, so
/// decomposed accents and emoji sequences stay intact.
String oito2Initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '';
  String first(String word) => word.characters.first;
  final letters = words.length == 1
      ? first(words.first)
      : first(words.first) + first(words.last);
  return letters.toUpperCase();
}

/// A picture of a person or thing: [image] when it loads, otherwise the
/// initials of [name] on a color picked from the name, otherwise [icon].
///
/// The initials show while the image loads and if it fails. A [status]
/// adds a presence dot at the bottom end. Assistive technologies read
/// [name] and the status.
class Oito2Avatar extends StatelessWidget {
  /// Creates an avatar.
  const Oito2Avatar({
    super.key,
    this.image,
    this.name,
    this.icon = LucideIcons.user_round,
    this.size = 40,
    this.shape = Oito2AvatarShape.circle,
    this.status,
    this.backgroundColor,
  });

  /// The picture.
  final ImageProvider? image;

  /// The name the initials, the color and the accessibility label come
  /// from.
  final String? name;

  /// The fallback when there is no name.
  final IconData icon;

  /// The width and height.
  final double size;

  /// The outline.
  final Oito2AvatarShape shape;

  /// The presence status, or null for none.
  final Oito2AvatarStatus? status;

  /// The fallback background; defaults to a color picked from [name].
  final Color? backgroundColor;

  BorderRadius get _radius => shape == Oito2AvatarShape.circle
      ? BorderRadius.circular(size / 2)
      : BorderRadius.circular(size * 0.22);

  Color _background(ColorScheme scheme) {
    final name = this.name;
    if (backgroundColor != null) return backgroundColor!;
    if (name == null || name.trim().isEmpty) {
      return scheme.surfaceContainerHighest;
    }
    const accents = Oito2AccentColor.values;
    final hash = name.codeUnits.fold(0, (h, c) => (h * 31 + c) & 0x7fffffff);
    return accents[hash % accents.length].color;
  }

  String _statusLabel(Oito2Localizations strings) => switch (status!) {
    Oito2AvatarStatus.online => strings.statusOnline,
    Oito2AvatarStatus.away => strings.statusAway,
    Oito2AvatarStatus.busy => strings.statusBusy,
    Oito2AvatarStatus.offline => strings.statusOffline,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = semanticColorsOf(context);
    final strings = Oito2Localizations.of(context);
    final background = _background(scheme);
    final foreground = name == null || name!.trim().isEmpty
        ? scheme.onSurfaceVariant
        : Oito2Contrast.foregroundFor(background);
    final initials = name == null ? '' : oito2Initials(name!);
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: background,
      child: initials.isEmpty
          ? Icon(icon, size: size * 0.55, color: foreground)
          : Text(
              initials,
              maxLines: 1,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
    );
    final image = this.image;
    Widget picture = ClipRRect(
      borderRadius: _radius,
      child: image == null
          ? fallback
          : Image(
              image: image,
              width: size,
              height: size,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, synchronous) =>
                  frame == null && !synchronous ? fallback : child,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
    final status = this.status;
    if (status != null) {
      final dot = (size * 0.28).clamp(8.0, 16.0);
      final color = switch (status) {
        Oito2AvatarStatus.online => semantic.success,
        Oito2AvatarStatus.away => semantic.warning,
        Oito2AvatarStatus.busy => semantic.errorText,
        Oito2AvatarStatus.offline => scheme.outline,
      };
      picture = Stack(
        clipBehavior: Clip.none,
        children: [
          picture,
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: dot * 0.18,
                ),
              ),
            ),
          ),
        ],
      );
    }
    final label = [?name, if (status != null) _statusLabel(strings)].join(', ');
    return Semantics(
      image: true,
      label: label.isEmpty ? null : label,
      excludeSemantics: true,
      child: SizedBox.square(dimension: size, child: picture),
    );
  }
}

/// [avatars] in an overlapping row, showing at most [max] and a "+N"
/// bubble for the rest.
///
/// The ring around each avatar and the bubble follow [shape], which
/// should match the avatars'.
class Oito2AvatarGroup extends StatelessWidget {
  /// Creates an avatar group.
  const Oito2AvatarGroup({
    super.key,
    required this.avatars,
    this.max = 4,
    this.size = 32,
    this.overlap = 0.3,
    this.shape = Oito2AvatarShape.circle,
    this.semanticLabel,
  }) : assert(max > 0),
       assert(overlap >= 0 && overlap < 1);

  /// The avatars, usually [Oito2Avatar]s of the same [size].
  final List<Widget> avatars;

  /// The number of avatars shown before the "+N" bubble.
  final int max;

  /// The avatar size, used for the spacing and the bubble.
  final double size;

  /// The fraction of each avatar covered by the next one, from 0 up to,
  /// but not including, 1.
  final double overlap;

  /// The shape of the avatars.
  final Oito2AvatarShape shape;

  /// The accessibility label of the whole group, such as "Project
  /// members".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shown = avatars.take(max).toList();
    final hidden = avatars.length - shown.length;
    final ring = theme.scaffoldBackgroundColor;
    final circle = shape == Oito2AvatarShape.circle;
    BoxDecoration decoration(Color color, double extent) => BoxDecoration(
      color: color,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(extent * 0.22),
    );
    Widget ringed(Widget child) => Container(
      padding: const EdgeInsets.all(2),
      decoration: decoration(ring, size + 4),
      child: child,
    );
    final items = [
      for (final avatar in shown) ringed(avatar),
      if (hidden > 0)
        ringed(
          Semantics(
            label: Oito2Localizations.of(context).moreCount(hidden),
            excludeSemantics: true,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: decoration(scheme.surfaceContainerHighest, size),
              child: Text(
                '+$hidden',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
    ];
    final step = (size + 4) * (1 - overlap);
    final group = SizedBox(
      height: size + 4,
      width: step * (items.length - 1) + size + 4,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            PositionedDirectional(start: i * step, top: 0, child: items[i]),
        ],
      ),
    );
    final label = semanticLabel;
    return label == null
        ? group
        : Semantics(container: true, label: label, child: group);
  }
}
