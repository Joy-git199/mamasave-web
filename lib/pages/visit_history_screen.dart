// lib/pages/visit_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/health_visit.dart';
import 'package:mamasave/models/user_profile.dart'; // Import UserProfile

// The VisitHistoryScreen displays a comprehensive list of health visits.
// This screen can be adapted to show visits for a specific mother (if navigated from MotherDashboard)
// or visits conducted by a specific CHW/Midwife (if navigated from their dashboards).
class VisitHistoryScreen extends StatelessWidget {
  final String? userId; // Optional: ID of the user (mother, CHW, or midwife)
  final String? role; // Optional: Role of the user for filtering purposes

  const VisitHistoryScreen({super.key, this.userId, this.role});

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final theme = Theme.of(context); // Get theme for consistent colors

    List<HealthVisit> visits = [];
    String screenTitle = 'Visit History';

    if (role == 'Mother' && userId != null) {
      visits = dataManager.getHealthVisitsForMother(userId!);
      final UserProfile? motherProfile = dataManager.getUserById(userId!);
      screenTitle = '${motherProfile?.name ?? 'Mother'}\'s Visit History';
    } else if (role == 'CHW' && userId != null) {
      visits = dataManager
          .getAllHealthVisits()
          .where((visit) =>
              visit.visitorId == userId && visit.visitorRole == 'CHW')
          .toList();
      final UserProfile? chwProfile = dataManager.getUserById(userId!);
      screenTitle = '${chwProfile?.name ?? 'CHW'}\'s Visit History';
    } else if (role == 'Midwife' && userId != null) {
      visits = dataManager
          .getAllHealthVisits()
          .where((visit) =>
              visit.visitorId == userId && visit.visitorRole == 'Midwife')
          .toList();
      final UserProfile? midwifeProfile = dataManager.getUserById(userId!);
      screenTitle = '${midwifeProfile?.name ?? 'Midwife'}\'s Visit History';
    } else {
      // Default: Show all visits (e.g., for an admin view or if no specific user context)
      visits = dataManager.getAllHealthVisits();
      screenTitle = 'All Health Visits';
    }

    // Sort visits by date, most recent first.
    visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme color
      appBar: AppBar(
        title: Text(screenTitle, style: AppStyles.headline2.copyWith(color: AppColors.whiteTextColor)),
        backgroundColor: theme.appBarTheme.backgroundColor, // Use theme color
        foregroundColor: theme.appBarTheme.foregroundColor, // Use theme color
        elevation: 0,
        centerTitle: true,
      ),
      body: visits.isEmpty
          ? Center(
              child: Text(
                'No visit history available.',
                style: AppStyles.bodyText1.copyWith(fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                // Get the mother's name
                final String motherName = dataManager.getMotherNameById(visit.motherId);
                // Get the visitor's name (if available)
                final UserProfile? visitorProfile = dataManager.getUserById(visit.visitorId ?? '');
                final String visitorDisplayName = visitorProfile?.name ?? visit.visitorRole;


                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  color: theme.cardColor, // Use theme card color
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visit Date: ${visit.visitDate.toLocal().toString().split(' ')[0]}',
                          style: AppStyles.subTitle
                              .copyWith(color: AppColors.primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mother: $motherName',
                          style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color),
                        ),
                        Text(
                          'Conducted by: $visitorDisplayName (${visit.visitorRole})',
                          style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color),
                        ),
                        if (visit.vitals != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Vitals: SpO2 ${visit.vitals!.spo2?.toStringAsFixed(1) ?? 'N/A'}%, Temp ${visit.vitals!.temperature?.toStringAsFixed(1) ?? 'N/A'}°C, HR ${visit.vitals!.heartRate?.toStringAsFixed(1) ?? 'N/A'} bpm, BP ${visit.vitals!.bloodPressure ?? 'N/A'}',
                            style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color),
                          ),
                           if (visit.vitals?.pressureKPa != null || visit.vitals?.pressureVoltage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Pressure: ${visit.vitals!.pressureKPa?.toStringAsFixed(1) ?? 'N/A'} kPa (${visit.vitals!.pressureVoltage?.toStringAsFixed(2) ?? 'N/A'} V)',
                              style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color),
                            ),
                          ),
                        ],
                        if (visit.dangerSigns.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Danger Signs: ${visit.dangerSigns.join(', ')}',
                            style: AppStyles.bodyText2.copyWith(
                                color: AppColors.dangerColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                        if (visit.notes.isNotEmpty) ...[ // Changed from visit.notes != null && visit.notes!.isNotEmpty
                          const SizedBox(height: 8),
                          Text(
                            'Notes: ${visit.notes}',
                            style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color),
                          ),
                        ],
                        if (visit.recommendations != null &&
                            visit.recommendations!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Recommendations: ${visit.recommendations}',
                            style: AppStyles.bodyText2
                                .copyWith(fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
