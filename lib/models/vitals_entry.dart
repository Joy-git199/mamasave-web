// lib/models/vitals_entry.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp

// Represents a single entry of vital signs, combining manual and sensor data.
class VitalsEntry {
  final String id; // Unique identifier for the vitals entry
  final String motherId; // ID of the mother these vitals belong to
  final DateTime timestamp; // Date and time when the vitals were recorded
  final double? spo2; // Oxygen saturation (SpO2) percentage
  final double? temperature; // Body temperature in Celsius
  final double? heartRate; // Heart rate in beats per minute (BPM) - now double?
  final String? bloodPressure; // Blood pressure reading (e.g., "120/80 mmHg") - from manual entry
  final double? pressureKPa; // NEW: Pressure sensor reading in kPa
  final double? pressureVoltage; // NEW: Pressure sensor reading in Volts

  // Constructor for the VitalsEntry model.
  VitalsEntry({
    required this.id,
    required this.motherId,
    required this.timestamp,
    this.spo2,
    this.temperature,
    this.heartRate,
    this.bloodPressure,
    this.pressureKPa, // Include new fields in constructor
    this.pressureVoltage, // Include new fields in constructor
  });

  // Factory constructor to create a VitalsEntry object from a Map (e.g., from Firestore or backend JSON).
  // This handles data coming from either the 'sensorReadings' (historical) or 'healthVisits' (manual) collections.
  factory VitalsEntry.fromMap(Map<String, dynamic> data, String id) {
    // Handle timestamp conversion from Firestore Timestamp or ISO string
    DateTime parsedTimestamp;
    if (data['timestamp'] is Timestamp) {
      parsedTimestamp = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is String) {
      parsedTimestamp = DateTime.parse(data['timestamp']);
    } else {
      parsedTimestamp = DateTime.now(); // Fallback
    }

    return VitalsEntry(
      id: id,
      motherId: data['uid'] as String? ?? data['motherId'] as String, // 'uid' for sensor, 'motherId' for health visits
      timestamp: parsedTimestamp,
      spo2: (data['spo2'] as num?)?.toDouble(),
      temperature: (data['temperature'] as num?)?.toDouble(),
      heartRate: (data['heartRate'] as num?)?.toDouble(), // Ensure it's double
      bloodPressure: data['bloodPressure'] as String?, // This is typically from manual entry
      pressureKPa: (data['pressure_kPa'] as num?)?.toDouble(), // Map new field
      pressureVoltage: (data['pressure_voltage'] as num?)?.toDouble(), // Map new field
    );
  }

  // Converts the VitalsEntry object to a Map for Firestore or backend.
  Map<String, dynamic> toMap() {
    return {
      'motherId': motherId,
      'timestamp': Timestamp.fromDate(timestamp), // Convert DateTime to Firestore Timestamp
      'spo2': spo2,
      'temperature': temperature,
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'pressure_kPa': pressureKPa,
      'pressure_voltage': pressureVoltage,
    };
  }

  // Provides a string representation of the VitalsEntry object for debugging.
  @override
  String toString() {
    return 'VitalsEntry(id: $id, motherId: $motherId, timestamp: $timestamp, SpO2: $spo2, Temp: $temperature, HR: $heartRate, Pressure: $pressureKPa kPa, $pressureVoltage V)';
  }
}
