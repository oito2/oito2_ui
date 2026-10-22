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

import 'package:material_ui/material_ui.dart';

import '../foundation/contrast.dart';
import '../syntax/syntax_palette.dart';
import '../tokens/colors.dart';
import 'color_roles.dart';
import 'extensions/chrome_colors.dart';
import 'extensions/semantic_colors.dart';

const _white = Color(0xFFFFFFFF);
const _transparent = Color(0x00000000);

/// The complete, resolved colors of one oito2 scheme: the Material
/// [colorScheme] plus the oito2 [semantic], [chrome] and [syntax] colors.
///
/// Build it with [Oito2ColorTheme.light] or [Oito2ColorTheme.dark] for the
/// oito2 base scheme, or with [Oito2ColorTheme.fromRoles] for any other
/// color theme family, such as the presets of `oito2_ui_themes` or an
/// app's own brand colors.
///
/// Text roles are guaranteed to reach WCAG AA: `onSurface`,
/// `onSurfaceVariant` and every [semantic] and [syntax] color reach
/// 4.5:1 against every surface of the scheme and against [background], and
/// `outline` reaches 3:1. With high contrast the targets rise to 7:1 and
/// 4.5:1.
@immutable
class Oito2ColorTheme {
  /// Creates a color theme from resolved values.
  const Oito2ColorTheme({
    required this.colorScheme,
    required this.background,
    required this.semantic,
    required this.chrome,
    required this.syntax,
    this.highContrast = false,
  });

  /// The light oito2 base scheme: GTK-style neutrals with [accent] as the
  /// primary hue.
  ///
  /// [accent] defaults to [Oito2AccentColor.fallback]. The primary fill
  /// keeps white text: its lightness is lowered only as far as needed for
  /// white to reach 4.5:1 (7:1 with [highContrast]).
  factory Oito2ColorTheme.light({Color? accent, bool highContrast = false}) =>
      _cached((Brightness.light, accent, highContrast), () {
        return _base(Brightness.light, accent, highContrast);
      });

  /// The dark oito2 base scheme: GTK-style neutrals with [accent] as the
  /// primary hue.
  ///
  /// See [Oito2ColorTheme.light] for how [accent] and [highContrast] apply.
  factory Oito2ColorTheme.dark({Color? accent, bool highContrast = false}) =>
      _cached((Brightness.dark, accent, highContrast), () {
        return _base(Brightness.dark, accent, highContrast);
      });

  /// The schemes built recently, by their inputs, so asking again for the
  /// same scheme returns it without recomputing the contrast adjustments.
  static final Map<Object, Oito2ColorTheme> _cache = {};

  static Oito2ColorTheme _cached(Object key, Oito2ColorTheme Function() build) {
    final cached = _cache.remove(key);
    if (cached != null) return _cache[key] = cached;
    if (_cache.length >= 32) _cache.remove(_cache.keys.first);
    return _cache[key] = build();
  }

  /// A scheme derived from the role colors of a theme family.
  ///
  /// The primary fill keeps [Oito2ColorRoles.primary] as given, with black
  /// or white text, whichever contrasts more. The surface ladder runs from
  /// the lower of the background and the card up to the secondary surface:
  ///
  /// - `surfaceContainerLowest` is whichever of `background` and `card`
  ///   sits lower (darker in a dark scheme, lighter in a light one);
  /// - `surfaceContainerLow` is halfway from it to `card`;
  /// - `surfaceContainer` and `surfaceContainerHigh` are one third and two
  ///   thirds of the way from `card` to `secondary`, and
  ///   `surfaceContainerHighest` is `secondary`;
  /// - the title bar is `surfaceContainer`;
  /// - `outline` is `border` mixed 35% toward `foreground`, and
  ///   `outlineVariant` is `border`.
  ///
  /// Text, outline, semantic and syntax colors are then adjusted to reach
  /// WCAG AA against every surface, as for the base scheme, or AAA with
  /// [highContrast].
  factory Oito2ColorTheme.fromRoles(
    Oito2ColorRoles roles, {
    bool highContrast = false,
  }) => _cached((roles, highContrast), () => _fromRoles(roles, highContrast));

  static Oito2ColorTheme _fromRoles(Oito2ColorRoles roles, bool highContrast) {
    final isDark = roles.brightness == Brightness.dark;
    final card = roles.card;
    final secondary = roles.secondary;
    final lowest = _isLowerLayer(roles.background, card, isDark)
        ? roles.background
        : card;
    final container = Color.lerp(card, secondary, 1 / 3)!;
    return _assemble(
      brightness: roles.brightness,
      highContrast: highContrast,
      primary: roles.primary,
      onPrimary: Oito2Contrast.foregroundFor(roles.primary),
      error: roles.destructive,
      background: roles.background,
      surface: card,
      surfaceContainerLowest: lowest,
      surfaceContainerLow: Color.lerp(lowest, card, 0.5)!,
      surfaceContainer: container,
      surfaceContainerHigh: Color.lerp(card, secondary, 2 / 3)!,
      surfaceContainerHighest: secondary,
      titleBar: container,
      onSurface: roles.foreground,
      onSurfaceVariant: roles.mutedForeground,
      outline: Color.lerp(roles.border, roles.foreground, 0.35)!,
      outlineVariant: roles.border,
      success: roles.success,
      warning: roles.warning,
      info: roles.info,
      syntax: roles.syntax,
    );
  }

  /// The Material color scheme.
  final ColorScheme colorScheme;

  /// The page background, used as the scaffold background.
  final Color background;

  /// Text-safe accent and status colors.
  final Oito2SemanticColors semantic;

  /// Structural chrome colors.
  final Oito2ChromeColors chrome;

  /// Syntax highlighting colors.
  final Oito2SyntaxPalette syntax;

  /// Whether this theme uses the high-contrast targets.
  final bool highContrast;

  /// The brightness of this theme.
  Brightness get brightness => colorScheme.brightness;

  /// Every surface of this theme: [background], the chrome surfaces and
  /// all `ColorScheme` surface roles.
  List<Color> get surfaces => _surfacesOf(colorScheme, background, chrome);

  static List<Color> _surfacesOf(
    ColorScheme scheme,
    Color background,
    Oito2ChromeColors? chrome,
  ) => [
    background,
    scheme.surface,
    scheme.surfaceDim,
    scheme.surfaceBright,
    scheme.surfaceContainerLowest,
    scheme.surfaceContainerLow,
    scheme.surfaceContainer,
    scheme.surfaceContainerHigh,
    scheme.surfaceContainerHighest,
    ?chrome?.titleBar,
    ?chrome?.sidebar,
    ?chrome?.mainbar,
    ?chrome?.dialog,
  ];

  static Oito2ColorTheme _base(
    Brightness brightness,
    Color? accent,
    bool highContrast,
  ) {
    final neutrals = Oito2NeutralPalette.of(brightness);
    final status = Oito2StatusPalette.of(brightness);
    final textTarget = highContrast
        ? Oito2Contrast.textAAA
        : Oito2Contrast.textAA;
    final isDark = brightness == Brightness.dark;
    return _assemble(
      brightness: brightness,
      highContrast: highContrast,
      primary: Oito2Contrast.ensure(
        accent ?? Oito2AccentColor.fallback.color,
        const [_white],
        textTarget,
      ),
      onPrimary: _white,
      error: status.error,
      background: neutrals.surfaceContainerLow,
      surface: neutrals.surface,
      surfaceContainerLowest: neutrals.surfaceContainerLowest,
      surfaceContainerLow: neutrals.surfaceContainerLow,
      surfaceContainer: neutrals.surfaceContainer,
      surfaceContainerHigh: neutrals.surfaceContainerHigh,
      surfaceContainerHighest: neutrals.surfaceContainerHighest,
      titleBar: neutrals.titleBar,
      onSurface: highContrast
          ? (isDark ? _white : const Color(0xFF000000))
          : neutrals.onSurface,
      onSurfaceVariant: neutrals.onSurfaceVariant,
      outline: neutrals.outline,
      outlineVariant: neutrals.outlineVariant,
      success: status.success,
      warning: status.warning,
      info: status.info,
      syntax: isDark ? _baseDarkSyntax : _baseLightSyntax,
    );
  }

  static Oito2ColorTheme _assemble({
    required Brightness brightness,
    required bool highContrast,
    required Color primary,
    required Color onPrimary,
    required Color error,
    required Color background,
    required Color surface,
    required Color surfaceContainerLowest,
    required Color surfaceContainerLow,
    required Color surfaceContainer,
    required Color surfaceContainerHigh,
    required Color surfaceContainerHighest,
    required Color titleBar,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color outlineVariant,
    required Color success,
    required Color warning,
    required Color info,
    required Oito2SyntaxPalette syntax,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTarget = highContrast
        ? Oito2Contrast.textAAA
        : Oito2Contrast.textAA;
    final nonTextTarget = highContrast
        ? Oito2Contrast.textAA
        : Oito2Contrast.nonTextAA;
    final seed = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );
    final chrome = Oito2ChromeColors.fromColorScheme(
      seed.copyWith(
        surface: surface,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
      ),
      background: background,
      titleBar: titleBar,
    );
    final surfaces = [
      background,
      surface,
      surfaceContainerLowest,
      surfaceContainerLow,
      surfaceContainer,
      surfaceContainerHigh,
      surfaceContainerHighest,
      chrome.titleBar,
      chrome.sidebar,
      chrome.mainbar,
      chrome.dialog,
    ];
    Color text(Color color) =>
        Oito2Contrast.ensure(color, surfaces, textTarget);

    final fixedOnSurface = text(onSurface);
    final fixedOutline = Oito2Contrast.ensure(outline, surfaces, nonTextTarget);
    final colorScheme = seed.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      error: error,
      onError: Oito2Contrast.foregroundFor(error),
      surface: surface,
      onSurface: fixedOnSurface,
      surfaceDim: isDark ? surfaceContainerLowest : surfaceContainerHighest,
      surfaceBright: isDark ? surfaceContainerHighest : surfaceContainerLowest,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: text(onSurfaceVariant),
      outline: fixedOutline,
      outlineVariant: highContrast ? fixedOutline : outlineVariant,
      inverseSurface: fixedOnSurface,
      onInverseSurface: surface,
      inversePrimary: Oito2Contrast.ensure(primary, [
        fixedOnSurface,
      ], Oito2Contrast.textAA),
      surfaceTint: _transparent,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
    );
    final primaryText = text(primary);
    return Oito2ColorTheme(
      colorScheme: colorScheme,
      background: background,
      highContrast: highContrast,
      semantic: Oito2SemanticColors(
        primaryText: primaryText,
        errorText: text(error),
        success: text(success),
        warning: text(warning),
        info: text(info),
        link: primaryText,
      ),
      chrome: chrome,
      syntax: syntax.ensureContrast(surfaces, target: textTarget),
    );
  }

  /// Whether [layer] sits below [card] in elevation: darker in a dark
  /// scheme, lighter in a light one.
  static bool _isLowerLayer(Color layer, Color card, bool isDark) {
    final layerLuminance = layer.computeLuminance();
    final cardLuminance = card.computeLuminance();
    return isDark
        ? layerLuminance < cardLuminance
        : layerLuminance > cardLuminance;
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2ColorTheme &&
      other.colorScheme == colorScheme &&
      other.background == background &&
      other.semantic == semantic &&
      other.chrome == chrome &&
      other.syntax == syntax &&
      other.highContrast == highContrast;

  @override
  int get hashCode => Object.hash(
    colorScheme,
    background,
    semantic,
    chrome,
    syntax,
    highContrast,
  );
}

/// Syntax colors of the light base scheme, from the GNOME color palette.
const _baseLightSyntax = Oito2SyntaxPalette(
  foreground: Color(0xFF202020),
  comment: Color(0xFF77767B),
  keyword: Color(0xFF9141AC),
  string: Color(0xFF26A269),
  number: Color(0xFFC64600),
  function: Color(0xFF1C71D8),
  type: Color(0xFF2190A4),
  tag: Color(0xFFC01C28),
  attribute: Color(0xFF986A44),
  constant: Color(0xFFD56199),
  invalid: Color(0xFFE01B24),
);

/// Syntax colors of the dark base scheme, from the GNOME color palette.
const _baseDarkSyntax = Oito2SyntaxPalette(
  foreground: Color(0xFFF7F7F7),
  comment: Color(0xFF9A9996),
  keyword: Color(0xFFDC8ADD),
  string: Color(0xFF8FF0A4),
  number: Color(0xFFFFA348),
  function: Color(0xFF99C1F1),
  type: Color(0xFF93DDC2),
  tag: Color(0xFFF66151),
  attribute: Color(0xFFF9F06B),
  constant: Color(0xFFF49AC1),
  invalid: Color(0xFFFF7B63),
);
