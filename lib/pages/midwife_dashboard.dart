// lib/pages/midwife_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/auth_service.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/health_visit.dart';
import 'package:mamasave/models/user_profile.dart'; // Import UserProfile
import 'package:table_calendar/table_calendar.dart';
import 'package:mamasave/widgets/custom_snackbar.dart';

// The MidwifeDashboard provides an overview for midwives, including statistics,
// recent emergencies, and upcoming visits.
class MidwifeDashboard extends StatefulWidget {
  const MidwifeDashboard({super.key});

  @override
  State<MidwifeDashboard> createState() => _MidwifeDashboardState();
}

class _MidwifeDashboardState extends State<MidwifeDashboard> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock Midwife ID.
  final String _currentMidwifeId = 'midwife_mock';

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final authService = Provider.of<AuthService>(context);
    final theme = Theme.of(context); // Get theme for dark mode check

    // FIX: Change type to UserProfile? and access properties with dot notation
    final UserProfile? currentUser = dataManager.getUserById(_currentMidwifeId);
    final String midwifeName = currentUser?.name ?? 'Midwife User'; // FIX: Access with dot notation

    final Map<String, int> stats = dataManager.getMidwifeSummaryStats();
    final List<HealthVisit> recentEmergencies =
        dataManager.getRecentEmergencyReports();
    final List<HealthVisit> upcomingVisits = dataManager.getUpcomingVisits();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme color
      appBar: AppBar(
        title: Text('Midwife Dashboard', style: AppStyles.headline2.copyWith(color: AppColors.whiteTextColor)), // FIX: Use AppStyles and AppColors
        backgroundColor: theme.primaryColor, // Use theme color
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: AppColors.whiteTextColor), // FIX: Set icon color
            onPressed: () {
              CustomSnackBar.showInfo(context,
                  'Navigating to Midwife Profile (feature coming soon!).');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.whiteTextColor), // FIX: Set icon color
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context).pushReplacementNamed('/');
              CustomSnackBar.showInfo(context, 'You have been logged out.');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, authService, midwifeName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $midwifeName!',
              style: AppStyles.headline2.copyWith(
                  color: theme.textTheme.displayMedium?.color),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Overview Statistics', Icons.bar_chart, context),
            const SizedBox(height: 16),
            _buildStatisticsGrid(stats, context),
            const SizedBox(height: 24),
            _buildSectionTitle(
                'Recent Emergency Reports', Icons.warning_amber, context),
            const SizedBox(height: 16),
            _buildEmergencyReports(recentEmergencies, dataManager, context),
            const SizedBox(height: 24),
            _buildSectionTitle(
                'Upcoming Visits', Icons.calendar_today, context),
            const SizedBox(height: 16),
            _buildCalendar(context),
            const SizedBox(height: 16),
            _buildUpcomingVisitsList(upcomingVisits, dataManager, context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Builds a section title with an icon.
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

  // Builds the grid displaying summary statistics.
  Widget _buildStatisticsGrid(Map<String, int> stats, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800
            ? 4
            : (constraints.maxWidth > 600 ? 2 : 2);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildStatCard('Total Mothers', stats['totalMothers'] ?? 0,
                Icons.group, context),
            _buildStatCard('Pregnant', stats['pregnantMothers'] ?? 0,
                Icons.pregnant_woman, context),
            _buildStatCard('Postnatal', stats['postnatalMothers'] ?? 0,
                Icons.child_care, context),
            _buildStatCard('Emergencies', stats['emergencies'] ?? 0,
                Icons.emergency, context,
                isEmergency: true),
          ],
        );
      },
    );
  }

  // Helper for individual statistic cards.
  Widget _buildStatCard(
      String title, int count, IconData icon, BuildContext context,
      {bool isEmergency = false}) {
    return Container(
      decoration: AppStyles.cardDecoration(context).copyWith(
        // Correct: Call as method
        color: isEmergency
            ? AppColors.dangerColor.withOpacity(0.1)
            : Theme.of(context).cardTheme.color,
        border: isEmergency
            ? Border.all(color: AppColors.dangerColor, width: 1.5)
            : null,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: isEmergency
                ? AppColors.dangerColor
                : Theme.of(context).hintColor,
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: AppStyles.headline2.copyWith(
              color: isEmergency
                  ? AppColors.dangerColor
                  : Theme.of(context).textTheme.displayMedium?.color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: AppStyles.bodyText2.copyWith(
              color: isEmergency
                  ? AppColors.dangerColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Builds the list of recent emergency reports.
  Widget _buildEmergencyReports(List<HealthVisit> emergencies,
      DataManager dataManager, BuildContext context) {
    if (emergencies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration:
            AppStyles.cardDecoration(context), // Correct: Call as method
        child: Center(
          child: Text(
            'No recent emergencies reported.',
            style: AppStyles.bodyText2.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    return Container(
      decoration: AppStyles.cardDecoration(context), // Correct: Call as method
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: emergencies.length,
        itemBuilder: (context, index) {
          final emergency = emergencies[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            color: AppColors.dangerColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mother: ${dataManager.getMotherNameById(emergency.motherId)}',
                    style: AppStyles.subTitle
                        .copyWith(color: AppColors.dangerColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${emergency.visitDate.toLocal().toString().split(' ')[0]}',
                    style: AppStyles.bodyText2.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    'Danger Signs: ${emergency.dangerSigns.join(', ')}',
                    style: AppStyles.bodyText1.copyWith(
                        color: AppColors.dangerColor,
                        fontWeight: FontWeight.bold),
                  ),
                  if (emergency.notes.isNotEmpty) // Changed from emergency.notes != null && emergency.notes!.isNotEmpty
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Notes: ${emergency.notes}',
                        style: AppStyles.bodyText2.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Builds the calendar view for upcoming visits.
  Widget _buildCalendar(BuildContext context) {
    // Pass context
    return Container(
      decoration: AppStyles.cardDecoration(context), // Correct: Call as method
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          CustomSnackBar.showInfo(context,
              'Selected day: ${selectedDay.toLocal().toString().split(' ')[0]}');
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppStyles.subTitle
              .copyWith(color: Theme.of(context).primaryColor),
          leftChevronIcon:
              Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
          rightChevronIcon:
              Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context)
                .hintColor
                .withOpacity(0.2), // Use theme hint color
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppStyles.bodyText1.copyWith(
              color: Theme.of(context).hintColor), // Use theme hint color
          selectedTextStyle: AppStyles.buttonTextStyle.copyWith(
              color: AppColors.whiteTextColor), // Correct: direct access
          defaultTextStyle: AppStyles.bodyText2
              .copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
          weekendTextStyle: AppStyles.bodyText2
              .copyWith(color: AppColors.dangerColor.withOpacity(0.7)),
        ),
      ),
    );
  }

  // Builds the list of upcoming visits.
  Widget _buildUpcomingVisitsList(
      List<HealthVisit> visits, DataManager dataManager, BuildContext context) {
    // Pass context
    if (visits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration:
            AppStyles.cardDecoration(context), // Correct: Call as method
        child: Center(
          child: Text(
            'No upcoming visits scheduled.',
            style: AppStyles.bodyText2.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    return Container(
      decoration: AppStyles.cardDecoration(context), // Correct: Call as method
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            color: Theme.of(context).cardTheme.color, // Use theme card color
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mother: ${dataManager.getMotherNameById(visit.motherId)}',
                    style: AppStyles.subTitle
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${visit.visitDate.toLocal().toString().split(' ')[0]}',
                    style: AppStyles.bodyText2.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    'Time: ${visit.visitDate.toLocal().toString().split(' ')[1].substring(0, 5)}',
                    style: AppStyles.bodyText2.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    'Visitor: ${visit.visitorRole}',
                    style: AppStyles.bodyText2.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Builds the navigation drawer for the Midwife's dashboard.
  Widget _buildDrawer(
      BuildContext context, AuthService authService, String userName) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.whiteTextColor
                      .withOpacity(0.8), // Correct: direct access
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: AppStyles.headline3.copyWith(
                      color:
                          AppColors.whiteTextColor), // Correct: direct access
                ),
                Text(
                  'Midwife Role',
                  style: AppStyles.bodyText2.copyWith(
                      color: AppColors.whiteTextColor
                          .withOpacity(0.8)), // Correct: direct access
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Dashboard',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)), // Corrected
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.people,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('All Mothers',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)), // Corrected
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/all_mothers');
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Visit Schedule',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)), // Corrected
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(
                '/visit_history',
                arguments: {'userId': _currentMidwifeId, 'role': 'Midwife'},
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.report_problem,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Emergency Reports',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)), // Corrected
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/panic_history');
            },
          ),
          ListTile(
            leading: Icon(Icons.upload_file,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Documents & Records',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)), // Corrected
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/documents_upload');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Settings',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)), // Corrected
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Help & Support',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)), // Corrected
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/help_support');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.dangerColor),
            title: Text('Logout',
                style:
                    AppStyles.bodyText1.copyWith(color: AppColors.dangerColor)),
            onTap: () async {
              Navigator.pop(context);
              await authService.signOut();
              Navigator.of(context).pushReplacementNamed('/');
              CustomSnackBar.showInfo(context, 'You have been logged out.');
            },
          ),
        ],
      ),
    );
  }
}
