import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultnote/core/icons/lucide_icons.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../providers/pin_provider.dart';

class PinAuthScreen extends ConsumerStatefulWidget {
  final Widget child;
  const PinAuthScreen({super.key, required this.child});

  @override
  ConsumerState<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends ConsumerState<PinAuthScreen> {
  String _enteredPin = '';
  String _errorMsg = '';
  
  void _onDigitPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMsg = '';
      });
      if (_enteredPin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onDeletePress() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMsg = '';
      });
    }
  }

  void _submitPin() async {
    final pinState = ref.read(pinProvider);
    if (!pinState.hasPin) {
      await ref.read(pinProvider.notifier).setPin(_enteredPin);
    } else {
      final success = ref.read(pinProvider.notifier).verifyPin(_enteredPin);
      if (!success) {
        setState(() {
          _errorMsg = 'Incorrect PIN. Try again.';
          _enteredPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinProvider);
    if (pinState.isUnlocked) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = pinState.hasPin ? 'Enter your PIN' : 'Create a 4-digit PIN';

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (_errorMsg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_errorMsg, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length 
                          ? (isDark ? Colors.white : Colors.black) 
                          : Colors.transparent,
                      border: Border.all(color: Colors.grey),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 64),
              _buildNumpad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NumpadButton('1', () => _onDigitPress('1')),
              _NumpadButton('2', () => _onDigitPress('2')),
              _NumpadButton('3', () => _onDigitPress('3')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NumpadButton('4', () => _onDigitPress('4')),
              _NumpadButton('5', () => _onDigitPress('5')),
              _NumpadButton('6', () => _onDigitPress('6')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NumpadButton('7', () => _onDigitPress('7')),
              _NumpadButton('8', () => _onDigitPress('8')),
              _NumpadButton('9', () => _onDigitPress('9')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 72),
              _NumpadButton('0', () => _onDigitPress('0')),
              SizedBox(
                width: 72,
                height: 72,
                child: IconButton(
                  onPressed: _onDeletePress,
                  icon: const Icon(LucideIcons.x, size: 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String digit;
  final VoidCallback onTap;

  const _NumpadButton(this.digit, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        tier: GlassTier.tier2,
        borderRadius: BorderRadius.circular(36),
        padding: const EdgeInsets.all(0),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Text(
            digit,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
