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

import 'package:flutter/widgets.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'platform_stub.dart' if (dart.library.io) 'platform_io.dart';
import 'settings_reader.dart';

/// Entry point for reading the operating system preferences.
abstract final class Oito2Settings {
  /// Creates the reader for [platform] (default [Oito2Platform.current])
  /// backed by the real system stores.
  static Oito2SystemSettingsReader reader({Oito2Platform? platform}) =>
      createReader(platform ?? Oito2Platform.current());

  /// Reads the current system settings of [platform] once, then releases
  /// the reader.
  static Future<Oito2SystemSettings> load({Oito2Platform? platform}) async {
    final settingsReader = reader(platform: platform);
    try {
      return await settingsReader.read();
    } finally {
      await settingsReader.close();
    }
  }

  /// Emits the current system settings of [platform], then every change.
  ///
  /// The reader, with its system connections, is created when the stream
  /// is listened to and released when the subscription is cancelled, so a
  /// stream that is never listened to opens nothing.
  static Stream<Oito2SystemSettings> watch({Oito2Platform? platform}) {
    Oito2SystemSettingsReader? settingsReader;
    late final StreamController<Oito2SystemSettings> controller;
    StreamSubscription<Oito2SystemSettings>? subscription;
    controller = StreamController(
      onListen: () {
        final created = settingsReader = reader(platform: platform);
        subscription = created.watch().listen(
          controller.add,
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await subscription?.cancel();
        await settingsReader?.close();
      },
    );
    return controller.stream;
  }
}

/// Keeps an [Oito2SystemScope] in sync with the operating system.
///
/// Shows [initialSettings] (or the platform fallback) until the first read
/// completes, then rebuilds [child] whenever the desktop environment
/// settings, the accent color, the platform brightness, the text scale or
/// the accessibility preferences change.
///
/// It also applies two preferences to the [MediaQuery] of [child]:
///
/// - When [Oito2SystemSettings.reduceMotion] is true,
///   [MediaQueryData.disableAnimations] becomes true. It is never turned
///   off, so a platform that already disables animations keeps them off.
/// - On native Linux desktops whose text scale Flutter doesn't read (KDE
///   Plasma, Xfce, Cinnamon, MATE, COSMIC and LXQt), a known
///   [Oito2SystemSettings.textScaleFactor] replaces the text scaler
///   Flutter derives from GNOME's `text-scaling-factor`. The factor
///   replaces that scaler instead of multiplying it, so text is scaled
///   once. On the GNOME family (GNOME, Budgie, Pantheon, Unity and unknown
///   desktops) and on other platforms, Flutter already applies the
///   system text scale and the scaler is left as is. A scaler that an
///   ancestor [MediaQuery] changed is also left as is.
///
/// The cursor size is only exposed: the cursor theme and its size are
/// applied by the toolkit and the compositor.
class Oito2SystemSettingsScope extends StatefulWidget {
  /// Creates a scope that watches the system settings for [child].
  const Oito2SystemSettingsScope({
    super.key,
    this.initialSettings,
    this.reader,
    required this.child,
  });

  /// The settings shown before the first read, typically the result of
  /// [Oito2Settings.load] awaited in `main`.
  final Oito2SystemSettings? initialSettings;

  /// The reader to watch; defaults to [Oito2Settings.reader].
  final Oito2SystemSettingsReader? reader;

  /// The widget below the scope.
  final Widget child;

  @override
  State<Oito2SystemSettingsScope> createState() =>
      _Oito2SystemSettingsScopeState();
}

class _Oito2SystemSettingsScopeState extends State<Oito2SystemSettingsScope>
    with WidgetsBindingObserver {
  late Oito2SystemSettingsReader _reader;
  late Oito2SystemSettings _settings;

  /// Whether [_reader] was created here, so this state closes it.
  bool _ownsReader = false;
  StreamSubscription<Oito2SystemSettings>? _subscription;

  @override
  void initState() {
    super.initState();
    _ownsReader = widget.reader == null;
    _reader = widget.reader ?? Oito2Settings.reader();
    _settings =
        widget.initialSettings ??
        Oito2SystemSettings.fallback(_reader.platform);
    _listen();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Follows [_reader]; a failed read keeps the last settings shown.
  void _listen() {
    _subscription = _reader.watch().listen(_apply, onError: (Object _) {});
  }

  @override
  void didUpdateWidget(Oito2SystemSettingsScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reader == widget.reader) return;
    _subscription?.cancel();
    if (_ownsReader) _reader.close();
    _ownsReader = widget.reader == null;
    _reader = widget.reader ?? Oito2Settings.reader();
    _listen();
  }

  /// Shows [settings] when they differ from the ones shown.
  void _apply(Oito2SystemSettings settings) {
    if (!mounted || settings == _settings) return;
    setState(() => _settings = settings);
  }

  @override
  void didChangeAccessibilityFeatures() => _reread();

  @override
  void didChangePlatformBrightness() => _reread();

  @override
  void didChangeTextScaleFactor() => _reread();

  /// Reads the settings again after a platform-level change.
  void _reread() {
    _reader.read().then(_apply, onError: (Object _) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    if (_ownsReader) _reader.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    var child = widget.child;
    final media = MediaQuery.maybeOf(context);
    // The MediaQuery is always inserted, so a changed preference keeps the
    // state of the subtree.
    if (media != null) {
      child = MediaQuery(
        data: media.copyWith(
          disableAnimations:
              media.disableAnimations || settings.reduceMotion == true,
          textScaler: _textScaler(media, settings),
        ),
        child: child,
      );
    }
    return Oito2SystemScope(settings: settings, child: child);
  }

  /// Returns the text scaler for the subtree: [media]'s scaler, replaced by
  /// the factor of [settings] where Flutter doesn't read the desktop's text
  /// scale and no ancestor changed the scaler Flutter derives.
  static TextScaler _textScaler(
    MediaQueryData media,
    Oito2SystemSettings settings,
  ) {
    final factor = settings.textScaleFactor;
    final environment = settings.desktopEnvironment;
    if (factor == null ||
        environment == null ||
        _embedderReadsTextScale(environment)) {
      return media.textScaler;
    }
    // Flutter derives a SystemTextScaler from the platform; any other
    // scaler was set by an ancestor.
    return media.textScaler is SystemTextScaler
        ? TextScaler.linear(factor)
        : media.textScaler;
  }

  /// Whether the Linux embedder reads the text scale of [environment]:
  /// it reads GNOME's `org.gnome.desktop.interface text-scaling-factor`,
  /// the key the GNOME family uses.
  static bool _embedderReadsTextScale(Oito2DesktopEnvironment environment) {
    return switch (environment) {
      Oito2DesktopEnvironment.kde ||
      Oito2DesktopEnvironment.xfce ||
      Oito2DesktopEnvironment.cinnamon ||
      Oito2DesktopEnvironment.mate ||
      Oito2DesktopEnvironment.cosmic ||
      Oito2DesktopEnvironment.lxqt => false,
      _ => true,
    };
  }
}
