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

/// Code editor for `oito2_ui`.
///
/// `Oito2CodeEditor` is an editable code field built on `re_editor`,
/// highlighted with the `Oito2SyntaxPalette` of the active oito2 scheme
/// through `oito2_ui_syntax`.
///
/// Besides the editor, this library exports `re_editor`'s
/// `CodeLineEditingController` and its value types, and `Oito2Highlighter`
/// of `oito2_ui_syntax`, the type of `Oito2CodeEditor.highlighter`. The
/// rest of `oito2_ui_syntax`, such as `Oito2CodeBlock`, the default
/// languages and `Oito2GitignoreMatcher`, is imported from that package.
library;

export 'package:oito2_ui_syntax/oito2_ui_syntax.dart' show Oito2Highlighter;
export 'package:re_editor/re_editor.dart'
    show
        CodeLine,
        CodeLineEditingController,
        CodeLineEditingValue,
        CodeLineOptions,
        CodeLinePosition,
        CodeLineSelection,
        CodeLines;

export 'src/code_editor.dart';
