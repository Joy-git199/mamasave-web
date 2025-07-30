# Flutter App Backend

This is the backend for the Flutter application, built with Node.js, Express.js, and Firebase Admin SDK.

## Prerequisites
- Node.js (v14 or higher recommended)
- Firebase project with service account credentials

## Setup

1. **Clone this repository and navigate to the backend folder:**
   ```sh
   cd backend
   ```

2. **Install dependencies:**
   ```sh
   npm install
   ```

3. **Add Firebase service account credentials:**
   - Go to Firebase Console > Project Settings > Service Accounts
   - Click "Generate new private key" and download the JSON file
   - Save it as `serviceAccountKey.json` in the `backend` folder (replace the placeholder file)

4. **Configure environment variables:**
   - Edit the `.env` file if you want to change the default port (default is 5000)

5. **Run the server:**
   ```sh
   npm start
   ```

6. **Test the server:**
   - Open your browser or use curl/Postman to visit `http://localhost:5000/`
   - You should see: `Backend server is running!`

## Project Structure
- `index.js` - Main server file
- `serviceAccountKey.json` - Firebase credentials (DO NOT commit this file)
- `.env` - Environment variables

## Next Steps
- Implement authentication endpoints
- Add Firestore data handling routes
- Add user settings and document upload endpoints 