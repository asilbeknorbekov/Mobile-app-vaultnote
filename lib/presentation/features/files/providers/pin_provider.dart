import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app.dart';

class PinState {
  final bool isUnlocked;
  final bool hasPin;

  PinState({required this.isUnlocked, required this.hasPin});
}

class PinNotifier extends StateNotifier<PinState> {
  final Ref _ref;
  static const _pinKey = 'vaultnote_pin';

  PinNotifier(this._ref) : super(PinState(isUnlocked: false, hasPin: false)) {
    _init();
  }

  void _init() {
    final prefs = _ref.read(sharedPrefsProvider);
    final savedPin = prefs.getString(_pinKey);
    state = PinState(
      isUnlocked: savedPin == null, // Unlocked by default if no PIN is set
      hasPin: savedPin != null,
    );
  }

  Future<bool> setPin(String pin) async {
    final prefs = _ref.read(sharedPrefsProvider);
    await prefs.setString(_pinKey, pin);
    state = PinState(isUnlocked: true, hasPin: true);
    return true;
  }

  bool verifyPin(String pin) {
    final prefs = _ref.read(sharedPrefsProvider);
    final savedPin = prefs.getString(_pinKey);
    if (savedPin == pin) {
      state = PinState(isUnlocked: true, hasPin: true);
      return true;
    }
    return false;
  }

  void lock() {
    if (state.hasPin) {
      state = PinState(isUnlocked: false, hasPin: true);
    }
  }
}

final pinProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier(ref);
});
