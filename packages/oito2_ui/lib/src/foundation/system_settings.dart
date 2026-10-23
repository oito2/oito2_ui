// Copyright (C) 2026  OITO2
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

import 'desktop_environment.dart';
import 'platform_info.dart';
import 'window_button_layout.dart';

/// The operating system preferences that shape an `oito2_ui` app: platform,
/// desktop environment, window controls, accent color and contrast.
///
/// [Oito2SystemSettings.fallback] derives every value from the platform
/// alone. The `oito2_ui_settings` package reads the real values from the
/// operating system.
@immutable
class Oito2SystemSettings {
  /// Creates system settings from explicit values.
  const Oito2SystemSettings({
    required this.platform,
    required this.windowControlStyle,
    required this.windowButtonLayout,
    this.desktopEnvironment,
    this.accentColor,
    this.highContrast = false,
  });

  /// Creates settings derived from [platform] only.
  ///
  /// On native Linux, [desktopEnvironment] defaults to
  /// [Oito2DesktopEnvironment.unknown]; on other platforms it stays null.
  /// The window control style and button layout follow
  /// [Oito2WindowControlStyle.resolve] and
  /// [Oito2WindowButtonLayout.defaultFor]. There is no accent color and high
  /// contrast is off.
  factory Oito2SystemSettings.fallback(
    Oito2Platform platform, {
    Oito2DesktopEnvironment? desktopEnvironment,
  }) {
    final environment = platform.isLinux && platform.isDesktopNative
        ? desktopEnvironment ?? Oito2DesktopEnvironment.unknown
        : null;
    final style = Oito2WindowControlStyle.resolve(
      platform,
      desktopEnvironment: environment,
    );
    return Oito2SystemSettings(
      platform: platform,
      desktopEnvironment: environment,
      windowControlStyle: style,
      windowButtonLayout: Oito2WindowButtonLayout.defaultFor(style),
    );
  }

  /// The platform the app runs on.
  final Oito2Platform platform;

  /// The Linux desktop environment, or null outside native Linux.
  final Oito2DesktopEnvironment? desktopEnvironment;

  /// The visual family of the window control buttons.
  final Oito2WindowControlStyle windowControlStyle;

  /// The order and side of the window control buttons.
  final Oito2WindowButtonLayout windowButtonLayout;

  /// The system accent color, or null when the system has none or it is
  /// unknown.
  final Color? accentColor;

  /// Whether the system asks for high contrast.
  final bool highContrast;

  /// Returns a copy with the given fields replaced.
  ///
  /// [accentColor] and [desktopEnvironment] can't be reset to null through
  /// this method; create a new instance for that.
  Oito2SystemSettings copyWith({
    Oito2Platform? platform,
    Oito2DesktopEnvironment? desktopEnvironment,
    Oito2WindowControlStyle? windowControlStyle,
    Oito2WindowButtonLayout? windowButtonLayout,
    Color? accentColor,
    bool? highContrast,
  }) {
    return Oito2SystemSettings(
      platform: platform ?? this.platform,
      desktopEnvironment: desktopEnvironment ?? this.desktopEnvironment,
      windowControlStyle: windowControlStyle ?? this.windowControlStyle,
      windowButtonLayout: windowButtonLayout ?? this.windowButtonLayout,
      accentColor: accentColor ?? this.accentColor,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2SystemSettings &&
      other.platform == platform &&
      other.desktopEnvironment == desktopEnvironment &&
      other.windowControlStyle == windowControlStyle &&
      other.windowButtonLayout == windowButtonLayout &&
      other.accentColor == accentColor &&
      other.highContrast == highContrast;

  @override
  int get hashCode => Object.hash(
    platform,
    desktopEnvironment,
    windowControlStyle,
    windowButtonLayout,
    accentColor,
    highContrast,
  );

  @override
  String toString() =>
      'Oito2SystemSettings(platform: $platform, '
      'desktopEnvironment: ${desktopEnvironment?.name}, '
      'windowControlStyle: ${windowControlStyle.name}, '
      'windowButtonLayout: $windowButtonLayout, '
      'accentColor: $accentColor, highContrast: $highContrast)';
}

/// Exposes [Oito2SystemSettings] to the widgets below it.
class Oito2SystemScope extends InheritedWidget {
  /// Creates a scope that provides [settings] to [child].
  const Oito2SystemScope({
    super.key,
    required this.settings,
    required super.child,
  });

  /// The settings provided to descendant widgets.
  final Oito2SystemSettings settings;

  /// Returns the settings of the closest enclosing [Oito2SystemScope], or
  /// null when there is none. Registers [context] for rebuilds when they
  /// change.
  static Oito2SystemSettings? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Oito2SystemScope>()
        ?.settings;
  }

  /// Returns the settings of the closest enclosing [Oito2SystemScope], or
  /// [Oito2SystemSettings.fallback] for [Oito2Platform.current] when there
  /// is none.
  static Oito2SystemSettings of(BuildContext context) {
    return maybeOf(context) ??
        Oito2SystemSettings.fallback(Oito2Platform.current());
  }

  @override
  bool updateShouldNotify(Oito2SystemScope oldWidget) =>
      settings != oldWidget.settings;
}
