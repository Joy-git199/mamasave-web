import 'package:flutter/material.dart';

class ReportEmergencyPage extends StatefulWidget {
  const ReportEmergencyPage({super.key});

  @override
  State<ReportEmergencyPage> createState() => _ReportEmergencyPageState();
}

class _ReportEmergencyPageState extends State<ReportEmergencyPage> {
  final List<String> mothers = ["Jane Doe", "Sarah N", "Mary K"];
  String? selectedMother;
  String? selectedEmergency;

  final emergencies = [
    "Severe bleeding",
    "Severe headache",
    "Convulsions",
    "High fever",
    "Unconscious"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Emergency")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Mother"),
              items: mothers
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) => setState(() => selectedMother = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Type of Emergency"),
              items: emergencies
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedEmergency = val),
            ),
            const SizedBox(height: 12),
            const Text("Attach Photo (optional)"),
            Container(
              height: 100,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              color: Colors.grey[300],
              child: const Center(child: Text("Image placeholder")),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text("Submit Emergency Alert"),
              onPressed: () {
                // Submit logic
              },
            )
          ],
        ),
      ),
    );
  }
}
