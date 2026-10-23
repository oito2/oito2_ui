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

/// A window controller that records every call and lets tests drive its
/// state.
class FakeWindowController implements Oito2WindowController {
  /// Creates a fake controller starting in [initial].
  FakeWindowController([Oito2WindowState initial = const Oito2WindowState()])
    : _state = ValueNotifier(initial);

  final ValueNotifier<Oito2WindowState> _state;

  /// The names of the called actions, in order.
  final List<String> calls = [];

  @override
  ValueListenable<Oito2WindowState> get state => _state;

  /// Replaces the current state.
  set value(Oito2WindowState value) => _state.value = value;

  @override
  Future<void> minimize() async => calls.add('minimize');

  @override
  Future<void> toggleMaximize() async {
    calls.add('toggleMaximize');
    _state.value = _state.value.copyWith(
      isMaximized: !_state.value.isMaximized,
    );
  }

  @override
  Future<void> close() async => calls.add('close');

  @override
  Future<void> startDrag() async => calls.add('startDrag');

  @override
  Future<void> showMenu() async => calls.add('showMenu');
}
