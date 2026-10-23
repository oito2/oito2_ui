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

import 'dart:async';
import 'dart:ui' show Color;

import 'package:oito2_ui/oito2_ui.dart';

import 'config_parsers.dart';
import 'sources.dart';

/// Builds [Oito2SystemSettings] from the system stores of the current
/// platform.
///
/// On native Linux it detects the desktop environment from [environment]
/// and reads the window button layout per desktop:
///
/// - GNOME, Budgie, Pantheon, Unity and unknown desktops:
///   `org.gnome.desktop.wm.preferences button-layout`.
/// - Cinnamon: `org.cinnamon.desktop.wm.preferences button-layout`.
/// - MATE: `org.mate.Marco.general button-layout`.
/// - KDE Plasma: `ButtonsOnLeft` and `ButtonsOnRight` in the
///   `[org.kde.kdecoration2]` group of `kwinrc`.
/// - Xfce: `button_layout` in `xfwm4.xml`.
/// - COSMIC: `com.system76.CosmicTk/v1/show_minimize` and
///   `show_maximize`.
///
/// KDE Plasma reads the accent from `AccentColor` in the `[General]` group
/// of `kdeglobals`, and high contrast from a `kdeglobals` color scheme whose
/// name contains "contrast". Every other desktop reads the accent from
/// `org.gnome.desktop.interface accent-color`, and high contrast from
/// `org.gnome.desktop.a11y.interface high-contrast` or a `HighContrast` GTK
/// theme. Without a desktop accent, the accent comes from the toolkit
/// theme through [accent].
///
/// Missing values fall back to each desktop's defaults. On other
/// platforms only the accent comes from [accent]. [platformHighContrast]
/// is combined with the desktop preference on every platform.
class Oito2SystemSettingsReader {
  /// Creates a reader for [platform] over the given sources.
  ///
  /// Every source defaults to an [Oito2EmptySource], and
  /// [platformHighContrast] to a function that returns false.
  Oito2SystemSettingsReader({
    required this.platform,
    this.environment = const {},
    this.gsettings = const Oito2EmptySource(),
    this.configFiles = const Oito2EmptySource(),
    this.accent = const Oito2EmptySource(),
    this.platformHighContrast = _never,
    this.debounce = const Duration(milliseconds: 150),
  });

  static bool _never() => false;

  /// The platform the settings are read for.
  final Oito2Platform platform;

  /// The process environment variables.
  final Map<String, String> environment;

  /// The GSettings store.
  final Oito2GSettingsSource gsettings;

  /// The user's configuration files.
  final Oito2ConfigFileSource configFiles;

  /// The toolkit or operating system accent color.
  final Oito2AccentSource accent;

  /// Whether the platform accessibility settings ask for high contrast.
  final bool Function() platformHighContrast;

  /// How long [watch] waits after a change before reading again, so a
  /// burst of changes produces one update.
  final Duration debounce;

  static const _gnomeWm = 'org.gnome.desktop.wm.preferences';
  static const _cinnamonWm = 'org.cinnamon.desktop.wm.preferences';
  static const _mateWm = 'org.mate.Marco.general';
  static const _gnomeInterface = 'org.gnome.desktop.interface';
  static const _gnomeA11y = 'org.gnome.desktop.a11y.interface';
  static const _kwinrc = 'kwinrc';
  static const _kdeglobals = 'kdeglobals';
  static const _xfwm = 'xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml';
  static const _cosmicMinimize =
      'cosmic/com.system76.CosmicTk/v1/show_minimize';
  static const _cosmicMaximize =
      'cosmic/com.system76.CosmicTk/v1/show_maximize';

  bool get _isLinuxDesktop => platform.isLinux && platform.isDesktopNative;

  /// The detected desktop environment, or null outside native Linux.
  Oito2DesktopEnvironment? get desktopEnvironment => _isLinuxDesktop
      ? Oito2DesktopEnvironment.detect(
          xdgCurrentDesktop: environment['XDG_CURRENT_DESKTOP'],
          desktopSession: environment['DESKTOP_SESSION'],
        )
      : null;

  /// Reads the current settings from every source.
  ///
  /// A source that fails to read counts as missing, so its value falls
  /// back to the desktop default.
  Future<Oito2SystemSettings> read() async {
    final environment = desktopEnvironment;
    final fallback = Oito2SystemSettings.fallback(
      platform,
      desktopEnvironment: environment,
    );
    final layout = environment == null
        ? null
        : await _buttonLayout(environment);
    final accentColor = environment == null
        ? await _safe(accent.read)
        : await _linuxAccent(environment);
    final highContrast =
        platformHighContrast() ||
        (environment != null && await _linuxHighContrast(environment));
    return Oito2SystemSettings(
      platform: platform,
      desktopEnvironment: environment,
      windowControlStyle: fallback.windowControlStyle,
      windowButtonLayout: layout ?? fallback.windowButtonLayout,
      accentColor: accentColor,
      highContrast: highContrast,
    );
  }

  /// Emits the current settings, then the new settings whenever a source
  /// reports a change that alters them.
  ///
  /// A read that a newer one overtakes is dropped, and a failed read is
  /// emitted as an error.
  Stream<Oito2SystemSettings> watch() {
    late StreamController<Oito2SystemSettings> controller;
    final subscriptions = <StreamSubscription<void>>[];
    Timer? timer;
    Oito2SystemSettings? last;
    var generation = 0;

    Future<void> emit() async {
      final current = ++generation;
      try {
        final settings = await read();
        if (current != generation || controller.isClosed) return;
        if (settings != last) {
          last = settings;
          controller.add(settings);
        }
      } on Object catch (error, stack) {
        if (current == generation && !controller.isClosed) {
          controller.addError(error, stack);
        }
      }
    }

    void schedule() {
      timer?.cancel();
      timer = Timer(debounce, emit);
    }

    controller = StreamController<Oito2SystemSettings>(
      onListen: () {
        for (final stream in _changeStreams()) {
          subscriptions.add(stream.listen((_) => schedule(), onError: (_) {}));
        }
        emit();
      },
      onCancel: () async {
        timer?.cancel();
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  /// Releases the connections the system stores hold, such as the D-Bus
  /// connections of GSettings. The reader can't be used afterwards.
  Future<void> close() => gsettings.close();

  /// The change streams of the sources that [read] uses on this platform
  /// and desktop.
  Iterable<Stream<void>> _changeStreams() sync* {
    yield accent.changes();
    final environment = desktopEnvironment;
    if (environment == null) return;
    switch (environment) {
      case Oito2DesktopEnvironment.kde:
        yield configFiles.changes(_kwinrc);
        yield configFiles.changes(_kdeglobals);
      case Oito2DesktopEnvironment.xfce:
        yield configFiles.changes(_xfwm);
      case Oito2DesktopEnvironment.cosmic:
        yield configFiles.changes(_cosmicMinimize);
        yield configFiles.changes(_cosmicMaximize);
      case Oito2DesktopEnvironment.cinnamon:
        yield gsettings.changes(_cinnamonWm);
      case Oito2DesktopEnvironment.mate:
        yield gsettings.changes(_mateWm);
      default:
        yield gsettings.changes(_gnomeWm);
    }
    if (environment != Oito2DesktopEnvironment.kde) {
      yield gsettings.changes(_gnomeInterface);
      yield gsettings.changes(_gnomeA11y);
    }
  }

  /// Reads the window button layout of [environment], or null when its
  /// GSettings key is missing or unparsable.
  Future<Oito2WindowButtonLayout?> _buttonLayout(
    Oito2DesktopEnvironment environment,
  ) async {
    switch (environment) {
      case Oito2DesktopEnvironment.kde:
        final kwinrc = await _safe(() => configFiles.read(_kwinrc)) ?? '';
        const group = 'org.kde.kdecoration2';
        // Missing keys use KWin's default buttons.
        return Oito2WindowButtonLayout.parseKde(
          buttonsOnLeft:
              Oito2ConfigParsers.iniValue(kwinrc, group, 'ButtonsOnLeft') ??
              'MS',
          buttonsOnRight:
              Oito2ConfigParsers.iniValue(kwinrc, group, 'ButtonsOnRight') ??
              'HIAX',
        );
      case Oito2DesktopEnvironment.xfce:
        final xml = await _safe(() => configFiles.read(_xfwm)) ?? '';
        // A missing property uses xfwm4's default layout.
        return Oito2WindowButtonLayout.parseXfwm(
          Oito2ConfigParsers.xfconfProperty(xml, 'button_layout') ?? 'O|SHMC',
        );
      case Oito2DesktopEnvironment.cosmic:
        // A missing or unparsable flag shows the button.
        Future<bool> flag(String path) async {
          final content = await _safe(() => configFiles.read(path));
          return content == null
              ? true
              : Oito2ConfigParsers.cosmicBool(content) ?? true;
        }
        return Oito2WindowButtonLayout(
          trailing: [
            if (await flag(_cosmicMinimize)) Oito2WindowButton.minimize,
            if (await flag(_cosmicMaximize)) Oito2WindowButton.maximize,
            Oito2WindowButton.close,
          ],
        );
      case Oito2DesktopEnvironment.cinnamon:
        return _gnomeLayout(_cinnamonWm);
      case Oito2DesktopEnvironment.mate:
        return _gnomeLayout(_mateWm);
      default:
        return _gnomeLayout(_gnomeWm);
    }
  }

  /// Parses the GNOME-style `button-layout` key of [schema], or returns
  /// null when it isn't a string.
  Future<Oito2WindowButtonLayout?> _gnomeLayout(String schema) async {
    final value = await _safe(() => gsettings.read(schema, 'button-layout'));
    return value is String ? Oito2WindowButtonLayout.parseGnome(value) : null;
  }

  /// Reads the desktop accent of [environment], falling back to [accent].
  Future<Color?> _linuxAccent(Oito2DesktopEnvironment environment) async {
    if (environment == Oito2DesktopEnvironment.kde) {
      final globals = await _safe(() => configFiles.read(_kdeglobals)) ?? '';
      final value = Oito2ConfigParsers.iniValue(
        globals,
        'General',
        'AccentColor',
      );
      final color = value == null ? null : Oito2ConfigParsers.kdeColor(value);
      if (color != null) return color;
    } else {
      final name = await _safe(
        () => gsettings.read(_gnomeInterface, 'accent-color'),
      );
      for (final accent in Oito2AccentColor.values) {
        if (accent.name == name) return accent.color;
      }
    }
    return _safe(accent.read);
  }

  /// Whether the desktop settings of [environment] ask for high contrast.
  Future<bool> _linuxHighContrast(Oito2DesktopEnvironment environment) async {
    if (environment == Oito2DesktopEnvironment.kde) {
      final globals = await _safe(() => configFiles.read(_kdeglobals)) ?? '';
      final scheme =
          Oito2ConfigParsers.iniValue(globals, 'General', 'ColorScheme') ?? '';
      return scheme.toLowerCase().contains('contrast');
    }
    final enabled = await _safe(
      () => gsettings.read(_gnomeA11y, 'high-contrast'),
    );
    if (enabled == true) return true;
    final theme = await _safe(
      () => gsettings.read(_gnomeInterface, 'gtk-theme'),
    );
    return theme is String && theme.toLowerCase().contains('highcontrast');
  }

  /// Runs [read], turning any error into null so one broken store never
  /// prevents reading the others.
  static Future<T?> _safe<T>(Future<T?> Function() read) async {
    try {
      return await read();
    } on Object {
      return null;
    }
  }
}
