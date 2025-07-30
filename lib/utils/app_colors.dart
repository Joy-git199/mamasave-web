import 'package:flutter/material.dart';

// Defines the refined color palette for the MamaSave application.
// Focused on high contrast, readability, and a balanced aesthetic (Google-like dark mode).
class AppColors {
  // --- Core Brand Colors (Light Mode) ---
  static const Color primaryColor = Color(0xFF607D8B); // Blue Grey 500
  static const Color accentColor = Color(0xFF8BC34A); // Light Green 500

  // --- Text Colors (Light Mode) ---
  static const Color textColor = Color(0xFF212121); // Dark Grey
  static const Color secondaryTextColor = Color(0xFF757575); // Medium Grey
  static const Color disabledTextColor = Color(0xFFBDBDBD); // Light Grey

  // --- Background & Surface Colors (Light Mode) ---
  static const Color backgroundColor = Color(0xFFF5F5F5); // Very light grey
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color dividerColor = Color(0xFFE0E0E0); // Light grey
  static const Color shadowColor = Color(0x1A000000); // Subtle black shadow

  // --- Core Brand Colors (Dark Mode) ---
  static const Color primaryColorDark = Color(0xFF64B5F6); // Light Blue 400
  static const Color accentColorDark = Color(0xFF8BC34A); // Same as light

  // --- Text Colors (Dark Mode) ---
  static const Color textColorDark = Color(0xFFE0E0E0); // Light grey
  static const Color secondaryTextColorDark = Color(0xFFA0A0A0); // Lighter grey
  static const Color disabledTextColorDark = Color(0xFF616161); // Darker grey

  // --- Background & Surface Colors (Dark Mode) ---
  static const Color backgroundColorDark = Color(0xFF121212); // Black-like
  static const Color surfaceColorDark = Color(0xFF1E1E1E); // Card/dialogs
  static const Color dividerColorDark = Color(0xFF333333); // Darker grey
  static const Color shadowColorDark = Color(0x33FFFFFF); // Subtle white shadow

  // --- Status/Feedback Colors ---
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color infoColor = Color(0xFF2196F3); // Blue
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color dangerColor = Color(0xFFF44336); // Red

  // --- Common Text Color for Buttons/AppBars ---
  static const Color whiteTextColor = Color(0xFFFFFFFF); // Always white

  // --- Gradient Colors ---
  static const Color gradientStart = Color(0xFFB0C4DE); // Light Steel Blue
  static const Color gradientEnd = Color(0xFFC0D6E6); // Lighter Steel Blue

  // --- Card Colors (FIXED - for use in UI logic) ---
  static const Color lightCardColor = surfaceColor; // Matches light surface
  static const Color darkCardColor = surfaceColorDark; // Matches dark surface
}
