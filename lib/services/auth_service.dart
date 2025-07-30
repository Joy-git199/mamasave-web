// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamasave/services/api_service.dart'; // Ensure this import is correct

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ApiService _apiService; // Make sure ApiService is injected

  User? _currentUser;
  String? _currentUserRole;
  String? _currentUserUid;
  String? _currentUserName;

  User? get currentUser => _currentUser;
  String? get currentUserRole => _currentUserRole;
  String? get currentUserUid => _currentUserUid;
  String? get currentUserName => _currentUserName;
  bool get isLoggedIn => _currentUser != null;

  Stream<User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  // FIX: Constructor now takes ApiService
  AuthService() : _apiService = ApiService() { // Initialize ApiService here
    onAuthStateChanged.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      await _syncUserWithBackend(user);
    } else {
      _currentUserRole = null;
      _currentUserUid = null;
      _currentUserName = null;
    }
    notifyListeners();
  }

  Future<void> _syncUserWithBackend(User user) async {
    try {
      // FIX: Corrected endpoint to match backend's /api/users/:firebaseUid
      final response = await _apiService.get('/users/${user.uid}');
      if (response['success'] && response['data'] != null) {
        _currentUserRole = response['data']['role'];
        _currentUserUid = user.uid;
        _currentUserName = response['data']['name'];
      } else {
        // Fallback or handle cases where backend profile might be missing (e.g., new Firebase user)
        if (kDebugMode) {
          print('Backend profile sync failed for ${user.uid}: ${response['error']}');
        }
        _currentUserRole = 'mother'; // Default role if profile not found
        _currentUserUid = user.uid;
        _currentUserName = user.displayName ?? user.email?.split('@').first ?? 'User';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing user with backend: $e');
      }
      _currentUserRole = 'mother'; // Default role on error
      _currentUserUid = user.uid;
      _currentUserName = user.displayName ?? user.email?.split('@').first ?? 'User';
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> signUp(String name, String email, String password, String role) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Firebase Auth user created. Now sync with backend.
        await user.updateDisplayName(name); // Update display name in Firebase Auth
        
        // FIX: Corrected endpoint to match backend's /api/users/signup
        final backendResponse = await _apiService.post('/users/signup', {
          'firebaseUid': user.uid,
          'email': email,
          'name': name,
          'role': role,
        });

        if (backendResponse['success']) {
          await _syncUserWithBackend(user); // Sync after successful backend registration
          return {'success': true};
        } else {
          // If backend registration fails, delete the Firebase user to prevent inconsistencies
          await user.delete();
          return {'success': false, 'error': backendResponse['error'] ?? 'Backend registration failed.'};
        }
      }
      return {'success': false, 'error': 'User creation failed in Firebase.'};
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error during signup: ${e.code} - ${e.message}');
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during signup: $e');
      }
      return {'success': false, 'error': 'An unexpected error occurred.'};
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // After Firebase client-side sign-in, verify with backend to get profile/role
        // FIX: Corrected endpoint for backend signin verification
        final backendResponse = await _apiService.post('/users/signin', {}); // Body can be empty as token is in header

        if (backendResponse['success']) {
          await _syncUserWithBackend(user); // Re-sync after successful backend verification
          return true;
        } else {
          if (kDebugMode) {
            print('Backend sign-in verification failed: ${backendResponse['error']}');
          }
          await _firebaseAuth.signOut(); // Sign out from Firebase if backend verification fails
          return false;
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error during signin: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during signin: $e');
      }
      return false;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // No need to clear _currentUser, _currentUserRole etc. here,
    // as _onAuthStateChanged listener handles it automatically when user becomes null.
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        return {'success': true, 'message': 'Password updated successfully!'};
      } else {
        return {'success': false, 'message': 'No user logged in.'};
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error during password change: ${e.code} - ${e.message}');
      }
      return {'success': false, 'message': e.message ?? 'Failed to update password.'};
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during password change: $e');
      }
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        if (updates.containsKey('name')) {
          await user.updateDisplayName(updates['name']);
        }
        // FIX: Corrected endpoint to match backend's /api/users/:firebaseUid for update
        final response = await _apiService.put('/users/$userId', updates);
        if (response['success']) {
          await _syncUserWithBackend(user); // Re-sync after successful backend update
          return {'success': true, 'message': 'Profile updated successfully!'};
        } else {
          return {'success': false, 'message': response['error'] ?? 'Failed to update profile on backend.'};
        }
      } else {
        return {'success': false, 'message': 'No user logged in.'};
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error updating profile: ${e.code} - ${e.message}');
      }
      return {'success': false, 'message': e.message ?? 'Firebase error updating profile.'};
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred updating profile: $e');
      }
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }
}