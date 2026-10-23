# Composition

oito2_ui components are built to be combined. They take widgets for their parts, builders for content that depends on state, and collections for their data, so a few pieces cover many layouts.

## Slots

Most components take their parts as widget parameters, such as `title`, `leading`, `trailing` or `icon`. Any widget fits a slot: an icon, a text, a badge or a whole row.

```dart
Oito2ListTile(
  leading: const Icon(LucideIcons.wifi),
  title: const Text('Wi-Fi'),
  subtitle: const Text('Connected'),
  trailing: Oito2Switch(value: wifi, onChanged: setWifi),
);
```

## Builders

When the content depends on the component's state, it takes a builder. `Oito2Popover` builds its anchor and its panel with the same controller, so either can open or close it:

```dart
Oito2Popover(
  builder: (context, controller) => FilledButton(
    onPressed: controller.toggle,
    child: const Text('Filters'),
  ),
  popoverBuilder: (context, controller) => TextButton(
    onPressed: controller.close,
    child: const Text('Done'),
  ),
);
```

## Collections

Lists of choices are described once as a collection and shared by the components that show them. An `Oito2ListCollection` says how to read each item's value, label, group and whether it is disabled.

```dart
final desktops = Oito2ListCollection(
  const [('gnome', 'GNOME'), ('kde', 'KDE Plasma'), ('xfce', 'Xfce')],
  valueOf: (item) => item.$1,
  labelOf: (item) => item.$2,
);

Oito2Select(collection: desktops, value: value, onChanged: setValue);
```

The same collection feeds `Oito2ListBox`, `Oito2Autocomplete` and the suggestions of `Oito2TagsField`; `Oito2TreeCollection` does the same for `Oito2TreeView`.

## Wrappers

Some components add one behavior to any child instead of drawing their own content: `Oito2FocusBorder` shows the focus ring, `Oito2Watermark` puts a faint mark behind the child, and `Oito2ScrollViewUndershoot` shades the edges of a scroll view.

```dart
Oito2ScrollViewUndershoot(
  child: ListView(children: items),
);
```

## Material widgets

The theme also styles Material widgets, so `FilledButton`, `TextField`, `Card` or `Scaffold` sit next to oito2 components without extra work. Use a Material widget when it already does the job, and an oito2 component when it adds behavior or the desktop look.
