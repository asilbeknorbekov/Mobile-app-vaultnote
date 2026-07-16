import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_colors.dart';

class GlassTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GlassColors.lightSeed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent, // Background will be handled by a gradient container
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GlassColors.darkSeed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  // A helper widget to provide the animated gradient/aurora backdrop
  static Widget buildBackground({required Widget child, required bool isDark}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          isDark ? 'assets/images/background.jpg' : 'assets/images/background_light.jpg',
          fit: BoxFit.cover,
        ),
        if (isDark)
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
        child,
      ],
    );
  }
}
