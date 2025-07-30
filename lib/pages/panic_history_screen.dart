// lib/pages/panic_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/health_visit.dart';

// The PanicHistoryScreen displays a list of all recorded panic button activations
// or self-reported emergency situations.
class PanicHistoryScreen extends StatelessWidget {
  const PanicHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    // Filter for visits that were self-reported and have danger signs (simulating panic reports)
    final List<HealthVisit> panicReports = dataManager
        .getAllHealthVisits()
        .where((visit) =>
            visit.dangerSigns.isNotEmpty &&
            visit.visitorRole == 'Self-Reported')
        .toList();

    // Sort by most recent first
    panicReports.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Ensure this uses theme color
      appBar: AppBar(
        title: const Text('Panic History'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Emergency Alerts',
                  style: AppStyles.headline2.copyWith(
                      color: AppColors.dangerColor), // Emphasize danger color
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'This section records all instances where the panic button was activated or emergency signs were reported.',
                  style: AppStyles.bodyText1.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Expanded(
            child: panicReports.isEmpty
                ? Center(
                    child: Text(
                      'No panic reports or emergency alerts recorded yet.',
                      style: AppStyles.bodyText1.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: panicReports.length,
                    itemBuilder: (context, index) {
                      final report = panicReports[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4, // Slightly higher elevation for emphasis
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        color: Theme.of(context)
                            .cardTheme
                            .color, // Use theme card color
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: AppColors.dangerColor, size: 28),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Emergency Alert',
                                    style: AppStyles.subTitle
                                        .copyWith(color: AppColors.dangerColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${report.visitDate.toLocal().toString().split(' ')[0]} at ${report.visitDate.toLocal().toString().split(' ')[1].substring(0, 5)}',
                                style: AppStyles.bodyText2.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color),
                              ),
                              const SizedBox(height: 4),
                              if (report.dangerSigns.isNotEmpty)
                                Text(
                                  'Reported Signs: ${report.dangerSigns.join(', ')}',
                                  style: AppStyles.bodyText1.copyWith(
                                      color: AppColors.dangerColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              if (report.notes != null &&
                                  report.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Notes: ${report.notes}',
                                    style: AppStyles.bodyText2.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color),
                                  ),
                                ),
                              if (report.recommendations != null &&
                                  report.recommendations!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Recommendations: ${report.recommendations}',
                                    style: AppStyles.bodyText2.copyWith(
                                        color: AppColors.infoColor,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
