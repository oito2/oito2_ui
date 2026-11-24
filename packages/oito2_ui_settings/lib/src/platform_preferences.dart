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

import 'dart:ui' show PlatformDispatcher;

import 'package:oito2_ui/oito2_ui.dart';

/// Returns whether the platform accessibility settings of [platform] ask
/// for reduced motion.
///
/// Returns true when Flutter reports disabled animations or reduced
/// motion. Otherwise returns false on platforms whose embedder reports the
/// preference (mobile and web) and null on native desktops, whose
/// embedders report it only on Linux and only from the GNOME settings.
bool? platformReduceMotion(Oito2Platform platform) {
  final features = PlatformDispatcher.instance.accessibilityFeatures;
  if (features.disableAnimations || features.reduceMotion) return true;
  return platform.isDesktopNative ? null : false;
}

/// Returns the text scale factor Flutter reports for the platform.
double platformTextScaleFactor() => PlatformDispatcher.instance.textScaleFactor;
