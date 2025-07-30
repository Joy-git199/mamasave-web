// lib/models/health_visit.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:mamasave/models/vitals_entry.dart'; // Import VitalsEntry

// Represents a single health visit record.
class HealthVisit {
  final String id; // Unique identifier for the visit
  final String motherId; // ID of the mother who had the visit
  final DateTime visitDate; // Date of the visit
  final String visitorRole; // Role of the person conducting the visit (e.g., 'CHW', 'Midwife', 'Self-Reported')
  final String? visitorId; // ID of the visitor (e.g., CHW's or Midwife's UID)
  final String notes; // General notes about the visit - now non-nullable with default
  final VitalsEntry? vitals; // Optional vitals recorded during this visit
  final List<String> dangerSigns; // List of observed danger signs
  final String? recommendations; // Recommendations given during the visit

  HealthVisit({
    required this.id,
    required this.motherId,
    required this.visitDate,
    required this.visitorRole,
    this.visitorId,
    this.notes = '', // Default empty string, making it non-nullable
    this.vitals,
    this.dangerSigns = const [], // Default empty list
    this.recommendations,
  });

  // Factory constructor to create a HealthVisit object from a Firestore document.
  factory HealthVisit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthVisit(
      id: doc.id,
      motherId: data['motherId'] as String,
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      visitorRole: data['visitorRole'] as String,
      visitorId: data['visitorId'] as String?,
      notes: data['notes'] as String? ?? '', // Handle null from Firestore
      vitals: data['vitals'] != null
          ? VitalsEntry.fromMap(data['vitals'] as Map<String, dynamic>, doc.id) // Use fromMap
          : null,
      dangerSigns: List<String>.from(data['dangerSigns'] ?? []),
      recommendations: data['recommendations'] as String?,
    );
  }

  // Converts the HealthVisit object to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'motherId': motherId,
      'visitDate': Timestamp.fromDate(visitDate),
      'visitorRole': visitorRole,
      'visitorId': visitorId,
      'notes': notes,
      'vitals': vitals?.toMap(), // Use toMap()
      'dangerSigns': dangerSigns,
      'recommendations': recommendations,
    };
  }
}
