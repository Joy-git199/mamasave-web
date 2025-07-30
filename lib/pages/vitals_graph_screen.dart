// lib/pages/vitals_graph_screen.dart

import 'package:flutter/material.dart';

// This is a placeholder for the VitalsGraphScreen.
// Graph functionality has been removed as per user request.
class VitalsGraphScreen extends StatelessWidget {
  final String motherId;

  const VitalsGraphScreen({super.key, required this.motherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitals Trends (Disabled)'),
      ),
      body: Center(
        child: Text('Vitals graph functionality is currently disabled.'),
      ),
    );
  }
}
