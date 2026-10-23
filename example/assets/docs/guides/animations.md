# Animations

oito2_ui components animate their changes, such as a sliding marker, an opening section or a toast, and keep every motion short so the interface stays responsive.

## Reduced motion

Every component reads `MediaQuery.disableAnimations`. When the system asks for reduced motion, or the app sets it, the components change state at once instead of animating.

```dart
MediaQuery(
  data: MediaQuery.of(context).copyWith(disableAnimations: true),
  child: content,
);
```

> Use the same flag in your own animations: give them `Duration.zero` when `MediaQuery.disableAnimationsOf(context)` is true.

## Swapping content

`Oito2Swap` switches between two widgets with a fade, scale, rotation or flip, such as a play and a pause icon.

```dart
Oito2Swap(
  swapped: playing,
  effect: Oito2SwapEffect.rotate,
  off: const Icon(LucideIcons.play),
  on: const Icon(LucideIcons.pause),
);
```

## Animated icons

`Oito2AnimatedIcon` plays a drawn icon from `Oito2AnimatedIcons` once, in a loop, or holds it still.

```dart
Oito2AnimatedIcon(
  Oito2AnimatedIcons.heart,
  mode: Oito2AnimationMode.repeat,
);
```

## Page transitions

`Oito2Theme` sets the page transitions per platform: on Linux and Windows the new page fades in while sliding a short distance, and the other platforms keep their own transitions, such as Cupertino on iOS and macOS. Routes pushed with `MaterialPageRoute` pick them up from the theme; `oito2PageTransitionsTheme()` returns them for a theme of your own.
