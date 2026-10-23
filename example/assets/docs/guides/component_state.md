# Component State

Every interactive component follows the Flutter pattern for state: the app owns the value and the component reports changes. Components with more state than a value take a controller.

## Controlled values

Most components take the current value and a callback, and show what you pass. The component doesn't change on its own: update the value in the callback and rebuild.

```dart
bool _enabled = false;

Oito2Switch(
  value: _enabled,
  onChanged: (value) => setState(() => _enabled = value),
);
```

| Approach | When to use it |
|---|---|
| `value` + `onChanged` | Simple values: switches, sliders, selects, entries |
| A controller | Selection, pages, trees, tours, timers: state with several parts or methods |
| Uncontrolled | Self-contained state the app doesn't need, such as an `Oito2Expandable` without `onChanged` |

## Disabling

A null callback disables the component: it ignores input, looks disabled and tells assistive technologies.

```dart
Oito2Slider(value: volume, onChanged: muted ? null : setVolume);
```

## Controllers

Components with richer state take a `ChangeNotifier` controller, such as `Oito2SelectionController`, `Oito2PageController`, `Oito2TreeController`, `Oito2TourController` or `Oito2TimerController`. Create it in a `State`, pass it to the component, and dispose it with the state.

```dart
class _FruitsState extends State<Fruits> {
  late final _selection = Oito2SelectionController(
    collection: fruits,
    mode: Oito2SelectionMode.multiple,
  );

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Oito2ListBox(collection: fruits, controller: _selection);
  }
}
```

## Reading the state

A controller notifies its listeners on every change. Rebuild part of the screen with `ListenableBuilder`:

```dart
ListenableBuilder(
  listenable: _selection,
  builder: (context, _) => Text('${_selection.selectedValues.length} selected'),
);
```
