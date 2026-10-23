# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Oito2ThemePreset` with 13 named presets: Everforest Light and Dark, Rosé Pine, Rosé Pine Moon and Rosé Pine Dawn, Nord Dark and Nord Light (an unofficial derivation), Dracula and Alucard, and Catppuccin Latte, Frappé, Macchiato and Mocha. Each preset exposes its `roles`, its complete `colors` (`Oito2ColorTheme`) and a Material `theme`.
- The official palettes of Nord, Dracula/Alucard, Everforest and Rosé Pine (`Oito2NordPalette`, `Oito2DraculaPalette`, `Oito2EverforestPalette`, `Oito2RosePinePalette`); Catppuccin is read from `catppuccin_flutter`.
- Syntax highlighting colors for every preset, following each theme's VS Code and Neovim ports.
- `Oito2ThemePreset.label`, a display name such as "Catppuccin Mocha", and `theme(highContrast:)`.

### Changed

- Preset role colors take their brightness from the preset and are built once.
