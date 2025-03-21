import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class GlobalHotkeyManager {
  static final GlobalHotkeyManager _instance = GlobalHotkeyManager._internal();

  factory GlobalHotkeyManager() {
    return _instance;
  }

  GlobalHotkeyManager._internal();

  Future<void> registerHotkeys(VoidCallback onHotKeyPressed) async {
    HotKey hotKey = HotKey(
      key: PhysicalKeyboardKey.keyQ,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.system,
    );   
    
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        onHotKeyPressed();
      },
    );
  }

Future<void> registerbsi(VoidCallback onHotKeyPressed) async {
    HotKey hotKeyBSI = HotKey(
      key: PhysicalKeyboardKey.keyB,
      modifiers: [HotKeyModifier.alt],
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      hotKeyBSI, 
      keyDownHandler: (hotKeyBSI) {
        onHotKeyPressed();
      },
    );
  }

  Future<void> unregisterAllHotkeys() async {
    await hotKeyManager.unregisterAll();
  }
}