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

import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../foundation/platform_info.dart';
import '../foundation/system_settings.dart';
import '../foundation/window_button_layout.dart';
import '../tokens/geometry.dart';
import 'title_bar_gesture_detector.dart';
import 'title_bar_theme.dart';
import 'window_control.dart';
import 'window_controller.dart';

/// Width reserved at the leading edge for the native macOS traffic lights.
const double _macosTrafficLightsInset = 72;

/// A desktop header bar: a title, optional leading widget and actions, and
/// window control buttons in the order of [buttonLayout].
///
/// The empty area of the bar moves the window when dragged, maximizes or
/// restores it on double click and opens the window menu on secondary
/// click, through [controller]. Without a controller the buttons render
/// disabled, unless [onClose] handles the close button.
///
/// Most apps use [Oito2WindowTitleBar], which picks the control style,
/// layout and controller from the system automatically.
class Oito2TitleBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a title bar.
  const Oito2TitleBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.centerTitle,
    this.style,
    this.controlStyle = Oito2WindowControlStyle.gnome,
    this.buttonLayout = const Oito2WindowButtonLayout(
      trailing: [
        Oito2WindowButton.minimize,
        Oito2WindowButton.maximize,
        Oito2WindowButton.close,
      ],
    ),
    this.controller,
    this.onClose,
    this.labels,
    this.leadingInset = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
    this.height,
    this.isDraggable = true,
  });

  /// The title, usually a [Text].
  final Widget? title;

  /// A widget placed before the title, such as a back button.
  final Widget? leading;

  /// Widgets placed after the title, such as icon buttons.
  final List<Widget> actions;

  /// Whether the title is centered; defaults to the theme, then true.
  final bool? centerTitle;

  /// How the bar is presented; defaults to the theme, then
  /// [Oito2TitleBarStyle.normal].
  final Oito2TitleBarStyle? style;

  /// The visual family of the window control buttons.
  final Oito2WindowControlStyle controlStyle;

  /// Which window buttons appear and on which side.
  final Oito2WindowButtonLayout buttonLayout;

  /// The window controller that receives button presses and gestures.
  final Oito2WindowController? controller;

  /// Replaces the controller's close action, for example to pop a route.
  final VoidCallback? onClose;

  /// Overrides of the window buttons' accessibility labels, which
  /// otherwise come from [Oito2Localizations].
  final Oito2WindowControlLabels? labels;

  /// Empty space kept at the leading edge, for native window buttons drawn
  /// by the operating system.
  final double leadingInset;

  /// The background color; defaults to the theme.
  final Color? backgroundColor;

  /// The color of the title, icons and glyphs; defaults to the theme.
  final Color? foregroundColor;

  /// The bottom border; defaults to the theme.
  final BorderSide? border;

  /// The bar height; defaults to the [Oito2TitleBarThemeData] height, then
  /// [Oito2Sizes.titleBarHeight].
  ///
  /// [preferredSize] has no context to read the theme from, so a
  /// [Scaffold] gives the bar [Oito2Sizes.titleBarHeight] unless [height]
  /// is set. To follow a themed height there, wrap the bar in a
  /// [PreferredSize] sized by [preferredSizeOf].
  final double? height;

  /// Whether dragging the bar moves the window.
  final bool isDraggable;

  @override
  Size get preferredSize => Size.fromHeight(
    style == Oito2TitleBarStyle.hidden
        ? 0
        : height ?? Oito2Sizes.titleBarHeight,
  );

  /// The size of a title bar with [style] and [height] in [context]'s
  /// theme: zero tall when hidden, otherwise [height], the theme height or
  /// [Oito2Sizes.titleBarHeight].
  static Size preferredSizeOf(
    BuildContext context, {
    Oito2TitleBarStyle? style,
    double? height,
  }) {
    final barTheme = Oito2TitleBarThemeData.of(context);
    if ((style ?? barTheme.style) == Oito2TitleBarStyle.hidden) {
      return const Size.fromHeight(0);
    }
    return Size.fromHeight(
      height ?? barTheme.height ?? Oito2Sizes.titleBarHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller == null) {
      return _build(context, const Oito2WindowState());
    }
    return ValueListenableBuilder<Oito2WindowState>(
      valueListenable: controller.state,
      builder: (context, state, _) => _build(context, state),
    );
  }

  Widget _build(BuildContext context, Oito2WindowState state) {
    final theme = Theme.of(context);
    final barTheme = Oito2TitleBarThemeData.of(context);
    final appBarTheme = theme.appBarTheme;
    final resolvedStyle = style ?? barTheme.style ?? Oito2TitleBarStyle.normal;
    if (resolvedStyle == Oito2TitleBarStyle.hidden) {
      return const SizedBox.shrink();
    }

    final barHeight = height ?? barTheme.height ?? Oito2Sizes.titleBarHeight;
    final background =
        backgroundColor ??
        barTheme.backgroundColor ??
        appBarTheme.backgroundColor ??
        theme.colorScheme.surface;
    final foreground =
        foregroundColor ??
        barTheme.foregroundColor ??
        appBarTheme.foregroundColor ??
        theme.colorScheme.onSurface;
    final bottomBorder =
        border ??
        barTheme.border ??
        BorderSide(color: theme.colorScheme.outlineVariant);
    final titleStyle =
        (barTheme.titleTextStyle ??
                appBarTheme.titleTextStyle ??
                theme.textTheme.titleMedium ??
                const TextStyle())
            .copyWith(color: foreground);
    final showControls =
        resolvedStyle == Oito2TitleBarStyle.normal &&
        controlStyle != Oito2WindowControlStyle.none;

    Widget control(Oito2WindowButton button) {
      final type = switch (button) {
        Oito2WindowButton.minimize => Oito2WindowControlType.minimize,
        Oito2WindowButton.maximize =>
          state.isMaximized
              ? Oito2WindowControlType.restore
              : Oito2WindowControlType.maximize,
        Oito2WindowButton.close => Oito2WindowControlType.close,
      };
      final action = switch (button) {
        Oito2WindowButton.minimize => controller?.minimize,
        Oito2WindowButton.maximize => controller?.toggleMaximize,
        Oito2WindowButton.close => onClose ?? controller?.close,
      };
      return Oito2WindowControl(
        type: type,
        style: controlStyle,
        label: Oito2WindowControlLabels.resolve(context, type, labels),
        foregroundColor: foreground,
        height: barHeight,
        isActive: state.isActive,
        onPressed: action,
      );
    }

    final isWindows = controlStyle == Oito2WindowControlStyle.windows;
    final gap = switch (controlStyle) {
      Oito2WindowControlStyle.windows || Oito2WindowControlStyle.macos => 0.0,
      _ => Oito2Spacing.sm,
    };
    final edge = isWindows ? 0.0 : Oito2Spacing.sm;

    Widget controls(List<Oito2WindowButton> buttons) {
      if (!showControls || buttons.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: gap,
        children: [for (final button in buttons) control(button)],
      );
    }

    final leadingControls = controls(buttonLayout.leading);
    final trailingControls = controls(buttonLayout.trailing);
    final title = this.title;

    final toolbar = NavigationToolbar(
      centerMiddle: centerTitle ?? barTheme.centerTitle ?? true,
      middleSpacing: Oito2Spacing.lg,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: leadingInset + edge),
          leadingControls,
          if (leading case final leading?) ...[
            const SizedBox(width: Oito2Spacing.xs),
            leading,
          ],
        ],
      ),
      middle: title == null
          ? null
          : IgnorePointer(
              child: DefaultTextStyle(
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Semantics(header: true, child: title),
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: Oito2Spacing.xs),
              child: action,
            ),
          if (showControls && buttonLayout.trailing.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: actions.isEmpty ? 0 : Oito2Spacing.xs,
              ),
              child: trailingControls,
            ),
          SizedBox(width: edge),
        ],
      ),
    );

    final content = IconTheme.merge(
      data: IconThemeData(color: foreground, size: Oito2Sizes.iconSize),
      child: AnimatedOpacity(
        opacity: state.isActive ? 1 : (barTheme.inactiveOpacity ?? 0.7),
        duration: const Duration(milliseconds: 150),
        child: toolbar,
      ),
    );

    return Semantics(
      container: true,
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: background,
          border: Border(bottom: bottomBorder),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isDraggable)
              Oito2TitleBarGestureDetector(
                controller: controller,
                child: const SizedBox.expand(),
              ),
            content,
          ],
        ),
      ),
    );
  }
}

/// Which side's window buttons an [Oito2WindowTitleBar] shows.
///
/// A window split into a sidebar and a content area can give each its own
/// title bar, as GNOME apps do: the sidebar bar shows the [leading]
/// buttons of the system layout and the content bar the [trailing] ones.
enum Oito2WindowButtonSides {
  /// Both sides of the system button layout.
  both,

  /// Only the leading side, such as macOS buttons or a left-side close.
  leading,

  /// Only the trailing side.
  trailing,
}

/// The app window's title bar, adapted to the platform.
///
/// - On native Linux and Windows it is an [Oito2TitleBar] with the window
///   control style and button layout of [Oito2SystemScope], driven by the
///   [Oito2WindowScope] controller.
/// - On native macOS it keeps room for the native traffic lights instead
///   of drawing its own buttons.
/// - On the web it shows the title and actions without window buttons,
///   since the browser owns the page lifecycle.
/// - On touch platforms it is a regular [AppBar], which handles the
///   status bar safe area.
class Oito2WindowTitleBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates an adaptive window title bar.
  const Oito2WindowTitleBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.centerTitle,
    this.style,
    this.controller,
    this.labels,
    this.platform,
    this.buttonSides = Oito2WindowButtonSides.both,
    this.backgroundColor,
    this.border,
  });

  /// The title, usually a [Text].
  final Widget? title;

  /// A widget placed before the title.
  final Widget? leading;

  /// Widgets placed after the title.
  final List<Widget> actions;

  /// Whether the title is centered; defaults to the theme.
  final bool? centerTitle;

  /// How the bar is presented on desktop platforms; defaults to the theme.
  final Oito2TitleBarStyle? style;

  /// The window controller; defaults to the closest [Oito2WindowScope].
  final Oito2WindowController? controller;

  /// Overrides of the window buttons' accessibility labels, which
  /// otherwise come from [Oito2Localizations].
  final Oito2WindowControlLabels? labels;

  /// The platform used to compute [preferredSize], which is read before
  /// the widget has a context; defaults to [Oito2Platform.current]. The
  /// layout itself follows [Oito2SystemScope].
  final Oito2Platform? platform;

  /// Which side's window buttons the bar shows, for split title bars.
  final Oito2WindowButtonSides buttonSides;

  /// The bar background on desktop and the web; defaults to the theme.
  final Color? backgroundColor;

  /// The bottom border on desktop and the web; defaults to the theme.
  final BorderSide? border;

  @override
  Size get preferredSize {
    final target = platform ?? Oito2Platform.current();
    if (target.usesTouchInput) return const Size.fromHeight(kToolbarHeight);
    return Size.fromHeight(
      style == Oito2TitleBarStyle.hidden ? 0 : Oito2Sizes.titleBarHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Oito2SystemScope.of(context);
    final target = settings.platform;

    if (target.usesTouchInput) {
      return AppBar(
        title: title,
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
      );
    }

    if (!target.isDesktopNative) {
      return Oito2TitleBar(
        title: title,
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
        style: style,
        controlStyle: Oito2WindowControlStyle.none,
        isDraggable: false,
        backgroundColor: backgroundColor,
        border: border,
      );
    }

    final controller = this.controller ?? Oito2WindowScope.maybeOf(context);
    final nativeButtons = target.isMacOS;
    final layout = settings.windowButtonLayout;
    final showLeading = buttonSides != Oito2WindowButtonSides.trailing;
    final showTrailing = buttonSides != Oito2WindowButtonSides.leading;
    Widget bar(Oito2WindowState state) => Oito2TitleBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      style: style,
      controlStyle: nativeButtons
          ? Oito2WindowControlStyle.none
          : settings.windowControlStyle,
      buttonLayout: Oito2WindowButtonLayout(
        leading: showLeading ? layout.leading : const [],
        trailing: showTrailing ? layout.trailing : const [],
      ),
      controller: controller,
      labels: labels,
      leadingInset: nativeButtons && showLeading && !state.isFullScreen
          ? _macosTrafficLightsInset
          : 0,
      backgroundColor: backgroundColor,
      border: border,
    );

    if (controller == null || !nativeButtons) {
      return bar(controller?.state.value ?? const Oito2WindowState());
    }
    return ValueListenableBuilder<Oito2WindowState>(
      valueListenable: controller.state,
      builder: (context, state, _) => bar(state),
    );
  }
}

/// The title bar of a dialog: a title and a close button that pops the
/// dialog route.
///
/// The close button follows the system window control style, falling back
/// to the GNOME style where the platform has none (web, touch and macOS),
/// and the side of the close button in the system button layout.
class Oito2DialogTitleBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates a dialog title bar.
  const Oito2DialogTitleBar({
    super.key,
    this.title,
    this.leading,
    this.onClose,
    this.labels,
  });

  /// The dialog title, usually a [Text].
  final Widget? title;

  /// A widget before the title, such as an [Icon] or an animated
  /// `Oito2AnimatedIcon` that tells what the dialog is about.
  final Widget? leading;

  /// Called when the close button is pressed; defaults to popping the
  /// current route.
  final VoidCallback? onClose;

  /// Override of the close button's accessibility label, which otherwise
  /// comes from [Oito2Localizations].
  final Oito2WindowControlLabels? labels;

  @override
  Size get preferredSize => const Size.fromHeight(Oito2Sizes.titleBarHeight);

  @override
  Widget build(BuildContext context) {
    final settings = Oito2SystemScope.of(context);
    final style = switch (settings.windowControlStyle) {
      Oito2WindowControlStyle.none ||
      Oito2WindowControlStyle.macos => Oito2WindowControlStyle.gnome,
      final style => style,
    };
    final closeLeading = settings.windowButtonLayout.leading.contains(
      Oito2WindowButton.close,
    );
    const close = [Oito2WindowButton.close];
    return Oito2TitleBar(
      title: title,
      leading: leading,
      controlStyle: style,
      buttonLayout: closeLeading
          ? const Oito2WindowButtonLayout(leading: close)
          : const Oito2WindowButtonLayout(trailing: close),
      labels: labels,
      onClose: onClose ?? () => Navigator.of(context).maybePop(),
      backgroundColor: const Color(0x00000000),
      border: BorderSide.none,
      isDraggable: false,
    );
  }
}
