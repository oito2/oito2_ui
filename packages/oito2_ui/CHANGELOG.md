# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- Bundled Inter variable font (regular and italic, SIL Open Font License).
- `Oito2Platform`: web, native desktop, native touch and web-on-touch detection with platform-driven `VisualDensity`.
- `Oito2DesktopEnvironment` with detection from `XDG_CURRENT_DESKTOP` and `DESKTOP_SESSION`.
- `Oito2WindowControlStyle`, `Oito2WindowButton` and `Oito2WindowButtonLayout`, with parsers for the GNOME, KDE and Xfce button layout formats.
- `Oito2SystemSettings` and the `Oito2SystemScope` inherited widget.
- `Oito2Contrast` WCAG contrast helpers.
- Design tokens: `Oito2Radius`, `Oito2Spacing`, `Oito2Sizes`, `Oito2NeutralPalette`, `Oito2AccentColor`, `Oito2StatusPalette` and `Oito2Typography`.
- Official palettes of Nord, Dracula/Alucard, Everforest and Rosé Pine (`Oito2NordPalette`, `Oito2DraculaPalette`, `Oito2EverforestPalette`, `Oito2RosePinePalette`); Catppuccin read from `catppuccin_flutter`.
- `Oito2ThemePreset` with the 13 named presets.
- `Oito2ColorTheme` and `Oito2ColorScheme`: the oito2 base scheme (GTK-style neutrals, custom accent, high contrast) and the 13 presets mapped to Material 3, with WCAG AA text roles on every surface.
- `Oito2SemanticColors` and `Oito2ChromeColors` theme extensions.
- `SyntaxHighlightPalette` with 11 token roles for every scheme.
- `Oito2Contrast.minRatio`, `Oito2Contrast.ensure` and `Oito2Contrast.textAAA`.
- `Oito2Theme` (`light`, `dark`, `fromPreset`, `fromSystem`, `fromColors`): Material 3 `ThemeData` with platform-adaptive density, control sizes, tap targets and splashes, and themes for buttons, inputs, cards, dialogs, sheets, drawers, menus, toggles, sliders, progress, chips, tabs, navigation, list tiles, scrollbars, snack bars and tooltips.
- Keyboard focus ring and text-safe primary tone on buttons, links, toggles and input focus; input errors in the text-safe error tone.
- `Oito2DesktopPageTransitionsBuilder` and `oito2PageTransitionsTheme`.
- `Oito2SyntaxTheme` theme extension carrying the scheme's `SyntaxHighlightPalette`.
- `Oito2Sizes.touchButtonHeight`.
- Window chrome: `Oito2TitleBar`, `Oito2WindowTitleBar` (adapts to native desktop, web and touch), `Oito2DialogTitleBar`, `Oito2WindowControl` drawn in the GNOME, Breeze, Xfwm, COSMIC, Windows and macOS styles, `Oito2TitleBarGestureDetector` (drag, double-click maximize, window menu), `Oito2TitleBarThemeData` and `Oito2TitleBarStyle`.
- `Oito2WindowController` contract, `Oito2WindowState` and the `Oito2WindowScope` inherited widget.

### Changed

- `Oito2Contrast.foregroundFor` returns black or white by the higher contrast ratio instead of a 0.5 luminance threshold.

