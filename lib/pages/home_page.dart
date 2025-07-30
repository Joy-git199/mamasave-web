// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/pages/mother_dashboard.dart';
import 'package:mamasave/pages/visit_history_screen.dart';
import 'package:mamasave/pages/pregnancy_progress_screen.dart';
import 'package:mamasave/pages/settings_screen.dart'; // Import settings screen for drawer
import 'package:mamasave/pages/help_support_screen.dart'; // Import help screen for drawer
import 'package:mamasave/pages/documents_upload_screen.dart'; // Import documents screen for drawer
import 'package:mamasave/services/auth_service.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/widgets/custom_snackbar.dart'; // For logout snackbar

// The HomePage serves as the main navigation hub for the mother's role.
// It includes a BottomNavigationBar for easy access to key sections.
class HomePage extends StatefulWidget {
  final String userName; // Passed from login/signup

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index for the selected tab in BottomNavigationBar

  // List of widgets (screens) to be displayed in the body based on selected tab.
  // Note: For VisitHistoryScreen, we pass the current mother's ID.
  static final List<Widget> _widgetOptions = <Widget>[
    const MotherDashboard(),
    const VisitHistoryScreen(
        userId: 'mother_001',
        role:
            'Mother'), // Assuming 'mother_001' is the current mother for mock data
    PregnancyProgressScreen(), // Removed const
  ];

  // Handles tap events on the BottomNavigationBar items.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final String currentMotherId =
        'mother_001'; // Assuming this is the logged-in mother's ID

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // AppBar title will change based on the selected tab for better context.
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        actions: const [
          // No direct actions here, as profile/logout are in the Drawer
        ],
      ),
      drawer: _buildDrawer(context, authService, dataManager, widget.userName,
          currentMotherId), // Navigation drawer
      body: _widgetOptions
          .elementAt(_selectedIndex), // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Visits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pregnant_woman_outlined),
            activeIcon: Icon(Icons.pregnant_woman),
            label: 'Progress',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            Theme.of(context).primaryColor, // Selected icon/label color
        unselectedItemColor:
            Theme.of(context).hintColor, // Unselected icon/label color
        onTap: _onItemTapped, // Callback for item taps
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        backgroundColor: Theme.of(context)
            .bottomNavigationBarTheme
            .backgroundColor, // Background color from theme
        selectedLabelStyle:
            AppStyles.bodyText2.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppStyles.bodyText2,
      ),
    );
  }

  // Helper function to get the AppBar title based on the selected index.
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Mother Dashboard';
      case 1:
        return 'Health Visits';
      case 2:
        return 'Pregnancy Progress';
      default:
        return 'MamaSave';
    }
  }

  // Builds the navigation drawer for the Mother's dashboard.
  Widget _buildDrawer(BuildContext context, AuthService authService,
      DataManager dataManager, String userName, String currentMotherId) {
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
              _onItemTapped(0); // Navigate to Dashboard
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
              _onItemTapped(1); // Navigate to Visit History
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
                arguments: {'motherId': currentMotherId},
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
              _onItemTapped(2); // Navigate to Pregnancy Progress
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
              await authService.signOut(); // Renamed to signOut
              Navigator.of(context).pushReplacementNamed('/');
              CustomSnackBar.showInfo(context, 'You have been logged out.');
            },
          ),
        ],
      ),
    );
  }
}
