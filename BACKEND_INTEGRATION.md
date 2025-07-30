# Backend Integration Guide

This document explains how the Flutter frontend integrates with the Node.js/Express backend.

## Backend Setup

1. **Start the backend server:**
   ```bash
   cd backend
   npm install
   npm start
   ```
   The server will run on `http://localhost:5000`

2. **Ensure Firebase credentials are set up:**
   - Replace `backend/serviceAccountKey.json` with your Firebase service account credentials
   - Make sure your Flutter app has the correct Firebase configuration files

## Frontend Integration

### Services

1. **AuthService** (`lib/services/auth_service.dart`):
   - Handles Firebase Authentication
   - Integrates with backend `/signup` and `/login` endpoints
   - Manages user state with `ChangeNotifier`

2. **ApiService** (`lib/services/api_service.dart`):
   - Handles all backend API calls
   - Manages authentication tokens
   - Includes methods for profile, settings, and sensor data

### Demo Page

The `BackendDemoPage` (`lib/pages/backend_demo_page.dart`) demonstrates:

1. **Authentication:**
   - Sign up with email/password
   - Sign in with email/password
   - Sign out functionality

2. **Profile Management:**
   - Fetch user profile from backend
   - Display user information

3. **Sensor Data:**
   - Send sample sensor readings to backend
   - Fetch sensor data from backend
   - Display sensor readings

### How to Access the Demo

1. Run your Flutter app
2. Navigate to the login page
3. Click the "Backend Demo" button
4. Test the authentication and API functionality

## API Endpoints Used

### Authentication
- `POST /signup` - Create new user
- `POST /login` - Verify user token

### User Profile
- `GET /profile` - Get user profile
- `PUT /profile` - Update user profile

### Settings
- `GET /settings` - Get user settings
- `PUT /settings` - Update user settings

### Sensor Data
- `POST /sensor-data` - Send sensor readings
- `GET /sensor-data` - Get sensor readings

## Testing the Integration

1. **Sign Up:**
   - Enter email and password
   - Click "Sign Up"
   - User is created in Firebase and backend

2. **Sign In:**
   - Enter email and password
   - Click "Sign In"
   - Token is verified with backend

3. **Fetch Profile:**
   - Click "Fetch Profile"
   - User profile data is retrieved from backend

4. **Send Sensor Data:**
   - Click "Send Sensor Data"
   - Sample sensor readings are sent to backend

5. **Fetch Sensor Data:**
   - Click "Fetch Sensor Data"
   - Sensor readings are retrieved from backend

## Error Handling

The integration includes comprehensive error handling:
- Network errors
- Authentication failures
- Invalid data responses
- User-friendly error messages

## Next Steps

1. Integrate the backend services into your existing app pages
2. Add more API endpoints as needed
3. Implement real sensor data collection
4. Add data visualization for sensor readings
5. Implement real-time updates using WebSockets or Firebase Realtime Database

## Troubleshooting

1. **Backend not running:**
   - Ensure the backend server is started on port 5000
   - Check that all dependencies are installed

2. **Firebase errors:**
   - Verify Firebase configuration files are correct
   - Check that service account credentials are valid

3. **Network errors:**
   - Ensure the backend URL is correct in the services
   - Check that the device can reach localhost:5000

4. **Authentication errors:**
   - Verify that Firebase Authentication is enabled
   - Check that the backend can access Firebase Admin SDK 