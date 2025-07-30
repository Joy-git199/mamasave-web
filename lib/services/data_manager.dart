// lib/services/data_manager.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore Timestamp in VitalsEntry
import 'package:mamasave/models/user_profile.dart'; // Ensure this model exists
import 'package:mamasave/models/vitals_entry.dart';
import 'package:mamasave/models/health_visit.dart'; // Ensure this model exists
import 'package:mamasave/models/contact.dart'; // Ensure this model exists
import 'package:mamasave/models/personal_note.dart'; // Ensure this model exists
import 'package:uuid/uuid.dart'; // For generating unique IDs for mock data
import 'package:mamasave/services/api_service.dart'; // Your existing ApiService dependency

import 'package:http/http.dart' as http; // For HTTP
import 'dart:convert'; // For JSON

class DataManager with ChangeNotifier {
  final ApiService _apiService; // Your existing ApiService dependency

  // In-memory data stores (will be populated by _initializeMockData or fetched)
  final List<UserProfile> _users = []; // Changed to List<UserProfile>
  final List<VitalsEntry> _vitalsEntries = []; // This will now hold fetched historical data
  final List<HealthVisit> _healthVisits = [];
  final List<Contact> _emergencyContacts = [];
  final List<PersonalNote> _personalNotes = [];


  DataManager(this._apiService) {
    _initializeMockData();
  }

  // ========================================================================
  // User Management (Updated to use UserProfile objects)
  // ========================================================================

  List<UserProfile> get users => List.unmodifiable(_users);

  // Now returns UserProfile?
  UserProfile? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.firebaseUid == id);
    } catch (e) {
      return null; // User not found
    }
  }

  String getMotherNameById(String motherId) {
    return getUserById(motherId)?.name ?? 'Unknown Mother';
  }

  String getMotherPregnancyStatus(String motherId) {
    return getUserById(motherId)?.pregnancyStatus ?? 'Status not set';
  }

  // Re-added: Returns a list of all mother UIDs
  List<String> getAllMotherIds() {
    return _users.where((user) => user.role == 'mother').map((user) => user.firebaseUid).toList();
  }

  // Re-added: Returns a list of all mother UserProfile objects
  List<UserProfile> getAllMothers() {
    return _users.where((user) => user.role == 'mother').toList();
  }

  // Re-added: Fetches user profile from the backend (using ApiService)
  Future<UserProfile?> fetchUserProfile(String userId) async {
    final response = await _apiService.get('/users/$userId'); // Corrected endpoint to /users/:firebaseUid
    if (response['success'] == true && response['data'] != null) {
      return UserProfile.fromMap(response['data'] as Map<String, dynamic>);
    }
    print('Error fetching user profile from API: ${response['error']}');
    return null;
  }

  // ========================================================================
  // Vitals Entry Management (Updated for Historical Fetch)
  // ========================================================================

  List<VitalsEntry> getVitalsEntriesForMother(String motherId) {
    return _vitalsEntries.where((entry) => entry.motherId == motherId).toList();
  }

  Future<void> fetchHistoricalSensorData(String motherId) async {
    final String backendHost = '192.168.1.133'; // Your PC's IP address
    final int backendPort = 5000;
    // This endpoint fetches ALL historical readings for a UID from 'sensor_readings_history'
    final String url = 'http://$backendHost:$backendPort/api/data/sensor/$motherId?limit=100';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        final List<VitalsEntry> historicalVitals = [];
        for (var rawReading in jsonList) {
          final String entryId = 'hist_${rawReading['timestamp']}_$motherId';
          historicalVitals.add(VitalsEntry.fromMap(rawReading, entryId));
        }

        _vitalsEntries.clear();
        _vitalsEntries.addAll(historicalVitals);
        
        notifyListeners();
        print('Successfully fetched and updated historical sensor data for $motherId.');

      } else {
        throw Exception('Failed to load historical data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching historical sensor data in DataManager: $e');
      rethrow;
    }
  }

  // Changed return type to Future<void>
  Future<void> addVitalsEntry(VitalsEntry entry) async {
    _vitalsEntries.add(entry);
    notifyListeners();
    // In a real app, you'd also send this to Firestore if it's a new entry
  }

  // ========================================================================
  // Health Visit Management (Existing)
  // ========================================================================

  List<HealthVisit> getAllHealthVisits() {
    return _healthVisits;
  }

  List<HealthVisit> getHealthVisitsForMother(String motherId) {
    return _healthVisits.where((visit) => visit.motherId == motherId).toList();
  }

  // Changed return type to Future<void>
  Future<void> addHealthVisit(HealthVisit visit) async {
    _healthVisits.add(visit);
    notifyListeners();
    // In a real app, you'd send this to Firestore
  }

  List<HealthVisit> getRecentEmergencyReports() {
    return _healthVisits.where((visit) => visit.dangerSigns.isNotEmpty).toList()
      ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
  }

  List<HealthVisit> getUpcomingVisits() {
    final now = DateTime.now();
    return _healthVisits
        .where((visit) =>
            visit.visitDate.isAfter(now) &&
            visit.visitDate.isBefore(now.add(const Duration(days: 7))))
        .toList()
      ..sort((a, b) => a.visitDate.compareTo(b.visitDate));
  }

  // ========================================================================
  // Emergency Contact Management (Existing)
  // ========================================================================

  List<Contact> getEmergencyContactsForMother(String motherId) {
    return _emergencyContacts.where((c) => c.isEmergencyContact).toList();
  }

  Future<void> addEmergencyContact(String motherId, Contact contact) async {
    if (contact.isEmergencyContact) {
      _emergencyContacts.add(contact);
      notifyListeners();
    }
  }

  Future<void> removeEmergencyContact(String motherId, String contactId) async {
    _emergencyContacts.removeWhere((contact) => contact.id == contactId);
    notifyListeners();
  }

  // ========================================================================
  // Personal Notes Management (Existing)
  // ========================================================================

  List<PersonalNote> getPersonalNotesForMother(String motherId) {
    return _personalNotes.where((note) => note.userId == motherId).toList();
  }

  Future<void> addPersonalNote(String motherId, PersonalNote note) async {
    _personalNotes.add(note);
    notifyListeners();
  }

  Future<void> removePersonalNote(String motherId, String noteId) async {
    _personalNotes.removeWhere((note) => note.id == noteId);
    notifyListeners();
  }

  // ========================================================================
  // Midwife Specific Stats (Existing)
  // ========================================================================

  Map<String, int> getMidwifeSummaryStats() {
    final totalMothers =
        _users.where((user) => user.role == 'mother').length;
    final pregnantMothers = _users
        .where((user) =>
            user.role == 'mother' &&
            user.pregnancyStatus != null &&
            user.pregnancyStatus!.startsWith('Week'))
        .length;
    final postnatalMothers = totalMothers - pregnantMothers;
    final emergencies =
        _healthVisits.where((visit) => visit.dangerSigns.isNotEmpty).length;

    return {
      'totalMothers': totalMothers,
      'pregnantMothers': pregnantMothers,
      'postnatalMothers': postnatalMothers,
      'emergencies': emergencies,
    };
  }

  // ========================================================================
  // Backend Demo Page Specific Methods (Re-added)
  // ========================================================================

  // Re-added: Sends sensor data to the backend (used by backend_demo_page.dart)
  Future<bool> sendSensorData(Map<String, dynamic> data) async {
    final response = await _apiService.post('/data/sensor/${data['uid']}', data); // Adjust endpoint
    if (response['success'] == true) {
      print('Sensor data sent successfully!');
      return true;
    }
    print('Error sending sensor data: ${response['error']}');
    return false;
  }

  // Re-added: Fetches sensor data from the backend for a user (used by backend_demo_page.dart)
  Future<List<Map<String, dynamic>>?> fetchSensorData(String userId) async {
    final response = await _apiService.get('/data/sensor/$userId'); // Adjust endpoint
    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List).cast<Map<String, dynamic>>();
    }
    print('Error fetching sensor data from API: ${response['error']}');
    return null;
  }

  // NEW: Method to trigger a temperature alert on the backend
  Future<void> triggerTemperatureAlert(String motherUid, double temperature, String sensorId) async {
    final Map<String, dynamic> alertData = {
      'motherUid': motherUid,
      'temperature': temperature,
      'sensorId': sensorId,
      'timestamp': DateTime.now().toIso8601String(), // ISO 8601 string for backend
    };

    try {
      // Send the alert data to a new backend endpoint
      final response = await _apiService.post('/alerts/temperature', alertData);
      if (response['success'] == true) {
        print('Temperature alert successfully sent to backend for mother $motherUid.');
      } else {
        print('Failed to send temperature alert to backend: ${response['error']}');
        throw Exception('Failed to send temperature alert: ${response['error']}');
      }
    } catch (e) {
      print('Error sending temperature alert via ApiService: $e');
      rethrow; // Re-throw to be caught by the UI
    }
  }


  // ========================================================================
  // Mock Data Initialization (Updated to use new UserProfile and VitalsEntry models)
  // ========================================================================

  void _initializeMockData() {
    const Uuid uuid = Uuid(); // Initialize Uuid for generating IDs

    _users.clear();
    _vitalsEntries.clear();
    _healthVisits.clear();
    _emergencyContacts.clear();
    _personalNotes.clear();

    // Mock Users (now as UserProfile objects)
    _users.add(UserProfile(
      firebaseUid: 'mother_001',
      email: 'aisha.nakato@example.com',
      name: 'Aisha Nakato',
      role: 'mother',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      phone: '+256771234567',
      age: 28,
      location: 'Kampala',
      pregnancyStatus: 'Week 25',
      assignedCHW: 'Alice CHW',
      assignedMidwife: 'Dr. Sarah',
    ));
    _users.add(UserProfile(
      firebaseUid: 'chw_mock',
      email: 'alice.chw@example.com',
      name: 'Alice CHW',
      role: 'chw',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ));
    _users.add(UserProfile(
      firebaseUid: 'midwife_mock',
      email: 'dr.sarah@example.com',
      name: 'Dr. Sarah',
      role: 'midwife',
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ));

    // Mock Vitals Entries (will be replaced by fetched data, but keeping for initial structure)
    // These mock vitals will be overwritten by fetchHistoricalSensorData
    _vitalsEntries.add(VitalsEntry(
      id: uuid.v4(),
      motherId: 'mother_001',
      timestamp: DateTime.now().subtract(const Duration(days: 30)),
      spo2: 98.0,
      temperature: 36.8,
      heartRate: 75.0,
      bloodPressure: '110/70',
      pressureKPa: 25.0,
      pressureVoltage: 2.8,
    ));
    _vitalsEntries.add(VitalsEntry(
      id: uuid.v4(),
      motherId: 'mother_001',
      timestamp: DateTime.now().subtract(const Duration(days: 15)),
      spo2: 97.5,
      temperature: 37.1,
      heartRate: 80.0,
      bloodPressure: '115/75',
      pressureKPa: 26.5,
      pressureVoltage: 2.9,
    ));
    _vitalsEntries.add(VitalsEntry(
      id: uuid.v4(),
      motherId: 'mother_001',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      spo2: 99.0,
      temperature: 36.9,
      heartRate: 78.0,
      bloodPressure: '120/80',
      pressureKPa: 28.0,
      pressureVoltage: 3.0,
    ));

    // Mock Health Visits
    _healthVisits.add(HealthVisit(
      id: uuid.v4(),
      motherId: 'mother_001',
      visitDate: DateTime.now().subtract(const Duration(days: 40)),
      visitorRole: 'CHW',
      visitorId: 'chw_mock',
      notes: 'Initial assessment, mother is doing well.',
      vitals: VitalsEntry(
        id: uuid.v4(),
        motherId: 'mother_001',
        timestamp: DateTime.now().subtract(const Duration(days: 40)),
        spo2: 98.0,
        temperature: 36.8,
        heartRate: 75.0,
        bloodPressure: '110/70',
        pressureKPa: null,
        pressureVoltage: null,
      ),
      dangerSigns: [],
      recommendations: 'Continue healthy diet and exercise.',
    ));
    _healthVisits.add(HealthVisit(
      id: uuid.v4(),
      motherId: 'mother_001',
      visitDate: DateTime.now().subtract(const Duration(days: 20)),
      visitorRole: 'Midwife',
      visitorId: 'midwife_mock',
      notes: 'Routine check-up, advised on nutrition.',
      vitals: VitalsEntry(
        id: uuid.v4(),
        motherId: 'mother_001',
        timestamp: DateTime.now().subtract(const Duration(days: 20)),
        spo2: 97.5,
        temperature: 37.1,
        heartRate: 80.0,
        bloodPressure: '115/75',
        pressureKPa: null,
        pressureVoltage: null,
      ),
      dangerSigns: [],
      recommendations: 'Take ginger tea for nausea.',
    ));
    _healthVisits.add(HealthVisit(
      id: uuid.v4(),
      motherId: 'mother_001',
      visitDate: DateTime.now().subtract(const Duration(days: 1)),
      visitorRole: 'Self-Reported',
      visitorId: 'mother_001',
      notes: 'Felt dizzy after standing up quickly.',
      vitals: null,
      dangerSigns: ['Dizziness'],
      recommendations: 'Emergency services alerted.',
    ));

    // Mock Emergency Contacts
    _emergencyContacts.add(Contact(
      id: uuid.v4(),
      name: 'John Doe',
      phoneNumber: '+256781234567',
      relationship: 'Husband',
      isEmergencyContact: true,
    ));
    _emergencyContacts.add(Contact(
      id: uuid.v4(),
      name: 'Jane Smith',
      phoneNumber: '+256755112233',
      relationship: 'Sister',
      isEmergencyContact: true,
    ));

    // Mock Personal Notes
    _personalNotes.add(PersonalNote(
      id: uuid.v4(),
      userId: 'mother_001',
      title: 'Grocery List',
      content: 'Milk, eggs, bread, fruits, vegetables.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ));
    _personalNotes.add(PersonalNote(
      id: uuid.v4(),
      userId: 'mother_001',
      title: 'Questions for Midwife',
      content:
          'Ask about exercise during third trimester. Discuss birth plan options.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ));
  }
}
