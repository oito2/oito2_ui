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

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Describes the platform an app runs on and the ergonomics that follow
/// from it.
///
/// [Oito2Platform.current] reads the running platform. The default
/// constructor accepts explicit values so tests and previews can simulate
/// any platform.
@immutable
class Oito2Platform {
  /// Creates a platform description from explicit values.
  const Oito2Platform({required this.targetPlatform, required this.isWeb});

  /// Creates a platform description for the running app.
  ///
  /// Reads [kIsWeb] and [defaultTargetPlatform], so it honors
  /// `debugDefaultTargetPlatformOverride`. On the web, [targetPlatform] is
  /// the operating system of the browser host.
  factory Oito2Platform.current() {
    return Oito2Platform(targetPlatform: defaultTargetPlatform, isWeb: kIsWeb);
  }

  /// The operating system, or the browser host operating system on the web.
  final TargetPlatform targetPlatform;

  /// Whether the app runs inside a web browser.
  final bool isWeb;

  /// Whether the app runs as a native desktop app (Linux, Windows or
  /// macOS), outside a browser.
  bool get isDesktopNative => !isWeb && _isDesktopOs;

  /// Whether the app runs as a native app on a touch-first operating system
  /// (Android, iOS or Fuchsia), outside a browser.
  bool get isTouch => !isWeb && !_isDesktopOs;

  /// Whether the app runs in a browser on a touch-first operating system.
  bool get isWebTouch => isWeb && !_isDesktopOs;

  /// Whether the primary input is touch, natively or in a browser.
  bool get usesTouchInput => isTouch || isWebTouch;

  /// Whether the operating system is Linux.
  bool get isLinux => targetPlatform == TargetPlatform.linux;

  /// Whether the operating system is Windows.
  bool get isWindows => targetPlatform == TargetPlatform.windows;

  /// Whether the operating system is macOS.
  bool get isMacOS => targetPlatform == TargetPlatform.macOS;

  /// Whether the operating system is Android.
  bool get isAndroid => targetPlatform == TargetPlatform.android;

  /// Whether the operating system is iOS.
  bool get isIOS => targetPlatform == TargetPlatform.iOS;

  /// The visual density for this platform: [VisualDensity.standard] for
  /// touch input and [VisualDensity.comfortable] for pointer input.
  VisualDensity get visualDensity =>
      usesTouchInput ? VisualDensity.standard : VisualDensity.comfortable;

  bool get _isDesktopOs => switch (targetPlatform) {
    TargetPlatform.linux ||
    TargetPlatform.windows ||
    TargetPlatform.macOS => true,
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => false,
  };

  /// Returns a copy with the given fields replaced.
  Oito2Platform copyWith({TargetPlatform? targetPlatform, bool? isWeb}) {
    return Oito2Platform(
      targetPlatform: targetPlatform ?? this.targetPlatform,
      isWeb: isWeb ?? this.isWeb,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2Platform &&
      other.targetPlatform == targetPlatform &&
      other.isWeb == isWeb;

  @override
  int get hashCode => Object.hash(targetPlatform, isWeb);

  @override
  String toString() =>
      'Oito2Platform(targetPlatform: ${targetPlatform.name}, isWeb: $isWeb)';
}
