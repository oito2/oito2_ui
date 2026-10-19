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
