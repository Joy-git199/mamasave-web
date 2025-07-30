// lib/pages/mother_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/auth_service.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/vitals_entry.dart';
import 'package:mamasave/models/health_visit.dart'; // Corrected import
import 'package:mamasave/models/user_profile.dart'; // Import UserProfile
import 'package:mamasave/widgets/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

import 'package:http/http.dart' as http; // NEW IMPORT for HTTP requests
import 'dart:convert'; // NEW IMPORT for JSON decoding
import 'dart:async'; // NEW IMPORT for Timer

// The MotherDashboard provides a personalized view for mothers.
// It displays real-time vitals, emergency status, visit history, and health tips.
class MotherDashboard extends StatefulWidget {
  const MotherDashboard({super.key});

  @override
  State<MotherDashboard> createState() => _MotherDashboardState();
}

class _MotherDashboardState extends State<MotherDashboard> {
  // Mock user ID for the mother. In a real app, this would come from AuthService.
  // We'll use a fixed mock ID for demonstration purposes.
  final String _currentMotherId = 'mother_001'; // Example mock ID

  // NEW: State variables to hold live sensor data
  String liveHeartRate = 'N/A';
  String liveSpO2 = 'N/A';
  String liveTemperature = 'N/A';
  String livePressureKPa = 'N/A';
  String livePressureVoltage = 'N/A';
  String liveLastUpdated = 'Never';
  String liveErrorMessage = '';

  // NEW: State variable for temperature alert
  bool _showTemperatureAlert = false;

  // NEW: Backend configuration for fetching live data
  // Ensure this IP matches your PC's current IP and the backend is running on this port
  final String _backendHost = '192.168.43.238'; // Your PC's current IP address
  final int _backendPort = 5000;
  final String _sensorFirebaseUid = 'esp32_sensor_001'; // Matches ESP32 code

  // NEW: Timer for periodic data fetching
  Timer? _sensorDataTimer;

  @override
  void initState() {
    super.initState();
    // NEW: Initial fetch of live sensor data
    _fetchLiveSensorData();
    // NEW: Set up a timer to fetch data every 5 seconds
    _sensorDataTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchLiveSensorData();
    });
  }

  @override
  void dispose() {
    _sensorDataTimer?.cancel(); // NEW: Cancel the timer when the widget is disposed
    super.dispose();
  }

  // NEW: Function to fetch live sensor data from the backend
  Future<void> _fetchLiveSensorData() async {
    if (!mounted) return; // Ensure widget is still mounted before setState

    setState(() {
      liveErrorMessage = ''; // Clear previous errors
    });

    // Construct the URL for fetching the latest data for this sensor ID
    // Note: The /api prefix is already handled by ApiService now, but this is a direct HTTP call.
    final String url = 'http://$_backendHost:$_backendPort/api/data/sensor/$_sensorFirebaseUid/latest';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return; // Check again after async call

      if (response.statusCode == 200) {
        // Backend returns a single object with the latest values
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          // Update UI with fetched data. Use .toStringAsFixed(1) for floats.
          // Handle potential missing keys gracefully with null checks or default values.
          liveHeartRate = (data['heartRate'] as num?)?.toStringAsFixed(1) ?? 'N/A';
          liveSpO2 = (data['spo2'] as num?)?.toStringAsFixed(1) ?? 'N/A';
          liveTemperature = (data['temperature'] as num?)?.toStringAsFixed(1) ?? 'N/A';
          livePressureKPa = (data['pressure_kPa'] as num?)?.toStringAsFixed(1) ?? 'N/A';
          livePressureVoltage = (data['pressure_voltage'] as num?)?.toStringAsFixed(2) ?? 'N/A';
          
          // Update last updated time (just time part)
          liveLastUpdated = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5); // HH:MM

          // NEW: Check for temperature alert
          final double? tempValue = double.tryParse(liveTemperature);
          // Only trigger alert if temperature is above 36.0 AND it's a valid number
          if (tempValue != null && tempValue > 36.0) {
            _showTemperatureAlert = true;
            _triggerBackendAlert(tempValue); // Trigger backend alert
          } else {
            _showTemperatureAlert = false;
          }
        });
      } else if (response.statusCode == 404) {
         setState(() {
          liveErrorMessage = 'No live sensor data available yet. Please send data from ESP32 or Backend Demo.';
          print('Live Data Error (404): ${response.body}');
        });
      }
      else {
        setState(() {
          liveErrorMessage = 'Failed to load live data: ${response.statusCode} - ${response.body}';
          print('Live Data Error: ${response.statusCode} - ${response.body}');
        });
      }
    } catch (e) {
      if (!mounted) return; // Check again after async call
      setState(() {
        liveErrorMessage = 'Live data network error: $e';
        print('Live data network error: $e');
      });
    }
  }

  // NEW: Function to trigger an alert on the backend
  Future<void> _triggerBackendAlert(double temperature) async {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    // Get the current user's UID (mother's UID)
    final String? motherUid = authService.currentUserUid;

    if (motherUid == null) {
      CustomSnackBar.showWarning(context, 'Cannot send alert: User not logged in.');
      return;
    }

    try {
      // Call DataManager to send the alert to the backend
      await dataManager.triggerTemperatureAlert(
        motherUid,
        temperature,
        _sensorFirebaseUid, // Pass the sensor ID
      );
      CustomSnackBar.showWarning(context, 'Temperature alert sent to emergency services!');
    } catch (e) {
      CustomSnackBar.showError(context, 'Failed to send temperature alert: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Listen to DataManager for updates to vitals and health visits.
    final dataManager = Provider.of<DataManager>(context);
    final authService = Provider.of<AuthService>(context);
    final theme = Theme.of(context); // Get theme for dark mode check

    // Get mock data for the current mother.
    final UserProfile? currentUser = // FIX: Changed type to UserProfile?
        dataManager.getUserById(_currentMotherId);
    final List<VitalsEntry> vitals =
        dataManager.getVitalsEntriesForMother(_currentMotherId);
    final List<HealthVisit> visits =
        dataManager.getHealthVisitsForMother(_currentMotherId);

    // Get the most recent vitals entry, if available.
    final VitalsEntry? latestVitals = vitals.isNotEmpty
        ? vitals.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
        : null;

    final String motherName = currentUser?.name ?? 'MamaSave User';
    final String pregnancyStatus =
        dataManager.getMotherPregnancyStatus(_currentMotherId);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme color
      // The AppBar was removed from here. HomePage now provides the main AppBar for the screen.
      drawer: _buildDrawer(context, authService, motherName), // Navigation drawer
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message and current status
            Text(
              'Hello, $motherName!',
              style: AppStyles.headline2.copyWith(
                  color: theme.textTheme.displayMedium?.color),
            ),
            const SizedBox(height: 8),
            Text(
              pregnancyStatus, // Dynamic pregnancy status
              style: AppStyles.subTitle.copyWith(
                  color: theme.textTheme.titleLarge?.color), // Use theme text color
            ),
            const SizedBox(height: 24),

            // NEW: Live Data Error message display
            if (liveErrorMessage.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                color: theme.brightness == Brightness.dark ? Colors.red.shade700 : Colors.red.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Live Data Error: $liveErrorMessage',
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // NEW: Temperature Alert Display
            if (_showTemperatureAlert)
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                color: AppColors.dangerColor.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.dangerColor, size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ALERT: High Temperature Detected! (${liveTemperature}°C). Emergency services have been notified.',
                          style: AppStyles.subTitle.copyWith(color: AppColors.dangerColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Real-time Vitals Section - UPDATED TO USE LIVE DATA
            _buildSectionTitle('Your Vitals', Icons.monitor_heart, context),
            const SizedBox(height: 16),
            // Pass live data to the vitals card
            _buildVitalsCard(
              context,
              liveSpO2,
              liveTemperature,
              liveHeartRate,
              livePressureKPa, // Pass live pressure kPa
              livePressureVoltage, // Pass live pressure voltage
              liveLastUpdated, // Pass live last updated time
              _currentMotherId, // Pass mother ID for trends
            ),
            const SizedBox(height: 24),

            // Emergency Button
            _buildEmergencyButton(context),
            const SizedBox(height: 24),

            // Health Tips Section
            _buildSectionTitle('Health Tips', Icons.lightbulb_outline, context),
            const SizedBox(height: 16),
            _buildHealthTips(context),
            const SizedBox(height: 24),

            // Visit History Section
            _buildSectionTitle('Visit History', Icons.history, context),
            const SizedBox(height: 16),
            _buildVisitHistory(visits, context),
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
        Icon(icon,
            color: Theme.of(context).primaryColor,
            size: 28), // Use theme primary color
        const SizedBox(width: 10),
        Text(
          title,
          style: AppStyles.headline3
              .copyWith(color: Theme.of(context).textTheme.displaySmall?.color),
        ),
      ],
    );
  }

  // Builds the vitals display card.
  // UPDATED: Now takes live data as parameters instead of a VitalsEntry object
  Widget _buildVitalsCard(
    BuildContext context,
    String spo2,
    String temperature,
    String heartRate,
    String pressureKPa,
    String pressureVoltage,
    String lastUpdatedTime,
    String motherId, // Retain motherId for navigation to trends
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Pass the motherId to the VitalsGraphScreen
        Navigator.of(context).pushNamed(
          '/vitals_graph',
          arguments: {'motherId': motherId},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: AppStyles.cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: $lastUpdatedTime', // Use liveLastUpdated
              style: AppStyles.bodyText2.copyWith(
                  color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 16), // Increased spacing for better readability
            LayoutBuilder(
              builder: (context, constraints) {
                // Adjust layout based on screen width
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildVitalsItem(
                        'SpO2',
                        '$spo2%', // Use liveSpO2
                        Icons.monitor,
                        context),
                    _buildVitalsItem(
                        'Temp',
                        '$temperature°C', // Use liveTemperature
                        Icons.thermostat,
                        context),
                    _buildVitalsItem(
                        'HR',
                        '$heartRate bpm', // Use liveHeartRate
                        Icons.favorite_border,
                        context),
                  ],
                );
              },
            ),
            const SizedBox(height: 16), // Increased spacing
            // Displaying pressure data from the live sensor
            Text(
              'Blood Pressure: N/A', // Keep this as N/A if not from the sensor
              style: AppStyles.bodyText1.copyWith(
                  color: theme.textTheme.bodyLarge?.color),
            ),
            Text( // NEW: Display live pressure sensor data here
              'Pressure: $pressureKPa kPa ($pressureVoltage V)',
              style: AppStyles.bodyText1.copyWith(
                  color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Tap to view trends',
                style: AppStyles.bodyText2.copyWith(
                    color: theme.textTheme.bodyMedium?.color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for individual vital sign display.
  Widget _buildVitalsItem(
      String label, String value, IconData icon, BuildContext context) {
    return Column(
      children: [
        Icon(icon,
            size: 30,
            color:
                Theme.of(context).hintColor), // Use theme hint color for accent
        const SizedBox(height: 5),
        Text(label,
            style: AppStyles.bodyText2.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color)),
        Text(value,
            style: AppStyles.headline3.copyWith(
                color: Theme.of(context).textTheme.displaySmall?.color)),
      ],
    );
  }

  // Builds the panic button.
  Widget _buildEmergencyButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement actual emergency contact logic (e.g., call, send alert)
          CustomSnackBar.showWarning(context,
              'Emergency button pressed! Sending alert to emergency contacts...');
          // Add a mock panic event to history
          final dataManager = Provider.of<DataManager>(context, listen: false);
          dataManager.addHealthVisit(HealthVisit(
            id: const Uuid().v4(),
            motherId: _currentMotherId,
            visitDate: DateTime.now(),
            visitorRole: 'Self-Reported',
            notes: 'Panic button activated.',
            dangerSigns: ['Panic Button Activated'],
            recommendations: 'Emergency services alerted.',
          ));
        },
        icon: const Icon(Icons.warning_amber_rounded, size: 30),
        label: Text('Panic Button',
            style: AppStyles.buttonTextStyle.copyWith(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dangerColor, // Red for emergency
          foregroundColor: AppColors.whiteTextColor, // Correct: direct access
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 8,
        ),
      ),
    );
  }

  // Builds the health tips section.
  Widget _buildHealthTips(BuildContext context) {
    // Pass context
    final List<String> tips = [
      'Stay hydrated, drink at least 8 glasses of water daily.',
      'Eat a balanced diet rich in fruits, vegetables, and lean protein.',
      'Get regular, moderate exercise as advised by your doctor.',
      'Ensure you get adequate rest, aim for 7-9 hours of sleep.',
      'Attend all your scheduled prenatal appointments.',
      'Practice deep breathing exercises to manage stress.',
      'Avoid smoking and alcohol during pregnancy.',
      'Report any unusual symptoms to your CHW or midwife immediately.',
    ];

    return Container(
      decoration: AppStyles.cardDecoration(context),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips
            .map((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 20, color: AppColors.successColor),
                      const SizedBox(width: 10),
                      Expanded(
                        // FIX: Added missing closing parenthesis for Text widget
                        child: Text(
                          tip,
                          style: AppStyles.bodyText2.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Builds the visit history section.
  Widget _buildVisitHistory(List<HealthVisit> visits, BuildContext context) {
    // Pass context
    if (visits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: AppStyles.cardDecoration(context),
        child: Center(
          child: Text(
            'No visit history available yet.',
            style: AppStyles.bodyText2.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    // Sort visits by date, most recent first.
    visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    return Container(
      decoration: AppStyles.cardDecoration(context),
      child: ListView.builder(
        shrinkWrap: true, // Important for nested list views
        physics:
            const NeverScrollableScrollPhysics(), // Disable scrolling for this list
        itemCount:
            visits.length > 3 ? 3 : visits.length, // Show only top 3 or fewer
        itemBuilder: (context, index) {
          final visit = visits[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 0, // Cards within a card, so no extra elevation
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            color: Theme.of(context)
                .scaffoldBackgroundColor, // Use scaffold background for nested cards
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visit on: ${visit.visitDate.toLocal().toString().split(' ')[0]}',
                    style: AppStyles.subTitle
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conducted by: ${visit.visitorRole}',
                    style: AppStyles.bodyText2.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  if (visit.notes != null && visit.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Notes: ${visit.notes}',
                        style: AppStyles.bodyText2.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                  if (visit.dangerSigns.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Danger Signs: ${visit.dangerSigns.join(', ')}',
                        style: AppStyles.bodyText2.copyWith(
                            color: AppColors.dangerColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (visit.vitals != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Vitals: SpO2 ${visit.vitals!.spo2?.toStringAsFixed(1) ?? 'N/A'}%, Temp ${visit.vitals!.temperature?.toStringAsFixed(1) ?? 'N/A'}°C, HR ${visit.vitals!.heartRate ?? 'N/A'} bpm, BP ${visit.vitals!.bloodPressure ?? 'N/A'}',
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

  // Builds the navigation drawer for the Mother's dashboard.
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
                  backgroundColor: AppColors.whiteTextColor.withOpacity(0.8),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: AppStyles.headline3
                      .copyWith(color: AppColors.whiteTextColor),
                ),
                Text(
                  'Mother Role',
                  style: AppStyles.bodyText2.copyWith(
                      color: AppColors.whiteTextColor.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Home (Dashboard)',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              // Assuming HomePage manages bottom nav, this will go to index 0
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.history,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Visit History',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(
                '/visit_history',
                arguments: {'userId': _currentMotherId, 'role': 'Mother'},
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.monitor_heart,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Vitals Trends',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(
                '/vitals_graph',
                arguments: {'motherId': _currentMotherId},
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.warning_amber_rounded,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Panic History',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/panic_history');
            },
          ),
          ListTile(
            leading: Icon(Icons.lightbulb_outline,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Health Tips',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/health_tips');
            },
          ),
          ListTile(
            leading: Icon(Icons.person_outline,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('My Profile (Contacts & Notes)',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/mother_profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.upload_file,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Documents & Records',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/documents_upload');
            },
          ),
          ListTile(
            leading: Icon(Icons.pregnant_woman,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Pregnancy Progress',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context)
                  .pushNamed('/pregnancy_progress'); // Direct navigation
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings,
                color: Theme.of(context).listTileTheme.iconColor),
            title: Text('Settings',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).listTileTheme.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color)),
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
                        Theme.of(context).textTheme.bodyLarge?.color)),
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
