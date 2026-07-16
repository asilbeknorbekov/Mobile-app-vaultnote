import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/security_provider.dart';

class PinState {
  final bool isUnlocked;
  final bool hasPin;

  PinState({required this.isUnlocked, required this.hasPin});
}

class PinNotifier extends StateNotifier<PinState> {
  final Ref _ref;

  PinNotifier(this._ref) : super(PinState(isUnlocked: false, hasPin: false)) {
    _init();
  }

  Future<void> _init() async {
    final security = _ref.read(securityServiceProvider);
    final hasPin = await security.isPinSet();
    
    if (mounted) {
      state = PinState(
        isUnlocked: !hasPin, // Unlocked by default if no PIN is set
        hasPin: hasPin,
      );
    }
  }

  Future<bool> setPin(String pin) async {
    final security = _ref.read(securityServiceProvider);
    await security.setPin(pin);
    if (mounted) {
      state = PinState(isUnlocked: true, hasPin: true);
    }
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    final security = _ref.read(securityServiceProvider);
    final success = await security.verifyPin(pin);
    if (success && mounted) {
      state = PinState(isUnlocked: true, hasPin: true);
    }
    return success;
  }

  Future<bool> authenticateWithBiometrics() async {
    final security = _ref.read(securityServiceProvider);
    final success = await security.authenticateWithBiometrics();
    if (success && mounted) {
      state = PinState(isUnlocked: true, hasPin: true);
    }
    return success;
  }

  void lock() {
    if (state.hasPin) {
      _ref.read(securityServiceProvider).lock();
      if (mounted) {
        state = PinState(isUnlocked: false, hasPin: true);
      }
    }
  }
}

final pinProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier(ref);
});
