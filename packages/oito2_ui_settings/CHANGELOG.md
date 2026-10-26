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

### Changed

- Accepts `dbus` 0.7 and 0.8 and `gsettings` 0.2.8 and 0.2.9, so apps can also depend on plugins that still require `dbus` 0.7.
- `Oito2GSettingsSource` gains `close()`; `Oito2DconfGSettingsSource` shares one session and one system D-Bus connection between schemas and accepts existing connections.
- `Oito2SystemSettingsReader.close()` releases the system store connections. `Oito2Settings.load()` releases its reader after reading, `Oito2Settings.watch()` when the subscription is cancelled, and `Oito2SystemSettingsScope` closes the reader it creates.

### Fixed

- Configuration file watching notices files replaced through a temporary file and a rename, as KDE and Xfce save them, and a configuration directory path that ends in a slash.
- `Oito2SystemSettingsReader.watch` drops a read that a newer one overtakes and emits a failed read as an error instead of leaving it unhandled.
- `Oito2SystemSettingsScope` follows a new `reader` and keeps the last settings when a read fails.
- `Oito2SystemThemeAccentSource` no longer changes `system_theme`'s global fallback color, counts every real accent color, and reports no changes where `system_theme` doesn't stream them.
- `Oito2DconfGSettingsSource.changes` stays quiet for a schema that isn't installed, such as the GNOME schemas on another desktop, instead of raising an unhandled error.
- `Oito2DconfGSettingsSource.close` closes each bus connection the source opened itself, also when only one bus was given.
- `Oito2Settings.watch` creates its reader, and its system connections, when the stream is listened to, so an unused stream opens nothing.
