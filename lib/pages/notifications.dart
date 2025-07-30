// notifications_page.dart
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {"from": "Midwife", "message": "Please check on Jane today."},
    {"from": "MamaSave", "message": "Reminder: Follow-up visit due in 2 days."},
    {"from": "Clinic", "message": "Immunization day moved to Friday."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final note = notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(note["from"] ?? ""),
            subtitle: Text(note["message"] ?? ""),
          );
        },
      ),
    );
  }
}
