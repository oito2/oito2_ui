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

// The window_manager 0.5.x API lives on, deprecated, in its legacy library.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_window/oito2_ui_window.dart';
import 'package:window_manager/legacy.dart';

/// A [WindowManager] that records the calls it gets and lets the tests
/// send window events to its listeners.
class _FakeWindowManager implements WindowManager {
  final List<String> calls = [];
  final List<bool> preventClose = [];
  bool maximized = false;

  /// Answers the state queries in place of the defaults when set.
  Future<bool> Function(String method)? query;

  final List<WindowListener> _listeners = [];

  Future<bool> _query(String method, bool value) async {
    calls.add(method);
    final query = this.query;
    if (query != null) return query(method);
    return value;
  }

  Future<void> _call(String method) async => calls.add(method);

  /// Sends the window event [name] to the listeners.
  void emit(String name) {
    for (final listener in List.of(_listeners)) {
      switch (name) {
        case 'maximize':
          listener.onWindowMaximize();
        case 'unmaximize':
          listener.onWindowUnmaximize();
        case 'focus':
          listener.onWindowFocus();
        case 'blur':
          listener.onWindowBlur();
        case 'enter-full-screen':
          listener.onWindowEnterFullScreen();
        case 'leave-full-screen':
          listener.onWindowLeaveFullScreen();
        case 'restore':
          listener.onWindowRestore();
        case 'close':
          listener.onWindowClose();
      }
    }
  }

  @override
  List<WindowListener> get listeners => List.of(_listeners);

  @override
  void addListener(WindowListener listener) => _listeners.add(listener);

  @override
  void removeListener(WindowListener listener) => _listeners.remove(listener);

  @override
  Future<bool> isMaximized() => _query('isMaximized', maximized);

  @override
  Future<bool> isFullScreen() => _query('isFullScreen', false);

  @override
  Future<bool> isFocused() => _query('isFocused', true);

  @override
  Future<void> minimize() => _call('minimize');

  @override
  Future<void> maximize({bool vertically = false}) => _call('maximize');

  @override
  Future<void> unmaximize() => _call('unmaximize');

  @override
  Future<void> close() => _call('close');

  @override
  Future<void> destroy() => _call('destroy');

  @override
  Future<void> startDragging() => _call('startDragging');

  @override
  Future<void> popUpWindowMenu() => _call('popUpWindowMenu');

  @override
  Future<void> setPreventClose(bool isPreventClose) async {
    calls.add('setPreventClose');
    preventClose.add(isPreventClose);
  }

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeWindowManager manager;
  late List<String> calls;
  late List<bool> preventClose;

  setUp(() {
    manager = _FakeWindowManager();
    calls = manager.calls;
    preventClose = manager.preventClose;
  });

  Future<void> sendEvent(String name) async => manager.emit(name);

  Future<Oito2NativeWindowController> attach({bool canShowMenu = true}) async {
    final controller = await Oito2NativeWindowController.attach(
      manager,
      canShowMenu: canShowMenu,
    );
    addTearDown(controller.dispose);
    return controller;
  }

  test('attach reads the initial window state', () async {
    manager.maximized = true;
    final controller = await attach();
    expect(
      controller.state.value,
      const Oito2WindowState(isMaximized: true, canShowMenu: true),
    );
    expect(calls, containsAll(['isMaximized', 'isFullScreen', 'isFocused']));
  });

  test('actions call window_manager', () async {
    final controller = await attach();
    calls.clear();
    await controller.minimize();
    await controller.close();
    await controller.startDrag();
    await controller.showMenu();
    expect(calls, ['minimize', 'close', 'startDragging', 'popUpWindowMenu']);
  });

  test('toggleMaximize maximizes or restores', () async {
    final controller = await attach();
    calls.clear();
    await controller.toggleMaximize();
    expect(calls, ['isMaximized', 'maximize']);

    manager.maximized = true;
    calls.clear();
    await controller.toggleMaximize();
    expect(calls, ['isMaximized', 'unmaximize']);
  });

  test('showMenu does nothing when the platform has no window menu', () async {
    final controller = await attach(canShowMenu: false);
    calls.clear();
    await controller.showMenu();
    expect(calls, isEmpty);
  });

  test('window events update the state', () async {
    final controller = await attach();

    await sendEvent('maximize');
    expect(controller.state.value.isMaximized, isTrue);
    await sendEvent('unmaximize');
    expect(controller.state.value.isMaximized, isFalse);

    await sendEvent('blur');
    expect(controller.state.value.isActive, isFalse);
    await sendEvent('focus');
    expect(controller.state.value.isActive, isTrue);

    await sendEvent('enter-full-screen');
    expect(controller.state.value.isFullScreen, isTrue);
    await sendEvent('leave-full-screen');
    expect(controller.state.value.isFullScreen, isFalse);
  });

  test('restore re-reads the window state', () async {
    final controller = await attach();
    manager.maximized = true;
    calls.clear();
    await sendEvent('restore');
    await Future<void>.delayed(Duration.zero);
    expect(calls, contains('isMaximized'));
    expect(controller.state.value.isMaximized, isTrue);
  });

  test('a failed refresh keeps the last state', () async {
    final controller = await attach();
    manager.query = (method) async {
      throw PlatformException(code: 'unavailable');
    };
    await expectLater(controller.refresh(), completes);
    expect(controller.state.value.isActive, isTrue);
  });

  test('a refresh that ends after dispose changes nothing', () async {
    final controller = await Oito2NativeWindowController.attach(
      manager,
      canShowMenu: true,
    );
    final gate = Completer<void>();
    manager.query = (method) async {
      await gate.future;
      return false;
    };
    final refresh = controller.refresh();
    controller.dispose();
    gate.complete();
    await expectLater(refresh, completes);
  });

  test('a window event overtakes a refresh in flight', () async {
    final controller = await attach();
    final gate = Completer<void>();
    manager.query = (method) async {
      await gate.future;
      return false;
    };
    final refresh = controller.refresh();
    await sendEvent('maximize');
    gate.complete();
    await refresh;
    expect(controller.state.value.isMaximized, isTrue);
  });

  test('without a native window, initialization returns null', () async {
    expect(await Oito2Window.ensureInitialized(), isNull);
  });

  test('close handlers hold back the native close while added', () async {
    final controller = await attach();
    Future<bool> allow() async => true;
    Future<bool> refuse() async => false;
    calls.clear();
    controller
      ..addCloseHandler(allow)
      ..addCloseHandler(refuse);
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['setPreventClose']);
    controller
      ..removeCloseHandler(refuse)
      ..removeCloseHandler(allow);
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['setPreventClose', 'setPreventClose']);
  });

  test('a close request asks the handlers before destroying', () async {
    final controller = await attach();
    final asked = <String>[];
    var allowFirst = false;
    controller
      ..addCloseHandler(() async {
        asked.add('first');
        return allowFirst;
      })
      ..addCloseHandler(() async {
        asked.add('second');
        return true;
      });
    await Future<void>.delayed(Duration.zero);
    calls.clear();

    await sendEvent('close');
    await Future<void>.delayed(Duration.zero);
    expect(asked, ['second', 'first']);
    expect(calls, isNot(contains('destroy')));

    allowFirst = true;
    asked.clear();
    await sendEvent('close');
    await Future<void>.delayed(Duration.zero);
    expect(asked, ['second', 'first']);
    expect(calls, contains('destroy'));
  });

  test('a close request without handlers leaves the window alone', () async {
    await attach();
    calls.clear();
    await sendEvent('close');
    await Future<void>.delayed(Duration.zero);
    expect(calls, isEmpty);
  });

  test('a close request while the handlers are asked is ignored', () async {
    final controller = await attach();
    final gate = Completer<bool>();
    var asked = 0;
    controller.addCloseHandler(() {
      asked++;
      return gate.future;
    });
    await sendEvent('close');
    await sendEvent('close');
    gate.complete(true);
    await Future<void>.delayed(Duration.zero);
    expect(asked, 1);
    expect(calls.where((call) => call == 'destroy'), hasLength(1));
  });

  test('a close handler that throws keeps the window open and reports '
      'the error', () async {
    final controller = await attach();
    final reported = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previous);
    var asked = 0;
    var fail = true;
    controller
      ..addCloseHandler(() async {
        asked++;
        return true;
      })
      ..addCloseHandler(() async {
        if (fail) throw StateError('broken handler');
        return true;
      });
    await Future<void>.delayed(Duration.zero);
    calls.clear();

    await sendEvent('close');
    await Future<void>.delayed(Duration.zero);
    expect(reported.single.exception, isA<StateError>());
    expect(reported.single.library, 'oito2_ui_window');
    expect(asked, 0);
    expect(calls, isNot(contains('destroy')));

    // The next close request asks the handlers again.
    fail = false;
    await sendEvent('close');
    await Future<void>.delayed(Duration.zero);
    expect(asked, 1);
    expect(calls, contains('destroy'));
  });

  test('dispose lets the native close through again', () async {
    final controller = await attach();
    controller.addCloseHandler(() async => false);
    await Future<void>.delayed(Duration.zero);
    expect(preventClose, [true]);
    controller.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(preventClose, [true, false]);
    calls.clear();
    await sendEvent('close');
    await Future<void>.delayed(Duration.zero);
    expect(calls, isEmpty);
  });

  test('dispose stops listening to window events', () async {
    final controller = await Oito2NativeWindowController.attach(
      manager,
      canShowMenu: true,
    );
    expect(manager.listeners, contains(controller));
    controller.dispose();
    expect(manager.listeners, isNot(contains(controller)));
  });
}
