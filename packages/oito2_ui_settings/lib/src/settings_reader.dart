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
import 'dart:ui' show Brightness, Color;

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
/// The accent comes from [portalAccent], the desktop portal's
/// `org.freedesktop.appearance accent-color`. Without a portal accent, KDE
/// Plasma reads `AccentColor` in the `[General]` group of `kdeglobals` and
/// GNOME reads `org.gnome.desktop.interface accent-color`; other desktops,
/// and these two when their key is missing, use the toolkit theme through
/// [accent]. Cinnamon and MATE read again when their own interface schema
/// changes, such as when the GTK theme changes.
///
/// KDE Plasma reads high contrast from a `kdeglobals` color scheme whose
/// name contains "contrast"; every other desktop from
/// `org.gnome.desktop.a11y.interface high-contrast` or a `HighContrast` GTK
/// theme.
///
/// The color scheme comes from [colorScheme], the desktop portal's
/// `org.freedesktop.appearance color-scheme`. When the portal states no
/// preference, the desktop store decides: `org.gnome.desktop.interface
/// color-scheme` (`prefer-dark` or `prefer-light`) on the GNOME family,
/// Cinnamon and MATE; a `kdeglobals` color scheme or look-and-feel package
/// whose name contains "dark" on KDE Plasma; the
/// `com.system76.CosmicTheme.Mode/v1/is_dark` flag on COSMIC. Xfce and
/// LXQt have no store beyond the portal.
///
/// Reduced motion is true when [reducedMotion], the desktop portal's
/// `org.freedesktop.appearance reduced-motion`, or a desktop key asks for
/// it: `org.gnome.desktop.interface enable-animations` turned off or
/// `org.gnome.desktop.a11y.interface reduced-motion` set to `reduce` on
/// the GNOME family; `org.cinnamon.desktop.interface enable-animations`
/// or `org.cinnamon desktop-effects-workspace` turned off on Cinnamon;
/// `org.mate.interface enable-animations` or `gtk-enable-animations`
/// turned off on MATE; `AnimationDurationFactor=0` in the `[KDE]` group of
/// `kdeglobals` on KDE Plasma. It is false when a source states no such
/// preference, and null when none is available, as on Xfce, LXQt and
/// COSMIC without a portal that reports it.
///
/// The text scale factor comes from `text-scaling-factor` in
/// `org.gnome.desktop.interface` (GNOME family) or
/// `org.cinnamon.desktop.interface` (Cinnamon); from a font DPI divided by
/// 96 elsewhere: `org.mate.font-rendering dpi` on MATE (null while it is
/// 0, the automatic DPI), `forceFontDPI` in the `[General]` group of
/// `kcmfonts` on KDE Plasma on X11 (1.0 while it isn't forced, and always
/// 1.0 in a Wayland session, where Plasma doesn't apply it) and `Xft/DPI` in
/// `xsettings.xml` on Xfce (1.0 without the property, null for the
/// automatic DPI). COSMIC and LXQt have no text scaling setting.
///
/// The cursor size comes from `cursor-size` in
/// `org.gnome.desktop.interface` (GNOME family),
/// `org.cinnamon.desktop.interface` (Cinnamon) or
/// `org.mate.peripherals-mouse` (MATE); from `cursorSize` in the `[Mouse]`
/// group of `kcminputrc` on KDE Plasma (24 without it),
/// `Gtk/CursorThemeSize` in `xsettings.xml` on Xfce,
/// `com.system76.CosmicComp/v1/cursor_size` on COSMIC and `cursor_size` in
/// the `[Mouse]` group of `lxqt/session.conf` on LXQt. Sizes of 0 or less
/// mean the cursor theme's default and read as null.
///
/// Missing values fall back to each desktop's defaults. On other
/// platforms the accent comes from [accent], the color scheme from
/// [platformBrightness], reduced motion from [platformReduceMotion] and
/// the text scale factor from [platformTextScaleFactor]; the cursor size
/// is null. [platformHighContrast] is combined with the desktop preference
/// on every platform, and [platformReduceMotion] with the desktop
/// preference on native Linux.
class Oito2SystemSettingsReader {
  /// Creates a reader for [platform] over the given sources.
  ///
  /// Every source defaults to an [Oito2EmptySource], [platformHighContrast]
  /// to a function that returns false and [platformBrightness],
  /// [platformReduceMotion] and [platformTextScaleFactor] to functions that
  /// return null.
  Oito2SystemSettingsReader({
    required this.platform,
    this.environment = const {},
    this.gsettings = const Oito2EmptySource(),
    this.configFiles = const Oito2EmptySource(),
    this.accent = const Oito2EmptySource(),
    this.portalAccent = const Oito2EmptySource(),
    this.colorScheme = const Oito2EmptySource(),
    this.reducedMotion = const Oito2EmptySource(),
    this.platformHighContrast = _never,
    this.platformBrightness = _noBrightness,
    this.platformReduceMotion = _unknownMotion,
    this.platformTextScaleFactor = _unknownTextScale,
    this.debounce = const Duration(milliseconds: 150),
  });

  static bool _never() => false;

  static Brightness? _noBrightness() => null;

  static bool? _unknownMotion() => null;

  static double? _unknownTextScale() => null;

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

  /// The desktop portal's accent color, read first on native Linux.
  final Oito2AccentSource portalAccent;

  /// The desktop portal's color scheme preference.
  final Oito2ColorSchemeSource colorScheme;

  /// The desktop portal's reduced motion preference.
  final Oito2ReducedMotionSource reducedMotion;

  /// Whether the platform accessibility settings ask for high contrast.
  final bool Function() platformHighContrast;

  /// The light or dark scheme the platform reports outside native Linux,
  /// or null when it reports none.
  final Brightness? Function() platformBrightness;

  /// Whether the platform asks for reduced motion, or null when it doesn't
  /// report the preference.
  final bool? Function() platformReduceMotion;

  /// The text scale factor the platform reports, or null when it reports
  /// none.
  final double? Function() platformTextScaleFactor;

  /// How long [watch] waits after a change before reading again, so a
  /// burst of changes produces one update.
  final Duration debounce;

  static const _gnomeWm = 'org.gnome.desktop.wm.preferences';
  static const _cinnamonWm = 'org.cinnamon.desktop.wm.preferences';
  static const _mateWm = 'org.mate.Marco.general';
  static const _gnomeInterface = 'org.gnome.desktop.interface';
  static const _cinnamonInterface = 'org.cinnamon.desktop.interface';
  static const _mateInterface = 'org.mate.interface';
  static const _gnomeA11y = 'org.gnome.desktop.a11y.interface';
  static const _cinnamon = 'org.cinnamon';
  static const _mateFonts = 'org.mate.font-rendering';
  static const _mateMouse = 'org.mate.peripherals-mouse';
  static const _kcmfonts = 'kcmfonts';
  static const _kcminputrc = 'kcminputrc';
  static const _xsettings = 'xfce4/xfconf/xfce-perchannel-xml/xsettings.xml';
  static const _cosmicCursorSize =
      'cosmic/com.system76.CosmicComp/v1/cursor_size';
  static const _lxqtSession = 'lxqt/session.conf';

  /// The font DPI that stands for a text scale factor of 1.0.
  static const _baseDpi = 96.0;
  static const _kwinrc = 'kwinrc';
  static const _kdeglobals = 'kdeglobals';
  static const _xfwm = 'xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml';
  static const _cosmicMinimize =
      'cosmic/com.system76.CosmicTk/v1/show_minimize';
  static const _cosmicMaximize =
      'cosmic/com.system76.CosmicTk/v1/show_maximize';
  static const _cosmicDark = 'cosmic/com.system76.CosmicTheme.Mode/v1/is_dark';

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
    final scheme = environment == null
        ? platformBrightness()
        : await _linuxColorScheme(environment);
    final reduceMotion = environment == null
        ? platformReduceMotion()
        : await _linuxReduceMotion(environment);
    final textScaleFactor = environment == null
        ? platformTextScaleFactor()
        : await _linuxTextScaleFactor(environment);
    final cursorSize = environment == null
        ? null
        : await _linuxCursorSize(environment);
    return Oito2SystemSettings(
      platform: platform,
      desktopEnvironment: environment,
      windowControlStyle: fallback.windowControlStyle,
      windowButtonLayout: layout ?? fallback.windowButtonLayout,
      accentColor: accentColor,
      colorScheme: scheme,
      highContrast: highContrast,
      reduceMotion: reduceMotion,
      textScaleFactor: textScaleFactor,
      cursorSize: cursorSize,
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
  /// connections of GSettings and of the desktop portal. The reader can't
  /// be used afterwards.
  Future<void> close() async {
    await gsettings.close();
    await accent.close();
    await portalAccent.close();
    await colorScheme.close();
    await reducedMotion.close();
  }

  /// The change streams of the sources that [read] uses on this platform
  /// and desktop.
  Iterable<Stream<void>> _changeStreams() sync* {
    yield accent.changes();
    final environment = desktopEnvironment;
    if (environment == null) return;
    yield portalAccent.changes();
    yield colorScheme.changes();
    yield reducedMotion.changes();
    switch (environment) {
      case Oito2DesktopEnvironment.kde:
        yield configFiles.changes(_kwinrc);
        yield configFiles.changes(_kdeglobals);
        yield configFiles.changes(_kcmfonts);
        yield configFiles.changes(_kcminputrc);
      case Oito2DesktopEnvironment.xfce:
        yield configFiles.changes(_xfwm);
        yield configFiles.changes(_xsettings);
      case Oito2DesktopEnvironment.cosmic:
        yield configFiles.changes(_cosmicMinimize);
        yield configFiles.changes(_cosmicMaximize);
        yield configFiles.changes(_cosmicDark);
        yield configFiles.changes(_cosmicCursorSize);
      case Oito2DesktopEnvironment.cinnamon:
        yield gsettings.changes(_cinnamonWm);
        yield gsettings.changes(_cinnamonInterface);
        yield gsettings.changes(_cinnamon);
      case Oito2DesktopEnvironment.mate:
        yield gsettings.changes(_mateWm);
        yield gsettings.changes(_mateInterface);
        yield gsettings.changes(_mateFonts);
        yield gsettings.changes(_mateMouse);
      case Oito2DesktopEnvironment.lxqt:
        yield gsettings.changes(_gnomeWm);
        yield configFiles.changes(_lxqtSession);
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

  /// Reads the portal accent, then the desktop accent of [environment],
  /// falling back to [accent].
  ///
  /// The GNOME `accent-color` key is read on GNOME alone: other desktops
  /// may install its schema without using it, and its default would hide
  /// their theme's accent.
  Future<Color?> _linuxAccent(Oito2DesktopEnvironment environment) async {
    final portal = await _safe(portalAccent.read);
    if (portal != null) return portal;
    if (environment == Oito2DesktopEnvironment.kde) {
      final globals = await _safe(() => configFiles.read(_kdeglobals)) ?? '';
      final value = Oito2ConfigParsers.iniValue(
        globals,
        'General',
        'AccentColor',
      );
      final color = value == null ? null : Oito2ConfigParsers.kdeColor(value);
      if (color != null) return color;
    } else if (environment == Oito2DesktopEnvironment.gnome) {
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

  /// Reads the color scheme of [environment]: the desktop portal first,
  /// then the desktop's own store. Returns null when neither states a
  /// preference.
  Future<Brightness?> _linuxColorScheme(
    Oito2DesktopEnvironment environment,
  ) async {
    final portal = await _safe(colorScheme.read);
    if (portal != null) return portal;
    switch (environment) {
      case Oito2DesktopEnvironment.kde:
        final globals = await _safe(() => configFiles.read(_kdeglobals)) ?? '';
        final scheme =
            Oito2ConfigParsers.iniValue(globals, 'General', 'ColorScheme') ??
            Oito2ConfigParsers.iniValue(globals, 'KDE', 'LookAndFeelPackage') ??
            '';
        return scheme.toLowerCase().contains('dark') ? Brightness.dark : null;
      case Oito2DesktopEnvironment.cosmic:
        final content = await _safe(() => configFiles.read(_cosmicDark));
        return switch (content == null
            ? null
            : Oito2ConfigParsers.cosmicBool(content)) {
          true => Brightness.dark,
          false => Brightness.light,
          null => null,
        };
      case Oito2DesktopEnvironment.xfce:
      case Oito2DesktopEnvironment.lxqt:
        return null;
      default:
        final value = await _safe(
          () => gsettings.read(_gnomeInterface, 'color-scheme'),
        );
        return switch (value) {
          'prefer-dark' => Brightness.dark,
          'prefer-light' => Brightness.light,
          _ => null,
        };
    }
  }

  /// Whether [environment] or the platform asks for reduced motion: true
  /// when any source asks for it, false when a source states no such
  /// preference, null when none is available.
  Future<bool?> _linuxReduceMotion(Oito2DesktopEnvironment environment) async {
    final answers = <bool?>[
      platformReduceMotion(),
      await _safe(reducedMotion.read),
    ];
    // A turned-off animation switch asks for reduced motion.
    Future<bool?> animationsOff(String schema, String key) async {
      final value = await _safe(() => gsettings.read(schema, key));
      return value is bool ? !value : null;
    }

    switch (environment) {
      case Oito2DesktopEnvironment.kde:
        final globals = await _safe(() => configFiles.read(_kdeglobals)) ?? '';
        final factor = double.tryParse(
          Oito2ConfigParsers.iniValue(
                globals,
                'KDE',
                'AnimationDurationFactor',
              ) ??
              '',
        );
        // A missing factor is KDE's default speed.
        answers.add(factor == 0);
      case Oito2DesktopEnvironment.cinnamon:
        answers
          ..add(await animationsOff(_cinnamonInterface, 'enable-animations'))
          ..add(await animationsOff(_cinnamon, 'desktop-effects-workspace'));
      case Oito2DesktopEnvironment.mate:
        answers
          ..add(await animationsOff(_mateInterface, 'enable-animations'))
          ..add(await animationsOff(_mateInterface, 'gtk-enable-animations'));
      case Oito2DesktopEnvironment.xfce:
      case Oito2DesktopEnvironment.lxqt:
      case Oito2DesktopEnvironment.cosmic:
        break;
      default:
        answers.add(await animationsOff(_gnomeInterface, 'enable-animations'));
        final motion = await _safe(
          () => gsettings.read(_gnomeA11y, 'reduced-motion'),
        );
        answers.add(switch (motion) {
          'reduce' => true,
          'no-preference' => false,
          _ => null,
        });
    }
    if (answers.contains(true)) return true;
    return answers.contains(false) ? false : null;
  }

  /// Reads the text scale factor of [environment], or null when the
  /// desktop has no such setting or leaves it to the automatic DPI.
  Future<double?> _linuxTextScaleFactor(
    Oito2DesktopEnvironment environment,
  ) async {
    // Converts a font DPI to a factor; 0 or less is the automatic DPI.
    double? fromDpi(num? dpi) =>
        dpi == null || dpi <= 0 ? null : dpi / _baseDpi;

    Future<double?> gnomeFactor(String schema) async {
      final value = await _safe(
        () => gsettings.read(schema, 'text-scaling-factor'),
      );
      return value is double && value > 0 ? value : null;
    }

    switch (environment) {
      case Oito2DesktopEnvironment.kde:
        // Plasma applies the forced font DPI on X11 only.
        if (this.environment['XDG_SESSION_TYPE'] == 'wayland') return 1.0;
        final fonts = await _safe(() => configFiles.read(_kcmfonts)) ?? '';
        final dpi = int.tryParse(
          Oito2ConfigParsers.iniValue(fonts, 'General', 'forceFontDPI') ?? '',
        );
        // An unforced DPI leaves text at its normal size.
        return fromDpi(dpi) ?? 1.0;
      case Oito2DesktopEnvironment.xfce:
        final xml = await _safe(() => configFiles.read(_xsettings));
        final value = xml == null
            ? null
            : Oito2ConfigParsers.xfconfProperty(xml, 'DPI');
        // Without the property Xfce uses its default of 96 DPI.
        if (value == null) return 1.0;
        return fromDpi(int.tryParse(value));
      case Oito2DesktopEnvironment.mate:
        final dpi = await _safe(() => gsettings.read(_mateFonts, 'dpi'));
        return fromDpi(dpi is num ? dpi : null);
      case Oito2DesktopEnvironment.cinnamon:
        return gnomeFactor(_cinnamonInterface);
      case Oito2DesktopEnvironment.cosmic:
      case Oito2DesktopEnvironment.lxqt:
        return null;
      default:
        return gnomeFactor(_gnomeInterface);
    }
  }

  /// Reads the cursor size of [environment], or null when it is unknown or
  /// left to the cursor theme's default.
  Future<int?> _linuxCursorSize(Oito2DesktopEnvironment environment) async {
    int? positive(int? size) => size == null || size <= 0 ? null : size;

    Future<int?> gsettingsSize(String schema) async {
      final value = await _safe(() => gsettings.read(schema, 'cursor-size'));
      return positive(value is int ? value : null);
    }

    switch (environment) {
      case Oito2DesktopEnvironment.kde:
        final input = await _safe(() => configFiles.read(_kcminputrc)) ?? '';
        final value = Oito2ConfigParsers.iniValue(input, 'Mouse', 'cursorSize');
        // A missing size is KDE's default of 24.
        return positive(value == null ? 24 : int.tryParse(value));
      case Oito2DesktopEnvironment.xfce:
        final xml = await _safe(() => configFiles.read(_xsettings)) ?? '';
        final value = Oito2ConfigParsers.xfconfProperty(xml, 'CursorThemeSize');
        return positive(value == null ? null : int.tryParse(value));
      case Oito2DesktopEnvironment.cosmic:
        final content = await _safe(() => configFiles.read(_cosmicCursorSize));
        return positive(
          content == null
              ? null
              : Oito2ConfigParsers.cosmicOptionalInt(content),
        );
      case Oito2DesktopEnvironment.lxqt:
        final session = await _safe(() => configFiles.read(_lxqtSession)) ?? '';
        final value = Oito2ConfigParsers.iniValue(
          session,
          'Mouse',
          'cursor_size',
        );
        return positive(value == null ? null : int.tryParse(value));
      case Oito2DesktopEnvironment.cinnamon:
        return gsettingsSize(_cinnamonInterface);
      case Oito2DesktopEnvironment.mate:
        return gsettingsSize(_mateMouse);
      default:
        return gsettingsSize(_gnomeInterface);
    }
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
