import 'package:flutter/material.dart';

class GlassColors {
  // Base colors for gradients
  static const Color lightBackgroundStart = Color(0xFFF3F4F6); // Soft off-white
  static const Color lightBackgroundEnd = Color(0xFFE5E7EB);   // Pastel gradient base
  
  static const Color darkBackgroundStart = Color(0xFF0F172A);  // Deep navy
  static const Color darkBackgroundEnd = Color(0xFF1E293B);    // Charcoal

  // Glass Fills
  static const Color lightGlassFill = Color(0x66FFFFFF); // White at 40% opacity
  static const Color darkGlassFill = Color(0x66000000);  // Black at 40% opacity
  
  // Glass Borders
  static const Color glassBorderLight = Color(0x66FFFFFF); // White at 40% opacity
  static const Color glassBorderDark = Color(0x40FFFFFF);  // White at 25% opacity
  
  // Outer Shadows
  static const Color glassShadow = Color(0x26000000); // Black at 15% opacity

  // Seed Colors for M3
  static const Color lightSeed = Color(0xFF6366F1); // Indigo
  static const Color darkSeed = Color(0xFF818CF8);  // Soft Indigo
}
