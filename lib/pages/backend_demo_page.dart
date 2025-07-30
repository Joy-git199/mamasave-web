// lib/pages/backend_demo_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/services/auth_service.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/user_profile.dart'; // Import UserProfile
import 'package:mamasave/widgets/custom_snackbar.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'dart:convert'; // For jsonEncode/decode

class BackendDemoPage extends StatefulWidget {
  const BackendDemoPage({super.key});

  @override
  State<BackendDemoPage> createState() => _BackendDemoPageState();
}

class _BackendDemoPageState extends State<BackendDemoPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  // NEW: Controller for fetching specific user's historical data
  final TextEditingController _userIdController = TextEditingController();
  // NEW: Controller for sending raw sensor data JSON
  final TextEditingController _sensorDataRawController = TextEditingController();


  UserProfile? _userProfile; // FIX: Changed type to UserProfile?
  List<Map<String, dynamic>>? _sensorData;
  String? _message;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill user ID for fetching historical data if a user is logged in
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUserUid != null) {
      _userIdController.text = authService.currentUserUid!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _roleController.dispose();
    _userIdController.dispose(); // Dispose new controller
    _sensorDataRawController.dispose(); // Dispose new controller
    super.dispose();
  }

  void _setMessage(String msg) {
    setState(() => _message = msg);
  }

  void _setIsLoading(bool loading) {
    setState(() => _isLoading = loading);
  }

  // --- Authentication Actions ---
  Future<void> _signUp() async {
    _setIsLoading(true);
    _setMessage('');

    final authService = Provider.of<AuthService>(context, listen: false);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _roleController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty) {
      CustomSnackBar.showError(context, 'Please fill all fields');
      _setIsLoading(false);
      return;
    }

    try {
      final result = await authService.signUp(name, email, password, role);
      if (result['success'] == true) {
        CustomSnackBar.showSuccess(context, 'Sign Up Successful! Please log in.');
        _setMessage('Sign Up Successful for $email as $role!');
      } else {
        final err = result['error'] ?? 'Unknown error';
        CustomSnackBar.showError(context, 'Sign Up Failed: $err');
        _setMessage('Sign Up Failed: $err');
      }
    } catch (e) {
      CustomSnackBar.showError(context, 'An error occurred during sign up.');
      _setMessage('Error during sign up: $e');
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> _signIn() async {
    _setIsLoading(true);
    _setMessage('');

    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar.showError(context, 'Please enter email and password');
      _setIsLoading(false);
      return;
    }

    try {
      final success = await authService.signIn(email, password);
      if (success) {
        CustomSnackBar.showSuccess(context, 'Login Successful!');
        _setMessage('Logged in as ${authService.currentUserName} (${authService.currentUserRole})');
        // Update _userIdController with the newly logged-in user's UID
        if (authService.currentUserUid != null) {
          _userIdController.text = authService.currentUserUid!;
        }
      } else {
        CustomSnackBar.showError(context, 'Login Failed. Invalid credentials.');
        _setMessage('Login Failed. Invalid credentials.');
      }
    } catch (e) {
      CustomSnackBar.showError(context, 'An error occurred during login.');
      _setMessage('Error during login: $e');
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> _signOut() async {
    _setIsLoading(true);
    _setMessage('');

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signOut();
      CustomSnackBar.showSuccess(context, 'Signed out successfully!');
      _setMessage('Signed out.');
      setState(() {
        _userProfile = null;
        _sensorData = null;
        _userIdController.clear(); // Clear user ID on sign out
      });
    } catch (e) {
      CustomSnackBar.showError(context, 'Error signing out.');
      _setMessage('Error signing out: $e');
    } finally {
      _setIsLoading(false);
    }
  }

  // --- Backend Data Actions ---
  Future<void> _fetchUserProfile() async {
    _setIsLoading(true);
    _setMessage('');

    final authService = Provider.of<AuthService>(context, listen: false);
    final dataManager = Provider.of<DataManager>(context, listen: false);

    if (authService.currentUserUid == null) {
      CustomSnackBar.showError(context, 'No user logged in.');
      _setMessage('No user logged in.');
      _setIsLoading(false);
      return;
    }

    try {
      final UserProfile? profile = await dataManager.fetchUserProfile(authService.currentUserUid!); // Ensure it's UserProfile
      if (profile != null) {
        setState(() => _userProfile = profile); // FIX: Assign UserProfile directly
        CustomSnackBar.showSuccess(context, 'Profile fetched successfully!');
        _setMessage('Profile fetched for ${profile.name ?? 'user'}.'); // FIX: Access with dot notation
      } else {
        CustomSnackBar.showError(context, 'Failed to fetch user profile.');
        _setMessage('Failed to fetch user profile.');
      }
    } catch (e) {
      CustomSnackBar.showError(context, 'Error fetching profile.');
      _setMessage('Error fetching profile: $e');
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> _sendSensorData() async {
    _setIsLoading(true);
    _setMessage('');

    final authService = Provider.of<AuthService>(context, listen: false);
    final dataManager = Provider.of<DataManager>(context, listen: false);

    if (authService.currentUserUid == null) {
      CustomSnackBar.showError(context, 'No user logged in.');
      _setMessage('No user logged in.');
      _setIsLoading(false);
      return;
    }

    // Use the raw sensor data controller for sending data
    Map<String, dynamic> sensorData;
    try {
      sensorData = json.decode(_sensorDataRawController.text);
      // Ensure the UID is part of the data being sent
      sensorData['uid'] = authService.currentUserUid!;
    } catch (e) {
      CustomSnackBar.showError(context, 'Invalid JSON for sensor data.');
      _setMessage('Error: Invalid JSON for sensor data: $e');
      _setIsLoading(false);
      return;
    }

    try {
      final success = await dataManager.sendSensorData(sensorData);
      if (success) {
        CustomSnackBar.showSuccess(context, 'Sensor data sent!');
        _setMessage('Sensor data sent: ${jsonEncode(sensorData)}');
      } else {
        CustomSnackBar.showError(context, 'Failed to send sensor data.');
        _setMessage('Failed to send sensor data.');
      }
    } catch (e) {
      CustomSnackBar.showError(context, 'Error sending data.');
      _setMessage('Error sending data: $e');
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> _fetchSensorData() async {
    _setIsLoading(true);
    _setMessage('');

    final dataManager = Provider.of<DataManager>(context, listen: false);
    final String targetUserId = _userIdController.text.trim();

    if (targetUserId.isEmpty) {
      CustomSnackBar.showError(context, 'Please enter a User ID to fetch historical data.');
      _setMessage('Please enter a User ID to fetch historical data.');
      _setIsLoading(false);
      return;
    }

    try {
      final data = await dataManager.fetchSensorData(targetUserId);
      if (data != null) {
        setState(() => _sensorData = data);
        CustomSnackBar.showSuccess(context, 'Sensor data fetched!');
        _setMessage('Fetched ${data.length} readings for $targetUserId.');
      } else {
        CustomSnackBar.showError(context, 'Failed to fetch sensor data.');
        _setMessage('Failed to fetch sensor data.');
      }
    } catch (e) {
      CustomSnackBar.showError(context, 'Error fetching data.');
      _setMessage('Error fetching data: $e');
    } finally {
      _setIsLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context); // To get current user UID for display

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme color
      appBar: AppBar(
        title: Text('Backend Demo', style: AppStyles.headline2.copyWith(color: AppColors.whiteTextColor)), // Use AppStyles and AppColors
        backgroundColor: theme.primaryColor, // Use theme color
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current Logged-in User UID: ${authService.currentUserUid ?? 'N/A'}',
              style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 20),

            Text('User Authentication', style: AppStyles.headline2.copyWith(color: theme.primaryColor)), // Use theme color
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              // FIX: Use InputDecoration directly and apply theme defaults
              decoration: InputDecoration(
                labelText: 'Email',
              ).applyDefaults(theme.inputDecorationTheme),
              keyboardType: TextInputType.emailAddress,
              style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              // FIX: Use InputDecoration directly and apply theme defaults
              decoration: InputDecoration(
                labelText: 'Password',
              ).applyDefaults(theme.inputDecorationTheme),
              obscureText: true,
              style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              // FIX: Use InputDecoration directly and apply theme defaults
              decoration: InputDecoration(
                labelText: 'Name (for Sign Up)',
              ).applyDefaults(theme.inputDecorationTheme),
              style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _roleController,
              // FIX: Use InputDecoration directly and apply theme defaults
              decoration: InputDecoration(
                labelText: 'Role (e.g., mother, chw, midwife)',
              ).applyDefaults(theme.inputDecorationTheme),
              style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              style: theme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.all(AppColors.accentColor), // Specific color for signup
              ),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Sign Up', style: AppStyles.buttonTextStyle),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              style: theme.elevatedButtonTheme.style, // Use theme's primary button style
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Sign In', style: AppStyles.buttonTextStyle),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _signOut,
              style: theme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.all(AppColors.dangerColor), // Specific color for signout
              ),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Sign Out', style: AppStyles.buttonTextStyle),
            ),
            const SizedBox(height: 32),

            Text('Backend Data Operations', style: AppStyles.headline2.copyWith(color: theme.primaryColor)), // Use theme color
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchUserProfile,
              style: theme.elevatedButtonTheme.style, // Use theme's primary button style
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Fetch My User Profile', style: AppStyles.buttonTextStyle),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sensorDataRawController,
              // FIX: Use InputDecoration directly and apply theme defaults
              decoration: InputDecoration(
                labelText: 'Sensor Data (JSON, e.g., {"heartRate": 75.2, "spo2": 98.1, "temperature": 36.5, "pressure_kPa": 101.3, "pressure_voltage": 3.3, "timestamp": "2024-07-30T10:00:00Z"})',
                alignLabelWithHint: true, // Helps with multiline label
              ).applyDefaults(theme.inputDecorationTheme),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendSensorData,
              style: theme.elevatedButtonTheme.style, // Use theme's primary button style
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Send Sensor Data', style: AppStyles.buttonTextStyle),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userIdController,
              // FIX: Use InputDecoration directly and apply theme defaults
              decoration: InputDecoration(
                labelText: 'User ID for Historical Data (e.g., esp32_sensor_001)',
              ).applyDefaults(theme.inputDecorationTheme),
              style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchSensorData,
              style: theme.elevatedButtonTheme.style, // Use theme's primary button style
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Fetch Historical Sensor Data', style: AppStyles.buttonTextStyle),
            ),
            const SizedBox(height: 32),

            if (_message != null && _message!.isNotEmpty)
              Card(
                color: theme.cardTheme.color, // Use theme card color
                margin: const EdgeInsets.only(top: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Status: $_message', style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color)), // Use theme text color
                ),
              ),

            if (_userProfile != null) ...[
              const SizedBox(height: 16),
              Card(
                color: theme.cardTheme.color, // Use theme card color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Profile:', style: AppStyles.headline3.copyWith(color: theme.textTheme.displaySmall?.color)), // Use theme text color
                      const SizedBox(height: 8),
                      Text('ID: ${_userProfile!.firebaseUid ?? 'N/A'}', style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color)), // FIX: Access with dot notation
                      Text('Name: ${_userProfile!.name ?? 'N/A'}', style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color)), // FIX: Access with dot notation
                      Text('Email: ${_userProfile!.email ?? 'N/A'}', style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color)), // FIX: Access with dot notation
                      Text('Role: ${_userProfile!.role ?? 'N/A'}', style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color)), // FIX: Access with dot notation
                    ],
                  ),
                ),
              ),
            ],

            if (_sensorData != null && _sensorData!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: theme.cardTheme.color, // Use theme card color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sensor Data (${_sensorData!.length} readings):', style: AppStyles.headline3.copyWith(color: theme.textTheme.displaySmall?.color)), // Use theme text color
                      const SizedBox(height: 8),
                      ..._sensorData!.take(5).map((reading) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          // Displaying all known fields from the sensor data
                          'Type: ${reading['type'] ?? 'N/A'}, Value: ${reading['value'] ?? 'N/A'} '
                          '| HR: ${reading['heartRate'] ?? 'N/A'}, SpO2: ${reading['spo2'] ?? 'N/A'}, Temp: ${reading['temperature'] ?? 'N/A'} '
                          '| Pressure: ${reading['pressure_kPa'] ?? 'N/A'} kPa (${reading['pressure_voltage'] ?? 'N/A'} V) '
                          '@ ${DateTime.fromMillisecondsSinceEpoch(reading['timestamp'] ?? 0).toLocal()}',
                          style: AppStyles.bodyText2.copyWith(color: theme.textTheme.bodyMedium?.color), // Use theme text color
                        ),
                      )),
                      if (_sensorData!.length > 5)
                        Text('... and ${_sensorData!.length - 5} more readings.', style: AppStyles.bodyText2.copyWith(fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
