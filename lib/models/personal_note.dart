// lib/models/personal_note.dart

import 'package:flutter/foundation.dart'; // For @required if not using null safety everywhere

// Represents a personal note created by a user within the app.
class PersonalNote {
  final String id; // Unique identifier for the note
  final String userId; // ID of the user who created the note
  final String title; // Title of the note
  final String content; // Content of the note
  final DateTime createdAt; // Timestamp when the note was created
  final DateTime?
      updatedAt; // Optional: Timestamp when the note was last updated

  // Constructor for the PersonalNote model.
  PersonalNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a PersonalNote object from a JSON map.
  factory PersonalNote.fromJson(Map<String, dynamic> json) {
    return PersonalNote(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt:
          DateTime.parse(json['createdAt'] as String), // Parse date string
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Converts the PersonalNote object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt':
          createdAt.toIso8601String(), // Convert DateTime to ISO 8601 string
      'updatedAt': updatedAt
          ?.toIso8601String(), // Convert DateTime to ISO 8601 string if not null
    };
  }

  // Provides a string representation of the PersonalNote object for debugging.
  @override
  String toString() {
    return 'PersonalNote(id: $id, title: $title, userId: $userId, createdAt: $createdAt)';
  }
}
