// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/foundation.dart'; // For print statements in debug mode

/// Manages all API calls to the MamaSave backend.
/// Handles base URL, headers (including authentication tokens), and response parsing.
class ApiService {
  // Base URL for your backend API
  // IMPORTANT: Ensure this matches your backend server's address and port.
  // This should NOT end with a slash, as the API methods will add it.
  final String _baseUrl = 'http://192.168.43.238:5000/api'; // Changed to include /api here

  // Private constructor
  ApiService._privateConstructor();

  // Singleton instance
  static final ApiService _instance = ApiService._privateConstructor();

  // Factory constructor to return the singleton instance
  factory ApiService() {
    return _instance;
  }

  /// Helper to get authenticated headers, including Firebase ID token.
  Future<Map<String, String>> _getHeaders() async {
    String? idToken = await _getIdToken();
    return {
      'Content-Type': 'application/json',
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };
  }

  /// Fetches the current user's Firebase ID token.
  Future<String?> _getIdToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting Firebase ID token: $e');
      }
    }
    return null;
  }

  /// Internal method to construct the full URI safely.
  Uri _buildUri(String endpoint) {
    // Remove any leading/trailing slashes from the endpoint
    final cleanedEndpoint = endpoint.replaceAll(RegExp(r'^/|/$'), '');
    // Construct the URI, ensuring exactly one slash between base URL and endpoint
    return Uri.parse('$_baseUrl/$cleanedEndpoint');
  }

  /// Handles HTTP GET requests.
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = _buildUri(endpoint); 
      if (kDebugMode) {
        print('GET Request to: $uri');
      }
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response, endpoint);
    } catch (e) {
      if (kDebugMode) {
        print('API GET Error on $endpoint: $e');
      }
      return {'success': false, 'error': 'Network error or invalid response: $e'};
    }
  }

  /// Handles HTTP POST requests.
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final uri = _buildUri(endpoint);
      if (kDebugMode) {
        print('POST Request to: $uri with body: ${json.encode(data)}');
      }
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response, endpoint);
    } catch (e) {
      if (kDebugMode) {
        print('API POST Error on $endpoint: $e');
      }
      return {'success': false, 'error': 'Network error or invalid response: $e'};
    }
  }

  /// Handles HTTP PUT requests.
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final uri = _buildUri(endpoint);
      if (kDebugMode) {
        print('PUT Request to: $uri with body: ${json.encode(data)}');
      }
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response, endpoint);
    } catch (e) {
      if (kDebugMode) {
        print('API PUT Error on $endpoint: $e');
      }
      return {'success': false, 'error': 'Network error or invalid response: $e'};
    }
  }

  /// Handles HTTP DELETE requests.
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = _buildUri(endpoint);
      if (kDebugMode) {
        print('DELETE Request to: $uri');
      }
      final response = await http.delete(
        uri,
        headers: headers,
      );
      return _handleResponse(response, endpoint);
    } catch (e) {
      if (kDebugMode) {
        print('API DELETE Error on $endpoint: $e');
      }
      return {'success': false, 'error': 'Network error or invalid response: $e'};
    }
  }

  /// Internal method to parse HTTP responses.
  Map<String, dynamic> _handleResponse(http.Response response, String endpoint) {
    if (kDebugMode) {
      print('Response for $endpoint (Status: ${response.statusCode}): ${response.body}');
    }

    try {
      // Check if the response body is empty or not valid JSON
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Sometimes success responses have no body (e.g., 204 No Content)
          return {'success': true, 'data': {}};
        } else {
          return {'success': false, 'error': 'API Error ${response.statusCode}: Empty response body.'};
        }
      }

      final dynamic decodedResponse = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decodedResponse};
      } else {
        // Handle API-specific error messages if your backend sends them
        final String errorMessage = decodedResponse['error'] ?? decodedResponse['message'] ?? 'Unknown error';
        return {'success': false, 'error': 'API Error ${response.statusCode}: $errorMessage'};
      }
    } on FormatException catch (e) {
      return {'success': false, 'error': 'Invalid JSON response from backend: $e. Response body: ${response.body}'};
    } catch (e) {
      return {'success': false, 'error': 'Error processing response: $e'};
    }
  }
}
