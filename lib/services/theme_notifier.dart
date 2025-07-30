// lib/services/theme_notifier.dart

import 'package:flutter/material.dart';

// ThemeNotifier is a ChangeNotifier that holds the current ThemeMode
// and allows other parts of the app to listen for theme changes.
class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  // Sets the new theme mode and notifies listeners.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners(); // Notify all widgets listening to this notifier
    }
  }

  // Toggles between light and dark mode (if not system)
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      // If currently system, toggle to light/dark based on current system brightness
      // For simplicity, we'll toggle to light if system is dark, and dark if system is light.
      // In a real app, you might want to read system brightness here.
      _themeMode = ThemeMode.light; // Default toggle from system to light
    }
    notifyListeners();
  }
}
