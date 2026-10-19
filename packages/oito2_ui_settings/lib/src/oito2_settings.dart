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

  /// Reads the current system settings once.
  static Future<Oito2SystemSettings> load({Oito2Platform? platform}) =>
      reader(platform: platform).read();

  /// Emits the current system settings, then every change.
  static Stream<Oito2SystemSettings> watch({Oito2Platform? platform}) =>
      reader(platform: platform).watch();
}

/// Keeps an [Oito2SystemScope] in sync with the operating system.
///
/// Shows [initialSettings] (or the platform fallback) until the first read
/// completes, then rebuilds [child] whenever the desktop environment
/// settings, the accent color or the accessibility preferences change.
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
  StreamSubscription<Oito2SystemSettings>? _subscription;

  @override
  void initState() {
    super.initState();
    _reader = widget.reader ?? Oito2Settings.reader();
    _settings =
        widget.initialSettings ??
        Oito2SystemSettings.fallback(_reader.platform);
    _subscription = _reader.watch().listen(_apply);
    WidgetsBinding.instance.addObserver(this);
  }

  void _apply(Oito2SystemSettings settings) {
    if (!mounted || settings == _settings) return;
    setState(() => _settings = settings);
  }

  @override
  void didChangeAccessibilityFeatures() {
    _reader.read().then(_apply);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Oito2SystemScope(settings: _settings, child: widget.child);
}
