// lib/utils/app_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamasave/utils/app_colors.dart'; // Corrected import

// Defines consistent text styles, input decorations, and button styles for the application.
class AppStyles {
  // --- Text Styles ---
  // These styles define font family, size, and weight. Their colors will be
  // applied dynamically via MaterialApp's textTheme based on the current theme.
  static final TextStyle headline1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle headline2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle headline3 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle subTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyText1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyText2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle buttonTextStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color:
        AppColors.whiteTextColor, // Buttons always have white text for contrast
  );

  static final TextStyle linkTextStyle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    // Removed direct color here, will be set by TextButtonThemeData in main.dart
  );

  // --- Input Decoration Theme ---
  // FIX: Removed 'const' keyword here and from OutlineInputBorder constructors
  // because BorderRadius.circular is not a const constructor.
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    // fillColor will be set dynamically in main.dart based on theme
    contentPadding:
        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // FIX: Removed const
      borderSide: BorderSide.none, // No border by default, rely on fill color
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // FIX: Removed const
      // Border color will be set dynamically in main.dart
      borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1.0), // Default transparent, theme will override
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // FIX: Removed const
      // Border color will be set dynamically in main.dart
      borderSide: const BorderSide(
          color: Colors.transparent,
          width: 2.0), // Default transparent, theme will override
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // FIX: Removed const
      borderSide: const BorderSide(
          color: AppColors.dangerColor, width: 2.0), // Red for errors
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // FIX: Removed const
      borderSide: const BorderSide(color: AppColors.dangerColor, width: 2.0),
    ),
    // labelStyle and hintStyle will be set dynamically in main.dart based on theme
  );

  // --- Button Styles ---
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    // backgroundColor will be set dynamically in main.dart based on theme
    foregroundColor: AppColors.whiteTextColor, // Text color on primary button
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // Rounded corners for buttons
    ),
    elevation: 4, // Subtle shadow
    textStyle: buttonTextStyle,
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    // foregroundColor and side will be set dynamically in main.dart based on theme
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    textStyle: bodyText1.copyWith(fontWeight: FontWeight.w600),
  );

  // --- Card Decoration ---
  // This is now a method that takes BuildContext to dynamically get theme colors
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDarkMode ? AppColors.surfaceColorDark : AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(16.0), // Rounded corners for cards
      boxShadow: [
        BoxShadow(
          color: isDarkMode ? AppColors.shadowColorDark : AppColors.shadowColor,
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
