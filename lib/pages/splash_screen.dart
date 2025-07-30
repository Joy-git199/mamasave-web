// lib/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart'; // Corrected import
import 'package:mamasave/utils/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/services/auth_service.dart';

// The SplashScreen is the first screen users see when the app launches.
// It handles initializations and navigates to the appropriate screen (onboarding, login, or dashboard).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Determines the next screen to navigate to based on authentication status.
  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate loading time

    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.isLoggedIn) { // Removed the parentheses
      // If logged in, navigate to the appropriate dashboard based on role
      String role =
          authService.currentUserRole ?? 'mother'; // Default to mother
      if (role == 'mother') {
        Navigator.of(context).pushReplacementNamed('/mother_dashboard');
      } else if (role == 'chw') {
        Navigator.of(context).pushReplacementNamed('/chw_dashboard');
      } else if (role == 'midwife') {
        Navigator.of(context).pushReplacementNamed('/midwife_dashboard');
      } else {
        Navigator.of(context)
            .pushReplacementNamed('/role_selection'); // Fallback
      }
    } else {
      // If not logged in, navigate to onboarding or login
      // For now, let's go directly to login page.
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).primaryColor, // Use theme primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Ensure you have a logo.png in your assets folder
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              'MamaSave',
              style: AppStyles.headline1.copyWith(
                color: AppColors.whiteTextColor, // Correct: direct access
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Partner in Maternal Health',
              style: AppStyles.bodyText1.copyWith(
                color: AppColors.whiteTextColor
                    .withOpacity(0.8), // Correct: direct access
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.whiteTextColor), // Correct: direct access
            ),
            const SizedBox(height: 20),
            Text(
              'Loading...',
              style: AppStyles.bodyText2.copyWith(
                  color: AppColors.whiteTextColor), // Correct: direct access
            ),
          ],
        ),
      ),
    );
  }
}
