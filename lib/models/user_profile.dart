// lib/models/user_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class UserProfile {
  final String firebaseUid;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final String appTheme;
  final String? phone; // Optional
  final int? age; // Optional
  final String? location; // Optional
  final String? pregnancyStatus; // Optional for mothers
  final String? assignedCHW; // Optional for mothers
  final String? assignedMidwife; // Optional for mothers

  UserProfile({
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.appTheme = 'default',
    this.phone,
    this.age,
    this.location,
    this.pregnancyStatus,
    this.assignedCHW,
    this.assignedMidwife,
  });

  // Factory constructor to create a UserProfile from a Firestore document snapshot
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      firebaseUid: doc.id, // UID is the document ID
      email: data['email'] as String,
      name: data['name'] as String,
      role: data['role'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      appTheme: data['appTheme'] as String? ?? 'default',
      phone: data['phone'] as String?,
      age: (data['age'] as num?)?.toInt(),
      location: data['location'] as String?,
      pregnancyStatus: data['pregnancyStatus'] as String?,
      assignedCHW: data['assignedCHW'] as String?,
      assignedMidwife: data['assignedMidwife'] as String?,
    );
  }

  // Factory constructor to create a UserProfile from a Map (e.g., from backend API response)
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    // Handle timestamp if it comes as ISO string from backend
    DateTime parsedCreatedAt;
    if (data['createdAt'] is Timestamp) {
      parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedCreatedAt = DateTime.parse(data['createdAt']);
    } else {
      parsedCreatedAt = DateTime.now(); // Fallback
    }

    return UserProfile(
      firebaseUid: data['firebaseUid'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      role: data['role'] as String,
      createdAt: parsedCreatedAt,
      appTheme: data['appTheme'] as String? ?? 'default',
      phone: data['phone'] as String?,
      age: (data['age'] as num?)?.toInt(),
      location: data['location'] as String?,
      pregnancyStatus: data['pregnancyStatus'] as String?,
      assignedCHW: data['assignedCHW'] as String?,
      // Removed 'isEmergencyContact' as it does not belong to UserProfile
      assignedMidwife: data['assignedMidwife'] as String?,
    );
  }

  // Convert UserProfile object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firebaseUid': firebaseUid,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'appTheme': appTheme,
      'phone': phone,
      'age': age,
      'location': location,
      'pregnancyStatus': pregnancyStatus,
      'assignedCHW': assignedCHW,
      'assignedMidwife': assignedMidwife,
    };
  }
}
