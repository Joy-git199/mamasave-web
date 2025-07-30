// lib/widgets/drawer_item.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';

// A custom widget for items within the app's navigation drawer.
// It provides a consistent look and feel for navigation options.
class DrawerItem extends StatelessWidget {
  final IconData icon; // Icon to display next to the item text
  final String title; // Text title of the drawer item
  final VoidCallback onTap; // Callback function when the item is tapped
  final bool
      isSelected; // Indicates if this item is currently selected (highlighted)

  // Constructor for DrawerItem.
  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false, // Default to not selected
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Ensure no default material background
      child: InkWell(
        onTap: onTap, // Attach the onTap callback
        // Apply different background color if the item is selected
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
                8.0), // Slightly rounded corners for the item
          ),
          margin: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 4.0), // Margin around the item
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0), // Padding inside the item
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors
                        .textColor, // Icon color changes based on selection
                size: 24,
              ),
              const SizedBox(width: 16), // Spacing between icon and text
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.bodyText1.copyWith(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors
                            .textColor, // Text color changes based on selection
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal, // Bold text if selected
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
