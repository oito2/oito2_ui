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

/// The 13 named color presets for oito2_ui.
///
/// Everforest, Rosé Pine, Nord, Dracula/Alucard and Catppuccin, each
/// mapped from its official palette to [Oito2ColorRoles] and derived into
/// a complete oito2 scheme:
///
/// ```dart
/// MaterialApp(
///   theme: Oito2ThemePreset.catppuccinLatte.theme(),
///   darkTheme: Oito2ThemePreset.catppuccinMocha.theme(),
/// );
/// ```
library;

import 'package:oito2_ui/oito2_ui.dart';

export 'src/palettes/dracula_palette.dart';
export 'src/palettes/everforest_palette.dart';
export 'src/palettes/nord_palette.dart';
export 'src/palettes/rose_pine_palette.dart';
export 'src/theme_preset.dart';
