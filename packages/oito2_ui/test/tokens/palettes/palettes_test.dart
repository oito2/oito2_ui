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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

void main() {
  test('Nord keeps its official values', () {
    expect(Oito2NordPalette.nord0, const Color(0xFF2E3440));
    expect(Oito2NordPalette.nord6, const Color(0xFFECEFF4));
    expect(Oito2NordPalette.nord8, const Color(0xFF88C0D0));
    expect(Oito2NordPalette.nord10, const Color(0xFF5E81AC));
    expect(Oito2NordPalette.nord11, const Color(0xFFBF616A));
    expect(Oito2NordPalette.nord15, const Color(0xFFB48EAD));
  });

  test('Dracula and Alucard keep their official values', () {
    expect(Oito2DraculaPalette.dracula.background, const Color(0xFF282A36));
    expect(Oito2DraculaPalette.dracula.purple, const Color(0xFFBD93F9));
    expect(Oito2DraculaPalette.dracula.red, const Color(0xFFFF5555));
    expect(Oito2DraculaPalette.alucard.background, const Color(0xFFFFFBEB));
    expect(Oito2DraculaPalette.alucard.purple, const Color(0xFF644AC9));
    expect(Oito2DraculaPalette.alucard.foreground, const Color(0xFF1F1F1F));
  });

  test('Everforest keeps its official values', () {
    expect(Oito2EverforestPalette.dark.bgDim, const Color(0xFF232A2E));
    expect(Oito2EverforestPalette.dark.green, const Color(0xFFA7C080));
    expect(Oito2EverforestPalette.light.bg0, const Color(0xFFFDF6E3));
    expect(Oito2EverforestPalette.light.green, const Color(0xFF8DA101));
  });

  test('Everforest Light uses bgDim as its bg2 tone', () {
    expect(
      Oito2EverforestPalette.light.bg2,
      Oito2EverforestPalette.light.bgDim,
    );
  });

  test('Rosé Pine keeps its official values', () {
    expect(Oito2RosePinePalette.main.base, const Color(0xFF191724));
    expect(Oito2RosePinePalette.main.pine, const Color(0xFF31748F));
    expect(Oito2RosePinePalette.moon.pine, const Color(0xFF3E8FB0));
    expect(Oito2RosePinePalette.moon.rose, const Color(0xFFEA9A97));
    expect(Oito2RosePinePalette.dawn.base, const Color(0xFFFAF4ED));
    expect(Oito2RosePinePalette.dawn.pine, const Color(0xFF286983));
  });
}
