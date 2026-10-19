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

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/contrast.dart';
import '../syntax/syntax_palette.dart';
import '../tokens/colors.dart';
import '../tokens/palettes/dracula_palette.dart';
import '../tokens/palettes/everforest_palette.dart';
import '../tokens/palettes/nord_palette.dart';
import '../tokens/palettes/rose_pine_palette.dart';
import 'extensions/chrome_colors.dart';
import 'extensions/semantic_colors.dart';
import 'theme_preset.dart';

const _white = Color(0xFFFFFFFF);
const _transparent = Color(0x00000000);

/// The complete, resolved colors of one oito2 scheme: the Material
/// [colorScheme] plus the oito2 [semantic], [chrome] and [syntax] colors.
///
/// Build it with [Oito2ColorTheme.light] or [Oito2ColorTheme.dark] for the
/// oito2 base scheme, or with [Oito2ColorTheme.fromPreset] for a named
/// preset.
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
    this.preset,
    this.highContrast = false,
  });

  /// The light oito2 base scheme: GTK-style neutrals with [accent] as the
  /// primary hue.
  ///
  /// [accent] defaults to [Oito2AccentColor.fallback]. The primary fill
  /// keeps white text: its lightness is lowered only as far as needed for
  /// white to reach 4.5:1 (7:1 with [highContrast]).
  factory Oito2ColorTheme.light({Color? accent, bool highContrast = false}) =>
      _base(Brightness.light, accent, highContrast);

  /// The dark oito2 base scheme: GTK-style neutrals with [accent] as the
  /// primary hue.
  ///
  /// See [Oito2ColorTheme.light] for how [accent] and [highContrast] apply.
  factory Oito2ColorTheme.dark({Color? accent, bool highContrast = false}) =>
      _base(Brightness.dark, accent, highContrast);

  /// The scheme of [preset].
  ///
  /// The primary fill keeps the preset's official signature color, with
  /// black or white text, whichever contrasts more.
  factory Oito2ColorTheme.fromPreset(Oito2ThemePreset preset) {
    final roles = _presetRoles(preset);
    final isDark = preset.isDark;
    final card = roles.card;
    final secondary = roles.secondary;
    final lowest = _isLowerLayer(roles.background, card, isDark)
        ? roles.background
        : card;
    final container = Color.lerp(card, secondary, 1 / 3)!;
    return _assemble(
      brightness: preset.brightness,
      preset: preset,
      highContrast: false,
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

  /// The preset this theme was built from, or null for the base scheme.
  final Oito2ThemePreset? preset;

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
    Oito2ThemePreset? preset,
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
      preset: preset,
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
      other.preset == preset &&
      other.highContrast == highContrast;

  @override
  int get hashCode => Object.hash(
    colorScheme,
    background,
    semantic,
    chrome,
    syntax,
    preset,
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

/// The roles a preset family defines, before contrast adjustments.
class _PresetRoles {
  const _PresetRoles({
    required this.background,
    required this.card,
    required this.foreground,
    required this.primary,
    required this.secondary,
    required this.mutedForeground,
    required this.destructive,
    required this.border,
    required this.success,
    required this.warning,
    required this.info,
    required this.syntax,
  });

  final Color background;
  final Color card;
  final Color foreground;
  final Color primary;
  final Color secondary;
  final Color mutedForeground;
  final Color destructive;
  final Color border;
  final Color success;
  final Color warning;
  final Color info;
  final Oito2SyntaxPalette syntax;
}

_PresetRoles _presetRoles(Oito2ThemePreset preset) => switch (preset) {
  Oito2ThemePreset.everforestLight => _everforest(
    Oito2EverforestPalette.light,
    isDark: false,
  ),
  Oito2ThemePreset.everforestDark => _everforest(
    Oito2EverforestPalette.dark,
    isDark: true,
  ),
  Oito2ThemePreset.rosePine => _rosePine(Oito2RosePinePalette.main),
  Oito2ThemePreset.rosePineMoon => _rosePine(Oito2RosePinePalette.moon),
  Oito2ThemePreset.rosePineDawn => _rosePine(Oito2RosePinePalette.dawn),
  Oito2ThemePreset.nordDark => _nordDark(),
  Oito2ThemePreset.nordLight => _nordLight(),
  Oito2ThemePreset.dracula => _dracula(),
  Oito2ThemePreset.alucard => _alucard(),
  Oito2ThemePreset.catppuccinLatte => _catppuccin(catppuccin.latte),
  Oito2ThemePreset.catppuccinFrappe => _catppuccin(catppuccin.frappe),
  Oito2ThemePreset.catppuccinMacchiato => _catppuccin(catppuccin.macchiato),
  Oito2ThemePreset.catppuccinMocha => _catppuccin(catppuccin.mocha),
};

/// Everforest: every role is official.
_PresetRoles _everforest(Oito2EverforestPalette p, {required bool isDark}) =>
    _PresetRoles(
      background: p.bgDim,
      card: p.bg0,
      foreground: p.fg,
      primary: p.green,
      secondary: p.bg1,
      mutedForeground: p.grey1,
      destructive: p.red,
      border: isDark ? p.bg2 : p.bg3,
      success: p.green,
      warning: p.yellow,
      info: p.blue,
      syntax: Oito2SyntaxPalette(
        foreground: p.fg,
        comment: p.grey1,
        keyword: p.red,
        string: p.aqua,
        number: p.purple,
        function: p.green,
        type: p.yellow,
        tag: p.orange,
        attribute: p.blue,
        constant: p.purple,
        invalid: p.red,
      ),
    );

/// Rosé Pine: every role is official; `overlay` serves as both secondary
/// surface and border.
_PresetRoles _rosePine(Oito2RosePinePalette p) => _PresetRoles(
  background: p.base,
  card: p.surface,
  foreground: p.text,
  primary: p.pine,
  secondary: p.overlay,
  mutedForeground: p.muted,
  destructive: p.love,
  border: p.overlay,
  success: p.foam,
  warning: p.gold,
  info: p.iris,
  syntax: Oito2SyntaxPalette(
    foreground: p.text,
    comment: p.muted,
    keyword: p.pine,
    string: p.gold,
    number: p.gold,
    function: p.rose,
    type: p.foam,
    tag: p.foam,
    attribute: p.iris,
    constant: p.gold,
    invalid: p.love,
  ),
);

/// Nord, dark: every role is official.
_PresetRoles _nordDark() => const _PresetRoles(
  background: Oito2NordPalette.nord0,
  card: Oito2NordPalette.nord1,
  foreground: Oito2NordPalette.nord4,
  primary: Oito2NordPalette.nord8,
  secondary: Oito2NordPalette.nord2,
  mutedForeground: Oito2NordPalette.nord3,
  destructive: Oito2NordPalette.nord11,
  border: Oito2NordPalette.nord3,
  success: Oito2NordPalette.nord14,
  warning: Oito2NordPalette.nord13,
  info: Oito2NordPalette.nord9,
  syntax: Oito2SyntaxPalette(
    foreground: Oito2NordPalette.nord4,
    comment: Oito2NordPalette.nord3,
    keyword: Oito2NordPalette.nord9,
    string: Oito2NordPalette.nord14,
    number: Oito2NordPalette.nord15,
    function: Oito2NordPalette.nord8,
    type: Oito2NordPalette.nord7,
    tag: Oito2NordPalette.nord9,
    attribute: Oito2NordPalette.nord7,
    constant: Oito2NordPalette.nord12,
    invalid: Oito2NordPalette.nord11,
  ),
);

/// Nord, light: an unofficial derivation that swaps Polar Night and Snow
/// Storm and uses `nord10` as primary for contrast on a light background.
_PresetRoles _nordLight() => const _PresetRoles(
  background: Oito2NordPalette.nord6,
  card: Oito2NordPalette.nord5,
  foreground: Oito2NordPalette.nord0,
  primary: Oito2NordPalette.nord10,
  secondary: Oito2NordPalette.nord4,
  mutedForeground: Oito2NordPalette.nord3,
  destructive: Oito2NordPalette.nord11,
  border: Oito2NordPalette.nord4,
  success: Oito2NordPalette.nord14,
  warning: Oito2NordPalette.nord12,
  info: Oito2NordPalette.nord10,
  syntax: Oito2SyntaxPalette(
    foreground: Oito2NordPalette.nord0,
    comment: Oito2NordPalette.nord3,
    keyword: Oito2NordPalette.nord10,
    string: Oito2NordPalette.nord14,
    number: Oito2NordPalette.nord15,
    function: Oito2NordPalette.nord8,
    type: Oito2NordPalette.nord7,
    tag: Oito2NordPalette.nord10,
    attribute: Oito2NordPalette.nord7,
    constant: Oito2NordPalette.nord12,
    invalid: Oito2NordPalette.nord11,
  ),
);

/// Dracula: `background`, `currentLine` (card) and the accents are
/// official. Dracula has no third surface layer, so the secondary surface
/// is derived 12% from `currentLine` toward `foreground`, and the border
/// 15%.
_PresetRoles _dracula() {
  const p = Oito2DraculaPalette.dracula;
  return _PresetRoles(
    background: p.background,
    card: p.currentLine,
    foreground: p.foreground,
    primary: p.purple,
    secondary: Color.lerp(p.currentLine, p.foreground, 0.12)!,
    mutedForeground: p.comment,
    destructive: p.red,
    border: Color.lerp(p.currentLine, p.foreground, 0.15)!,
    success: p.green,
    warning: p.yellow,
    info: p.cyan,
    syntax: _draculaSyntax(p),
  );
}

/// Alucard: `background` and the accents are official. Alucard has no
/// second surface layer, so the card is the background itself, the
/// secondary surface is derived 6% from `background` toward `foreground`,
/// and the border 15%.
_PresetRoles _alucard() {
  const p = Oito2DraculaPalette.alucard;
  return _PresetRoles(
    background: p.background,
    card: p.background,
    foreground: p.foreground,
    primary: p.purple,
    secondary: Color.lerp(p.background, p.foreground, 0.06)!,
    mutedForeground: p.comment,
    destructive: p.red,
    border: Color.lerp(p.background, p.foreground, 0.15)!,
    success: p.green,
    warning: p.orange,
    info: p.cyan,
    syntax: _draculaSyntax(p),
  );
}

Oito2SyntaxPalette _draculaSyntax(Oito2DraculaPalette p) => Oito2SyntaxPalette(
  foreground: p.foreground,
  comment: p.comment,
  keyword: p.pink,
  string: p.yellow,
  number: p.purple,
  function: p.green,
  type: p.cyan,
  tag: p.pink,
  attribute: p.green,
  constant: p.purple,
  invalid: p.red,
);

/// Catppuccin: every role is official, read from `catppuccin_flutter`.
_PresetRoles _catppuccin(Flavor f) => _PresetRoles(
  background: f.mantle,
  card: f.base,
  foreground: f.text,
  primary: f.mauve,
  secondary: f.surface0,
  mutedForeground: f.overlay0,
  destructive: f.red,
  border: f.surface1,
  success: f.green,
  warning: f.yellow,
  info: f.blue,
  syntax: Oito2SyntaxPalette(
    foreground: f.text,
    comment: f.overlay2,
    keyword: f.mauve,
    string: f.green,
    number: f.peach,
    function: f.blue,
    type: f.yellow,
    tag: f.blue,
    attribute: f.yellow,
    constant: f.peach,
    invalid: f.red,
  ),
);
