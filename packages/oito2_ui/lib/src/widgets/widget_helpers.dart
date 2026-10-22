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

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/contrast.dart';
import '../theme/extensions/chrome_colors.dart';
import '../theme/extensions/semantic_colors.dart';
import '../tokens/colors.dart';
import '../tokens/geometry.dart';

/// Returns the semantic colors of the closest theme, or colors derived
/// from its `ColorScheme` and the status palette when the theme wasn't
/// built by `Oito2Theme`.
Oito2SemanticColors semanticColorsOf(BuildContext context) {
  final extension = Oito2SemanticColors.maybeOf(context);
  if (extension != null) return extension;
  final theme = Theme.of(context);
  final status = Oito2StatusPalette.of(theme.brightness);
  return Oito2SemanticColors(
    primaryText: theme.colorScheme.primary,
    errorText: theme.colorScheme.error,
    success: status.success,
    warning: status.warning,
    info: status.info,
    link: status.link,
  );
}

/// Returns the chrome colors of the closest theme, or colors derived from
/// its scaffold background when the theme wasn't built by `Oito2Theme`.
Oito2ChromeColors chromeColorsOf(BuildContext context) {
  return Oito2ChromeColors.maybeOf(context) ??
      Oito2ChromeColors.fromTheme(Theme.of(context));
}

/// The fill and mark colors of selected controls and progress indicators
/// in the closest theme.
///
/// The fill is the scheme's primary tone, with its on-color, when it
/// stands out 3:1 from the surface, the scaffold background and the
/// container surface; otherwise it is the text-safe primary tone, which
/// always does, with black or white, whichever contrasts more.
({Color fill, Color onFill}) selectedFillOf(BuildContext context) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final usePrimary =
      Oito2Contrast.minRatio(scheme.primary, [
        scheme.surface,
        theme.scaffoldBackgroundColor,
        scheme.surfaceContainer,
      ]) >=
      Oito2Contrast.nonTextAA;
  if (usePrimary) return (fill: scheme.primary, onFill: scheme.onPrimary);
  final text = semanticColorsOf(context).primaryText;
  return (fill: text, onFill: Oito2Contrast.foregroundFor(text));
}

/// An [IconButton] placed inside a text field decoration, such as a clear
/// or picker button.
///
/// Its tap target is shrink-wrapped, so on touch platforms it stays as
/// tall as the field instead of growing the field to the padded 48-pixel
/// target; the whole field row remains the touch target.
class FieldIconButton extends StatelessWidget {
  /// Creates a field icon button.
  const FieldIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  /// The icon.
  final IconData icon;

  /// The tooltip and accessibility label.
  final String tooltip;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: Oito2Sizes.iconSize),
    );
  }
}

/// The height of buttons and single-line fields in the closest theme: 34
/// pixels on pointer platforms and 40 on touch ones, read from the width
/// of the input decoration icon boxes, which match the field height.
double controlHeightOf(BuildContext context) =>
    Theme.of(context).inputDecorationTheme.suffixIconConstraints?.minWidth ??
    Oito2Sizes.buttonHeight;

/// An input decoration with no fill, border, padding or minimum size,
/// overriding the theme, for a text field placed inside another
/// decorated box.
InputDecoration bareInputDecoration({String? hintText}) => InputDecoration(
  hintText: hintText,
  isCollapsed: true,
  filled: false,
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  contentPadding: EdgeInsets.zero,
  constraints: const BoxConstraints(),
);

/// Reports the size of [child] after each layout.
class SizeReporter extends SingleChildRenderObjectWidget {
  /// Creates a size reporter.
  const SizeReporter({super.key, required this.onSize, super.child});

  /// Called with the child size after each layout.
  final ValueChanged<Size> onSize;

  @override
  RenderSizeReporter createRenderObject(BuildContext context) =>
      RenderSizeReporter(onSize);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSizeReporter renderObject,
  ) => renderObject.onSize = onSize;
}

/// The render object of [SizeReporter].
class RenderSizeReporter extends RenderProxyBox {
  /// Creates the render object.
  RenderSizeReporter(this.onSize);

  /// Called with the child size after each layout.
  ValueChanged<Size> onSize;

  @override
  void performLayout() {
    super.performLayout();
    onSize(size);
  }
}

/// Tells a double click from two single clicks on the same target without
/// a double-tap gesture recognizer, which would delay every single click
/// until the double-click timeout.
///
/// A click completes a double click when it lands on the same target as
/// the previous one before [kDoubleTapTimeout] runs out. The timeout runs
/// on a [Timer], so it follows real time whether or not frames are drawn.
class DoubleClickDetector {
  Object? _pending;
  Timer? _timer;

  /// Records a click on [target] and returns whether it completes a double
  /// click.
  bool click(Object target) {
    if (_timer != null && _pending == target) {
      cancel();
      return true;
    }
    _timer?.cancel();
    _pending = target;
    _timer = Timer(kDoubleTapTimeout, cancel);
    return false;
  }

  /// Forgets the pending click and stops its timeout.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
  }
}

/// A focus node that the widget gives or, when it gives none, the state
/// owns.
///
/// [onEffectiveFocusChange] listens to the node in use and follows it when
/// the widget starts or stops giving one, or gives another. An owned node
/// that the widget replaces is disposed after the frame, and the one still
/// owned with the state.
mixin OwnedFocusNodeMixin<W extends StatefulWidget> on State<W> {
  FocusNode? _ownedFocusNode;
  late FocusNode _listenedFocusNode;

  /// The node [widget] gives, if any.
  FocusNode? get widgetFocusNode;

  /// Creates the node owned while the widget gives none.
  FocusNode createOwnedFocusNode() => FocusNode();

  /// Called when the node in use gains or loses focus.
  void onEffectiveFocusChange() {}

  /// The node in use: the widget's, or the one this state owns.
  FocusNode get effectiveFocusNode =>
      widgetFocusNode ?? (_ownedFocusNode ??= createOwnedFocusNode());

  @override
  void initState() {
    super.initState();
    _listenedFocusNode = effectiveFocusNode
      ..addListener(onEffectiveFocusChange);
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = effectiveFocusNode;
    if (identical(current, _listenedFocusNode)) return;
    _listenedFocusNode.removeListener(onEffectiveFocusChange);
    _listenedFocusNode = current..addListener(onEffectiveFocusChange);
    final owned = _ownedFocusNode;
    if (owned != null && !identical(owned, current)) {
      _ownedFocusNode = null;
      // The node may still be attached until this frame rebuilds.
      WidgetsBinding.instance.addPostFrameCallback((_) => owned.dispose());
    }
  }

  @override
  void dispose() {
    _listenedFocusNode.removeListener(onEffectiveFocusChange);
    _ownedFocusNode?.dispose();
    super.dispose();
  }
}

/// A controller that the widget gives or, when it gives none, the state
/// owns.
///
/// [onControllerChange] listens to the controller in use and follows it
/// when the widget starts or stops giving one, or gives another, after
/// which [didChangeController] runs. An owned controller that the widget
/// replaces is disposed after the frame, and the one still owned with the
/// state.
mixin OwnedControllerMixin<W extends StatefulWidget, C extends ChangeNotifier>
    on State<W> {
  C? _ownedController;
  late C _listenedController;

  /// The controller [widget] gives, if any.
  C? get widgetController;

  /// Creates the controller owned while the widget gives none.
  C createOwnedController();

  /// Called when the controller in use notifies its listeners.
  void onControllerChange() {}

  /// Called after the controller in use changed from [previous].
  void didChangeController(C previous) {}

  /// The controller in use: the widget's, or the one this state owns.
  C get effectiveController =>
      widgetController ?? (_ownedController ??= createOwnedController());

  @override
  void initState() {
    super.initState();
    _listenedController = effectiveController..addListener(onControllerChange);
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = effectiveController;
    final previous = _listenedController;
    if (identical(current, previous)) return;
    previous.removeListener(onControllerChange);
    _listenedController = current..addListener(onControllerChange);
    final owned = _ownedController;
    if (owned != null && !identical(owned, current)) {
      _ownedController = null;
      // Widgets below may still listen to it until this frame rebuilds.
      WidgetsBinding.instance.addPostFrameCallback((_) => owned.dispose());
    }
    didChangeController(previous);
  }

  @override
  void dispose() {
    _listenedController.removeListener(onControllerChange);
    _ownedController?.dispose();
    super.dispose();
  }
}

/// The chevron pointing toward the end of [context]'s reading direction
/// when [forward], and toward its start otherwise.
IconData directionalChevron(BuildContext context, {required bool forward}) {
  final rtl = Directionality.of(context) == TextDirection.rtl;
  return forward != rtl ? LucideIcons.chevron_right : LucideIcons.chevron_left;
}

/// The arrow keys that move toward the start ([back]) and the end
/// ([forward]) of [context]'s reading direction.
({LogicalKeyboardKey back, LogicalKeyboardKey forward}) readingArrowsOf(
  BuildContext context,
) {
  final rtl = Directionality.of(context) == TextDirection.rtl;
  return rtl
      ? (
          back: LogicalKeyboardKey.arrowRight,
          forward: LogicalKeyboardKey.arrowLeft,
        )
      : (
          back: LogicalKeyboardKey.arrowLeft,
          forward: LogicalKeyboardKey.arrowRight,
        );
}

/// Scrolls the scroll view around [item] to center it, unless it is
/// already fully visible.
///
/// The scroll animates for [duration], or jumps when it is null or
/// animations are disabled. Returns false when [item] isn't laid out in a
/// scroll view.
bool revealCentered(BuildContext item, {Duration? duration}) {
  final box = item.findRenderObject();
  if (box == null || !box.attached) return false;
  final viewport = RenderAbstractViewport.maybeOf(box);
  final position = Scrollable.maybeOf(item)?.position;
  if (viewport == null || position == null) return false;
  final atTop = viewport.getOffsetToReveal(box, 0).offset;
  final atBottom = viewport.getOffsetToReveal(box, 1).offset;
  if (position.pixels >= atBottom && position.pixels <= atTop) return true;
  final target = viewport
      .getOffsetToReveal(box, 0.5)
      .offset
      .clamp(position.minScrollExtent, position.maxScrollExtent);
  final reduced = MediaQuery.maybeDisableAnimationsOf(item) ?? false;
  if (duration != null && !reduced) {
    position.animateTo(target, duration: duration, curve: Curves.easeInOut);
  } else {
    position.jumpTo(target);
  }
  return true;
}

/// The value of a check box after a tap: unchecked becomes checked, and
/// checked becomes mixed with [tristate] or unchecked otherwise; mixed
/// becomes unchecked.
bool? nextCheckValue(bool? value, {required bool tristate}) => switch (value) {
  false => true,
  true => tristate ? null : false,
  null => false,
};

/// Activates the radio of [value] in a group showing [groupValue]: selects
/// it, or clears the group when it is already selected and [toggleable].
void activateRadio<T>(
  T value,
  T? groupValue,
  ValueChanged<T?> onChanged, {
  bool toggleable = false,
}) {
  if (value != groupValue) {
    onChanged(value);
  } else if (toggleable) {
    onChanged(null);
  }
}

/// [duration], or zero when [context] asks to reduce motion.
Duration motionDuration(BuildContext context, Duration duration) =>
    (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
    ? Duration.zero
    : duration;

/// [height] as a button's minimum height, offset by the theme's visual
/// density, which buttons apply on top of their minimum, so the button
/// ends up [height] tall.
double densityOffsetHeight(BuildContext context, double height) =>
    height - Theme.of(context).visualDensity.baseSizeAdjustment.dy;
