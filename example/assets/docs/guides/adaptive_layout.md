# Adaptive Layout

oito2_ui layouts adapt to the width they are given and to the input: the navigation, the master-detail split and the control sizes change on their own, so one layout serves a phone, a tablet and a 960 px desktop window.

## Input and density

The theme reads the platform once, through `Oito2Platform`, and sizes every control for its primary input. Touch input means a native Android or iOS app, or a browser on Android or iOS; Linux, Windows and macOS use the pointer, natively and in a browser.

| | Pointer | Touch |
|---|---|---|
| Control height (buttons, fields, list and table rows) | 34 px (`Oito2Sizes.buttonHeight`) | 40 px (`Oito2Sizes.touchButtonHeight`) |
| Icon size in controls | 20 px (`Oito2Sizes.iconSize`) | 24 px |
| Tap target | The control itself (`MaterialTapTargetSize.shrinkWrap`) | At least 48 × 48 px (`MaterialTapTargetSize.padded`, `Oito2Sizes.minTouchTarget`) |
| `VisualDensity` | `VisualDensity.comfortable` | `VisualDensity.standard` |

Widgets with rows, such as `Oito2TreeView` and `Oito2DataTable`, take the control height as their row height unless `rowHeight` is given, so a list keeps the density of the buttons around it.

## Navigation

`Oito2NavigationPage` picks the navigation from its own width. The breakpoints come from the `Oito2NavigationPageThemeData` theme extension, and each page can override them with `compactBreakpoint` and `extendedBreakpoint`.

| Width | Pointer | Touch |
|---|---|---|
| Below `compactBreakpoint` (600 px) | Compact rail, 64 px: icons only, labels as tooltips | Bottom `NavigationBar` |
| From 600 px | Labelled rail, 88 px: small labels below the icons | Labelled rail |
| From `extendedBreakpoint` (none by default) | Extended rail, 240 px: labels beside the icons | Extended rail |

The rail is followed by a 1 px separator unless the theme turns it off. `railStyle` forces one rail style at every width, and the rail then also replaces the bottom bar on touch.

```dart
Oito2NavigationPage(
  extendedBreakpoint: 1200,
  items: const [
    Oito2NavigationItem(icon: Icon(LucideIcons.folder), label: 'Files'),
    Oito2NavigationItem(icon: Icon(LucideIcons.settings), label: 'Settings'),
  ],
  pageBuilder: (context, index) => pages[index],
);
```

## Master and detail

`Oito2MasterDetailPage` shows a list and the page of the selected item. At or above `breakpoint` (620 px by default, from `Oito2MasterDetailThemeData`) the list is a resizable pane beside the page. Below it the list fills the area and selecting an item pushes its page on a nested navigator; going back, also with the system back button, clears the selection. The selection survives the switch between the two layouts.

The side-by-side layout is an `Oito2PanedView`: the pane starts at `paneSize` (280 px), never shrinks below `minPaneSize` (180 px) and always leaves `minPageSize` (320 px) for the page.

## Panes and splitters

`Oito2PanedView` splits its area between one pane and a page with a 1 px divider; the defaults are the ones above, and arrow keys move a focused divider by 16 px. `Oito2Splitter` holds two or more panes, side by side or stacked, each with its own `minSize` (48 px by default) and `maxSize`, and collapsible panes that Enter, Space or a double click on the divider collapse and restore. Splitters nest, so a horizontal splitter can hold a vertical one. On touch platforms the divider keeps its thin line but takes drags across 48 px centered on it, and taps there still reach the panes.

## Columns

Tree grids (`Oito2TreeView` with `columns`) and `Oito2DataTable` share `Oito2TableColumn`. A column is either fixed, `Oito2ColumnWidth.fixed(96)`, or flexible, `Oito2ColumnWidth.flex(1, min: 160)`: fixed columns keep their width and flexible ones share what is left, each at least its `min`. When the columns are wider in total than the widget, the rows and the header scroll sideways together. A resizable column never gets narrower than 32 px (`Oito2TableColumn.minResizeWidth`).

## Recipe: a 960 px window

A file manager window 960 px wide, on a pointer platform, with the default theme:

1. `Oito2NavigationPage` gets the whole width. 960 px is above the 600 px compact breakpoint, so the rail is labelled: 88 px plus the 1 px separator leaves 871 px for the page. To keep more room, `railStyle: Oito2NavigationRailStyle.compact` keeps the 64 px rail and leaves 895 px.
2. `Oito2MasterDetailPage` gets the 871 px, above its 620 px breakpoint, so the list and the page sit side by side: the 280 px pane and its 1 px divider leave 590 px for the page. The user can drag the pane between 180 px and 551 px, the 871 px less the 320 px `minPageSize`. Shrinking the window until the page area is below 620 px, such as on a 700 px window (611 px after the rail), stacks the list and the page.
3. The page holds an `Oito2DataTable`, edge to edge, (or a tree grid) with one flexible and three fixed columns. The table takes 24 px for its row margins and padding (20 px for a tree grid), so the columns share 566 px: the fixed ones take 96 + 160 + 120 = 376 px and the name column gets the other 190 px.
4. On a narrower page the name column stops at its 160 px minimum, the columns add up to 536 px, and the table scrolls sideways instead of squeezing the cells.

```dart
Oito2DataTable<FileEntry>(
  collection: files,
  controller: selection,
  columns: [
    Oito2TableColumn(
      id: 'name',
      label: 'Name',
      width: const Oito2ColumnWidth.flex(1, min: 160),
      cellBuilder: (context, file) => Text(file.name),
    ),
    Oito2TableColumn(
      id: 'size',
      label: 'Size',
      width: const Oito2ColumnWidth.fixed(96),
      alignment: AlignmentDirectional.centerEnd,
      cellBuilder: (context, file) => Text(file.sizeLabel),
    ),
    Oito2TableColumn(
      id: 'modified',
      label: 'Modified',
      width: const Oito2ColumnWidth.fixed(160),
      cellBuilder: (context, file) => Text(file.modifiedLabel),
    ),
    Oito2TableColumn(
      id: 'kind',
      label: 'Kind',
      width: const Oito2ColumnWidth.fixed(120),
      cellBuilder: (context, file) => Text(file.kind),
    ),
  ],
);
```

## Tips

- Let each widget measure its own width instead of reading the window size: the breakpoints of `Oito2NavigationPage` and `Oito2MasterDetailPage` use the space they are given, so they also adapt inside a split pane or a dialog.
- Change the breakpoints for the whole app in the theme extensions, and per page only when one page needs a different layout.
- Keep the fixed columns to what fits on the narrowest window you support and give the flexible column a `min`, so narrow windows scroll instead of truncating every cell.
