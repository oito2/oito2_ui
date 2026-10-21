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
- Controls: `Oito2CheckButton`, `Oito2RadioButton`, `Oito2SwitchButton` (clickable labels, built on the painted toggles), `Oito2SplitButton`, `Oito2OptionButton`, `Oito2ColorDisk`, `Oito2ChoiceChipBar` and `Oito2PageIndicator`.
- Inputs: `Oito2SearchField`, `Oito2SearchTitleField`, `Oito2DateEntry`, `Oito2TimeEntry`, `Oito2DateTimeEntry` and `Oito2SegmentedEntry`; date and time parsing, hints and errors come from `MaterialLocalizations`.
- Utilities: `Oito2FocusBorder`, `Oito2EdgeFocusInterceptor`, `Oito2ScrollViewUndershoot`, `Oito2DiagonalClip` and `Oito2Draggable`.
- Painted toggles `Oito2Checkbox` (tristate), `Oito2Radio` (toggleable) and `Oito2Switch` (optional on/off shapes), drawn with filled shapes. They are 34-pixel targets on pointer platforms and 48 on touch, toggle with Space and Enter, show the focus ring in keyboard navigation, report checked/mixed/toggled states to assistive technologies, and skip their animation when animations are disabled. Selected fills use the scheme's primary tone with its on-color when it stands out 3:1 from the surfaces, and the text-safe primary tone otherwise.
- `Oito2ToggleButton`: the clickable label row of the check, radio and switch buttons, now public, focusable as one element.
- `Oito2CheckboxListTile`, `Oito2RadioListTile` and `Oito2SwitchListTile`, with `Oito2ControlAffinity`.
- Painted `Oito2CircularProgressIndicator` and `Oito2LinearProgressIndicator`, determinate and indeterminate (a spinning arc, a gliding pulse), drawn with filled shapes and round ends, still when animations are disabled, with a percentage as their accessibility value; colors and sizes come from the new `Oito2ProgressIndicatorThemeData` extension of `Oito2Theme`.
- `Oito2IconButton` (square, control height, toggle mode with a filled selected state), `Oito2BackButton` (start-side chevron, pops the route) and `Oito2CloseButton`; `Oito2DetailPage` uses `Oito2BackButton`.
- Collections, in pure Dart:
  - `Oito2ListCollection` (values, labels, disabled items, groups, typeahead, filtering).
  - `Oito2SelectionController` (none, single and multiple selection, Shift ranges, Control/Command toggles, select all).
  - `Oito2TreeCollection` and `Oito2TreeNode` (lookups, visible order for expanded branches, filtering, insert/remove/move/replace, building from file paths).
  - `Oito2AsyncListController` (cursor pages, filter text, sorting, stale loads dropped).
- `Oito2Format`: byte sizes (SI and IEC), compact numbers and localized relative times ("3 minutes ago" / "há 3 minutos").
- `Oito2HighlightedText`, which emphasizes the words of a query ignoring case and accents, and `Oito2Swap`, which animates between two widgets with a fade, scale, rotate or flip.
- Keyboard commands:
  - `Oito2Shortcut` and `Oito2KeyChord`: single chords and sequences, with a platform-neutral primary modifier and parsing from text such as `Mod+Shift+P` or `G H`.
  - `Oito2Command` and `Oito2Commands`: scoped commands that run on their shortcut while the focus is inside, with sequences that time out, plain-key shortcuts that skip text fields, and conflict detection.
  - `Oito2ShortcutLabel` (key caps in the platform notation) and `Oito2ShortcutRecorder`.
  - `showOito2CommandPalette`: searchable, keyboard-driven, with shortcuts shown.
- `Oito2Localizations` strings for relative times, the command palette and the shortcut recorder.
- `intl` is now a direct dependency.
- `Oito2PopupMenuButton`: a field-shaped button that opens a menu, sized like the text fields and opened with a click, Enter, Space or the Down arrow. Its items are `Oito2CheckedMenuItem` (single choice) and `Oito2MultiSelectMenuItem` (multiple choices; the menu stays open). `Oito2Select` picks a value from an `Oito2ListCollection`, with group headings and disabled items.
- `Oito2ListTile` and `Oito2ListTile.square`: interactive rows with hover, selected and keyboard focus states, sized per platform.
- `Oito2ExpansionPanel`: an accordion of `Oito2Expandable` sections, with an option to keep several open.
- `Oito2TabBar` and `Oito2Tab`: tabs with a sliding rounded pill, at the control height, fixed or scrollable.
- `Oito2Carousel` and `Oito2CarouselController`:
  - Pages change with buttons, dots, the arrow keys, or a swipe (also with a mouse); `loop` wraps around.
  - Automatic scrolling pauses on hover and focus and never runs when animations are disabled.
- `Oito2PageIndicatorLayout` (`fixed`, `stepped`, `bounded`) for `Oito2PageIndicator.layout`.
- `Oito2Autocomplete`: suggestions from an `Oito2ListCollection`, filtered ignoring case and accents, with highlighted matches, keyboard selection and a live region announcing the number of results.
- `Oito2Localizations.noResults` and `resultCount`.
- `Oito2NavigationRail` and `Oito2NavigationRailItem`:
  - three `Oito2NavigationRailStyle`s (compact with tooltips, labelled, extended), with an animated width;
  - a rounded selection pill, the keyboard focus ring and selectable-button semantics;
  - scrolling with undershoot shadows, keeping the selected destination in view.
- `Oito2NavigationPage` uses `Oito2NavigationRail`: a compact rail on narrow pointer layouts (the bottom bar stays for narrow touch layouts), labelled up to the extended breakpoint. `railStyle` forces a style; the Material `labelType` parameter is gone.
- `Oito2MasterListView`, the master list of `Oito2MasterDetailPage`, now public. It scrolls the selected tile into view, even one far below.
- `Oito2NavigationPageThemeData` and `Oito2MasterDetailThemeData` theme extensions, registered by `Oito2Theme`, for the breakpoints, pane sizes, spacing, colors and separator. The page parameters now default to them.
- `Oito2Localizations` with English and Brazilian Portuguese strings for the window controls, pane resizing, split button menus, chip bar arrows, page indicators and segmented entries; English is the fallback when its delegate isn't registered. `Oito2WindowControlLabels` and the widgets' label parameters now only override these strings.
- `Oito2AnimatedIcon`, `Oito2AnimationMode` (`once`, `repeat`, `still`) and `Oito2AnimatedIcons`: ten painted icons (`ok`, `okFilled`, `heart`, `heartFilled`, `star`, `starFilled`, `starHalfFilled`, `compass`, `compassFilled`, `noNetwork`) that show their final frame when animations are disabled. Custom icons use `Oito2AnimatedIconData`.
- `Oito2PlaceholderIcon`: a decorative picture placeholder painted from the color scheme.
- `Oito2FreedesktopIcons`: 199 freedesktop icon names mapped to Lucide icons, with `byName` lookup that ignores the `-symbolic` suffix.
- `Oito2Popover` and `Oito2PopoverController`: a non-modal panel anchored to a widget, with placement and flip (`Oito2PopoverPlacement`, `Oito2PopoverAlignment`), an optional arrow, the anchor width, nesting, Escape and outside-tap dismissal, and focus moved in and back.
- `Oito2HoverCard`: a card on hover or keyboard focus with open and close delays, and a long press on touch.
- `showOito2Sheet` and `Oito2Sheet`: start, end and bottom sheets, modal or not, closed by Escape, the scrim or a drag, with bottom snap points that also move by keyboard and assistive technologies.
- `Oito2Toaster`, `Oito2Toast` and `Oito2ToastHandle`: stacked notifications with placement, a visible limit, `Oito2InfoType` icons, an action, a time that stops on hover and focus, loading toasts and `promise`.
- `Oito2ContextMenuRegion`: right-click, long-press, Shift+F10 and menu-key menus on any widget, with nested `MenuAnchor` items.
- `Oito2Tour`, `Oito2TourController` and `Oito2TourStep`: guided steps with a spotlight, placement, progress, keyboard navigation, skip, and steps that wait for a tap on their target.
- `Oito2Localizations` strings for closing, dismissing, the notification area, the sheet handle and the tour buttons.
- `Oito2NumberEntry`: a spin field with steppers, limits, decimals in the locale format, keyboard steps, the mouse wheel and scrubbing.
- `Oito2PasswordField`: a visibility toggle, a Caps Lock warning and password autofill hints.
- `Oito2PinEntry`: one-character cells over a single field, with paste, one-time code autofill, masking and completion.
- `Oito2EditableLabel`: a label renamed in place by double click, Enter or F2.
- `Oito2TagsField`: tags as chips with delimiters, paste splitting, a limit, validation, keyboard navigation between tags and optional suggestions.
- `Oito2Rating`: stars with half values, hover preview, keyboard and slider semantics.
- `Oito2AngleSlider`: a dial for an angle with steps, markers, pointer and keyboard input.
- `Oito2ListBox`: a selectable list over `Oito2ListCollection` and `Oito2SelectionController`, with groups, typeahead and single or multiple selection.
- `Oito2ColorPicker`, `Oito2ColorPickerButton` and `Oito2ColorFormat`: saturation and brightness area, hue and opacity sliders, hex/RGB/HSL fields and swatches, inline or in a popover; `oito2ColorToHex` and `oito2ColorFromHex`.
- `Oito2Calendar` and `Oito2DatePicker`: a month grid with single or range selection, ISO week numbers (`oito2IsoWeekNumber`) and keyboard grid navigation, and a field that opens it in a popover.
- `Oito2Localizations` strings for the password, number, code, rating, tag, color and week labels.
- `Oito2TreeView` and `Oito2TreeController`: a virtualized tree over `Oito2TreeCollection` with keyboard navigation, single or multiple selection, cascading check boxes, filtering, inline renaming, type-ahead and lazy loading.
- `Oito2JsonTreeView` and `oito2JsonTree`: decoded JSON as a tree with JSON paths and syntax colors.
- `Oito2Pagination` and `oito2PaginationItems`: page buttons with ellipses, previous and next, a page size selector and a compact form.
- `Oito2Steps` and `Oito2Step`: a horizontal or vertical step indicator with completed, current and error states and linear or free navigation.
- `Oito2Splitter` and `Oito2SplitterPane`: any number of resizable, collapsible and nestable panes with limits and keyboard control.
- `Oito2TableOfContents` and `Oito2TocEntry`: a scroll-spy list of a scroll view's sections.
- `Oito2FloatingPanel`: a movable, resizable, minimizable and maximizable in-app window with the oito2 title bar.
- `Oito2Avatar`, `Oito2AvatarGroup`, `Oito2AvatarStatus`, `Oito2AvatarShape` and `oito2Initials`: pictures with initial and icon fallbacks, presence status and grouping.
- `Oito2CopyButton` and `Oito2CopyField`: copy to the clipboard with "Copied" feedback.
- `Oito2Marquee`: continuous horizontal or vertical scrolling that pauses on hover and focus and stays still when animations are off.
- `Oito2TimerController`, `Oito2TimerText` and `oito2FormatDuration`: a stopwatch or countdown with ticks and completion.
- `Oito2Localizations` strings for the copy, page, step, loading, presence and "more" labels.

### Changed

- `Oito2ListBox` reacts to a click at once: double clicks are told apart without delaying single clicks.
- `Oito2DateEntry` opens an `Oito2Calendar` in a popover instead of the Material date picker dialog.
- `Oito2Contrast.foregroundFor` returns black or white by the higher contrast ratio instead of a 0.5 luminance threshold.
- Single-line text fields, with or without prefix and suffix icons, `Oito2SearchField`, the date and time entries, segmented buttons and chips are as tall as the buttons: 34 pixels on pointer platforms and 40 on touch platforms. Helper and error text sit below that height. `DropdownMenu` keeps its own height, because its trailing button can't be sized from the theme.
- `Oito2SearchTitleField` keeps one size in both states: a box `fieldWidth` wide with the toggle button at its start. The title follows the button; the open search field fills the box and uses the button as its search icon. Escape on an empty field returns focus to the toggle button.
- `Oito2SearchField.prefixIcon` replaces the default search icon.
- `Oito2WindowTitleBar.buttonSides` (`Oito2WindowButtonSides`) shows only the leading or trailing window buttons of the system layout, for split title bars over a sidebar and a content area; `backgroundColor` and `border` style the bar on desktop and the web.
- The `Oito2NavigationPage` rail scrolls when its destinations don't fit the height.

