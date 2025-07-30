// lib/pages/health_tips_screen.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';

// The HealthTipsScreen displays a collection of health tips for mothers.
class HealthTipsScreen extends StatelessWidget {
  const HealthTipsScreen({super.key});

  // Mock data for health tips
  final List<Map<String, String>> healthTips = const [
    {
      'title': 'Stay Hydrated',
      'content':
          'Drink at least 8-10 glasses of water daily to support your body and baby.',
    },
    {
      'title': 'Balanced Diet',
      'content':
          'Eat a variety of fruits, vegetables, lean proteins, and whole grains for essential nutrients.',
    },
    {
      'title': 'Regular Exercise',
      'content':
          'Engage in moderate exercise like walking or prenatal yoga, as advised by your healthcare provider.',
    },
    {
      'title': 'Get Enough Rest',
      'content':
          'Aim for 7-9 hours of sleep per night. Rest when you feel tired.',
    },
    {
      'title': 'Attend Appointments',
      'content':
          'Do not miss your prenatal check-ups. They are crucial for monitoring your and your baby\'s health.',
    },
    {
      'title': 'Avoid Harmful Substances',
      'content':
          'Refrain from smoking, alcohol, and illicit drugs, as they can severely harm your baby.',
    },
    {
      'title': 'Manage Stress',
      'content':
          'Practice relaxation techniques like deep breathing or meditation to reduce stress levels.',
    },
    {
      'title': 'Monitor Danger Signs',
      'content':
          'Be aware of danger signs like severe headache, blurred vision, or vaginal bleeding, and report them immediately.',
    },
    {
      'title': 'Take Prenatal Vitamins',
      'content':
          'Ensure you take your prescribed prenatal vitamins, especially folic acid and iron.',
    },
    {
      'title': 'Dental Health',
      'content':
          'Maintain good oral hygiene. Pregnancy can affect gum health, so regular dental check-ups are important.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Ensure this uses theme color
      appBar: AppBar(
        title: const Text('Health Tips'),
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
                  'Tips for a Healthy Pregnancy',
                  style: AppStyles.headline2
                      .copyWith(color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Here are some essential health tips to guide you through your pregnancy journey.',
                  style: AppStyles.bodyText1.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: healthTips.length,
              itemBuilder: (context, index) {
                final tip = healthTips[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  color:
                      Theme.of(context).cardTheme.color, // Use theme card color
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                color: AppColors.infoColor, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tip['title']!,
                                style: AppStyles.subTitle.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tip['content']!,
                          style: AppStyles.bodyText1.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
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
