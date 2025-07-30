// lib/pages/all_mothers_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/user_profile.dart'; // Import UserProfile

class AllMothersListScreen extends StatelessWidget {
  const AllMothersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final theme = Theme.of(context);

    // FIX: Change type to List<UserProfile>
    final List<UserProfile> allMothers = dataManager.getAllMothers();

    return Scaffold(
      appBar: AppBar(
        title: Text('All Registered Mothers', style: AppStyles.headline2.copyWith(color: AppColors.whiteTextColor)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: allMothers.isEmpty
          ? Center(
              child: Text(
                'No mothers registered yet.',
                style: AppStyles.bodyText1.copyWith(fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: allMothers.length,
              itemBuilder: (context, index) {
                final mother = allMothers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  elevation: 4,
                  color: theme.cardColor, // Use theme card color
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                      child: Text(mother.name[0], style: AppStyles.headline3.copyWith(color: AppColors.primaryColor)),
                    ),
                    title: Text(mother.name, style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${mother.email}', style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color)),
                        Text('Status: ${mother.pregnancyStatus ?? 'N/A'}', style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color)),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: theme.hintColor, size: 18),
                    onTap: () {
                      // Navigate to MotherProfileScreen with the mother's ID
                      Navigator.of(context).pushNamed(
                        '/mother_profile',
                        arguments: {'motherId': mother.firebaseUid, 'role': 'Midwife'}, // Pass appropriate role
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
