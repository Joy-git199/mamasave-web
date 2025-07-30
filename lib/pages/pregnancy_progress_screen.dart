// lib/pages/pregnancy_progress_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/user_profile.dart'; // Import UserProfile
import 'package:mamasave/widgets/custom_snackbar.dart';

// The PregnancyProgressScreen provides a personalized view of pregnancy milestones.
class PregnancyProgressScreen extends StatelessWidget {
  const PregnancyProgressScreen({super.key});

  // Mock user ID for the mother.
  final String _currentMotherId = 'mother_001';

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final theme = Theme.of(context); // Get theme for dark mode check

    // FIX: Change type to UserProfile? and access properties with dot notation
    final UserProfile? currentUser = dataManager.getUserById(_currentMotherId);
    final String motherName = currentUser?.name ?? 'MamaSave User'; // FIX: Access with dot notation
    final String pregnancyStatus = dataManager.getMotherPregnancyStatus(_currentMotherId);

    int currentWeek = 0;
    if (pregnancyStatus.startsWith('Week')) {
      try {
        currentWeek = int.parse(pregnancyStatus.split(' ')[1]);
      } catch (e) {
        debugPrint('Error parsing pregnancy week: $e');
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme color
      appBar: AppBar(
        title: Text('My Pregnancy Progress', style: AppStyles.headline2.copyWith(color: AppColors.whiteTextColor)), // FIX: Use AppStyles and AppColors
        backgroundColor: theme.primaryColor, // Use theme color
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Hello, $motherName!',
                    style: AppStyles.headline2
                        .copyWith(color: theme.primaryColor), // Use theme primary color
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your current status:',
                    style: AppStyles.bodyText1.copyWith(
                        color: theme.textTheme.bodyLarge?.color), // Use theme text color
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.hintColor.withOpacity(0.1), // Use theme hint color
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: theme.hintColor, width: 1), // Use theme hint color
                    ),
                    child: Text(
                      pregnancyStatus,
                      style: AppStyles.headline3
                          .copyWith(color: theme.hintColor), // Use theme hint color
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            _buildSectionTitle('Key Milestones', Icons.track_changes, context),
            const SizedBox(height: 16),
            _buildMilestoneCard(
              title: 'First Trimester (Weeks 1-12)',
              description:
                  'Formation of major organs, baby\'s heart starts beating. Focus on folic acid intake.',
              currentWeek: currentWeek,
              startWeek: 1,
              endWeek: 12,
              context: context,
            ),
            const SizedBox(height: 16),
            _buildMilestoneCard(
              title: 'Second Trimester (Weeks 13-27)',
              description:
                  'Baby grows rapidly, you might feel the first movements. Energy levels often improve.',
              currentWeek: currentWeek,
              startWeek: 13,
              endWeek: 27,
              context: context,
            ),
            const SizedBox(height: 16),
            _buildMilestoneCard(
              title: 'Third Trimester (Weeks 28-40)',
              description:
                  'Baby gains weight, organs mature. Prepare for labor and delivery.',
              currentWeek: currentWeek,
              startWeek: 28,
              endWeek: 40,
              context: context,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(
                'What to Expect This Week', Icons.info_outline, context),
            const SizedBox(height: 16),
            Container(
              decoration: AppStyles.cardDecoration(context),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week $currentWeek Highlights:',
                    style: AppStyles.subTitle
                        .copyWith(color: theme.primaryColor), // Use theme primary color
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getWeekSpecificInfo(currentWeek),
                    style: AppStyles.bodyText1.copyWith(
                        color: theme.textTheme.bodyLarge?.color), // Use theme text color
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      CustomSnackBar.showInfo(
                          context, 'Detailed week-by-week guide coming soon!');
                    },
                    icon: Icon(Icons.read_more,
                        color: theme.elevatedButtonTheme.style?.foregroundColor
                            ?.resolve(MaterialState.values.toSet())),
                    label: const Text('Learn More'),
                    style: theme.elevatedButtonTheme.style,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper to build a section title.
  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppStyles.headline3
              .copyWith(color: Theme.of(context).textTheme.displaySmall?.color),
        ),
      ],
    );
  }

  // Helper to build a milestone card with progress.
  Widget _buildMilestoneCard({
    required String title,
    required String description,
    required int currentWeek,
    required int startWeek,
    required int endWeek,
    required BuildContext context,
  }) {
    bool isCompleted = currentWeek >= endWeek;
    double progress = 0.0;
    if (currentWeek >= startWeek && currentWeek <= endWeek) {
      progress = (currentWeek - startWeek) / (endWeek - startWeek);
    } else if (currentWeek > endWeek) {
      progress = 1.0;
    }

    return Container(
      decoration: AppStyles.cardDecoration(context).copyWith(
        // Corrected: .copyWith() on the returned BoxDecoration
        border: Border.all(
          color: isCompleted
              ? AppColors.successColor
              : Theme.of(context).primaryColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted
                    ? AppColors.successColor
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.subTitle.copyWith(
                    color: isCompleted
                        ? AppColors.successColor
                        : Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight:
                        isCompleted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppStyles.bodyText2
                .copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% Complete',
              style: AppStyles.bodyText2.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
        ],
      ),
    );
  }

  // Mock function to get week-specific information
  String _getWeekSpecificInfo(int week) {
    if (week >= 1 && week <= 4) {
      return 'Your baby is the size of a poppy seed. You might be feeling tired and experiencing morning sickness. Focus on folic acid.';
    } else if (week >= 5 && week <= 8) {
      return 'Your baby is developing major organs. You might notice changes in your breasts and increased urination. Stay hydrated.';
    } else if (week >= 9 && week <= 12) {
      return 'Your baby is the size of a plum. Nausea may start to subside. Consider sharing your news with close family and friends.';
    } else if (week >= 13 && week <= 16) {
      return 'Your baby is growing rapidly and you might feel the first flutter of movements. Your energy levels may increase.';
    } else if (week >= 17 && week <= 20) {
      return 'Your baby is the size of a banana. You might be feeling more comfortable. Time for your anatomy scan!';
    } else if (week >= 21 && week <= 24) {
      return 'Your baby is becoming more active. You might experience Braxton Hicks contractions. Stay active and eat well.';
    } else if (week >= 25 && week <= 28) {
      return 'Your baby is gaining weight and developing fat layers. You might feel more tired and have some aches. Start thinking about your birth plan.';
    } else if (week >= 29 && week <= 32) {
      return 'Your baby is moving into position for birth. You might experience more discomfort. Attend your antenatal classes.';
    } else if (week >= 33 && week <= 36) {
      return 'Your baby is almost full-term. You\'ll have more frequent check-ups. Rest as much as possible.';
    } else if (week >= 37 && week <= 40) {
      return 'Your baby is full-term and ready to meet you! Be aware of labor signs. Trust your body.';
    } else if (week > 40) {
      return 'Congratulations on your new arrival! Focus on recovery and bonding with your baby. Remember your postnatal check-ups.';
    }
    return 'Information for this week is not available or your pregnancy status is not yet set.';
  }
}
