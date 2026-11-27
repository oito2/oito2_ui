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

import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:dbus/dbus.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'io_sources.dart';
import 'platform_preferences.dart';
import 'settings_reader.dart';
import 'sources.dart';

/// Creates a reader backed by the real system stores of [platform].
///
/// On native Linux the GSettings and desktop portal sources share one
/// session and one system D-Bus connection, which the reader closes in
/// [Oito2SystemSettingsReader.close].
Oito2SystemSettingsReader createReader(Oito2Platform platform) {
  final environment = Platform.environment;
  final isLinux = platform.isLinux && platform.isDesktopNative;
  final session = isLinux ? DBusClient.session() : null;
  final system = isLinux ? DBusClient.system() : null;
  return Oito2SystemSettingsReader(
    platform: platform,
    environment: environment,
    gsettings: isLinux
        ? Oito2DconfGSettingsSource(sessionBus: session, systemBus: system)
        : const Oito2EmptySource(),
    configFiles: isLinux
        ? Oito2HomeConfigFileSource.fromEnvironment(environment)
        : const Oito2EmptySource(),
    accent: Oito2SystemThemeAccentSource(),
    portalAccent: isLinux
        ? Oito2PortalAccentSource(sessionBus: session)
        : const Oito2EmptySource(),
    colorScheme: isLinux
        ? Oito2PortalColorSchemeSource(sessionBus: session)
        : const Oito2EmptySource(),
    reducedMotion: isLinux
        ? Oito2PortalReducedMotionSource(sessionBus: session)
        : const Oito2EmptySource(),
    platformHighContrast: () =>
        PlatformDispatcher.instance.accessibilityFeatures.highContrast,
    platformBrightness: () => PlatformDispatcher.instance.platformBrightness,
    platformReduceMotion: () => platformReduceMotion(platform),
    platformTextScaleFactor: platformTextScaleFactor,
    onClose: isLinux
        ? () async {
            await session?.close();
            await system?.close();
          }
        : null,
  );
}
