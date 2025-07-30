// lib/pages/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/services/auth_service.dart';
import 'package:mamasave/services/theme_notifier.dart'; // Keep ThemeNotifier
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/user_profile.dart'; // NEW: Import UserProfile
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Original state variables for various settings
  bool _inAppMessagingEnabled = true;
  bool _receiveVisitReminders = true;
  bool _getWeeklyTips = true;
  bool _panicAlertConfirmations = true;
  bool _offlineModeEnabled = false;
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  // Original TextEditingControllers for profile editing
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();
  final TextEditingController _editPhoneController = TextEditingController();
  final TextEditingController _editAgeController = TextEditingController();
  final TextEditingController _editLocationController = TextEditingController();

  String? _currentUserUid;
  StreamSubscription? _authStateSubscription;

  // NEW: UserProfile object to hold fetched profile data
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _currentUserUid = authService.currentUserUid;
      
      _authStateSubscription = authService.onAuthStateChanged.listen((user) {
        if (!mounted) return;
        setState(() {
          _currentUserUid = user?.uid;
          if (user == null) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });
        _fetchAndDisplayUserDetails(); // Re-fetch details on auth state change
      });
      _fetchAndDisplayUserDetails(); // Initial fetch
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _editNameController.dispose();
    _editEmailController.dispose();
    _editPhoneController.dispose();
    _editAgeController.dispose();
    _editLocationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndDisplayUserDetails() async {
    if (_currentUserUid != null) {
      try {
        final DataManager dataManager = Provider.of<DataManager>(context, listen: false);
        // FIX: Now fetchUserProfile returns UserProfile?
        final UserProfile? fetchedProfile = await dataManager.fetchUserProfile(_currentUserUid!);
        if (fetchedProfile != null && mounted) {
          setState(() {
            _userProfile = fetchedProfile; // Store the fetched UserProfile
            _editNameController.text = fetchedProfile.name;
            _editEmailController.text = fetchedProfile.email;
            _editPhoneController.text = fetchedProfile.phone ?? '';
            _editAgeController.text = fetchedProfile.age?.toString() ?? '';
            _editLocationController.text = fetchedProfile.location ?? '';
            // Update theme dropdown based on fetched profile
            _selectedLanguage = _userProfile?.appTheme == 'dark' ? 'English' : 'English'; // Default to English, theme is separate
          });
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Failed to load profile: $e');
        }
      }
    } else {
      // Clear controllers if no user is logged in
      setState(() {
        _userProfile = null;
        _editNameController.clear();
        _editEmailController.clear();
        _editPhoneController.clear();
        _editAgeController.clear();
        _editLocationController.clear();
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      if(mounted) CustomSnackBar.showSuccess(context, 'Logged out successfully!');
    } catch (e) {
      if(mounted) CustomSnackBar.showError(context, 'Failed to log out: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    if (_currentUserUid == null) {
      CustomSnackBar.showError(context, 'You must be logged in to change your password.');
      return;
    }
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final authService = Provider.of<AuthService>(dialogContext, listen: false);
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Current Password', prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color)),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_reset_outlined, color: Theme.of(context).iconTheme.color)),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm New Password', prefixIcon: Icon(Icons.lock_reset_outlined, color: Theme.of(context).iconTheme.color)),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Change'),
              onPressed: _isLoading ? null : () async {
                if (_newPasswordController.text != _confirmNewPasswordController.text) {
                  CustomSnackBar.showError(dialogContext, 'New passwords do not match.');
                  return;
                }
                if (_newPasswordController.text.length < 6) {
                  CustomSnackBar.showError(dialogContext, 'New password must be at least 6 characters long.');
                  return;
                }
                setState(() => _isLoading = true);
                try {
                  final result = await authService.changePassword(_currentPasswordController.text, _newPasswordController.text);
                  if (result['success']) {
                    if(mounted) CustomSnackBar.showSuccess(dialogContext, 'Password changed successfully!');
                    if(mounted) Navigator.of(dialogContext).pop();
                  } else {
                    if(mounted) CustomSnackBar.showError(dialogContext, 'Failed to change password: ${result['message']}');
                  }
                } catch (e) {
                  if(mounted) CustomSnackBar.showError(dialogContext, 'An error occurred: $e');
                } finally {
                  if(mounted) setState(() => _isLoading = false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    if (_currentUserUid == null) {
      CustomSnackBar.showError(context, 'You must be logged in to edit your profile.');
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final authService = Provider.of<AuthService>(dialogContext, listen: false);
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _editNameController,
                  decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).iconTheme.color)),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _editEmailController,
                  decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color)),
                  keyboardType: TextInputType.emailAddress,
                  style: Theme.of(context).textTheme.bodyLarge,
                  readOnly: true, // Email is usually not editable
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _editPhoneController,
                  decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined, color: Theme.of(context).iconTheme.color)),
                  keyboardType: TextInputType.phone,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _editAgeController,
                  decoration: InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.calendar_today_outlined, color: Theme.of(context).iconTheme.color)),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _editLocationController,
                  decoration: InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined, color: Theme.of(context).iconTheme.color)),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                try {
                  final updateData = {
                    'name': _editNameController.text.trim(),
                    'phone': _editPhoneController.text.trim(),
                    'age': int.tryParse(_editAgeController.text.trim()),
                    'location': _editLocationController.text.trim(),
                  };
                  // Assuming authService.updateUserProfile takes a Map<String, dynamic>
                  final result = await authService.updateUserProfile(_currentUserUid!, updateData);
                  if (result['success']) {
                    if(mounted) CustomSnackBar.showSuccess(dialogContext, 'Profile updated successfully!');
                    if(mounted) Navigator.of(dialogContext).pop();
                    await _fetchAndDisplayUserDetails(); // Re-fetch to update UI
                  } else {
                    if(mounted) CustomSnackBar.showError(dialogContext, 'Failed to update profile: ${result['message']}');
                  }
                } catch (e) {
                  if(mounted) CustomSnackBar.showError(dialogContext, 'An error occurred: $e');
                } finally {
                  if(mounted) setState(() => _isLoading = false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.of(context).pop();
                  CustomSnackBar.showSuccess(context, 'Language set to English');
                },
              ),
              RadioListTile<String>(
                title: const Text('Luganda'),
                value: 'Luganda',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.of(context).pop();
                  CustomSnackBar.showSuccess(context, 'Language set to Luganda');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context); // Get theme for consistent colors

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Settings Section
                  Text(
                    'General Settings',
                    style: AppStyles.headline2.copyWith(
                        color: Theme.of(context).textTheme.headlineMedium?.color),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.person_outline,
                                color: Theme.of(context).iconTheme.color),
                            title: Text('Edit Profile',
                                style: Theme.of(context).textTheme.bodyLarge),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context).iconTheme.color),
                            onTap: () => _showEditProfileDialog(context),
                          ),
                          Divider(
                              color: Theme.of(context).dividerColor, height: 1),
                          ListTile(
                            leading: Icon(Icons.lock_outline,
                                color: Theme.of(context).iconTheme.color),
                            title: Text('Change Password',
                                style: Theme.of(context).textTheme.bodyLarge),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context).iconTheme.color),
                            onTap: () => _showChangePasswordDialog(context),
                          ),
                          Divider(
                              color: Theme.of(context).dividerColor, height: 1),
                          ListTile(
                            leading: Icon(Icons.language_outlined,
                                color: Theme.of(context).iconTheme.color),
                            title: Text('Language',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(_selectedLanguage,
                                style: Theme.of(context).textTheme.bodySmall),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context).iconTheme.color),
                            onTap: () => _showLanguageSelectionDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Preferences Section
                  Text(
                    'App Preferences',
                    style: AppStyles.headline2.copyWith(
                        color: Theme.of(context).textTheme.headlineMedium?.color),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.color_lens_outlined,
                                color: Theme.of(context).iconTheme.color),
                            title: Text('Dark Mode',
                                style: Theme.of(context).textTheme.bodyLarge),
                            trailing: Switch(
                              value: themeNotifier.themeMode == ThemeMode.dark,
                              onChanged: (bool value) {
                                themeNotifier.toggleTheme();
                                CustomSnackBar.showSuccess(context,
                                    'Dark Mode ${value ? 'enabled' : 'disabled'}');
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          // Other preference toggles
                          Divider(color: Theme.of(context).dividerColor, height: 1),
                          SwitchListTile(
                            title: Text('In-App Messaging', style: Theme.of(context).textTheme.bodyLarge),
                            secondary: Icon(Icons.message_outlined, color: Theme.of(context).iconTheme.color),
                            value: _inAppMessagingEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _inAppMessagingEnabled = value;
                              });
                              CustomSnackBar.showInfo(context, 'In-App Messaging ${value ? 'enabled' : 'disabled'}');
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                          Divider(color: Theme.of(context).dividerColor, height: 1),
                          SwitchListTile(
                            title: Text('Receive Visit Reminders', style: Theme.of(context).textTheme.bodyLarge),
                            secondary: Icon(Icons.notifications_active_outlined, color: Theme.of(context).iconTheme.color),
                            value: _receiveVisitReminders,
                            onChanged: (bool value) {
                              setState(() {
                                _receiveVisitReminders = value;
                              });
                              CustomSnackBar.showInfo(context, 'Visit Reminders ${value ? 'enabled' : 'disabled'}');
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                          Divider(color: Theme.of(context).dividerColor, height: 1),
                          SwitchListTile(
                            title: Text('Get Weekly Health Tips', style: Theme.of(context).textTheme.bodyLarge),
                            secondary: Icon(Icons.lightbulb_outline, color: Theme.of(context).iconTheme.color),
                            value: _getWeeklyTips,
                            onChanged: (bool value) {
                              setState(() {
                                _getWeeklyTips = value;
                              });
                              CustomSnackBar.showInfo(context, 'Weekly Health Tips ${value ? 'enabled' : 'disabled'}');
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                          Divider(color: Theme.of(context).dividerColor, height: 1),
                          SwitchListTile(
                            title: Text('Panic Alert Confirmations', style: Theme.of(context).textTheme.bodyLarge),
                            secondary: Icon(Icons.security_outlined, color: Theme.of(context).iconTheme.color),
                            value: _panicAlertConfirmations,
                            onChanged: (bool value) {
                              setState(() {
                                _panicAlertConfirmations = value;
                              });
                              CustomSnackBar.showInfo(context, 'Panic Alert Confirmations ${value ? 'enabled' : 'disabled'}');
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                          Divider(color: Theme.of(context).dividerColor, height: 1),
                          SwitchListTile(
                            title: Text('Offline Mode', style: Theme.of(context).textTheme.bodyLarge),
                            secondary: Icon(Icons.cloud_off_outlined, color: Theme.of(context).iconTheme.color),
                            value: _offlineModeEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _offlineModeEnabled = value;
                              });
                              CustomSnackBar.showInfo(context, 'Offline Mode ${value ? 'enabled' : 'disabled'}');
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Account Actions Section
                  Text(
                    'Account Actions',
                    style: AppStyles.headline2.copyWith(
                        color: Theme.of(context).textTheme.headlineMedium?.color),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.logout,
                                color: Theme.of(context).colorScheme.error),
                            title: Text('Logout',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error)),
                            onTap: _handleLogout,
                          ),
                          Divider(
                              color: Theme.of(context).dividerColor, height: 1),
                          ListTile(
                            leading: Icon(Icons.delete_forever,
                                color: Theme.of(context).colorScheme.error),
                            title: Text('Delete Account',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error)),
                            onTap: () async {
                              CustomSnackBar.showInfo(context, 'Delete Account functionality not yet implemented.');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Extension for String capitalization (kept from previous version)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
