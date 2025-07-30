// lib/models/contact.dart

import 'package:flutter/foundation.dart'; // For @required if not using null safety everywhere

// Represents a contact person for emergency or general communication.
class Contact {
  final String id; // Unique identifier for the contact
  final String name; // Name of the contact person
  final String phoneNumber; // Phone number of the contact
  final String
      relationship; // Relationship to the user (e.g., "Husband", "Sister", "Friend")
  final bool isEmergencyContact; // True if this contact is for emergencies

  // Constructor for the Contact model.
  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isEmergencyContact = false, // Default to false
  });

  // Factory constructor to create a Contact object from a JSON map.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String,
      isEmergencyContact: json['isEmergencyContact'] as bool,
    );
  }

  // Converts the Contact object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'isEmergencyContact': isEmergencyContact,
    };
  }

  // Provides a string representation of the Contact object for debugging.
  @override
  String toString() {
    return 'Contact(id: $id, name: $name, phoneNumber: $phoneNumber, relationship: $relationship, isEmergencyContact: $isEmergencyContact)';
  }
}
