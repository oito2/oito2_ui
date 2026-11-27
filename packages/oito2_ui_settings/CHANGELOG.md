# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- `Oito2Settings.load`, `Oito2Settings.watch` and `Oito2Settings.reader`: read the operating system preferences into `Oito2SystemSettings`.
- `Oito2SystemSettingsScope`: keeps an `Oito2SystemScope` in sync with the system, including accessibility changes.
- Linux desktop support: window button layout for GNOME, Budgie, Pantheon, Unity, Cinnamon, MATE (GSettings), KDE Plasma (`kwinrc`), Xfce (`xfwm4.xml`) and COSMIC; accent from GNOME 47+ `accent-color`, KDE `AccentColor` or the GTK theme; high contrast from GNOME a11y settings, a `HighContrast` GTK theme or a KDE contrast color scheme.
- System accent on Windows, macOS and Android through `system_theme`; platform high-contrast preference everywhere.
- `Oito2SystemSettingsReader`, the source interfaces and `Oito2ConfigParsers` for custom sources and testing.
- Color scheme preference: `Oito2PortalColorSchemeSource` reads `org.freedesktop.appearance color-scheme` from the XDG desktop portal on Linux, falling back to GNOME `color-scheme`, a dark KDE color scheme or look-and-feel package, or the COSMIC theme mode; other platforms report the platform brightness. `Oito2SystemSettingsScope` reads again when the platform brightness changes.
- Reduced motion, text scale and cursor size, followed live: `Oito2PortalReducedMotionSource` reads `org.freedesktop.appearance reduced-motion` from the XDG desktop portal (GNOME 50+, KDE Plasma 6.6+); the desktop stores add GNOME `enable-animations` and a11y `reduced-motion`, Cinnamon `enable-animations` and `desktop-effects-workspace`, MATE `enable-animations` and `gtk-enable-animations`, and KDE `AnimationDurationFactor=0`. The text scale comes from `text-scaling-factor` (GNOME family, Cinnamon) or the font DPI (MATE `font-rendering dpi`, KDE `forceFontDPI` on X11, Xfce `Xft/DPI`); the cursor size from `cursor-size` (GNOME family, Cinnamon, MATE), KDE `kcminputrc`, Xfce `Gtk/CursorThemeSize`, COSMIC `cursor_size` and LXQt `session.conf`. Other platforms report Flutter's `disableAnimations`/`reduceMotion` and `textScaleFactor`.
- `Oito2SystemSettingsScope` turns `MediaQuery.disableAnimations` on when the system asks for reduced motion, and on KDE Plasma, Xfce, Cinnamon, MATE, COSMIC and LXQt replaces the text scaler Flutter derives from GNOME's `text-scaling-factor` with the desktop's own factor (replaced, never multiplied); on the GNOME family and other platforms Flutter's text scale is kept. It reads again when the platform text scale changes.
- `Oito2ConfigParsers.cosmicOptionalInt` for COSMIC `Some(n)` values.
- Portal accent: `Oito2PortalAccentSource` reads `org.freedesktop.appearance accent-color` from the XDG desktop portal (GNOME, KDE, COSMIC and XApp portals) and follows its changes; on Linux it comes before the desktop stores, so COSMIC reports its accent.
- `Oito2SystemSettingsReader.onClose`, called by `close` after the sources, and `Oito2SystemSettingsReader.portalTimeout` (1 second).

### Changed

- Accepts `dbus` 0.7 and 0.8 and `gsettings` 0.2.8 and 0.2.9, so apps can also depend on plugins that still require `dbus` 0.7.
- `Oito2SystemSettingsReader` takes a `colorScheme` source and a `platformBrightness` callback; `Oito2EmptySource` also implements the new `Oito2ColorSchemeSource`.
- `Oito2SystemSettingsReader` takes a `reducedMotion` source and `platformReduceMotion` and `platformTextScaleFactor` callbacks; `Oito2EmptySource` also implements the new `Oito2ReducedMotionSource`.
- `Oito2SystemSettingsReader` takes a `portalAccent` source; `Oito2AccentSource` gains `close()`, which `Oito2SystemSettingsReader.close()` calls.
- The GNOME `accent-color` key is read on GNOME only: other desktops (Budgie, Cinnamon, MATE, Pantheon, Unity, Xfce, ...) use the GTK theme accent.
- `Oito2GSettingsSource` gains `close()`; `Oito2DconfGSettingsSource` shares one session and one system D-Bus connection between schemas and accepts existing connections.
- `Oito2SystemSettingsReader.close()` releases the system store connections. `Oito2Settings.load()` releases its reader after reading, `Oito2Settings.watch()` when the subscription is cancelled, and `Oito2SystemSettingsScope` closes the reader it creates.
- On Linux, `Oito2SystemSettingsReader.read` reads the independent settings at the same time and each configuration file once (`kdeglobals` was read up to four times), and a desktop portal setting that doesn't answer within `portalTimeout` counts as missing, so a slow `xdg-desktop-portal` no longer holds back `Oito2Settings.load`; `watch` reads again when the portal reports a change.
- The reader of `Oito2Settings` shares one session and one system D-Bus connection between its GSettings and portal sources, instead of opening up to five, and closes them in `close`.

### Fixed

- `Oito2HomeConfigFileSource.read` and `changes` refuse a path that leaves the configuration directory, such as an absolute path or one that climbs out with `..`: `read` returns null and `changes` never emits.
- Configuration file watching notices files replaced through a temporary file and a rename, as KDE and Xfce save them, and a configuration directory path that ends in a slash.
- `Oito2SystemSettingsReader.watch` drops a read that a newer one overtakes and emits a failed read as an error instead of leaving it unhandled.
- `Oito2SystemSettingsScope` follows a new `reader` and keeps the last settings when a read fails.
- `Oito2SystemThemeAccentSource` no longer changes `system_theme`'s global fallback color, counts every real accent color, and reports no changes where `system_theme` doesn't stream them.
- `Oito2DconfGSettingsSource.changes` stays quiet for a schema that isn't installed, such as the GNOME schemas on another desktop, instead of raising an unhandled error.
- `Oito2DconfGSettingsSource.close` closes each bus connection the source opened itself, also when only one bus was given.
- On MATE and Ubuntu MATE, the accent no longer stays at the GNOME schema's default blue when that schema is installed but unused.
- Cinnamon and MATE read the accent again when their interface settings change, such as a new GTK theme.
- Configuration file watching notices a file whose folder doesn't exist yet when the app starts, such as the COSMIC window button settings on a fresh account.
- `Oito2Settings.watch` creates its reader, and its system connections, when the stream is listened to, so an unused stream opens nothing.
- Configuration file watching follows symbolic links: when a watched file, such as `kdeglobals` or `xsettings.xml`, is a link managed by a dotfiles tool, changes to the file it points to are noticed too.
