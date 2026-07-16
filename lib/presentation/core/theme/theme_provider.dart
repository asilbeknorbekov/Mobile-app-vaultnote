import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  static const _themeKey = 'app_theme_mode';

  ThemeNotifier(this._ref) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final prefs = _ref.read(sharedPrefsProvider);
    final themeString = prefs.getString(_themeKey);
    if (themeString != null) {
      if (themeString == 'light') {
        state = ThemeMode.light;
      } else if (themeString == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = _ref.read(sharedPrefsProvider);
    String themeString = 'system';
    if (mode == ThemeMode.light) themeString = 'light';
    if (mode == ThemeMode.dark) themeString = 'dark';
    await prefs.setString(_themeKey, themeString);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref);
});
