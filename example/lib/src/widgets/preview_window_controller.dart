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

import 'package:flutter/foundation.dart';
import 'package:oito2_ui/oito2_ui.dart';

/// A window controller for the title and header bar previews: it toggles the
/// maximized state and ignores the other actions, so the previews never
/// affect the real window.
class PreviewWindowController implements Oito2WindowController {
  final ValueNotifier<Oito2WindowState> _state = ValueNotifier(
    const Oito2WindowState(),
  );

  @override
  ValueListenable<Oito2WindowState> get state => _state;

  /// Sets whether the previewed window is active.
  set isActive(bool value) =>
      _state.value = _state.value.copyWith(isActive: value);

  @override
  Future<void> toggleMaximize() async => _state.value = _state.value.copyWith(
    isMaximized: !_state.value.isMaximized,
  );

  @override
  Future<void> minimize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> startDrag() async {}

  @override
  Future<void> showMenu() async {}

  /// Releases the state notifier.
  void dispose() => _state.dispose();
}
