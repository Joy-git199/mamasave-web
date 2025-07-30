// lib/pages/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart'; // Corrected import
import 'package:mamasave/utils/app_styles.dart';

// The OnboardingScreen guides new users through the app's features.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingPages = [
    {
      'image': 'assets/onboarding1.png', // Placeholder
      'title': 'Track Your Pregnancy',
      'description':
          'Monitor your health, baby\'s growth, and key milestones throughout your pregnancy journey.',
    },
    {
      'image': 'assets/onboarding2.png', // Placeholder
      'title': 'Connect with Care',
      'description':
          'Easily reach out to Community Health Workers (CHW) and Midwives for support and appointments.',
    },
    {
      'image': 'assets/onboarding3.png', // Placeholder
      'title': 'Emergency Support',
      'description':
          'Access immediate help with our panic button and connect with emergency contacts and services.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Use theme color
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingPages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _onboardingPages[index]['image']!,
                        height: 250,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _onboardingPages[index]['title']!,
                        style: AppStyles.headline2.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.color), // Use theme text color
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _onboardingPages[index]['description']!,
                        style: AppStyles.bodyText1.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color), // Use theme text color
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingPages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Theme.of(context)
                                .dividerColor, // Use theme colors
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _currentPage == _onboardingPages.length - 1
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                              '/login'); // Navigate to login after onboarding
                        },
                        style: Theme.of(context)
                            .elevatedButtonTheme
                            .style, // Use theme button style
                        child: const Text('Get Started'),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                  '/login'); // Skip to login
                            },
                            child: Text(
                              'Skip',
                              style: AppStyles.linkTextStyle.copyWith(
                                  color: Theme.of(context)
                                      .textButtonTheme
                                      .style
                                      ?.foregroundColor
                                      ?.resolve(MaterialState.values
                                          .toSet())), // Use theme text button color
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            style: Theme.of(context)
                                .elevatedButtonTheme
                                .style, // Use theme button style
                            child: const Text('Next'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
