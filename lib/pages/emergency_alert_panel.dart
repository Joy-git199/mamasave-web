import 'package:flutter/material.dart';

class EmergencyAlertsPage extends StatelessWidget {
  const EmergencyAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> alerts = [
      {
        "name": "Sarah N.",
        "time": "2025-07-23 12:45 PM",
        "issue": "Severe bleeding",
      },
      {
        "name": "Grace K.",
        "time": "2025-07-22 9:00 AM",
        "issue": "High fever",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Alerts")),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Card(
            child: ListTile(
              title: Text("${alert["name"]} - ${alert["issue"]}"),
              subtitle: Text("Reported at: ${alert["time"]}"),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  // TODO: Handle responses
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'call', child: Text('📞 Call Now')),
                  const PopupMenuItem(
                      value: 'responded', child: Text('✅ Mark Responded')),
                  const PopupMenuItem(
                      value: 'refer', child: Text('🏥 Refer to Facility')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
