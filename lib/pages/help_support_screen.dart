// lib/pages/help_support_screen.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/widgets/custom_snackbar.dart';

// The HelpSupportScreen provides information on how to get help and support.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need Assistance?',
              style: AppStyles.headline2
                  .copyWith(color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re here to help you with any questions or issues you might have regarding the MamaSave app.',
              style: AppStyles.bodyText1.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Frequently Asked Questions (FAQs)',
                Icons.help_outline, context),
            const SizedBox(height: 16),
            Container(
              decoration: AppStyles.cardDecoration(context),
              child: Column(
                children: [
                  _buildFaqTile(
                    context,
                    'How do I track my pregnancy progress?',
                    'You can track your pregnancy progress by navigating to the "Pregnancy Progress" section from your Mother Dashboard. Here you can see weekly milestones and what to expect.',
                  ),
                  _buildFaqTile(
                    context,
                    'How do I contact my CHW or Midwife?',
                    'You can find the contact details of your assigned Community Health Worker (CHW) and Midwife in your Mother Profile under "Personal Information".',
                  ),
                  _buildFaqTile(
                    context,
                    'What should I do in an emergency?',
                    'In case of an emergency, use the "Panic Button" on your Mother Dashboard. This will alert your emergency contacts and relevant health personnel.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Contact Support', Icons.support_agent, context),
            const SizedBox(height: 16),
            Container(
              decoration: AppStyles.cardDecoration(context),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.email_outlined,
                        color: Theme.of(context).listTileTheme.iconColor),
                    title: Text('Email Support',
                        style: AppStyles.bodyText1.copyWith(
                            color: Theme.of(context).listTileTheme.textColor ??
                                Theme.of(context).textTheme.bodyLarge?.color)),
                    subtitle: Text(
                      'support@mamasave.org',
                      style: AppStyles.bodyText2.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 18,
                        color: Theme.of(context)
                            .listTileTheme
                            .iconColor
                            ?.withOpacity(0.7)),
                    onTap: () {
                      CustomSnackBar.showInfo(
                          context, 'Opening email client (simulated).');
                      // TODO: Implement actual email launch
                    },
                  ),
                  Divider(
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: Icon(Icons.phone_outlined,
                        color: Theme.of(context).listTileTheme.iconColor),
                    title: Text('Call Hotline',
                        style: AppStyles.bodyText1.copyWith(
                            color: Theme.of(context).listTileTheme.textColor ??
                                Theme.of(context).textTheme.bodyLarge?.color)),
                    subtitle: Text(
                      '+256 700 123 456',
                      style: AppStyles.bodyText2.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 18,
                        color: Theme.of(context)
                            .listTileTheme
                            .iconColor
                            ?.withOpacity(0.7)),
                    onTap: () {
                      CustomSnackBar.showInfo(
                          context, 'Calling hotline (simulated).');
                      // TODO: Implement actual phone call
                    },
                  ),
                  Divider(
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: Icon(Icons.chat_bubble_outline,
                        color: Theme.of(context).listTileTheme.iconColor),
                    title: Text('Live Chat',
                        style: AppStyles.bodyText1.copyWith(
                            color: Theme.of(context).listTileTheme.textColor ??
                                Theme.of(context).textTheme.bodyLarge?.color)),
                    subtitle: Text(
                      'Chat with a support agent during working hours.',
                      style: AppStyles.bodyText2.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 18,
                        color: Theme.of(context)
                            .listTileTheme
                            .iconColor
                            ?.withOpacity(0.7)),
                    onTap: () {
                      CustomSnackBar.showInfo(
                          context, 'Live chat functionality coming soon!');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'For urgent matters, please use the Panic Button on your dashboard.',
                style: AppStyles.bodyText2.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                textAlign: TextAlign.center,
              ),
            ),
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
        Expanded(
          // Added Expanded to ensure text wraps
          child: Text(
            title,
            style: AppStyles.headline3.copyWith(
                color: Theme.of(context).textTheme.displaySmall?.color),
            softWrap: true, // Ensure text wraps
          ),
        ),
      ],
    );
  }

  // Helper for building FAQ expansion tiles.
  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    return ExpansionTile(
      leading: Icon(Icons.info_outline,
          color: Theme.of(context).listTileTheme.iconColor),
      title: Text(question,
          style: AppStyles.bodyText1.copyWith(
              color: Theme.of(context).listTileTheme.textColor ??
                  Theme.of(context).textTheme.bodyLarge?.color)),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            answer,
            style: AppStyles.bodyText2
                .copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      ],
      iconColor: Theme.of(context).listTileTheme.iconColor,
      collapsedIconColor: Theme.of(context).listTileTheme.iconColor,
    );
  }
}
