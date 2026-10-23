# Refs

Some tasks need a handle on a component: moving the focus to it, measuring where it is, or calling a method of its state. Flutter does this with focus nodes, keys and controllers.

## Focus nodes

Components that take the keyboard focus accept a `focusNode`. Create it in a `State`, pass it, and dispose it with the state; call `requestFocus` to move the focus there.

```dart
late final _search = FocusNode();

@override
void dispose() {
  _search.dispose();
  super.dispose();
}

Oito2SearchField(focusNode: _search, onChanged: filter);

// Later, for example from a shortcut:
_search.requestFocus();
```

## Keys to find widgets

A `GlobalKey` names a widget so another one can find it on screen. `Oito2TableOfContents` uses the keys of the section headings to know which one is in view, and `Oito2Tour` uses them to point at the widget each step explains.

```dart
final _newProject = GlobalKey();

late final _tour = Oito2TourController(
  steps: [
    Oito2TourStep(
      target: _newProject,
      title: 'Create a project',
      description: 'Start here to set up your first project.',
    ),
  ],
);

FilledButton(key: _newProject, onPressed: create, child: const Text('New'));
```

## Component state

A few components expose methods on their state. Reach it from below with the component's `of` function, or from anywhere with a `GlobalKey`:

```dart
// From a widget inside the toaster:
Oito2Toaster.of(context).show(const Oito2Toast(title: 'Saved'));

// From outside, through a key:
final _toaster = GlobalKey<Oito2ToasterState>();
Oito2Toaster(key: _toaster, child: app);
_toaster.currentState?.show(const Oito2Toast(title: 'Saved'));
```

## Controllers

Prefer a controller when the component offers one: it works without a key, can be shared by several widgets, and notifies listeners of every change. See **Component State**.
