// lib/widgets/loading_overlay.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart'; // Import your app colors

// A simple overlay widget to indicate a loading state across the screen.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading; // Whether the overlay should be visible
  final Widget child; // The widget tree to display beneath the overlay
  final String? message; // Optional message to display (e.g., "Loading...")

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main content of the screen
        child,
        // The loading overlay, conditionally visible
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withOpacity(0.5), // Semi-transparent black background
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.whiteTextColor), // White spinner
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: TextStyle(
                            color: AppColors.whiteTextColor, fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
