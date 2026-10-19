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

import 'dart:ui' show PlatformDispatcher;

import 'package:oito2_ui/oito2_ui.dart';

import 'settings_reader.dart';

/// Creates a reader for platforms without `dart:io`, such as the web: no
/// desktop stores, only the platform high-contrast preference.
Oito2SystemSettingsReader createReader(Oito2Platform platform) {
  return Oito2SystemSettingsReader(
    platform: platform,
    platformHighContrast: () =>
        PlatformDispatcher.instance.accessibilityFeatures.highContrast,
  );
}
