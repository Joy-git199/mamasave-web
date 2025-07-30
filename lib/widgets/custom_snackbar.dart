// lib/widgets/custom_snackbar.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';

// A utility class to show custom-styled SnackBars.
class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    Color? iconColor,
  }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(); // Hide any current snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: iconColor ?? textColor ?? AppColors.whiteTextColor),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: AppStyles.bodyText2
                    .copyWith(color: textColor ?? AppColors.whiteTextColor),
              ),
            ),
          ],
        ),
        backgroundColor:
            backgroundColor ?? AppColors.primaryColor, // Default background
        duration: duration,
        behavior: SnackBarBehavior.floating, // Makes it float above FAB
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        margin: const EdgeInsets.all(16), // Margin from edges
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
      ),
    );
  }

  // Pre-defined snackbar types for convenience
  static void showSuccess(BuildContext context, String message) {
    show(context,
        message: message,
        backgroundColor: AppColors.successColor,
        icon: Icons.check_circle_outline);
  }

  static void showInfo(BuildContext context, String message) {
    show(context,
        message: message,
        backgroundColor: AppColors.infoColor,
        icon: Icons.info_outline);
  }

  static void showWarning(BuildContext context, String message) {
    show(context,
        message: message,
        backgroundColor: AppColors.warningColor,
        icon: Icons.warning_amber_rounded);
  }

  static void showError(BuildContext context, String message) {
    show(context,
        message: message,
        backgroundColor: AppColors.dangerColor,
        icon: Icons.error_outline);
  }
}
