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

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_window/oito2_ui_window.dart';
import 'package:window_manager/window_manager.dart';

const _channel = MethodChannel('window_manager');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<String> calls;
  late bool maximized;

  setUp(() {
    calls = [];
    maximized = false;
    messenger.setMockMethodCallHandler(_channel, (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'isMaximized' => maximized,
        'isFullScreen' => false,
        'isFocused' => true,
        _ => null,
      };
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(_channel, null));

  Future<void> sendEvent(String name) async {
    await messenger.handlePlatformMessage(
      _channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('onEvent', {'eventName': name}),
      ),
      (_) {},
    );
  }

  Future<Oito2NativeWindowController> attach({bool canShowMenu = true}) async {
    final controller = await Oito2NativeWindowController.attach(
      windowManager,
      canShowMenu: canShowMenu,
    );
    addTearDown(controller.dispose);
    return controller;
  }

  test('attach reads the initial window state', () async {
    maximized = true;
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

    maximized = true;
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
    maximized = true;
    calls.clear();
    await sendEvent('restore');
    await Future<void>.delayed(Duration.zero);
    expect(calls, contains('isMaximized'));
    expect(controller.state.value.isMaximized, isTrue);
  });

  test('a failed refresh keeps the last state', () async {
    final controller = await attach();
    messenger.setMockMethodCallHandler(_channel, (call) async {
      throw PlatformException(code: 'unavailable');
    });
    await expectLater(controller.refresh(), completes);
    expect(controller.state.value.isActive, isTrue);
  });

  test('a refresh that ends after dispose changes nothing', () async {
    final controller = await Oito2NativeWindowController.attach(
      windowManager,
      canShowMenu: true,
    );
    final gate = Completer<void>();
    messenger.setMockMethodCallHandler(_channel, (call) async {
      await gate.future;
      return false;
    });
    final refresh = controller.refresh();
    controller.dispose();
    gate.complete();
    await expectLater(refresh, completes);
  });

  test('a window event overtakes a refresh in flight', () async {
    final controller = await attach();
    final gate = Completer<void>();
    messenger.setMockMethodCallHandler(_channel, (call) async {
      await gate.future;
      return false;
    });
    final refresh = controller.refresh();
    await sendEvent('maximize');
    gate.complete();
    await refresh;
    expect(controller.state.value.isMaximized, isTrue);
  });

  test('without the window plugin, initialization returns null', () async {
    messenger.setMockMethodCallHandler(_channel, null);
    expect(await Oito2Window.ensureInitialized(), isNull);
  });

  test('dispose stops listening to window events', () async {
    final controller = await Oito2NativeWindowController.attach(
      windowManager,
      canShowMenu: true,
    );
    expect(windowManager.listeners, contains(controller));
    controller.dispose();
    expect(windowManager.listeners, isNot(contains(controller)));
  });
}
