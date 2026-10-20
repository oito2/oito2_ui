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
- `Oito2ColorTheme` and `Oito2ColorScheme`: the oito2 base scheme (GTK-style neutrals, custom accent, high contrast) mapped to Material 3, with WCAG AA text roles on every surface.
- `Oito2ColorRoles` and `Oito2ColorTheme.fromRoles`: a complete, WCAG-checked oito2 scheme from the dozen role colors a theme family defines (background, card, foreground, accent, secondary surface, border and status colors). The named presets live in the separate `oito2_ui_themes` package.
- `Oito2SemanticColors` and `Oito2ChromeColors` theme extensions. The chrome sidebar, mainbar, title bar and dialog tones come from the Material 3 surface container roles, kept at least 1.04:1 apart from the page background.
- `Oito2SyntaxPalette` with 11 token roles for every scheme.
- `Oito2Contrast.minRatio`, `Oito2Contrast.ensure` and `Oito2Contrast.textAAA`.
- `Oito2Theme` (`light`, `dark`, `fromSystem`, `fromColors`): Material 3 `ThemeData` with platform-adaptive density, control sizes, tap targets and splashes, and themes for buttons, inputs, cards, dialogs, sheets, drawers, menus, toggles, sliders, progress, chips, tabs, navigation, list tiles, scrollbars, snack bars and tooltips.
- Keyboard focus ring and text-safe primary tone on buttons, links, toggles and input focus; input errors in the text-safe error tone.
- `Oito2DesktopPageTransitionsBuilder` and `oito2PageTransitionsTheme`.
- `Oito2SyntaxTheme` theme extension carrying the scheme's `Oito2SyntaxPalette`.
- `Oito2Sizes.touchButtonHeight`.
- Window chrome: `Oito2TitleBar`, `Oito2WindowTitleBar` (adapts to native desktop, web and touch), `Oito2DialogTitleBar`, `Oito2WindowControl` drawn in the GNOME, Breeze, Xfwm, COSMIC, Windows and macOS styles, `Oito2TitleBarGestureDetector` (drag, double-click maximize, window menu), `Oito2TitleBarThemeData` and `Oito2TitleBarStyle`.
- `Oito2WindowController` contract, `Oito2WindowState` and the `Oito2WindowScope` inherited widget.
- Layout and navigation widgets: `Oito2MasterDetailPage` (side-by-side or stacked by width) with `Oito2MasterTile`, `Oito2MasterTileScope` and `Oito2DetailPage`; `Oito2NavigationPage` (rail or bottom bar by width) with `Oito2NavigationItem`; `Oito2PanedView` (resizable with pointer, keyboard and assistive technologies); `Oito2PageController`.
- Container widgets: `Oito2BorderContainer`, `Oito2Section`, `Oito2Tile`, `Oito2TileList`, `Oito2SelectableContainer`, `Oito2Banner`, `Oito2InfoBox`, `Oito2InfoBadge`, `Oito2Expandable` and `Oito2Watermark`.
- Lucide icons through `flutter_lucide` (a single tree-shaken icon font), re-exported as `LucideIcons` so apps use the same icon set without depending on the icon package directly.
- Controls: `Oito2CheckButton`, `Oito2RadioButton`, `Oito2SwitchButton` (clickable labels), `Oito2SplitButton`, `Oito2OptionButton`, `Oito2ColorDisk`, `Oito2ChoiceChipBar` and `Oito2PageIndicator`.
- Inputs: `Oito2SearchField`, `Oito2SearchTitleField`, `Oito2DateEntry`, `Oito2TimeEntry`, `Oito2DateTimeEntry` and `Oito2SegmentedEntry`; date and time parsing, hints and errors come from `MaterialLocalizations`.
- Utilities: `Oito2FocusBorder`, `Oito2EdgeFocusInterceptor`, `Oito2ScrollViewUndershoot`, `Oito2DiagonalClip` and `Oito2Draggable`.
- `Oito2Localizations` with English and Brazilian Portuguese strings for the window controls, pane resizing, split button menus, chip bar arrows, page indicators and segmented entries; English is the fallback when its delegate isn't registered. `Oito2WindowControlLabels` and the widgets' label parameters now only override these strings.

### Changed

- `Oito2Contrast.foregroundFor` returns black or white by the higher contrast ratio instead of a 0.5 luminance threshold.
- Single-line text fields, with or without prefix and suffix icons, `Oito2SearchField`, the date and time entries, segmented buttons and chips are as tall as the buttons: 34 pixels on pointer platforms and 40 on touch platforms. Helper and error text sit below that height. `DropdownMenu` keeps its own height, because its trailing button can't be sized from the theme.
- `Oito2SearchTitleField` keeps one size in both states: a box `fieldWidth` wide with the toggle button at its start. The title follows the button; the open search field fills the box and uses the button as its search icon. Escape on an empty field returns focus to the toggle button.
- `Oito2SearchField.prefixIcon` replaces the default search icon.

